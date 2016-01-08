#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/dclunie/ParseDD_file.pl,v $
#$Date: 2009/08/29 16:14:12 $
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
my $list = [];
for my $file (@ARGV){
  Posda::Dclunie::parse_dict_file($file, $list);
}
my $hash = Posda::Dclunie::dd_to_keywordhash($list);
print "results: ";
Debug::GenPrint($dbg, $hash, 1, $depth);
print "\n";
