#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Digest::MD5;
use Posda::BackgroundProcess;

my $usage = <<EOF;
CheckPublicMissingFilesInSeriesByCollection.pl <bkgrnd_id> <collection> <notify>
or
CheckPublicMissingFilesInSeriesByCollection.pl -h

The script doesn't expect lines on STDIN:

EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 2){
  die "$usage\n";
}

my ($invoc_id, $collection, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

print "Entering Background\n";

$background->ForkAndExit;

my $start_time = `date`;
chomp $start_time;
$background->WriteToEmail("Starting CheckPublicMissingFilesInSeriesByCollection.pl at $start_time\n");
print STDERR "Starting CheckPublicMissingFilesInSeriesByCollection.pl at $start_time\n";
close STDOUT;
close STDIN;
my $get_series = Query("DistinctSeriesByCollectionPublic");
my $files_in_series = Query("PublicFilesInSeries");

my @series;

$get_series->RunQuery(sub {
  my($row) = @_;
  push @series, $row->[0];
}, sub {}, $collection);

my $num_series = @series;
$background->WriteToEmail("$num_series found for collection $collection\n");
my $rpt = $background->CreateReport("FilesInSeriesReport");
$rpt->print("\"series_instance_uid\",\"files_in_series\",\"files_found\"\n");
my $start_loop = time;
for my $ser (@series) {
  my @files;
  my $files_found;
  $files_in_series->RunQuery(sub {
    my($row) = @_;
    my $path = $row->[0];
    if($path =~ /^.*storage(\/.*)$/){
      push @files, "/nas/public/storage$1";
    }
  }, sub {}, $ser);
  my $num_files = @files;
  my $num_found = 0;
  for my $file (@files){
    if(-f $file) { $num_found += 1 }
  }
  $rpt->print("\"$ser\",\"$num_files\",\"$num_found\"\n");
}
my $loop_elapsed = time - $start_loop;

$background->WriteToEmail("Loop finished after " .
   "$loop_elapsed seconds\n");
$background->Finish;
