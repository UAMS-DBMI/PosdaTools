#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::Background::PhiScan;

my $usage = <<EOF;
FirstPassPhiScanAndReport.pl <bkgrnd_id> <description> <max_lines> <notify>
or
FirstPassPhiScanAndReport.pl -h

The script expects lines on STDIN:
<series_instance_uid>

EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 3){
  die "$usage\n";
}

my ($invoc_id, $description, $max_lines, $notify) = @ARGV;

my %Series;
while(my $line = <STDIN>){
  chomp $line;
  $Series{$line} = 1;
}
my @SeriesList = keys %Series;
my $num_series = @SeriesList;
print "Found $num_series to scan\n";
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
$background->WriteToEmail("Creating " .
  "\"SimplePhiReportAllMetaQuotes\" report.\n");
$background->PrepareBackgroundReportBasedOnQuery(
  "SimplePhiReportAllMetaQuotes", "Full Phi Report", $max_lines, $id);
$background->Finish;
