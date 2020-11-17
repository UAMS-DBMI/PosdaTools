#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::Background::PhiScan;

my $usage = <<EOF;
PhiVaPublicScanTp.pl <?bkgrnd_id?> <activity_id> <import_event_id> <max_rows> <notify>
or
PhiVaPublicScanTp.pl -h

The script doesn't expect lines on STDIN:

EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 4){
  die "$usage\n";
}

my ($invoc_id, $act_id, $imp_event_id, $max_rows, $notify) = @ARGV;
my $num_rows = 0;
my %SeriesInImportEvent;
Query('SeriesInImportEvent')->RunQuery(sub{
  my($row) = @_;
  $SeriesInImportEvent{$row->[0]} = 1;
},sub{}, $imp_event_id);
my @SeriesList = keys %SeriesInImportEvent;
my $description = "VA 'Public' Scan of import_event $imp_event_id ($notify)";

my $num_series = @SeriesList;
print "Found $num_series in import_event $imp_event_id\n";
unless($num_series > 0) { print "nothing to scan\n" ; exit }
print "Background to do scan: \"$description\"\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
print "Going to background\n";
$background->Daemonize;
my $start_time = time;
$background->WriteToEmail("Starting PHI scan: \"$description\"\n");
my $scan = Posda::Background::PhiScan->NewFromScan(
  \@SeriesList, $description, "ImportEventId($imp_event_id)", $invoc_id, $act_id, $background);
my $end_time = time;
my $elapsed = $end_time - $start_time;
my $id = $scan->{phi_scan_instance_id};
$background->WriteToEmail("Created scan id: $id in $elapsed seconds\n");
$background->WriteToEmail("Scan ($id) description: $description\n");
$background->WriteToEmail("Creating " .
  "\"SimplePhiReportAllMetaQuotes\" report\n");
$background->PrepareBackgroundReportBasedOnQuery(
  "SimplePhiReportAllMetaQuotes", "Phi Report All", $max_rows, $id);
$background->Finish;
