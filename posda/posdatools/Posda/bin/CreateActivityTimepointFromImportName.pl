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
CreateActivityTimepointFromImportName.pl <?bkgrnd_id?> <activity_id> "<import_name>" "<comment>" <notify>
  or
CreateActivityTimepointFromImportName.pl -h
Expects no lines on STDIN:
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }

unless($#ARGV == 4) { print $usage; exit }

my($invoc_id, $import_name, $act_id, $comment, $notify) = @ARGV;
my $start = time;

#############################
# This is code which sets up the Background Process and Starts it
my $forground_time = time - $start;
print "Going to background to create timepoint  after $forground_time seconds\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->Daemonize;
my $now = `date`;
$background->WriteToEmail("Creating timepoint from named import for $act_id:" .
  "import_name: $import_name\n" .
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
my %Files;
Query('GetDicomFilesByImportName')->RunQuery(sub{
  my($row) = @_;
  $Files{$row->[0]} = 1;
}, sub {}, $import_name);
my $ins_file = Query("InsertActivityTimepointFile");
for my $file_id (keys %Files){
  $ins_file->RunQuery(sub{}, sub{}, $act_time_id, $file_id);
}
my $creation_time = time;
my $creation = $creation_time - $start_creation;
$background->WriteToEmail("Created tables in $creation seconds.\n");
$background->WriteToEmail("Preparing reports.\n");
##################################
my $ActInfo = Posda::ActivityInfo->new($act_id);
my $when = `date`;
chomp $when;
my $TpFileInfo = $ActInfo->GetFileInfoForTp($act_time_id);
my $new_fh = $ActInfo->MakeFileHierarchyFromInfo(
  $TpFileInfo);
my $rpt1 = $background->CreateReport("Timepoint Report");
$rpt1->print("Timepoint Creation Report\r\n");
$rpt1->print("key,value\r\n");
$rpt1->print("report,\"Timepoint Report\"\r\n");
$rpt1->print("script,\"$0\"\r\n");
$rpt1->print("tp_id,$act_time_id\r\n");
$rpt1->print("activity_id,$act_id\r\n");
$rpt1->print("when,$when\r\n");
$rpt1->print("who,$notify\r\n");
$rpt1->print("\r\n");
$ActInfo->PrintHierarchyReport($rpt1, $new_fh);

my $new_cfh = $ActInfo->MakeCondensedHierarchyFromInfo(
  $TpFileInfo);
my $rpt4 = $background->CreateReport("Condensed Timepoint Report");
$rpt4->print("Condensed Timepoint Creation Report");
$rpt4->print("key,value\r\n");
$rpt4->print("report,\"Condensed Timepoint Content Report\"\r\n");
$rpt4->print("script,\"$0\"\r\n");
$rpt4->print("tp_id,$act_time_id\r\n");
$rpt4->print("activity_id,$act_id\r\n");
$rpt4->print("when,$when\r\n");
$rpt4->print("who,$notify\r\n");
$rpt4->print("\r\n");
$ActInfo->PrintCondensedHierarchyReport($rpt4, $new_cfh);
##################################
$background->Finish;
