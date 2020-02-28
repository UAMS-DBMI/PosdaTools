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

#############################
# This is code which sets up the Background Process and Starts it
print "Going to background for processing\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
$background->Daemonize;
####################################################
# Get Structure Sets In Latest Timepoint
# and volume
# and files linked to ROIs
#
my %StructureSets;
my %Patients;
my($ActTpId, $ActTpComment, $ActTpDate);
my %VolumeBySs;
my %LinkedSopsBySs;
my %VolumeErrorsBySs;
Query('LatestActivityTimepointsForActivity')->RunQuery(sub{
  my($row) = @_;
  my($activity_id, $activity_created,
    $activity_description, $activity_timepoint_id,
    $timepoint_created, $comment, $creating_user) = @$row;
  $ActTpId = $activity_timepoint_id;
  $ActTpComment = $comment;
  $ActTpDate = $timepoint_created;
  $background->WriteToEmail("LinkRtByActivityTimepoint.pl:\n" .
    "Activity Id: $act_id\n" .
    "Timepoint Id: $ActTpId\n" .
    "Timepoint Date $ActTpDate\n" .
    "Timepoint Comment $ActTpComment\n");
}, sub {}, $act_id);
Query('GetStructureSetsByActivityTimepoint')->RunQuery(sub{
  my($row) = @_;
  my($file_id, $path, $pat_id) = @$row;
  $StructureSets{$file_id}->{path} = $path;
  $StructureSets{$file_id}->{patient} = $pat_id;
  $Patients{$pat_id}->{$path} = 1;
}, sub {}, $ActTpId);
my $get_ss_vol = Query("GetStructureSetVolumeByFileId");
my $get_linked = Query("GetLinkedSopsByStructureSetFileId");
my $get_path_posda = Query("GetVisibleFilePathPosdaBySopInst");
my $get_path_public = Query("GetFilePathPublicBySopInst");
for my $ss_id (keys %StructureSets){
  my $pat_id = $StructureSets{$ss_id}->{patient};
  $get_ss_vol->RunQuery(sub{
    my($row) = @_;
    my($sop_inst) = @$row;
    $VolumeBySs{$ss_id}->{$sop_inst} = 1;
  }, sub {}, $ss_id);
  $get_linked->RunQuery(sub{
    my($row) = @_;
    my($sop_inst) = @$row;
    $LinkedSopsBySs{$ss_id}->{$sop_inst} = 1;
    unless(exists $VolumeBySs{$ss_id}->{$sop_inst}){
      unless(exists $VolumeErrorsBySs{$ss_id}){
        $VolumeErrorsBySs{$ss_id} = 0;
      }
      $VolumeErrorsBySs{$ss_id} += 1;
      $VolumeBySs{$ss_id}->{$sop_inst} = 1;
    }
  }, sub {}, $ss_id);
  my %sops_in_posda;
  my %sops_in_public;
  my %sops_not_found;
  sop:
  for my $sop (keys %{$VolumeBySs{$ss_id}}){
    my $path_in_posda;
    $get_path_posda->RunQuery(sub {
      my($row) = @_;
      my $path = $row->[0];
      $path_in_posda = $path;
    }, sub {}, $sop);
    if(defined $path_in_posda){
      $sops_in_posda{$sop} = 1;
      $Patients{$pat_id}->{$path_in_posda} = 1;
      next sop;
    }
    my $path_in_public;
    $get_path_public->RunQuery(sub {
      my($row) = @_;
      my $path = $row->[0];
      $path_in_public = $path;
      if($path_in_public =~ /(storage.*)$/){
        $path_in_public = "/nas/public/" . $1;
      }
    }, sub {}, $sop);
    if(defined $path_in_public){
      $sops_in_public{$sop} = 1;
      $Patients{$pat_id}->{$path_in_public} = 1;
      next sop;
    }
    $sops_not_found{$sop} = 1;
  }
  my $in_posda = keys %sops_in_posda;
  my $in_public = keys %sops_in_public;
  my $not_found = keys %sops_not_found;
  $background->WriteToEmail("For SS $ss_id:" .
    "  in posda: $in_posda, in public $in_public, " .
   "not found: $not_found\n");
}

####################################################
# Create directory for linking
#
my $sub_dir = "Act_$act_id" . "_$ActTpId";
my $base_dir = "/nas/public/posda/cache/NewItcToolsData/submission/dicom/incoming";
unless(-d $base_dir) {
  $background->WriteToEmail("Error: $base_dir is not a directory\n");
  $background->Finish;
  exit;
}
my $dir = "$base_dir/$sub_dir";
if(-e $dir){
  $background->WriteToEmail("Error: $dir already exists\n");
  $background->Finish;
  exit;
}
unless(mkdir($dir) == 1){
  $background->WriteToEmail("Error ($!): couldn't mkdir $dir\n");
  $background->Finish;
  exit;
}
$background->WriteToEmail("Created directory: $dir\n");
####################################################
### Linking Directories Here
###
pat:
for my $pat (keys %Patients) {
  my $pat_dir = "$dir/$pat";
  unless(-d $pat_dir){
    unless(mkdir($pat_dir) == 1){
      $background->WriteToEmail("Couldn't create directory for pat ($pat)\n");
      next pat;
    }
  }
  my $file_seq = 0;
  for my $f (keys %{$Patients{$pat}}){
    $file_seq += 1;
    my $l_name = "$pat_dir/$file_seq.dcm";
    symlink $f, $l_name;
  }
}

$background->Finish;
