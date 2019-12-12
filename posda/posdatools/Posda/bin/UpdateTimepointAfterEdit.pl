#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Digest::MD5;
use Posda::BackgroundProcess;
use File::Path 'rmtree';

my $usage = <<EOF;
UpdateTimepointAfterEdit.pl <?bkgrnd_id?> <activity_id> <activity_timepoint_id> <subprocess_invocation_id> <notify>
or
UpdateTimepointAfterEdit.pl -h

The script doesn't expect lines on STDIN:

It does the following before entering background:
  1) It checks the status of the dicom_edit_compare_disposition row with
     that sub_invoc_id.  Unless it is "Import Complete - to files deleted"", print an
     error and exit.
     (Query: GetDicomEditCompareDisposition)
  2) Make the following lists:
     a) A list of the files which are "to" files in dicom_edit_compare, which have
        a file_id and are visible. (Query: FindVisibleToFiles)
     b) A list of the files which are "to" files in dicom_edit_compare with no file_id.
        (Query: FindNonExistentToFiles)
     c) A list of files which are "to" files in dicom_edit_compare with file_id
        but are not visible. (Query: FindHiddenToFiles)
     d) A list of files in the activity_timepoint which are visible.
        (Query: VisibleFilesInTimepoint)
     e) A list of files in the activity_timepoint which are not visible.
        (Query: HiddenFilesInTimepoint)
  3) If there are files in dicom_edit_compare which have no file_id, this is a serious
     error, which is reported.  The script then terminates.
  4) It will produce a report including:
     - The number of files visible in activity_timepoint
     - The number of files hidden in activity_timepoint
     - The number of files visible in dicom_edit_compare
     - The number of files hidden in dicom_edit_compare

Then it drops into the background to do its stuff:
  1) Unhide all files in dicom_edit_compare which are hidden
     using UnhideFilesWithStatus.pl
  2) Create an new activity_timepoint and populate it with:
     a) All files in dicom_edit_compare
     b) All visible files in old activity_timepoint
     Queries:
       CreateActivityTimepoint
       InsertActivityTimepointFile
       GetActivityTimepointId

Then it is done.
EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 4){
  my $num_args = $#ARGV;
  print "Error: wrong number of args ($num_args) vs 5:\n";
  print "$usage\n";
  die "$usage\n";
}

my ($invoc_id, $act_id, $act_tp_id, $subproc_invoc_id, $notify) = @ARGV;

my $get_decd = Query("GetDicomEditCompareDisposition");
my $status;
my $DestDir;
$get_decd->RunQuery(sub {
  my($row) = @_;
  my($num_sched, $num_ok, $num_failed, $current_disp, $dest_dir) = @$row;
  $status = $current_disp;
  $DestDir = $dest_dir;
}, sub{}, $subproc_invoc_id);
unless($status eq "Import Complete - to files deleted"){
  print "Error: status is \"$status\".\nInappropriate for timepoint update\n";
  print "Terminated abnormally\n";
  exit;
}

my %NonExistentToFiles;
Query("FindNonExistentToFiles")->RunQuery(sub{
  my($row) = @_;
  my $file_id = $row->[0];
  $NonExistentToFiles{$file_id} = 1;
}, sub{}, $subproc_invoc_id);
my $num_nonexistent = keys %NonExistentToFiles;
if($num_nonexistent > 0){
  print "Error: there are $num_nonexistent files produced by edit which weren't imported\n";
  print "Terminated abnormally\n";
  exit;
}
my %VisibleToFiles;
Query("FindVisibleToFiles")->RunQuery(sub{
  my($row) = @_;
  my $file_id = $row->[0];
  $VisibleToFiles{$file_id} = 1;
}, sub{}, $subproc_invoc_id);

my %HiddenToFiles;
Query("FindHiddenToFiles")->RunQuery(sub{
  my($row) = @_;
  my $file_id = $row->[0];
  $HiddenToFiles{$file_id} = 1;
}, sub{}, $subproc_invoc_id);

