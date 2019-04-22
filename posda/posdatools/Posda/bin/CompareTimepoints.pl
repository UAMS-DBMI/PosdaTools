#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
CompareTimepoints.pl <?bkgrnd_id?> <activity_id> <from_timepoint_id> <to_timepoint_id> <notify>
or 
CompareTimepoints.pl -h

Expects no input on STDIN
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage; exit;
}
unless($#ARGV == 4){
  my $num_args = @ARGV;
  print "Wrong number of args ($num_args vs 5)\n";
  print $usage;
  exit;
}
my($invoc_id, $act_id, $from_tp, $to_tp, $notify) = @ARGV;
print "Going to background to compare time points for activity $act_id\n" ,
  "from:   $from_tp\n" .
  "  to:   $to_tp\n" .
  "notify: $notify\n";
print "(Background part just a stub for now)\n";
my $back = Posda::BackgroundProcess->new($invoc_id, $notify);
$back->Daemonize;
$back->WriteToEmail("In background to compare time points for activity $act_id\n" ,
  "from:   $from_tp\n" .
  "  to:   $to_tp\n" .
  "notify: $notify\n");
$back->WriteToEmail("(Background part just a stub for now)\n");
$back->Finish;
