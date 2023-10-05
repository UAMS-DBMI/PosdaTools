#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::ActivityInfo;
use Debug;
my $dbg = sub { print @_ };
$| = 1; # this should probably be at the top of the script, maybe in the lib?

#die "not finished implementation";
my $usage = <<EOF;
Usage:
AddSeriesToActivityTimepoint.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>
  or
AddSeriesToActivityTimepoint.pl -h

Expects lines on STDIN:
<series_instance_uid>
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }
unless($#ARGV == 3) { print $usage; exit }
my($invoc_id, $act_id, $comment, $notify) = @ARGV;
my %AllSeries;
my %series_to_add;
while(my $line = <STDIN>){
  chomp $line;
  $series_to_add{$line} = 1;
  $AllSeries{$line} = 1;
}
my @SeriesToAdd = keys %series_to_add;
my $num_series = @SeriesToAdd;
print "Going to background to add $num_series to timepoint\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->Daemonize;
$background->WriteToEmail(
  "Starting script: AddSeriesToActivityTimepoint.pl\n" .
  "Activity_id: $act_id\n" .
  "Comment: $comment\n" .
  "Notify: $notify\n");
my $start = time;
my $ActInfo = Posda::ActivityInfo->new($act_id);
my $current_tp_id = $ActInfo->LatestTimepoint;
my $CurrentTpFileInfo = $ActInfo->GetFileInfoForTp($current_tp_id);
my %SeriesInCurrentTp;
my %SeriesToAddAlreadyInTp;
for my $f (keys %{$CurrentTpFileInfo}){
  my $s = $CurrentTpFileInfo->{$f}->{series_instance_uid};
  if(exists $series_to_add{$s}){
    $SeriesToAddAlreadyInTp{$s} = 1;
  }
  $SeriesInCurrentTp{$s} = 1;
  $AllSeries{$s} = 1;
}
my $num_new_series = @SeriesToAdd;
my $num_old_series = keys %SeriesInCurrentTp;
my $tot_num_series = keys %AllSeries;
my $num_series_overlap = keys %SeriesToAddAlreadyInTp;;
my $time_to_gather_tp_info = time - $start;
$background->WriteToEmail(
  "After $time_to_gather_tp_info seconds:\n" .
  "\t$num_new_series series to add\n" .
  "\t$num_old_series series to old time point\n" .
  "\t$tot_num_series series to be in new time point\n" .
  "\t$num_series_overlap series overlap\n");
my $start_build = time;
my($act_tp_id, $TpFileInfo) = $ActInfo->CreateTpFromSeriesList(
  \%AllSeries, $comment, $notify);
my $time_to_create = time - $start_build;
$background->WriteToEmail(
  "Created timepoint_id $act_tp_id after $time_to_create seconds.\n");
my $file_hier = $ActInfo->MakeFileHierarchyFromInfo($TpFileInfo);
my $rpt1 = $background->CreateReport("Timepoint Creation Report");
$rpt1->print("key,value\r\n");
$rpt1->print("script,\"$0\"\r\n");
$rpt1->print("report,\"Timepoint Creation Report\"\r\n");
$rpt1->print("comment,\"$comment\"\r\n");
$rpt1->print("activity_id,\"$act_id\"\r\n");
$rpt1->print("old_activity_timepoint_id,\"$current_tp_id\"\r\n");
$rpt1->print("new_activity_timepoint_id,\"$act_tp_id\"\r\n");
my $when = `date`;
chomp $when;
$rpt1->print("when,\"$when\"\r\n");
$rpt1->print("who,$notify\r\n");
$rpt1->print("\r\n");
$ActInfo->PrintHierarchyReport($rpt1, $file_hier);
my $cond_file_hier = $ActInfo->MakeCondensedHierarchyFromInfo($TpFileInfo);
my $rpt2 = $background->CreateReport("Condensed Timepoint Creation Report");
$rpt2->print("key,value\r\n");
$rpt2->print("script,\"$0\"\r\n");
$rpt2->print("report,\"Condensed Timepoint Creation Report\"\r\n");
$rpt2->print("comment,\"$comment\"\r\n");
$rpt2->print("activity_id,\"$act_id\"\r\n");
$rpt2->print("old_activity_timepoint_id,\"$current_tp_id\"\r\n");
$rpt2->print("new_activity_timepoint_id,\"$act_tp_id\"\r\n");
my $when1 = `date`;
chomp $when1;
$rpt2->print("when,\"$when1\"\r\n");
$rpt2->print("who,$notify\r\n");
$rpt2->print("\r\n");
$ActInfo->PrintCondensedHierarchyReport($rpt2, $cond_file_hier);
$background->Finish;
