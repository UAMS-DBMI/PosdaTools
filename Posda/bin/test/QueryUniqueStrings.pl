#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/QueryUniqueStrings.pl,v $
#$Date: 2014/04/11 14:49:49 $
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
  if($key =~ /$string/){
    print "matching string: $key\n";
    for my $f (sort keys %{$struct->{$key}}){
      print "\t$f\n";
      for my $ele (sort keys %{$struct->{$key}->{$f}}){
        print "\t\t$ele\n";
      }
    }
  }
}