my %VisibleFilesInTimepoint;
Query("VisibleFilesInTimepoint")->RunQuery(sub{
  my($row) = @_;
  my $file_id = $row->[0];
  $VisibleFilesInTimepoint{$file_id} = 1;
}, sub{}, $act_tp_id);

my %HiddenFilesInTimepoint;
Query("HiddenFilesInTimepoint")->RunQuery(sub{
  my($row) = @_;
  my $file_id = $row->[0];
  $HiddenFilesInTimepoint{$file_id} = 1;
}, sub{}, $act_tp_id);

my $vis_in_tp = keys %VisibleFilesInTimepoint;
my $hid_in_tp = keys %HiddenFilesInTimepoint;
my $vis_to = keys %VisibleToFiles;
my $hid_to = keys %HiddenToFiles;

print "Visible in timepoint $act_tp_id: $vis_in_tp\n";
print "Hidden in timepoint $act_tp_id: $hid_in_tp\n";
print "Visible in edit $subproc_invoc_id: $vis_to\n";
print "Hidden in edit $subproc_invoc_id: $hid_to\n";
print "Going to background to process\n";

my $bk = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
print "Entering Background\n";
$bk->Daemonize;

$bk->SetActivityStatus("Unhiding $hid_to files in edit $subproc_invoc_id\n");
if($hid_to > 0){
  my $start = time;
  open HIDE,
    "|UnhideFilesWithStatus.pl $notify \"Unhiding to files " .
    "in dicom_edit_compare($subproc_invoc_id)\"";
  for my $file_id (keys %HiddenToFiles){
    print HIDE "$file_id&hidden\n";
  }
  close HIDE;
  my $elapsed = time - $start;
  $bk->WriteToEmail("Unhid $hid_to to files in: $elapsed seconds\n");
}

$bk->SetActivityStatus("Creating Activity Timepoint");
my $cre = Query("CreateActivityTimepoint");
$cre->RunQuery(sub {}, sub {},
  $act_id, $0, "From old tp $act_tp_id and edit $subproc_invoc_id", $notify);
my $new_tp;
my $gid = Query("GetActivityTimepointId");
$gid->RunQuery(sub {
  my($row) = @_;
  $new_tp = $row->[0];
}, sub{});
unless(defined $new_tp){
  $bk->WriteToEmail("Unable to get activity timepoint id.\n");
  $bk->Finish("Error: Failed to create timepoint");
  exit;
}
$bk->WriteToEmail("Old Activity Timepoint Id: $act_tp_id, New timepoint: $new_tp\n");

{
  my $start = time;
  $bk->SetActivityStatus("Inserting files into timepoint $new_tp");
  my $ins_file = Query("InsertActivityTimepointFile");
  for my $file_id (keys %HiddenToFiles){
    $ins_file->RunQuery(sub{}, sub{}, $new_tp, $file_id);
  }
  for my $file_id (keys %VisibleToFiles){
    $ins_file->RunQuery(sub{}, sub{}, $new_tp, $file_id);
  }
  for my $file_id (keys %VisibleFilesInTimepoint){
    $ins_file->RunQuery(sub{}, sub{}, $new_tp, $file_id);
  }
  my $tot_inserted = $hid_to + $vis_to + $vis_in_tp;
  my $elapsed = time - $start;
  $bk->WriteToEmail("inserted $tot_inserted file into timepoint $new_tp in $elapsed seconds");
}

$bk->SetActivityStatus("Preparing timepoint creation report");
$bk->PrepareBackgroundReportBasedOnQuery(
  "TimepointCreationReport", 
  "Timepoint Creation Report (activity_id $act_id, old tp: $act_tp_id, tp_id $new_tp)",
  1000, $new_tp);
$bk->Finish("Created new activity_timpoint id = $new_tp");
