#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Debug;
my $dbg = sub { print @_ };
$| = 1; # this should probably be at the top of the script, maybe in the lib?

my $usage = <<EOF;
Usage:
CreateActivityTimepointFromImportEventId.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>
  or
CreateActivityTimepointFromImportEventId.pl -h
Expects lines on STDIN:
<import_event_id>

Note: This gets ALL files in import_events into timepoint, not just DICOM files.
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }

unless($#ARGV == 3) { print $usage; exit }

my($invoc_id, $act_id, $comment, $notify) = @ARGV;
print "All processing in background\n";
my $start = time;
my %InputEvents;
while(my $line = <STDIN>){
  chomp $line;
  $InputEvents{$line} = 1;
}

my %Files;
for my $import_event_id (keys %InputEvents){
  Query('GetAllFilesByImportEventId')->RunQuery(sub{
    my($row) = @_;
    $Files{$row->[0]} = 1;
  }, sub {}, $import_event_id);
}
#############################
# This is code which sets up the Background Process and Starts it
my $forground_time = time - $start;
my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
$background->Daemonize;
my $now = `date`;
$background->WriteToEmail("Creating timepoint from named import for $act_id:" .
  "at $now\n");
my $start_creation = time;
### Creation of tables here
my $cre = Query("CreateActivityTimepoint");
$cre->RunQuery(sub {}, sub {},
  $act_id, $0, $comment, $notify);
my $act_time_id;
my $gid = Query("GetActivityTimepointId");
$gid->RunQuery(sub {
  my($row) = @_;
  $act_time_id = $row->[0];
}, sub{});
$background->WriteToEmail("Activity Timepoint Id: $act_time_id\n");
unless(defined $act_time_id){
  $background->WriteToEmail("Unable to get activity timepoint id.\n");
  $background->Finish;
  exit;
}

my $ins_file = Query("InsertActivityTimepointFile");
for my $file_id (keys %Files){
  $ins_file->RunQuery(sub{}, sub{}, $act_time_id, $file_id);
}
my $creation_time = time;
my $creation = $creation_time - $start_creation;
$background->WriteToEmail("Created tables in $creation seconds.\n");
$background->WriteToEmail("NOTE: Reports are no longer included in this email." .
  "Users should rely on the timepoint report queries instead.\n");
my $num_files = keys %Files;
$background->Finish("Created activity_timepoint $act_time_id with" .
  " $num_files files");
