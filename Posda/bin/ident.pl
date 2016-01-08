#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/ident.pl,v $
#$Date: 2014/04/24 19:31:36 $
#$Revision: 1.1 $
#
#Copyright 2014, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
my $file = $ARGV[0];
open FILE, "<$file" or die "can't open $file";
my $buff;
print "$file:\n";
outer:
while(read(FILE, $buff, 1) == 1){
  if($buff ne '$') { next }
  inner:
  while(read(FILE, $buff, 1, length($buff)) == 1){
#print "buff: \"$buff\"\n";
    if($buff =~ /^(\$[^:\$\n]+:[^\$\n]+\$)$/){
      print "\t$buff\n";
      next outer;
    }
    if($buff =~ /\n/){
      next outer;
    }
  }
}
