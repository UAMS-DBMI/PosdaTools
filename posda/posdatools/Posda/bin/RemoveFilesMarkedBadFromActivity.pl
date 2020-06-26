#!/usr/bin/perl -w
use strict;
use Posda::DB qw(Query);
use Posda::BackgroundProcess;
my $usage = <<EOF;
RemoveFilesMarkedBadFromActivity.pl <?bkgrnd_id?> <activity_id> <visual_review_id> <notify>

Expects nothing on <STDIN>

EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}

unless($#ARGV == 3){
  my $num_args = @ARGV;
  print "Wrong number of args: $num_args vs 4\n";
  print $usage;
  die $usage;
}
my($invoc_id, $activity_id, $vr_id, $notify) = @ARGV;
my $bk = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
print "All in background\n";
$bk->Daemonize;
my $old_activity_timepoint_id;
Query("LatestActivityTimepointForActivity")->RunQuery(sub{
  my($row) = @_;
  $old_activity_timepoint_id = $row->[0];
}, sub{}, $activity_id);
my @SopsNotFinished;
Query("SopsInTimepointWithUnfinishedVR")->RunQuery(sub{
  my($row) = @_;
  push @SopsNotFinished, $row->[0];
}, sub {}, $activity_id, $vr_id);
my $num_not_finished = @SopsNotFinished;
$bk->WriteToEmail("Script RemoveFilesMarkedBadFromActivity:\n" .
  "  activity_id               = $activity_id\n" .
  "  old_activity_timepoint_id = $old_activity_timepoint_id\n" .
  "  visual_review_id          = $vr_id\n" .
  "  num_sops_not_finished     = $num_not_finished\n");
if($num_not_finished > 0){
  $bk->WriteToEmail("\nWarning: there are $num_not_finished in the visual review " .
   "($vr_id) with " .
   "a review status other than 'Good' or 'Bad'.\n" .
   "These will be copied to the new timepoint.\n" .
   "The new timepoint will not be ready for transfer to " .
   "public until these are resolved\n\n");
}
Query("CreateActivityTimepoint")->RunQuery(sub {}, sub {},
  $activity_id, $0, "From visual review ($vr_id)", $notify);
my $act_time_id;
Query("GetActivityTimepointId")->RunQuery(sub {
  my($row) = @_;
  $act_time_id = $row->[0];
}, sub{});
$bk->WriteToEmail("Activity Timepoint Id: $act_time_id\n");
unless(defined $act_time_id){
  $bk->WriteToEmail("Unable to get activity timepoint id.\n");
  $bk->Finish("Error - unable to get activity timepoint id.");
  exit;
}
$bk->WriteToEmail(
  "  new_activity_timepoint_id = $act_time_id\n\n");
$bk->WriteToEmail("Invoking " .
  "PopulateNewActivityTimepointFromOld($old_activity_timepoint_id, " .
  "$vr_id, $act_time_id)\nto copy files from " .
  "timepoint $old_activity_timepoint_id to timepoint $act_time_id, " .
  "excluding files marked bad in visual review $vr_id.\n");

Query("PopulateNewActivityTimepointFromOld")->RunQuery(
  sub{}, sub {}, $old_activity_timepoint_id, $vr_id,
  $act_time_id);
$bk->Finish("New timepoint $act_time_id created");
