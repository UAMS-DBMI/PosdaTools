#!/usr/bin/perl -w
use strict;
my $usage = <<EOF;
UnhideBatchSeriesWithStatus.pl <who> <reason>
  reads a list of series from STDIN
  runs UnhideSeriesWithStatus.pl <series> <who> "<reason>"
    as a sub-process for each.
  prints "Unhide status for series : <series>" on STDOUT for
    each series hidden

  Meant to be invoked as a table handler from DbIf
EOF
unless($#ARGV == 1) { die $usage }
my($who, $why) = @ARGV;
while(my $line = <STDIN>){
  chomp $line;
  print "Unhide status for series : $line\n";
  my $cmd ="UnhideSeriesWithStatus.pl $line $who \"$why\"";
  open CMD, "$cmd|" or die "can't open $cmd|";
  while(my $line = <CMD>) { print $line }
}
