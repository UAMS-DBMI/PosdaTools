#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/RtogTextToNum.pl,v $
#$Date: 2010/03/24 18:48:28 $
#$Revision: 1.1 $
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
while(my $line = <STDIN>){
  chomp $line;
  $line =~ s/\0//g;
  $line =~ s/\r//;
  if($line =~ /^\s*\"[^\"]+\"\s*(.*)\s*$/){
    $line = $1;
  }
  my @fields = split(/\s+/, $line);
  for my $i (@fields){
    if($i =~ /^(.*),$/){
      $i = $1;
    }
    if($i =~ /^\s*$/) { next }
    print "$i\n";
  }
}
