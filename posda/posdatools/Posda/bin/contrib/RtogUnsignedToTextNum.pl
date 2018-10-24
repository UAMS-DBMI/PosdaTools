#!/usr/bin/perl -w
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use strict;
my $buff;
while((my $len = read(STDIN, $buff, 2048) > 0)){
  my @buff = unpack("s*", $buff);
  for my $n (@buff){
    print "$n\n";
  }
}
