#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::ActivityInfo;
use Debug;
my $dbg = sub { print @_ };
$| = 1; # this should probably be at the top of the script, maybe in the lib?

my $usage = <<EOF;
Usage:
CreateActivityTimepointFromFileIds.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>
  or
CreateActivityTimepointFromFileIds.pl -h
Expects lines on STDIN:
<file_id>
...
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }

unless($#ARGV == 3) { print $usage; exit }

my($invoc_id, $act_id, $comment, $notify) = @ARGV;
my $start = time;
my %Files;
while (my $line = <STDIN>){
  chomp $line;
  $Files{$line} = 1;
}
my $tot_files = keys %Files;

#############################
# This is code which sets up the Background Process and Starts it
my $forground_time = time - $start;
print "Going to background to create timepoint  after $forground_time seconds\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
$background->Daemonize;
my $now = `date`;
$background->WriteToEmail("Creating timepoint from list of files:\n" .
  "Activity: $act_id\n" .
  "NumFiles: $tot_files\n" .
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
  $background->Finish("Error - unable to get activity timepoint id.");
  exit;
}

my $ins_file = Query("InsertActivityTimepointFile");
my $num_files = 0;
for my $file_id (keys %Files){
  $num_files += 1;
  $background->SetActivityStatus("Adding $num_files of $tot_files");
  $ins_file->RunQuery(sub{}, sub{}, $act_time_id, $file_id);
}
my $creation_time = time;
my $creation = $creation_time - $start_creation;
$background->WriteToEmail("Done - Created timepoint $act_time_id with $num_files files\n");
$background->Finish("Done - Created timepoint $act_time_id with $num_files files");
