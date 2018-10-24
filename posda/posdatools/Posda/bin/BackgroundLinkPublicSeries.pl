#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Digest::MD5;
use Posda::BackgroundProcess;

my $usage = <<EOF;
BackgroundLinkSeriesToStaging.pl <bkgrnd_id> <to_dir> <notify>
or
BackgroundLinkSeriesToStaging.pl -h

The script expects lines in the following format on STDIN:
<patient_id>&<study_instance_uid>&<series_instance_uid>
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

my ($invoc_id, $to_dir, $notify) = @ARGV;

unless(-d $to_dir) {
  print "$to_dir is not a directory\n";
  exit;
}
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
for my $pat (keys %Hierarchy){
  unless(-d "$to_dir/$pat"){
    unless((mkdir "$to_dir/$pat") == 1){
      print "Couldn't mkdir $to_dir/$pat\n";
      exit;
    }
  }
  for my $study (keys %{$Hierarchy{$pat}}){
    unless(-d "$to_dir/$pat/$study"){
      unless((mkdir "$to_dir/$pat/$study") == 1){
        print "Couldn't mkdir $to_dir/$pat\n";
        exit;
      }
    }
    for my $series (keys %{$Hierarchy{$pat}->{$study}}){
      unless(-d "$to_dir/$pat/$study/$series"){
        unless((mkdir "$to_dir/$pat/$study/$series") == 1){
          print "Couldn't mkdir $to_dir/$pat/$series\n";
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
my $files_in_series = Query("FilesInSeriesForApplicationOfPrivateDispositionPublic");

my $dest_dir = "$to_dir";
my $start_loop = time;
my $total_files_linked = 0;
for my $pat (keys %Hierarchy){
  for my $study(keys %{$Hierarchy{$pat}}){
    for my $series(keys %{$Hierarchy{$pat}->{$study}}){
      $dest_dir = "$to_dir/$pat/$study/$series";
      my $files_linked = 0;
      $files_in_series->RunQuery(sub {
        my($row) = @_;
        my($path, $sop_instance_uid, $modality) = @$row;
        if($path =~ /(storage.*)$/){
          $path = "/nas/public/" . $1;
        }
        my $dest_file = "$dest_dir/$modality" . "_$sop_instance_uid.dcm";
        my $result = symlink($path, $dest_file);
        if($result) { $files_linked += 1; $total_files_linked += 1 }
      }, sub {}, $series);
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
