#!/usr/bin/perl -w
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use strict;
while (my $line = <STDIN>){
  chomp $line;
  if($line =~ /^(.*)\.new/){
    print "mv $line $1\n";
  }
}
