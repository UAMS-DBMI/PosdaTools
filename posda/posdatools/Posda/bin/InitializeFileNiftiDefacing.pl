#!/usr/bin/perl -w use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Nifti::Parser;
use Posda::DefacingSubmit;
use Debug;
my $dbg = sub { print STDERR @_ };

my $usage = <<EOF;
Usage:
InitializeFileNiftiDefacing.pl <?bkgrnd_id?> <activity_id> <notify>
  or
InitializeFileNiftiDefacing.pl -h

Expects lines on STDIN:
<nifti_file_id>

Uses following named queries:
  InFileNifti(file_id) returning(count)
  InFileNiftiDefacing(file_id) returning(count)
  InsertFileNiftiDefacing(file_id) returning(id)
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }

unless($#ARGV == 2) { print $usage; exit }

my($invoc_id, $activity_id, $notify) = @ARGV;

my %FileIds;
for my $line(<STDIN>){
  chomp $line;
  $FileIds{$line} = 1;
}
my $num_nifti_files = keys %FileIds;
print "Going to background to process $num_nifti_files file_ids\n";

my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;
my $start = time;
my $in_fn = Query('InFileNifti');
my $in_fnd = Query('InFileNiftiDefacing');
my $c_fnd = Query('InsertFileNiftiDefacing');
my $current = 0;
my $num_already_queued = 0;
my $num_not_nifti = 0;
my $num_inserted = 0;
my $num_errors = 0;
file:
for my $f (keys %FileIds){
  $current += 1;
  $back->SetActivityStatus("Processing $current of $num_nifti_files");
  if($in_fn->FetchOneHash($f)->{count} == 0){
    $num_not_nifti += 1;
    next file;
  }
  if($in_fnd->FetchOneHash($f)->{count} != 0){
    $num_already_queued += 1;
    next file;
  }
  my $fnd_id = $c_fnd->FetchOneHash($f, $invoc_id)->{id};
  unless(defined $fnd_id){
    $num_errors += 1;
    next file;
  }
  Posda::DefacingSubmit::AddToDefacingQueue($fnd_id, $f);
  $num_inserted += 1;
}
my $elapsed = time - $start;
$back->WriteToEmail("Processed $num_nifti_files files in $elapsed seconds.\n" .
  "$num_inserted rows were created in nifti_file_defacing\n" .
  "$num_already_queued already had a row in nifti_file_defacing\n" .
  "$num_not_nifti did not have a row in file_nifti\n" .
  "$num_errors failed to insert into nifti_file_defacing\n"
);
$back->Finish("Processed $current of $num_nifti_files");
