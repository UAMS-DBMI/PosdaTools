#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;

my $usage = <<EOF;
ScheduleVisualReviewFromActivityTimepoint.pl <bkgrnd_id> <activity_id> <notify>
or
ScheduleVisualReviewFromActivityTimepoint.pl -h

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
print "All processing in background\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
$background->Daemonize;
my $create_instance = Query("CreateVisualReviewInstanceWithInvocId");
my $get_review_instance_id = Query("GetVisualReviewInstanceId");

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
$background->SetActivityStatus("Found timepoint ($OldActTpId) for " .
  "activity: $act_id");
print "Operating on timepoint $OldActTpId";
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
my @series = keys %SeriesInOldTp;

my $num_series = @series;
$background->SetActivityStatus("Found $num_series in timepoint $OldActTpId");

$create_instance->RunQuery(sub{}, sub {},
  $invoc_id, "Activity Id: $act_id", $notify, $num_series);
my $visual_review_instance_id;
$get_review_instance_id->RunQuery(sub{
  my($row) = @_;
  $visual_review_instance_id = $row->[0];
},sub {});
my $update_status = Query("UpdateStatusVisualReviewInstance");
my $finalize = Query("FinalizeVisualReviewScheduling");
my $tot_series = 0;
for my $i (0 .. $#series){
  my $ith = $i +1;
  print STDERR "process $ith of $num_series in timepoint $OldActTpId";
  $background->SetActivityStatus(
    "process $ith of $num_series in timepoint $OldActTpId");
  my $s = $series[$i];
  my $tot_equiv = 0;
  my $cmd = "NewCreateSeriesEquivalenceClasses.pl $s $OldActTpId $visual_review_instance_id";
  open CMD, "$cmd|";
  while(my $line = <CMD>){
    if($line =~ /\s*(\d+)\s*classes for series\s*(.*)\s*$/){
      my $num_equiv = $1;
      $tot_equiv += $num_series;
      $tot_series += 1;
      $background->WriteToEmail("$line\n");
      $update_status->RunQuery(sub {}, sub{},
        $tot_series, $tot_equiv, $visual_review_instance_id);
    }
  }
  close CMD;
}
$finalize->RunQuery(sub{}, sub {}, $visual_review_instance_id);
$background->Finish("Schedule Complete - Manual Process Follows");;
