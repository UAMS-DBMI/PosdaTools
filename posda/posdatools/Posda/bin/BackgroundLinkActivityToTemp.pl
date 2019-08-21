#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Digest::MD5;
use Posda::BackgroundProcess;
use Posda::ActivityInfo;
use Posda::UUID;
use Posda::NBIASubmit;
use File::Basename;
use File::Path 'make_path';

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
my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
print "Entering Background\n";

$background->Daemonize;

#############################
### Compute the Destination Dir (and die if it already exists)
##


my $BaseDir = $ENV{NBIA_STORAGE_ROOT}
  or die "NBIA_STORAGE_ROOT env var is undefined! cannot continue";

unless(-d $BaseDir){
  print "Error: Base dir ($BaseDir) isn't a directory\n";
}


my %Hierarchy;
my $num_pats = 0;
my $num_studies = 0;
my $num_series = 0;

# todo - Get list of files from activity and
#        make hierarchy
my $act_info = Posda::ActivityInfo->new($activity_id);

my $collection_name = $act_info->GetCollection;
my $site_name = $act_info->GetSite;
my $site_code = $act_info->GetSiteCode;

my $tp_id = $act_info->LatestTimepoint;
my $FileInfo = $act_info->GetFileInfoForTp($tp_id);
for my $f (keys %{$FileInfo}){
  my $pat_id = $FileInfo->{$f}->{patient_id};
  my $series_uid = $FileInfo->{$f}->{series_instance_uid};
  my $study_uid = $FileInfo->{$f}->{study_instance_uid};
  $Hierarchy{$pat_id}->{$study_uid}->{$series_uid}->{$f} =
    $FileInfo->{$f};
}

my $start_time = `date`;
chomp $start_time;
$background->WriteToEmail("Starting BackgroundLinkActivityToTemp.pl at $start_time\n");
$background->WriteToEmail("Activity Id: $activity_id\n");

my $start_loop = time;
my $total_files_linked = 0;
for my $pat (keys %Hierarchy){
  for my $study(keys %{$Hierarchy{$pat}}){
    for my $series(keys %{$Hierarchy{$pat}->{$study}}){
      my $files_linked = 0;
      for my $file (keys %{$Hierarchy{$pat}->{$study}->{$series}}){
        my $f_info = $FileInfo->{$file};
        my $sop_instance_uid = $f_info->{sop_instance_uid};
        my $modality = $f_info->{modality};
        my $path = $f_info->{file_path};

        my $f_filename = Posda::NBIASubmit::GenerateFilename($sop_instance_uid);

				my $full_filename = "$BaseDir/$f_filename";
				my $dirname = dirname($full_filename);
				make_path($dirname);

        my $result = symlink($path, $full_filename);
        if($result) {
          $files_linked += 1;
          $total_files_linked += 1;

          Posda::NBIASubmit::AddToSubmitAndThumbQs(
            $invoc_id,
            $f_info->{file_id},
            $collection_name,
            $site_name,
            $site_code,
            0,  # batch
            $full_filename
          );
        }
      }
      $background->WriteToEmail("$files_linked for series $series\n");
    }
  }
}

my $loop_elapsed = time - $start_loop;

$background->WriteToEmail("Loop finished after " .
   "$loop_elapsed seconds\n");
$background->WriteToEmail("$total_files_linked files linked and sent to public\n");
$background->Finish;
