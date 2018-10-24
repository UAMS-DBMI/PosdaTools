#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::Background::PhiScan;

my $usage = <<EOF;
PhiPublicScanTp.pl <?bkgrnd_id?> <activity_id> <notify>
or
PhiPublicScanTp.pl -h

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

my ($invoc_id, $act_id, $notify) = @ARGV;
my $num_rows = 0;

my $OldActTpId;
my $OldActTpComment;
my $OldActTpDate;
my %FilesInOldTp;
my %SeriesInOldTp;
Query('LatestActivityTimepointsForActivity')->RunQuery(sub{
  my($row) = @_;
  my($activity_id, $activity_created,
    $activity_description, $activity_timepoint_id,
    $timepoint_created, $comment, $creating_user) = @$row;
  $OldActTpId = $activity_timepoint_id;
  $OldActTpComment = $comment;
  $OldActTpDate = $timepoint_created;
}, sub {}, $act_id);
Query('FileIdsByActivityTimepointId')->RunQuery(sub {
  my($row) = @_;
  $FilesInOldTp{$row->[0]} = 1;
}, sub {}, $OldActTpId);
my $q = Query('SeriesForFile');
for my $file_id(keys %FilesInOldTp){
  $q->RunQuery(sub {
    my($row) = @_;
    $SeriesInOldTp{$row->[0]} = 1;
  }, sub {}, $file_id);
}
my @SeriesList = keys %SeriesInOldTp;
my $description = "Public Scan of activity $act_id, tp $OldActTpId ($notify)";

my $num_series = @SeriesList;
print "Found $num_series\n";
print "Background to do scan: \"$description\"\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
print "Going to background\n";
$background->Daemonize;
my $start_time = time;
$background->WriteToEmail("Starting PHI scan: \"$description\"\n");
my $scan = Posda::Background::PhiScan->NewFromScan(
  \@SeriesList, $description, "Public");
my $end_time = time;
my $elapsed = $end_time - $start_time;
my $id = $scan->{phi_scan_instance_id};
$background->WriteToEmail("Created scan id: $id in $elapsed seconds\n");
$background->WriteToEmail("Creating " .
  "\"SimplePhiReportAllMetaQuotes\" report.\n");
my $rpt1 = $background->CreateReport("Full Public Scan");
my $lines = $scan->PrintTableFromQuery(
  "SimplePhiReportAllMetaQuotes", $rpt1);
my $rpt3 = $background->CreateReport("Edit Skeleton");
$rpt3->print("element,vr,q_value,description,disp,num_series," .
  "p_op,q_arg1,q_arg2,Operation,scan_id,notify\r\n");
$rpt3->print(",,,,,,,,,ProposeEdits,$id,$notify\r\n");
$background->Finish;

