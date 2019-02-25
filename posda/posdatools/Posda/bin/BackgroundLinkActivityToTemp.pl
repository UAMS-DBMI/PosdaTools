#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Digest::MD5;
use Posda::BackgroundProcess;
use Posda::ActivityInfo;
use Posda::UUID;
our $ug = Data::UUID->new;
sub get_uuid {
  return lc $ug->create_str();
}

my $usage = <<EOF;
BackgroundLinkActivityToTemp.pl <?bkgrnd_id?> <activity_id> <notify>
or
BackgroundLinkActivityToTemp.pl -h

The script expects no lines on STDIN
EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 2){
  print "Wrong number of args\n";
  die "$usage\n";
}

my ($invoc_id, $activity_id, $notify) = @ARGV;
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
print "Entering Background\n";

$background->Daemonize;

#############################
### Compute the Destination Dir (and die if it already exists)
##
my $sub_dir = get_uuid();
my $CacheDir = $ENV{POSDA_CACHE_ROOT};
unless(-d $CacheDir){
  $background->WriteToEmail("Error: Cache dir ($CacheDir) isn't a directory\n");
  $background->Finish;
  exit;
}
my $EditDir = "$CacheDir/private_dispositions";
unless(-d $EditDir){
  unless(mkdir($EditDir) == 1){
    $background->WriteToEmail("Error: can't mkdir $EditDir ($!)");
    $background->Finish;
    exit;
  }
}
my $DestDir = "$EditDir/$sub_dir";
if(-e $DestDir) {
  $background->WriteToEmail("Error: Destination dir ($DestDir) already exists\n");
  $background->Finish;
  exit;
}
unless(mkdir($DestDir) == 1){
  back->WriteToEmail("Error: can't mkdir $DestDir ($!)");
  $background->Finish;
  exit;
}

my %Hierarchy;
my $num_pats = 0;
my $num_studies = 0;
my $num_series = 0;

# todo - Get list of files from activity and
#        make hierarchy
my $act_info = Posda::ActivityInfo->new($activity_id);
my $tp_id = $act_info->LatestTimepoint;
my $FileInfo = $act_info->GetFileInfoForTp($tp_id);
for my $f (keys %{$FileInfo}){
  my $pat_id = $FileInfo->{$f}->{patient_id};
  my $series_uid = $FileInfo->{$f}->{series_instance_uid};
  my $study_uid = $FileInfo->{$f}->{study_instance_uid};
  $Hierarchy{$pat_id}->{$study_uid}->{$series_uid}->{$f} =
    $FileInfo->{$f};
}

# Make directory hierarchy
for my $pat (keys %Hierarchy){
  unless(-d "$DestDir/$pat"){
    unless((mkdir "$DestDir/$pat") == 1){
      $background->WriteToEmail("Couldn't mkdir $DestDir/$pat\n");
      $background->Finish;
      exit;
    }
  }
  for my $study (keys %{$Hierarchy{$pat}}){
    unless(-d "$DestDir/$pat/$study"){
      unless((mkdir "$DestDir/$pat/$study") == 1){
        $background->WriteToEmail("Couldn't mkdir $DestDir/$pat/$study\n");
        $background->Finish;
        exit;
      }
    }
    for my $series (keys %{$Hierarchy{$pat}->{$study}}){
      unless(-d "$DestDir/$pat/$study/$series"){
        unless((mkdir "$DestDir/$pat/$study/$series") == 1){
          $background->WriteToEmail("Couldn't mkdir $DestDir/$pat/$study/$series\n");
          $background->Finish;
          exit;
        }
      }
    }
  }
}
$background->WriteToEmail("Made Directory Hierarchy\n");

my $start_time = `date`;
chomp $start_time;
$background->WriteToEmail("Starting BackgroundLinkActivityToTemp.pl at $start_time\n");
$background->WriteToEmail("Destination directory: $DestDir\n");
$background->WriteToEmail("Activity Id: $activity_id\n");

my $to_dir = "$DestDir";
my $start_loop = time;
my $total_files_linked = 0;
for my $pat (keys %Hierarchy){
  for my $study(keys %{$Hierarchy{$pat}}){
    for my $series(keys %{$Hierarchy{$pat}->{$study}}){
      my $dest_dir = "$to_dir/$pat/$study/$series";
      my $files_linked = 0;
      for my $file (keys %{$Hierarchy{$pat}->{$study}->{$series}}){
        my $f_info = $FileInfo->{$file};
        my $sop_instance_uid = $f_info->{sop_instance_uid};
        my $modality = $f_info->{modality};
        my $path = $f_info->{file_path};
        my $dest_file = "$dest_dir/$modality" . "_$sop_instance_uid.dcm";
        my $result = symlink($path, $dest_file);
        if($result) { $files_linked += 1; $total_files_linked += 1 }
      }
      $background->WriteToEmail("$files_linked for series $series\n");
    }
  }
}

my $loop_elapsed = time - $start_loop;

$background->WriteToEmail("Loop finished after " .
   "$loop_elapsed seconds\n");
$background->WriteToEmail("$total_files_linked files linked under directory:" .
   "$to_dir\n");
$background->Finish;
