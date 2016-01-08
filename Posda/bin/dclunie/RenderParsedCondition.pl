#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/dclunie/RenderParsedCondition.pl,v $
#$Date: 2009/09/14 15:14:50 $
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
unless($#ARGV == 1 || $#ARGV == 2){
  die "usage: RenderParsedCondition.pl <file_name> <condition> [<depth>]\n"
}
my $dbg = sub {print @_};
my $cond_file = $ARGV[0];
my $cond_name = $ARGV[1];
my $depth = 3;
if(defined $ARGV[2]) { $depth = $ARGV[2] }
my $condn = Posda::Dclunie::parse_condn_file("$cond_file");

print "$cond_name: ";
Debug::GenPrint($dbg, $condn->{$cond_name}, 1, $depth);
print "\n";
