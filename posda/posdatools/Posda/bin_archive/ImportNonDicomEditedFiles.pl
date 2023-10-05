#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Digest::MD5;
use Posda::BackgroundProcess;
use File::Path 'rmtree';

my $usage = <<EOF;
ImportNonDicomEdits.pl <bkgrnd_id> <sub_invoc_id> <notify>
or
ImportNonDicomEdits.pl -h

The script doesn't expect lines on STDIN:

It does the following before entering background:
  1) It checks the status of the non_dicom_edit_compare_disposition row with
     that sub_invoc_id.  Unless it is "Comparisons Complete", print an
     error and exit.
     Query: "StartTransactionPosda"
     Query: "LockNonDicomEditCompareDisposition"
     Query: "GetNonDicomEditCompareDisposition".
     Query: "EndTransactionPosda"
  1.5) Update the disposition to "Import In Progress"
     Query: "UpdateNonDicomEditCompareDispositionStatus"
     Query: "EndTransactionPosda"
  2) Make the following lists:
     a) A list of the files which are "from" files in dicom_edit_compare which
        are visible in the database with their current visibility.
        Query: "GetNonDicomEditCompareFromFiles"
     b) A list of the files which are "to" files in dicom_edit_compare.  With
        these files, get path, a file_id (if available), 
        Query: "GetNonDicomEditCompareToFiles"
  3) The file_ids which occur only in the "from" files are to be hidden.
  5) If there are files which are in both the "from" and "to" files,
     This is an abnormal occurance and should be noted in the email and the
     invocation response. 
     These files need to be visible.
  6) Any files in the "to" list which have file_ids and are not visible need
     to be made visible.  This is also an abnormal occurance, and should be 
     noted in email and the invocation response.
  7) The files in the "to" list which do not have file_ids need to be imported.
Then it drops into the background to actually do any hides and make visible,
and import operations.
It uses the following sub scripts:
  HideNonDicomFilesWithStatus.pl to hide files
  UnHideNonDicomFilesWithStatus.pl to unhide files are hidden and need to
     to not be.
  ImportMultipleFilesIntoPosda.pl to import new files into Posda.
  
These operations are done in the following order:
  1) Hide files which need to be hidden
  2) Unhide files which are hidden and shouldn't be
  4) Import new files

Importing files into Posda is throttled by only writing files to the subprocess
when there are fewer than 100 files waiting to be processed processed in Posda.
100 files are written in a batch.
Query: GetPosdaQueueSize

When the file handle to ImportMultiple files in Posda closes (i.e all files have
been imported), this script will get the maximum file_id and then wait until that
file has been processed before it exits.  This will insure that all imported
files have been processed.
Query: GetMaxFileId
Query: GetMaxProcessedFileId

Finally, it will insure that all of the "to" files are imported, and visible, 
and have a location distinct from the path in dicom_edit_compare, 
and that all of the "from" files are hidden (except those that are also 
"to" files (note exception)).

Then it will update the status of dicom_edit_compare_disposition to 
"Import Complete - deleting from files".
Then it will delete all the "from" files (and the directory in which they 
reside).  It will use "rmtree" from File::Path to do this.

Then it will update the status of dicom_edit_compare_disposition to
"Import Complete - from files deleted".

Then it is done.
EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 2){
  my $num_args = $#ARGV;
  print "Error: wrong number of args ($num_args) vs 2:\n";
  print "$usage\n";
  die "$usage\n";
}

my ($invoc_id, $subproc_invoc_id, $notify) = @ARGV;

my $get_decd = Query("GetNonDicomEditCompareDisposition");
my $start_trans = Query("StartTransactionPosda");
my $end_trans = Query("EndTransactionPosda");
my $loc_decd = Query("LockNonDicomEditCompareDisposition");
my $status;
my $DestDir;
$start_trans->RunQuery(sub{}, sub{});
$loc_decd->RunQuery(sub{}, sub{});
$get_decd->RunQuery(sub {
  my($row) = @_;
  my($num_sched, $num_ok, $num_failed, $current_disp, $dest_dir) = @$row;
  $status = $current_disp;
  $DestDir = $dest_dir;
}, sub{}, $subproc_invoc_id);
unless($status eq "Comparisons Complete"){
  $end_trans->RunQuery(sub{}, sub{});
  print "Error: status is \"$status\".\nInappropriate for import\n";
  exit;
}
my $upd_decd = Query("UpdateNonDicomEditCompareDispositionStatus");
$upd_decd->RunQuery(sub{}, sub{}, "Import In Progress", $subproc_invoc_id);
$end_trans->RunQuery(sub{}, sub{});

