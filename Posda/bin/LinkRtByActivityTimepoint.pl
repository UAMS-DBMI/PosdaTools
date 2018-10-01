#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Debug;
my $dbg = sub { print @_ };

my $usage = <<EOF;
Usage:
Posda/bin/LinkRtByActivityTimepoint.pl <?bkgrnd_id?> <activity_id> <notify>
  or
Posda/bin/LinkRtByActivityTimepoint.pl -h

Expects no lines on STDIN:

EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }

unless($#ARGV == 2) { print $usage; exit }

my($invoc_id, $act_id, $notify) = @ARGV;
my $start = time;

####################################################
# Derive Hierarchy from Activity Timepoint
#
my $ActTpId;
my $ActTpComment;
my $ActTpDate;
my %FilesInTp;
my %SeriesInTp;
my %StudiesInTp;
my %PatientsInTp;
my %TpHierarchy;
Query('LatestActivityTimepointsForActivity')->RunQuery(sub{
  my($row) = @_;
  my($activity_id, $activity_created,
    $activity_description, $activity_timepoint_id,
    $timepoint_created, $comment, $creating_user) = @$row;
  $ActTpId = $activity_timepoint_id;
  $ActTpComment = $comment;
  $ActTpDate = $timepoint_created;
}, sub {}, $act_id);
Query('FileIdsByActivityTimepointId')->RunQuery(sub {
  my($row) = @_;
  $FilesInTp{$row->[0]} = 1;
}, sub {}, $ActTpId);
my $q = Query('PatientStudySeriesForFile');
for my $file_id(keys %FilesInTp){
  $q->RunQuery(sub {
    my($row) = @_;
    my($patient_id, $study_id, $series_id, $path) = @$row;
    $SeriesInTp{$series_id} = 1;
    $StudiesInTp{$study_id} = 1;
    $PatientsInTp{$patient_id} = 1;
    $TpHierarchy{$patient_id}->{$study_id}->{$series_id}->{$path} = 1;
  }, sub {}, $file_id);
}
my $num_tp_series = keys %SeriesInTp;
my $num_tp_studiea = keys %StudiesInTp;
my $num_tp_patients = keys %StudiesInTp;
print "Found $num_tp_patients patients, " .
  "$num_tp_studiea studies, " .
  "$num_tp_series series\n";

####################################################
my $sub_dir = "Act_$act_id" . "_$ActTpId";
my $base_dir = "/nas/public/posda/cache/NewItcToolsData/submission/dicom/incoming";
unless(-d $base_dir) {
  print "Error: $base_dir is not a directory\n";
  exit;
}
print "Base directory: $base_dir\n";
my $dir = "$base_dir/$sub_dir";
if(-e $dir){
  print "Error: $dir already exists\n";
  exit;
}
unless(mkdir($dir) == 1){
  print "Error ($!): couldn't mkdir $dir\n";
  exit;
}
print "Created directory: $dir\n";
my $errors = 0;
for my $pat (keys %TpHierarchy){
  unless(-d "$dir/$pat"){
    if(mkdir("$dir/$pat") == 1){
      print "Created dir: $dir/$pat\n";
    } else {
      print "Error ($!) : Couldn't create directory: $dir/$pat\n";
      $errors += 1;
    }
  }
  for my $study(keys %{$TpHierarchy{$pat}}){
    unless(-d "$dir/$pat/$study"){
      if(mkdir("$dir/$pat/$study") == 1){
        print "Created dir: $dir/$pat/$study\n";
      } else {
        print "Error ($!) : Couldn't create directory: $dir/$pat/$study\n";
        $errors += 1;
      }
    }
    for my $series(keys %{$TpHierarchy{$pat}->{$study}}){
      unless(-d "$dir/$pat/$study/$series"){
        if(mkdir("$dir/$pat/$study/$series") == 1){
          print "Created dir: $dir/$pat/$study/$series\n";
        } else {
          print "Error ($!) : Couldn't create directory: $dir/$pat/$study/$series\n";
          $errors += 1;
        }
      }
      for my $file (keys %{$TpHierarchy{$pat}->{$study}->{$series}}){
        unless(-f $file){
          print "Error: $file doesn't exist\n";
        }
      }
    }
  }
}
if($errors > 0){
  print "Not linking files due to error\n";
  exit;
}
#############################
# This is code which sets up the Background Process and Starts it
my $forground_time = time - $start;
print "Going to background to create timepoint  after $forground_time seconds\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->Daemonize;
my $start_creation = time;
### Linking Directories Here
my $file_seq = 0;
for my $pat (keys %TpHierarchy){
  for my $study (keys %{$TpHierarchy{$pat}}){
    for my $series (keys %{$TpHierarchy{$pat}->{$study}}){
      for my $file (keys %{$TpHierarchy{$pat}->{$study}->{$series}}){
        my $new_file = "$dir/$pat/$study/$series/$file_seq";
        $file_seq += 1;
        symlink $file, $new_file;
      }
    }
  }  
}
###
my $link_time = time - $start_creation;
my $num_files = keys %FilesInTp;
$background->WriteToEmail("Linked $num_files files in $link_time seconds.\n");
$background->Finish;
