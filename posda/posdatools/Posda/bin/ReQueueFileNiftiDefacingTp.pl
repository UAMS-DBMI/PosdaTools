#!/usr/bin/perl -w use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Nifti::Parser;
use Posda::DefacingSubmit;
use Debug;
my $dbg = sub { print STDERR @_ };

my $usage = <<EOF;
Usage:
ReQueueFileNiftiDefacingTp.pl <?bkgrnd_id?> <activity_id> <notify>
  or
ReQueueFileNiftiDefacingTp.pl -h

Expects no lines on STDIN:

Uses following named queries:
  GetIncompleteNiftiDefacings(activity_id) returning(nifti_file_id, file_nifti_defacing_id)
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }

unless($#ARGV == 2) { print $usage; exit }

my($invoc_id, $activity_id, $notify) = @ARGV;

my %FileIds;
Query('GetIncompleteNiftiDefacings')->RunQuery(sub{
  my($row) = @_;
  my($file_id, $fnd_id) = @$row;
  $FileIds{$file_id} = $fnd_id;
}, sub{}, $activity_id);
my $num_nifti_files = keys %FileIds;
print "Going to background to process $num_nifti_files file_ids\n";

my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;
my $start = time;
file:
for my $f (keys %FileIds){
  my $fnd_id = $FileIds{$f};
  Posda::DefacingSubmit::AddToDefacingQueue($fnd_id, $f);
  $num_queued += 1;
}
my $elapsed = time - $start;
$back->WriteToEmail("Processed $num_nifti_files files in $elapsed seconds.\n" .
  "$num_queued were requeued for defacing\n");
$back->Finish("Processed $num_queued of $num_nifti_files");
