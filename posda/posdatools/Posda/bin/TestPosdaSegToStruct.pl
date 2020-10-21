#!/usr/bin/perl -w
use strict;
use Posda::SegToStruct;
use Debug;
my $dbg = sub { print @_ };

my $s2s = Posda::SegToStruct->new($ARGV[0]);

print "Parsed Seg: ";
Debug::GenPrint($dbg, $s2s, 1);
print "\n";
