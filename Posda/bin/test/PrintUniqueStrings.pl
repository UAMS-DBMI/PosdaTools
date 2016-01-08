#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/PrintUniqueStrings.pl,v $
#$Date: 2014/05/13 20:18:24 $
#$Revision: 1.1 $
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Storable qw( fd_retrieve);
my $file = $ARGV[0];
my $string = $ARGV[1];
open FILE, "<$file" or die "can't open $file";
my $struct = fd_retrieve(*FILE);
for my $key (sort keys %$struct){
  print "$key\n";
}
