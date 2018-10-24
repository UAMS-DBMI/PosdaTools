#!/usr/bin/perl -w
use strict;
my $usage = "AddGroup13.pl <source> <dest> <project> <site> <id>";
unless ($#ARGV == 4) { die $usage }
print "ChangeDicomElements.pl '$ARGV[0]' '$ARGV[1]' " .
  "'(0013,\"CTP\",10)' '$ARGV[2]' " .
  "'(0013,\"CTP\",11)' '$ARGV[2]' " .
  "'(0013,\"CTP\",12)' '$ARGV[3]' " .
  "'(0013,\"CTP\",13)' '$ARGV[4]'\n";
