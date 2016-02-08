#!/usr/bin/perl -w
use strict;
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
