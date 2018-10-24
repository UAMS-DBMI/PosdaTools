#!/usr/bin/perl -w
#
use Storable qw( fd_retrieve );
use Debug;
my $dbg = sub {print @_};
my $file = $ARGV[0];
open FILE, "<$file" or die "can't open $file";
my $struct = fd_retrieve(\*FILE);
print "Structure: ";
Debug::GenPrint($dbg, $struct, 1, $ARGV[1]);
print "\n";
