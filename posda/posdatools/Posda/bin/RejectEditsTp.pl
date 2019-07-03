#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Digest::MD5;
use Posda::BackgroundProcess;
use File::Path 'rmtree';

my $usage = <<EOF;
RejectEditsTp.pl <bkgrnd_id> <activity_id> <sub_invoc_id> <notify>
or
RejectEditsTp.pl -h

The script doesn't expect lines on STDIN:

It does the following before entering background:
  1) It checks the status of the dicom_edit_compare_disposition row with
     that sub_invoc_id.  Unless it is "Comparisons Complete", print an
     error and exit.
     Query: "StartTransactionPosda"
     Query: "LockDicomEditCompareDisposition"
     Query: "GetDicomEditCompareDisposition".
     Query: "EndTransactionPosda"
  1.5) Update the disposition to "Rejection/Deletion In Progress"
     Query: "UpdateDicomEditCompareDispositionStatus"
     Query: "EndTransaction"
  2) Make a list of all of the "to" file paths.

Then it drops into the background to delete files and directory.

It uses the rmtree operation from File::Path to delete the directory.

Then it will update the status of dicom_edit_compare_disposition to
"Rejection Complete - to files deleted".

Then it is done.
EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 3){
  my $num_args = $#ARGV;
  print "Error: wrong number of args ($num_args) vs 2:\n";
  print "$usage\n";
  die "$usage\n";
}

my ($invoc_id, $activity_id, $subproc_invoc_id, $notify) = @ARGV;

my $get_decd = Query("GetDicomEditCompareDisposition");
my $start_trans = Query("StartTransactionPosda");
my $end_trans = Query("EndTransactionPosda");
my $loc_decd = Query("LockDicomEditCompareDisposition");
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
  print "Error: status is \"$status\".\nInappropriate for rejection\n";
  exit;
}
my $upd_decd = Query("UpdateDicomEditCompareDispositionStatus");
$upd_decd->RunQuery(sub{}, sub{}, "Rejection/Deletion In Progress",
   $subproc_invoc_id);
$end_trans->RunQuery(sub{}, sub{});

my @ToFileList;
my $get_to = Query("GetDicomEditCompareToFiles");
$get_to->RunQuery(sub {
  my($row) = @_;
  my($path, $file_id, $proj_name, $visibility) = @$row;
  push @ToFileList, $path;
}, sub {}, $subproc_invoc_id);
my $num_to_files = @ToFileList;
print "To Delete -\n" .
  "Directory: $DestDir\n" .
  "Files: $num_to_files\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
print "Entering Background\n";
$background->Daemonize;

my $start_time = `date`;
chomp $start_time;
my $start = time;
$background->WriteToEmail("Starting\n" .
  "RejectEdits.pl \"$invoc_id\" \"$subproc_invoc_id\" \"$notify\"\n" .
  "at $start_time\n");
$background->SetActivityStatus("deleting $num_to_files files");
$background->WriteToEmail("To Delete -\n" .
  "Directory: $DestDir\n" .
  "Files: $num_to_files\n");
rmtree($DestDir);
my $elapsed = time - $start;
$background->WriteToEmail("Deleted directory and $num_to_files in " .
  "$elapsed seconds\n");
my $upd = Query("UpdateDicomEditCompareDispositionStatus");
$upd->RunQuery(sub{}, sub{}, "Rejection Complete - to files deleted",
   $subproc_invoc_id);

$background->Finish("Deleted $num_to_files temporary files");;
