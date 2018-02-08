#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Digest::MD5;
use Posda::BackgroundProcess;
use Posda::DownloadableDir;
use Data::UUID;
our $ug = Data::UUID->new;
sub get_uuid {
  return lc $ug->create_str();
}


my $usage = <<EOF;
BackgroundLinkSeries.pl <bkgrnd_id> <notify>
or
BackgroundLinkSeries.pl -h

The script expects lines in the following format on STDIN:
<patient_id>&<study_instance_uid>&<series_instance_uid>
EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 1){
  print "Wrong number of args\n";
  die "$usage\n";
}

my ($invoc_id, $notify) = @ARGV;

#############################
# Compute the Destination Dir (and die if it already exists)
my $sub_dir = get_uuid();
my $CacheDir = $ENV{POSDA_CACHE_ROOT};
unless(-d $CacheDir){
  print "Error: Cache dir ($CacheDir) isn't a directory\n";
}
my $LinkDir = "$CacheDir/linked_output";
unless(-d $LinkDir){
  unless(mkdir($LinkDir) == 1){
    print "Error: can't mkdir $LinkDir ($!)";
    exit;
  }
}
my $DestDir = "$LinkDir/$sub_dir";
if(-e $DestDir) {
  print "Error: Destination dir ($DestDir) already exists\n";
  exit;
}
unless(mkdir($DestDir) == 1){
  print "Error: can't mkdir $DestDir ($!)";
  exit;
}
#############################

my %Hierarchy;
my $num_pats = 0;
my $num_studies = 0;
my $num_series = 0;
while(my $line = <STDIN>){
  chomp $line;
  my($pat_id, $study_uid, $series_uid) = split(/&/, $line);
  $Hierarchy{$pat_id}->{$study_uid}->{$series_uid} = 1;
}
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
my $get_files = Query("FilesInSeries");
for my $pat (keys %Hierarchy){
  unless(-d "$DestDir/$pat"){
    unless((mkdir "$DestDir/$pat") == 1){
      print "Couldn't mkdir $DestDir/$pat\n";
      exit;
    }
  }
  for my $study (keys %{$Hierarchy{$pat}}){
    unless(-d "$DestDir/$pat/$study"){
      unless((mkdir "$DestDir/$pat/$study") == 1){
        print "Couldn't mkdir $DestDir/$pat\n";
        exit;
      }
    }
    for my $series (keys %{$Hierarchy{$pat}->{$study}}){
      unless(-d "$DestDir/$pat/$study/$series"){
        unless((mkdir "$DestDir/$pat/$study/$series") == 1){
          print "Couldn't mkdir $DestDir/$pat/$series\n";
          exit;
        }
      }
    }
  }
}
print "Made Hierarchy\n";
print "Entering Background\n";

$background->ForkAndExit;

my $start_time = `date`;
chomp $start_time;
$background->WriteToEmail("Starting BackgroundLinkSeriesToStaging.pl at $start_time\n");
print STDERR "Starting BackgroundLinkSeriesToStaging.pl at $start_time\n";
my $files_in_series = Query("FilesInSeriesForApplicationOfPrivateDisposition");

my $dest_dir = "$DestDir";
my $start_loop = time;
my $total_files_linked = 0;
for my $pat (keys %Hierarchy){
  for my $study(keys %{$Hierarchy{$pat}}){
    for my $series(keys %{$Hierarchy{$pat}->{$study}}){
      $dest_dir = "$DestDir/$pat/$study/$series";
      my $files_linked = 0;
      $files_in_series->RunQuery(sub {
        my($row) = @_;
        my($path, $sop_instance_uid, $modality) = @$row;
        my $dest_file = "$dest_dir/$modality" . "_$sop_instance_uid.dcm";
        my $result = symlink($path, $dest_file);
        if($result) { $files_linked += 1; $total_files_linked += 1 }
      }, sub {}, $series);
      #$background->WriteToEmail("$files_linked for series $series\n");
    }
  }
}

my $loop_elapsed = time - $start_loop;

$background->WriteToEmail("Loop finished after " .
   "$loop_elapsed seconds\n");
$background->WriteToEmail("$total_files_linked files linked under directory:" .
   "$DestDir\n");
my $dl_dir = Posda::DownloadableDir->new($DestDir);

$background->WriteToEmail("$dl_dir->{link}\n");
my $caption = "Delete Directory And Dismiss This Message";
my $op = "ScriptButton";
my $param_hash = {
  op => "DeleteAndDismiss",
  dir_id => $dl_dir->{downloadable_dir_id},
  path => $dl_dir->{path},
  hash => $dl_dir->{security_hash},
};
$background->InsertEmailButton($caption, $op, $param_hash);
$background->Finish;
