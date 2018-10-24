#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Digest::MD5;
use Posda::BackgroundProcess;

my $usage = <<EOF;
CopyCollectionToStaging.pl <bkgrnd_id> <collection> <dir> <notify>
or
CopyCollectionToStaging.pl -h

The script doesn't expect lines on STDIN:

EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 3){
  die "$usage\n";
}

my ($invoc_id, $collection, $to_dir, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
unless(-d $to_dir) {
  print "$to_dir is not a directory\n";
  exit;
}
my %Hierarchy;
my $get_series = Query("DistinctPatientStudySeriesByCollection");
$get_series->RunQuery(sub {
  my($row) = @_;
  my($patient, $study, $series, $sop_text, $modality, $num_files) = @$row;
  $Hierarchy{$patient}->{$study}->{$series} = {
    sop_desc => $sop_text,
    modality => $modality,
    num_files => $num_files,
  };
}, sub {}, $collection);
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
$background->WriteToEmail("Starting CopyCollectionToStaging.pl at $start_time\n");
print STDERR "Starting CopyCollectionToStaging.pl at $start_time\n";
close STDOUT;
close STDIN;
my $files_in_series = Query("FilesInSeriesForSend");

my $dest_dir = "$to_dir";
my $start_loop = time;
for my $pat (keys %Hierarchy){
  $dest_dir = "$to_dir/$pat";
  for my $study(keys %{$Hierarchy{$pat}}){
    $dest_dir = "$to_dir/$pat/$study";
    for my $series(keys %{$Hierarchy{$pat}->{$study}}){
      $dest_dir = "$to_dir/$pat/$study/$series";
      $files_in_series->RunQuery(sub {
        my($row) = @_;
        my($file_id, $path, $xfer_stx, $sop_class_uid, 
          $data_set_size, $data_set_start, $sop_instance_uid, $dig) = @$row;
        my $dest_file = "$dest_dir/$sop_instance_uid.dcm";
        my $cmd = "cp \"$path\" \"$dest_file\"";
        `$cmd`;
      }, sub {}, $series);
    }
  }
}

my $loop_elapsed = time - $start_loop;

$background->WriteToEmail("Loop finished after " .
   "$loop_elapsed seconds\n");
$background->Finish;
