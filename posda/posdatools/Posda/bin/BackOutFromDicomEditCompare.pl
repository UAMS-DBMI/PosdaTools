#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Digest::MD5;
use Posda::BackgroundProcess;

my $usage = <<EOF;
BackOutFromDicomEditCompare.pl <bkgrnd_id> <sub_invoc_id> <user> <notify>
or
BackOutFromDicomEditCompare.pl -h

The script doesn't expect lines on STDIN:

It backs out the results of a prior "ImportEditedFilesFromDicomEditCompare.pl" 
command.

EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 3){
  die "$usage\n";
}

my ($this_invoc_id, $invoc_id, $user, $notify) = @ARGV;
my $get_digest_list = Query("FromDigestToDigestFromDicomEditCompare");
my $get_file_ids_and_visibilities = Query("FromAndToFileIdWithVisibilityFromDigests");
my @DigestsToChange;
$get_digest_list->RunQuery(sub {
  my($row) = @_;
  my($from_digest, $to_digest) = @$row;
  push @DigestsToChange, [$from_digest, $to_digest];
}, sub {}, $invoc_id);
my @CommandPairs;
pair:
for my $pair (@DigestsToChange){
  my $from_digest = $pair->[0];
  my $to_digest = $pair->[1];
  $get_file_ids_and_visibilities->RunQuery(sub {
    my($row) = @_;
    my($from_file_id, $to_file_id, $from_vis, $to_vis)
      = @$row;
    unless($from_vis == 'hidden'){
      print "Error: for {$from_file_id => $to_file_id}," .
        " from not hidden\n";
      next pair;
    }
    unless(!defined($to_vis)|| $to_vis eq '<undef>'){
      print "Error: for {$from_file_id => $to_file_id}," .
        " from not visible\n";
      next pair;
    }
    push(@CommandPairs, [
      "$from_file_id&hidden", "$to_file_id&<undef>" ]);
  }, sub {}, $from_digest, $to_digest, $from_digest, $to_digest);
}
my $num_commands =  @CommandPairs;
print "Found $num_commands Edits to back out\n";
print "invoc_id: $invoc_id\n";
print "user: $user\n";
print "notify $notify\n";
if($num_commands <= 0){
  print "Not entering background yet - nothing to do\n";
  exit;
}
####
#for my $pair (@CommandPairs){
#  print "Args to Unhide: $pair->[0], Args to Hide: $pair->[1]\n";
#}
#print "Not entering background yet - still debugging\n";
#exit;
####

my $background = Posda::BackgroundProcess->new($this_invoc_id, $notify);

print "Entering Background\n";

$background->ForkAndExit;

my $start_time = `date`;
chomp $start_time;
my $start = time;
$background->WriteToEmail("Starting BackOutFromDicomEditCompare.pl at $start_time\n");
open HIDE, "|HideFilesWithStatus.pl $user \"Backing out $invoc_id\"";
open UNHIDE, "|UnhideFilesWithStatus.pl $user \"Backing out $invoc_id\"";
my $num_changed = 0;
sop:
for my $pair(@CommandPairs){
  print UNHIDE "$pair->[0]\n";
  print HIDE "$pair->[1]\n";
  $num_changed += 1;
}
my $now = time;
my $elapsed = $now - $start;
$background->WriteToEmail("Changed $num_changed in $elapsed seconds\n");
close HIDE;
close UNHIDE;
my $later = time;
my $close_time = $later - $now;
$background->WriteToEmail("Subprocess close delay: $close_time seconds\n");
$background->Finish;
