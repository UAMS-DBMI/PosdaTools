#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Digest::MD5;
use Posda::BackgroundProcess;
use File::Path 'rmtree';

my $usage = <<EOF;
SlowRoll.pl <?bkgrnd_id?> <activity_id> <notify>
or
SlowRoll.pl -h

The script doesn't expect lines on STDIN:

It doesn't do anything except sleep for 10 seconds 6 times, thereby
occupying space on a background processor for just about a minute.

While wasting a minute it does "SetActivityStatus" to update message 
before each sleep.

EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 2){
  my $num_args = $#ARGV;
  print "Error: wrong number of args ($num_args) vs 3:\n";
  print "$usage\n";
  die "$usage\n";
}

my ($invoc_id, $activity_id, $notify) = @ARGV;
my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
print "Entering Background\n";
$background->Daemonize;
print "Here is a message from the background\n";
print STDERR "Here is a error message from the background\n";
for my $i (0 .. 5){
  $background->SetActivityStatus("$i" . "'th 10 second wait");
  sleep 10;
}
$background->Finish("Done wasting a minute");