my $get_from = Query("GetNonDicomEditCompareFromFiles"); my %FromFiles;
$get_from->RunQuery(sub {
  my($row) = @_;
  my($file_id, $proj_name, $visibility) = @$row;
  $FromFiles{$file_id} = [$proj_name, $visibility];
}, sub {}, $subproc_invoc_id);
my $get_to = Query("GetNonDicomEditCompareToFiles");
my %FilesBothFromAndTo;
my %FromFilesToHide;
my %FromFilesAlreadyHidden;
my %ToFilesToUnhide;
my %ToFilesToImport;
$get_to->RunQuery(sub {
  my($row) = @_;
  my($path, $file_id, $proj_name, $visibility) = @$row;
  if(defined($file_id)){
    if(exists $FromFiles{$file_id}){
      print "Warning: $file_id is in both From and To files\n";
      $FilesBothFromAndTo{$file_id} = $FromFiles{$file_id};
      delete $FromFiles{$file_id};
    } else {
      if(defined $visibility){
        print "Warning: to_file $file_id already exists\n";
        $ToFilesToUnhide{$file_id} = [$proj_name, $visibility];
      }
    }
  } else {
     $ToFilesToImport{$path} = 1;
  }
}, sub {}, $subproc_invoc_id);
my $num_from_files = keys %FromFiles;
#Analyze files, build lists report abnormals, etc;
for my $file_id (keys %FromFiles){
  my($proj_name, $visibility) = @{$FromFiles{$file_id}};
  if(defined $visibility){
    print "Warning: from_file $file_id is already hidden\n";
    $FromFilesAlreadyHidden{$file_id} = $FromFiles{$file_id};
  } else {
    $FromFilesToHide{$file_id} = $FromFiles{$file_id};
  }
  delete $FromFiles{$file_id};
}
my $num_from_files_to_hide = keys %FromFilesToHide;
my $num_from_files_already_hidden = keys %FromFilesAlreadyHidden;
my $num_files_both_from_and_to = keys %FilesBothFromAndTo;
my $num_files_already_imported_to_unhide = 
  keys %ToFilesToUnhide;
my $num_to_files_to_unhide = keys %ToFilesToUnhide;
my $num_to_files_to_import = keys %ToFilesToImport;
print "From files  to hide: $num_from_files_to_hide\n" .
  "From files already hidden: $num_from_files_already_hidden\n" .
  "Files in both from and to: $num_files_both_from_and_to\n" .
  "To files already imported (to unhide): " .
  "$num_files_already_imported_to_unhide\n" .
  "To files to import: $num_to_files_to_import\n";

#print "Not Entering background\n";
#exit;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
my @FilesToImport = keys %ToFilesToImport;

print "Entering Background\n";

$background->Daemonize;

my $start_time = `date`;
chomp $start_time;
$background->WriteToEmail("Starting:\n" .
  "ImportNonDicomEditedFiles.pl \"$invoc_id\" \"$subproc_invoc_id\" \"$notify\"\n" .
  "at $start_time\n");
