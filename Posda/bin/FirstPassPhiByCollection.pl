#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::Background::PhiScan;

my $usage = <<EOF;
FirstPassPhiScanAndReport.pl <bkgrnd_id> <collection> <notify>
or
FirstPassPhiScanAndReport.pl -h

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
my $q;
my %Series;
my $num_rows = 0;
my $description;
my $q_name;
$q = Query("DistinctSeriesByCollection");
$q_name = "DistinctSeriesByCollection(\"$collection\")";
$description = "First Pass Scan of $collection ($notify)";
$q->RunQuery(sub {
  my($row) = @_;
  my($series, $file_type, $modality, $count) = @$row;
  $Series{$series} = 1;
  $num_rows += 1;
}, sub {}, $collection);
my @SeriesList = keys %Series;
my $num_series = @SeriesList;
print "Found $num_series to scan in $num_rows rows returned by $q_name\n";
print "Background to do scan: \"$description\"\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
print "Going to background\n";
$background->Daemonize;
my $start_time = time;
$background->WriteToEmail("Starting PHI scan: \"$description\"\n");
my $scan = Posda::Background::PhiScan->NewFromScan(
  \@SeriesList, $description, "Posda");
my $end_time = time;
my $elapsed = $end_time - $start_time;
my $id = $scan->{phi_scan_instance_id};
$background->WriteToEmail("Created scan id: $id in $elapsed seconds\n");
$scan->PrepareBackgroundReportBasedOnQuery(
  "SimplePublicPhiReportSelectedVrWithMetaquotes",
  "Public with Selected VR", $background, 50000);
$scan->PrepareBackgroundReportBasedOnQuery(
  "SimplePhiReportAllRelevantPrivateOnlyWithMetaQuotes",
  "Relevant Private", $background, 50000);
$background->Finish;
