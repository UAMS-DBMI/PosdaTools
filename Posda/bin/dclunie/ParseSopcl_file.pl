#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/dclunie/ParseSopcl_file.pl,v $
#$Date: 2009/09/14 15:13:18 $
#$Revision: 1.1 $
#
#Copyright 2009, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use strict;
use Posda::Dclunie;
use Debug;
my $dbg = sub {print @_};
my $depth = shift @ARGV;
my $hash = Posda::Dclunie::parse_sopcl_file($ARGV[0]);
print "results: ";
Debug::GenPrint($dbg, $hash, 1, $depth);
print "\n";
