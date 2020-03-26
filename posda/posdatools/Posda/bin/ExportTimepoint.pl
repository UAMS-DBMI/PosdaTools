#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;

my $usage = <<EOF;
ExportTimepoint.pl <?bkgrnd_id?> <activity_id> "<destination_name>"  <notify>
or
ExportTimepoint.pl -h

Expects no lines STDIN

Uses the following queries:
  
Does the following:
  Creates an export_event row:
    submitter_type: "subprocess_invocation"
    export_destination: <destination_name>
    subprocess_invocation_id: <bkgrnd_id>
    creation_time: now()
    request_pending: false
  For every row in activity_timepoint_file
  for the current activity_timepoint:
    add a row to file_export:
      export_event_id: from creation of export_event
      file_id: from activity_timepoint_file
      when_queued: now()
      transfer_status: "pending"
  After all files have been processed, the script will 
  update export_event:
      set request_status = "start"
      set request_pending = "true"

Queries Used:
  CreateExportEvent
  GetExportEventId
  LatestActivityTimepointForActivity
  FilesInTimepoint
  CreateFileExportRow
  ExportDaemonRequest
EOF

$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
unless($#ARGV == 3){
  die "$usage\n";
}
my ($invoc_id, $activity_id, $destination, $notify) = @ARGV;
print "Going straight to Background\n";
my $bg = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$bg->Daemonize;
my $activity_timepoint_id;
Query("LatestActivityTimepointForActivity")->RunQuery(sub{
  my($row) = @_;
  $activity_timepoint_id = $row->[0];
}, sub {}, $activity_id);
if(defined $activity_timepoint_id){
  $bg->WriteToEmail("Exporting\n  activity_timepoint_id: $activity_timepoint_id\n");
} else {
  $bg->WriteToEmail("Unable to get activity_timepoint_id for activity $invoc_id\n");
  $bg->Finish("Failed: unable to get activity_timepoint_id");
  exit;
}
$bg->SetActivityStatus("Getting files in timepoint\n");
my @file_ids;
my $num_files = 0;
Query("FilesInTimepoint")->RunQuery(sub{
  my($row) = @_;
  $num_files += 1;
  push @file_ids, $row->[0];
}, sub {}, $activity_timepoint_id);
$num_files = @file_ids;
$bg->WriteToEmail("Found $num_files to export\n");

$bg->SetActivityStatus("Creating Export Event\n");
my $export_event_id;
Query("CreateExportEvent")->RunQuery(sub{
}, sub{}, "subprocess_invocation", $invoc_id, $destination);
Query("GetExportEventId")->RunQuery(sub{
  my($row) = @_;
  $export_event_id = $row->[0];
}, sub{});
if(defined $export_event_id){
  $bg->WriteToEmail("Export Event ($export_event_id) to $destination\n");
} else {
  $bg->WriteToEmail("Unable to create Export Event\n");
  $bg->Finish("Failed: unable to create Export Event");
  exit;
}

my $num_queued = 0;
my $q = Query("CreateFileExportRow");
for my $f (@file_ids){
  $q->RunQuery(sub{}, sub {}, $export_event_id, $f);
  $num_queued += 1;
  $bg->SetActivityStatus("Queued $num_queued of $num_files for export $export_event_id\n");
}

Query("ExportDaemonRequest")->RunQuery(sub{}, sub{}, "start", $export_event_id);

$bg->Finish("Done: queued $num_files to export_event $export_event_id");
