#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Digest::MD5;
use Posda::BackgroundProcess;

my $usage = <<EOF;
ImportEditedFilesFromDicomEditCompare.pl <bkgrnd_id> <sub_invoc_id> <file_per_round> <max_queue_size> <notify>
or
ImportEditedFilesFromDicomEditCompare.pl -h

The script doesn't expect lines on STDIN:

It imports edited files as specified in dicom_edit_compare table, using
the query "GetFilesToImportFromEdit".

This query select rows in dicom_edit_compare for which:
  1) the from file hasn't been hidden, and
  2) the to file hasn't been imported.

This script waits until the number of files waiting in posda is < max_queue_size
Then it selects files to be imported with a limit of files_per_round, and
import the to files, hiding the from files.

Uses "ImportMultipleFilesIntoPosda.pl" to import the files
Uses "StreamHideFilesWithStatus.pl to hide the old files

It repeats this until there are no more files to edit in the dicom_edit_compare table
EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 4){
  die "$usage\n";
}

my ($invoc_id, $edit_file_id, $files_per_round, $max_queue_for_start, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

print "Entering Background\n";

$background->ForkAndExit;

my $start_time = `date`;
chomp $start_time;
$background->WriteToEmail("Starting ImportEditedFilesFromDicomEditCompare.pl at $start_time\n");
$background->WriteToReport("Starting ImportEditedFilesFromDicomEditCompare.pl at $start_time\n");
print STDERR "Starting ImportEditedFilesFromDicomEditCompare.pl at $start_time\n";
close STDOUT;
close STDIN;
my $get_queue_size = Query("GetPosdaQueueSize");
my $get_import_list = Query("GetFilesToImportFromEdit");
my $sleep_time = 0;
import_loop:
while(1){
  print STDERR "At top of import_loop\n";
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
    print STDERR "Total sleep time $sleep_time\n";
    $sleep_time = 0;
  }
  print STDERR "Queue size ($queue_size) <= $max_queue_for_start\n";
  print STDERR "Querying for files to import\n";
  my @list;
  $get_import_list->RunQuery(sub {
    my($row) = @_;
    my $from_file_digest = $row->[1];
    my $to_file_digest = $row->[2];
    my $to_file_path = $row->[3];
    push(@list, [$to_file_path, $from_file_digest]);
  }, sub {}, $edit_file_id, $edit_file_id, $edit_file_id, $files_per_round);
  my $num_to_import = @list;
  if($num_to_import <= 0){ last import_loop }
  print STDERR "Found $num_to_import files to import this round\n";
  my $start = time;
  open IMPORT, "|ImportMultipleFilesIntoPosda.pl \"Import based on edit $edit_file_id\"";
  {
    my $ofh = select IMPORT;
    $| = 1;
    select $ofh;
  }
  open HIDE, "|StreamHideFilesWithStatus.pl \"$notify\" \"Edit: $edit_file_id\"";
  {
    my $ofh = select HIDE;
    $| = 1;
    select $ofh;
  }
  for my $f (@list){
    print IMPORT "$f->[0]\n";
    print HIDE "$f->[1]\n";
  }
  print IMPORT "fubar\n";
  print HIDE "fubar\n";
  my $till_queueing_done = time - $start;
  print STDERR "Pipe-ing $num_to_import files done after $till_queueing_done\n";
  print STDERR "Closing IMPORT pipe\n";
  close IMPORT;
  my $after_queue_cleared = time - $start;
  print STDERR "Import Pipe cleared after $after_queue_cleared\n";
  print STDERR "Closing HIDE pipe\n";
  close HIDE;
  $after_queue_cleared = time - $start;
  print STDERR "Hide Pipe cleared after $after_queue_cleared\n";
}
print STDERR "No files left to import\n";
my $link = $background->GetReportDownloadableURL;
$background->WriteToEmail("Report URL: $link\n");
$background->LogCompletionTime;
