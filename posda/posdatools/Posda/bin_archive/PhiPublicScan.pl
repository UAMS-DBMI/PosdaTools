#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::Background::PhiScan;

my $usage = <<EOF;
PhiPublicScan.pl <?bkgrnd_id?> <activity_id> <max_rows> <collection> <site> <notify>
or
PhiPublicScan.pl -h

The script doesn't expect lines on STDIN:

EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 5){
  my $n_args = @ARGV;
  print "Error: wrong number args $n_args vs 6\n";
  print "$usage\n";
  die "$usage\n";
}

my ($invoc_id, $act_id, $max_rows, $collection, $site, $notify) = @ARGV;
print "invoc_id, $act_id, $max_rows, $collection, $site, $notify\n";
my $q;
my %Series;
my $num_rows = 0;
my $description;
my $q_name;

$q = Query("DistinctSeriesByCollectionSitePublic");
$q_name = "DistinctSeriesByCollectionSitePublic(\"$collection\", " .
  "\"$site\")";
$description = "Public Scan of $collection\\$site ($notify)";
$q->RunQuery(sub {
  my($row) = @_;
    my($series, $file_type, $modality, $count) = @$row;
    $Series{$series} = 1;
    $num_rows += 1;
  }, sub {}, $collection, $site
);
my @SeriesList = keys %Series;
my $num_series = @SeriesList;
print "Found $num_series to scan in $num_rows rows returned by $q_name\n";
print "Background to do scan: \"$description\"\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
print "Going to background\n";
$background->Daemonize;
my $start_time = time;
$background->WriteToEmail("Starting PHI scan: \"$description\"\n");

$background->SetActivityStatus("Scanning for PHI");
my $scan = Posda::Background::PhiScan->NewFromScan(
  \@SeriesList, $description, "Public", $invoc_id, $act_id, $background);
my $end_time = time;
my $elapsed = $end_time - $start_time;
my $id = $scan->{phi_scan_instance_id};
$background->WriteToEmail("Created scan id: $id in $elapsed seconds\n");
$background->WriteToEmail("Scan ($id) description: $description\n");

$background->WriteToEmail("Creating " .
  "\"SimplePhiReportAllMetaQuotes\" report\n");
$background->SetActivityStatus("Preparing Report");
$background->PrepareBackgroundReportBasedOnQuery(
  "SimplePhiReportAllMetaQuotes", "Phi Report All", $max_rows, $id);

$elapsed = time - $start_time;
$background->Finish("Finished report in $elapsed seconds");
