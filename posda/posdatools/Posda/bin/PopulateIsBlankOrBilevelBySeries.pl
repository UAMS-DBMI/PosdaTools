#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
PopulateIsBlankOrBilevelBySeries.pl <?bkgrnd_id?> <notify>
  <?bkgrnd_id?> - id of row in subprocess_invocation table
  email sent to <notify>

Expects the following list on <STDIN>
  <series_instance_uid>
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 1){
  print $usage;
  exit;
}
my($invoc_id, $notify) = @ARGV;
my @Series;
while(my $line = <STDIN>){
  chomp $line;
  $Series{$line} = 1;
}
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

