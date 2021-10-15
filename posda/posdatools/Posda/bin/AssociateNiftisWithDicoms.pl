#!/usr/bin/perl -w
use strict;
use Posda::BackgroundProcess;
my $usage = <<EOF;
AssociateNiftisWithDicoms.pl <?bkgrnd_id?> <activity_id> <notify>

Expects lines of the following format on STDIN:
<activity_timepoint_id>&<nifti_file_id>&<series_instance_uid>

Invokes
RelateDicomToNifti.pl <activity_timepoint_id <nifti_file_id> <series_instance_uid>
for each line.

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
my $num_args = @ARGV;
unless($num_args == 3){
  die "Wrong number of args ($num_args vs 3)";
}
my($invoc_id, $activity_id, $notify) = @ARGV;
my @Commands;
while (my $line = <STDIN>){
  chomp $line;
  my($atp_id, $nf_id, $series) = split(/&/, $line);
  my $cmd = "RelateDicomToNifti.pl $atp_id $nf_id $series";
  push @Commands, $cmd;
}
my $num_cmds = @Commands;
print "Going to background to process $num_cmds commands\n";
my $b = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$b->Daemonize;
open COMMAND, "|/bin/sh" or die "Can't open subshell";
for my $c (@Commands){
  print COMMAND "$c\n";
}
close COMMAND;
$b->Finish("queued $num_cmds");
