#!/usr/bin/perl -w
use strict;
#$Source: /home/bbennett/pass/archive/Posda/bin/test/DirReader.pl,v $
#$Date: 2012/03/23 20:37:19 $
#$Revision: 1.1 $
#
#Copyright 2012, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
my $dir = $ARGV[0];
opendir DIR, $dir or die "Can't open dir $dir";
while(my $f = readdir(DIR)){
  unless(-d "$dir/$f") { next }
  if($f =~ /^\./) { next }
  print "$f\n";
}
closedir DIR;
