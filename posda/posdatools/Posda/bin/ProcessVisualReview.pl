#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::Background::PhiScan;

my $usage = <<EOF;
ProcessVisualReview.pl <bkgrnd_id> <scan_id> <notify>
or
ProcessVisualReview.pl -h

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

my ($invoc_id, $scan_id, $notify) = @ARGV;
my $get_info = Query("GetVisualReviewInstanceInfo");
my $vi_desc;
$get_info->RunQuery(sub {
  my($row) = @_;
 $vi_desc = $row->[0];
}, sub {}, $scan_id);
my %Counts;
my $get_counts = Query("GetVisualReviewStatusCountsById");
$get_counts->RunQuery(sub{
  my($row) = @_;
  my($status, $count) = @$row;
}, sub{}, $scan_id);
my $num_stats = keys %Counts;
if($num_stats > 2){
  print "There are more than 2 review stati for thie ($scan_id) " .
    "visual review:\n";
  for my $i (sort keys %Counts){
    print "\t$i: $Counts{$i}\n";
  }
  exit;
}
for my $stat (keys %Counts){
  if($stat ne "Good" && $stat ne "Bad"){
    print "This ($scan_id) visual review has some review stati " .
      "other than \"Good\" or \"Bad\" (\"$stat\")\n";
    exit;
  }
}
my %BadSeries;
my $get_bad = Query("GetSeriesByVisualReviewIdAndStatus");
$get_bad->RunQuery(sub{
  my($row) = @_;
  $BadSeries{$row->[0]} = 1;
}, sub {}, $scan_id, 'Bad');
my %GoodSeries;
my $get_good = Query("GetSeriesByVisualReviewIdAndStatus");
$get_good->RunQuery(sub{
  my($row) = @_;
  $GoodSeries{$row->[0]} = 1;
}, sub {}, $scan_id, 'Good');
for my $series (keys %GoodSeries){
  if(exists $BadSeries{$series}){
    print "Error: series ($series) is both good and bad\n";
    exit;
  }
}
my $get_hidden = Query('GetHiddenFilesBySeriesAndVisualReviewId');
for my $s (keys %GoodSeries){
  $get_hidden->RunQuery(sub {
    my($row) = @_;
    print "Error: Good series($s) contains hidden files\n";
    exit;
  }, sub {}, $scan_id, $s);
}
my @SeriesList = keys %GoodSeries;
my $num_series = @SeriesList;
print "Found $num_series to scan\n";
my %SeriesToHide;
my $get_vis = Query('GetVisibleFilesBySeriesAndVisualReviewId');
for my $s (keys %BadSeries){
  $get_vis->RunQuery(sub {
    my($row) = @_;
    $SeriesToHide{$s} = 1;
  }, sub{}, $scan_id, $s);
}
my @SeriesToHide = keys %SeriesToHide;
my $num_series_to_hide = @SeriesToHide;
print "Found $num_series_to_hide to hide\n";
for my $s (keys %BadSeries){
  $get_hidden->RunQuery(sub {
    my($row) = @_;
    my($s) = $row->[0];
    if(exists $SeriesToHide{$s}){
      print "Warning: series ($s) is already partially hidden\n";
    } else {
      print "Warning: series ($s) is already completely hidden\n";
    }
  }, sub {}, $scan_id, $s);
}

my$description = "First Pass Scan from processing of visual review \"" .
  "$vi_desc\" ($notify)";
print "Background to do scan: \"$description\"\n";
#print "not doing stuff for test\n"; exit;
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
print "Going to background\n";
$background->Daemonize;
my $start_time = time;
if(@SeriesToHide > 0){
  my $cmd = "HideBatchSeriesWithStatus.pl $notify " .
    "\"Hiding Bad series from visual_review $scan_id\"";
  open HIDER, "|HideBatchSeriesWithStatus.pl $notify $scan_id >/dev/null";
  for my $s (@SeriesToHide){
    print HIDER "$s\n";
  }
  close HIDER;
  my $hide_time = time - $start_time;
  $background->WriteToEmail("Series hide time: $hide_time seconds\n");
} else {
  $background->WriteToEmail("No series to hide\n");
}
$background->WriteToEmail("Starting PHI scan: \"$description\"\n");
my $scan = Posda::Background::PhiScan->NewFromScan(
  \@SeriesList, $description, "Posda");
my $end_time = time;
my $elapsed = $end_time - $start_time;
my $id = $scan->{phi_scan_instance_id};
$background->WriteToEmail("Created scan id: $id in $elapsed seconds\n");
$background->WriteToEmail("Creating " .
  "\"SimplePublicPhiReportSelectedVrWithMetaquotes\" report.\n");
my $rpt1 = $background->CreateReport("Selected Public VR");
my $lines = $scan->PrintTableFromQuery(
  "SimplePublicPhiReportSelectedVrWithMetaquotes", $rpt1);
$background->WriteToEmail("Creating " .
  "\"SimplePhiReportAllRelevantPrivateOnlyWithMetaQuotes\" report.\n");
my $rpt2 = $background->CreateReport("Selected Private");
$lines = $scan->PrintTableFromQuery(
  "SimplePhiReportAllRelevantPrivateOnlyWithMetaQuotes", $rpt2);
my $rpt3 = $background->CreateReport("Edit Skeleton");
$rpt3->print("element,vr,q_value,description,disp,num_series," .
  "p_op,q_arg1,q_arg2,Operation,scan_id,notify\r\n");
$rpt3->print(",,,,,,,,,ProposeEdits,$id,$notify\r\n");
$background->Finish;
