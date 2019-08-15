#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::Background::PhiScan;

my $usage = <<EOF;
SchedulePhiReviewFromActivityTimepoint.pl <bkgrnd_id> <activity_id> <notify>
or
SchedulePhiReviewFromActivityTimepoint.pl -h

Expects lines of the following form on STDIN:
<series_instance_uid>

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

my $num_series = @SeriesList;

my $description = "First Pass Scan activity timepoint for activity $act_id " .
  "($notify)";
print "Background to do scan: \"$description\"\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
print "Going to background\n";
$background->Daemonize;
my $start_time = time;
$background->WriteToEmail("Starting PHI scan: \"$description\"\n");
$background->WriteToEmail("$num_series series to scan\n");
my $scan = Posda::Background::PhiScan->NewFromScan(
  \@SeriesList, $description, "Posda", $invoc_id, $act_id, $background);
my $end_time = time;
my $elapsed = $end_time - $start_time;
my $id = $scan->{phi_scan_instance_id};
$background->WriteToEmail("Created scan id: $id in $elapsed seconds\n");
$background->SetActivityStatus("Preparing Reports");
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
$rpt3->print("element,vr,q_value,edit_description,disp,num_series," .
  "p_op,q_arg1,q_arg2,Operation,activity_id,scan_id,notify,sep_char\r\n");
$rpt3->print(",,,,,,,,,ProposeEditsTp,$act_id,$id,$notify,\"%\"\r\n");
$background->Finish("Completed - PHI Scan and results");
