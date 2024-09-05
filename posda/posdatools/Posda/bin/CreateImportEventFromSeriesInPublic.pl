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
/CreateImportEventFromSeriesInPublic.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>
  or
/CreateImportEventFromSeriesInPublic.pl -h
Expects lines on STDIN:
<series_instance_uid>
...
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }

unless($#ARGV == 3) { print $usage; exit }

my($invoc_id, $act_id, $comment, $notify) = @ARGV;
my $import_description =
  "ImportBased on CreateImportEventFromSeriesInPublic.pl $invoc_id $act_id '$comment' $notify";
my $start = time;
my %Series;
while (my $line = <STDIN>){
  chomp $line;
  $Series{$line} = 1;
}
my $tot_series = keys %Series;

#############################
# This is code which sets up the Background Process and Starts it
my $forground_time = time - $start;
print "Going to background to create timepoint after $forground_time seconds\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
$background->Daemonize;
my %Files;
my $num_series = 0;
my $q = Query("PublicFilesInSeries");
for my $series (keys %Series){
  $num_series += 1;
  $q->RunQuery(sub{
    my($row) = @_;
    my $file = $row->[0];
    if(-f $file){
      $Files{$file} = 1;
    } elsif(
       $file =~ /^\/usr\/local\/apps\/ncia\/CTP-server\/CTP\/storage(.*)$/
    ){
      $file = "/nas/public/storage$1";
      if(-f $file){
        $Files{$file} = 1;
      } else {
        $background->WriteToEmail("$file doesn't exist\n");
      }
    } else {
      $background->WriteToEmail("$file doesn't exist\n");
    }
  }, sub {}, $series);
  my $num_files = keys %Files;
  $background->SetActivityStatus("Scanned $num_series series, found $num_files files");
}
my @FilesToImport = keys %Files;
my $TotalFilesToImport = @FilesToImport;
$background->WriteToEmail("Found $TotalFilesToImport in $num_series Series in Public\n");
#################
# Import Loop
# Imports all files in @FilesToImport
# metering to insure files are only inserted when < $max_queue_for_start files waiting
# inserts $number_to_queue per batch
my $max_queue_for_start = 500;
my $number_to_queue = 100;

my $get_queue_size = Query("GetPosdaQueueSize");
my $total_sleep_time = 0;
my $sleep_time = 0;
my $import_start_time = time;
open IMPORT, "|ImportMultipleFilesIntoPosda.pl \"$import_description\"";
my $files_queued = 0;
import_loop:
while(1){
  my $num_files = @FilesToImport;
  #print STDERR "At top of import_loop\n";
  my $queue_size;
  $get_queue_size->RunQuery(sub{
    my($row) = @_;
    $queue_size = $row->[0];
  }, sub {});
  if($queue_size > $max_queue_for_start) {
    my $remaining = @FilesToImport;
    $background->SetActivityStatus("Throttling Import Queue");
    print STDERR "(Sleep 10) qs: $queue_size, rem: $remaining\n";
    sleep 10;
    $sleep_time += 10;
    next import_loop;
  }
  if($sleep_time > 0){
    $total_sleep_time += $sleep_time;
    print STDERR "sleep time this iteration: $sleep_time\n";
    $sleep_time = 0;
  }
  $background->SetActivityStatus("Queuing files for import ($files_queued queued, $num_files remaining)");
  for my $i (0 .. $number_to_queue - 1){
    my $files_remaining = @FilesToImport;
    if($files_remaining <= 0){ last import_loop }
    my $file = shift @FilesToImport;
    print IMPORT "$file\n";
    $files_queued += 1;
  }
}
$background->WriteToEmail("$files_queued files written to sub process ImportMultipleFilesIntoPosda.pl \"$import_description\"\n");
#print STDERR "No files left to import\n";
$background->SetActivityStatus("All files queued - waiting to clear");
# End Import Loop
#################
my $end_import_time = time;
my $elapsed_in_import = $end_import_time - $import_start_time;
$background->SetActivityStatus("Waiting for imports to clear");
$background->WriteToEmail("Total time spent in import: $elapsed_in_import (" .
#print STDERR "No files left to import\n";
$background->SetActivityStatus("All files queued - waiting to clear");
# End Import Loop
#################
my $end_import_time = time;
my $elapsed_in_import = $end_import_time - $import_start_time;
$background->SetActivityStatus("Waiting for imports to clear");
$background->WriteToEmail("Total time spent in import: $elapsed_in_import (" .
  "$total_sleep_time waiting on backlog)\n");
close IMPORT;
my $close_time = time;
my $wait_on_close = $close_time - $end_import_time;
$background->WriteToEmail("$wait_on_close waiting for import to clear\n");
$background->WriteToEmail("################################\n" .
  "Files imported to event named: $import_description\n" .
  "################################\n" .
  "Import Events with this name:\n");
Query('GetImportEventIdByImportName')->RunQuery(sub{
  my($row) = @_;
  my($id, $import_time, $duration, $num_files) = @$row;
  $background->WriteToEmail("$id\t$import_time\t$duration\t$num_files\n");
}, sub {}, $import_description);
$background->WriteToEmail("################################\n");

$background->Finish("Done - see email for status");
