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
CreateActivityListFromPatientCountAndUploadSpecSpreadsheet.pl <?bkgrnd_id?> <activity_id> <notify>
  or
CreateActivityListFromPatientCountAndUploadSpecSpreadsheet.pl -h
Expects lines on STDIN:
<patient_id>&<num_files>&<import_comment_like>&<import_type_like>&<from_to>&<from_to>

Uses query:
  FilesByPatientAndUploadParms
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }

unless($#ARGV == 2) { print $usage; exit }

my($invoc_id, $act_id, $notify) = @ARGV;
my $start = time;
my @Qargs;
while (my $line = <STDIN>){
  chomp $line;
  my($patient_id, $num_files, $import_comment_like, $import_type_like,
    $from, $to) = split /&/, $line;
  if($from =~ /^<(.*)>$/) { $from = $1 }
  if($to =~ /^<(.*)>$/) { $to = $1 }
  
  push @Qargs, {
    num_files_expected => $num_files,
    q_args => [$import_comment_like, $import_type_like,
      $from, $to, $patient_id]
  };
}
my $tot_pats = @Qargs;

#############################
# This is code which sets up the Background Process and Starts it
my $forground_time = time - $start;
print "Going to background to create timepoint  after $forground_time seconds\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
$background->Daemonize;
my $now = `date`;
$background->WriteToEmail("Getting List of files by patient:\n");
my %Files;
my $q = Query('FilesByPatientAndUploadParms');
for my $spec (@Qargs) {
  my @args = @{$spec->{q_args}};
  my $expected = $spec->{num_files_expected};
  my $count = 0;
  $q->RunQuery(sub{
    my($row) = @_;
    $Files{$row->[0]} = 1;
    $count += 1;
  }, sub {}, @args);
  if($count == $expected){
    $background->WriteToEmail("Found $expected files for patient_id $args[4] " .
      "(as expected)\n")
  } else {
    $background->WriteToEmail("Found $count files for patient_id $args[4] " .
      "(vs $expected expected)\n")
  }
}
my $tot_files = keys %Files;
$background->WriteToEmail("Creating timepoint from list of files:\n" .
  "Activity: $act_id\n" .
  "NumFiles: $tot_files\n" .
  "at $now\n");
my $start_creation = time;
### Creation of tables here
my $cre = Query("CreateActivityTimepoint");
$cre->RunQuery(sub {}, sub {},
  $act_id, $0, "CreateActivityListFromPatientCountAndUploadSpecSpreadsheet.pl: $invoc_id", $notify);
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
