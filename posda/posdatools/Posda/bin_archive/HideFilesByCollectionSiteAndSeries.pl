#!/usr/bin/perl -w
use strict;
use Posda::BackgroundProcess;
use Posda::DB qw( Query );
my $usage = <<EOF;
HideFilesByCollectionSiteAndSeries.pl <?bkgrnd_id?> <activity_id> <notify>
  expects lines on STDIN of following format:
<collection>&<site>&<series_instance_uid>
  uses Query VisibleFilesByCollectionSiteSeries to get list of file_ids.
  Hides files using HideFilesWithStatusIrrespectiveOfCtp.pl to hide files
  Rebuilds Timepoint
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 2) { die $usage }
my($invoc_id, $activity_id, $notify) = @ARGV;
my @SeriesSpec;
while(my $line = <STDIN>){
  chomp $line;
  my($collection, $site, $series_instance_uid) = split /&/, $line;
  push @SeriesSpec, [$collection, $site, $series_instance_uid];
}
my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
my $num_series = @SeriesSpec;
print "found $num_series specifications to hide\n";
print "Going to background\n";
$back->Daemonize;

my $current_series = 0;
my $tot_files_hidden = 0;
for my $spec (@SeriesSpec){
  $current_series += 1;
  $back->SetActivityStatus("Working on series $current_series of $num_series");
  my %file_ids;
  Query("VisibleFilesByCollectionSiteSeries")->RunQuery(sub{
    my($row) = @_;
    my($col, $site, $file_id, $vis) = @{$row};
    unless(defined $vis) { $vis = "<undef>" }
    $file_ids{$file_id} = $vis;
  }, sub {},
  $spec->[0], $spec->[1], $spec->[2]);
  my $num_files = keys %file_ids;
  $back->WriteToEmail("Series $spec->[2] has $num_files files to hide\n");
  open HIDE, "|HideFilesWithStatusIrrespectiveOfCtp.pl $notify  \"$0 ($invoc_id)\"" or die;
  for my $file_id (keys %file_ids){
    my $vis = $file_ids{$file_id};
    if($vis eq "<undef>"){
      $tot_files_hidden +=  1;
      print HIDE "$file_id&$vis\n";
      print STDERR "$file_id&$vis\n";
    }
  }
  close HIDE;
}
$back->SetActivityStatus("Finished Hides ($tot_files_hidden) - Creating New timepoint");

my $old_tp;
Query('LatestActivityTimepointForActivity')->RunQuery(sub{
  my($row) = @_;
  $old_tp = $row->[0];
}, sub {}, $activity_id);
unless(defined $old_tp){
  $back->WriteToEmail("ERROR: couldn't get current timepoint for activity $activity_id\n");
  $back->Finish("Failed - check report");
  exit;
}
my $comment = "New Timepoint for remaining visible files ($invoc_id)";
Query("CreateActivityTimepoint")->RunQuery(sub {}, sub {},
  $activity_id, $0, $comment, $notify);
my $new_tp;
Query("GetActivityTimepointId")->RunQuery(sub {
  my($row) = @_;
  $new_tp = $row->[0];
}, sub{});
unless(defined $new_tp){
  $back->WriteToEmail("ERROR: Unable to get new activity timepoint id.\n");
  $back->Finish("Failed - check report");
  exit;
}
$back->WriteToEmail("Activity Timepoint Ids: old = $old_tp, new = $new_tp\n");
$back->SetActivityStatus("Adding visible files from old tp to new tp");
my $q = Query('InsertActivityTimepointFile');
my $num_copied_from_old = 0;
Query('VisibleFilesInTimepoint')->RunQuery(sub {
  my($row) = @_;
  $q->RunQuery(sub{}, sub{}, $new_tp, $row->[0]);
  $num_copied_from_old += 1;
}, sub{}, $old_tp);
$back->WriteToEmail("$num_copied_from_old files copied from old_tp ($old_tp) " .
  "to new_tp ($new_tp)\n");

$back->SetActivityStatus("Building report for new timepoint");
$back->PrepareBackgroundReportBasedOnQuery(
  "TimepointCreationReport", "Timepoint Creation Report (activity_id $activity_id, tp_id $new_tp)", 1000, $new_tp);
$back->Finish("Completed Hiding files and rebuilding timepoint");