print STDERR "Starting ImportNonDicomEditedFiles.pl at $start_time\n";
#hide files 
if($num_from_files_to_hide > 0){
  $background->WriteToEmail(
    "Hiding $num_from_files_to_hide from files\n");
  my $start = time;
  open HIDE, "|HideNonDicomFilesWithStatus.pl $notify \"Hiding from files " .
    "in non_dicom_edit_compare($subproc_invoc_id)\"";
  for my $file_id (keys %FromFilesToHide){
    my($proj_name, $visibility) = @{$FromFilesToHide{$file_id}};
    unless(defined $visibility) { $visibility = "<undef>" }
    print HIDE "$file_id&$visibility\n";
  }
  close HIDE;
  my $elapsed = time - $start;
  $background->WriteToEmail("Duration of hide: $elapsed seconds\n");
}
if($num_files_already_imported_to_unhide > 0){
  $background->WriteToEmail(
    "Unhiding $num_files_already_imported_to_unhide files\n");
  my $start = time;
  open HIDE, "|UnHideNonDicomFilesWithStatus.pl $notify \"Unhiding from files " .
    "in non_dicom_edit_compare($subproc_invoc_id)\"";
  for my $file_id (keys %ToFilesToUnhide){
    my($proj_name, $visibility) = @{$ToFilesToUnhide{$file_id}};
    unless(defined $visibility) { $visibility = "<undef>" }
    print HIDE "$file_id&$visibility\n";
  }
  close HIDE;
  my $elapsed = time - $start;
  $background->WriteToEmail("Duration of unhide: $elapsed seconds\n");
}
##TODO
#Make reports for abnormals
##end TODO

#################
# Import Loop
# Imports all files in @FilesToImport
# metering to insure files are only inserted when < 100 files waiting 
# inserts 20 per batch
my $max_queue_for_start = 100;
my $number_to_queue = 20;
my $get_queue_size = Query("GetPosdaQueueSize");
my $total_sleep_time = 0;
my $sleep_time = 0;
my $import_start_time = time;
open IMPORT, "|ImportMultipleFilesIntoPosda.pl " .
  "\"Import based on dicom_edit_compare_disposition $subproc_invoc_id\"";
import_loop:
while(1){
  #print STDERR "At top of import_loop\n";
  my $queue_size;
  $get_queue_size->RunQuery(sub{
    my($row) = @_;
    $queue_size = $row->[0];
  }, sub {});
  if($queue_size > $max_queue_for_start) {
    print STDERR "Sleeping 10: queue_size $queue_size\n";
    sleep 10;
    $sleep_time += 10;
    next import_loop;
  }
  if($sleep_time > 0){
    $total_sleep_time += $sleep_time;
    print STDERR "sleep time this iteration: $sleep_time\n";
    $sleep_time = 0;
  }
  for my $i (0 .. $number_to_queue - 1){
    my $files_remaining = @FilesToImport;
    if($files_remaining <= 0){ last import_loop }
    my $file = shift @FilesToImport;
    print IMPORT "$file\n";
  }
}
print STDERR "No files left to import\n";
my $end_import_time = time;
my $elapsed_in_import = $end_import_time - $import_start_time;
$background->WriteToEmail("Total time spent in import: $elapsed_in_import (" .
  "$total_sleep_time waiting on backlog)\n");
close IMPORT;
my $close_time = time;
my $wait_on_close = $close_time - $end_import_time;
$background->WriteToEmail("$wait_on_close waiting for import to clear\n");
my $max_file_id;
my $max_imported_file_id;
my $get_max = Query("GetMaxFileId");
my $get_max_processed = Query("GetMaxProcessedFileId");
$get_max->RunQuery(sub {
  my($row) = @_;
  $max_file_id = $row->[0];
}, sub {});
$get_max_processed->RunQuery(sub {
  my($row) = @_;
  $max_imported_file_id = $row->[0];
}, sub {});
while($max_file_id > $max_imported_file_id){
  sleep 10;
  $get_max_processed->RunQuery(sub {
    my($row) = @_;
    $max_imported_file_id = $row->[0];
  }, sub {});
}
my $process_wait_time = time - $close_time;
$background->WriteToEmail("Waited $process_wait_time for " .
  "import processing to clear\n");
##TODO
#Check all "to" files imported OK and visible
#Check All "from" files are hidden
##end TODO
#Delete directory
my $start_delete = time;
$background->WriteToEmail("To Delete -\n" .
  "Directory: $DestDir\n" .
  "Files: $num_to_files_to_import\n");
rmtree($DestDir);
my $elapsed_in_delete = time - $start_delete;
$background->WriteToEmail("Deleted directory and $num_to_files_to_import in " .
  "$elapsed_in_delete seconds\n");
#Update status of dicom_edit_compare_disposition
my $upd = Query("UpdateNonDicomEditCompareDispositionStatus");
$upd->RunQuery(sub{}, sub{}, "Import Complete - to files deleted",
   $subproc_invoc_id);
