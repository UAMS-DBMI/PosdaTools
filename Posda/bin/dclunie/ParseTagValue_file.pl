#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/dclunie/ParseTagValue_file.pl,v $
#$Date: 2009/09/14 15:14:07 $
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
my $file = shift @ARGV;
my $depth = shift @ARGV;
unless(defined $depth) {$depth = 3}
my $hash = Posda::Dclunie::parse_tagval_file($file);
print "results: ";
Debug::GenPrint($dbg, $hash, 1, $depth);
print "\n";
