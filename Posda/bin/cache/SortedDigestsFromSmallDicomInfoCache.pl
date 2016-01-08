#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/cache/SortedDigestsFromSmallDicomInfoCache.pl,v $
#$Date: 2015/04/20 20:27:26 $
#$Revision: 1.1 $
#
#Copyright 2015, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
my $dir = $ARGV[0];
unless(-d $dir) { die "$ARGV[0] is not a directory" }
my @sorted_subdirs;
for my $i (0 .. 15){
  for my $j (0 .. 15){
    my $sub_dir = sprintf("%s/%01x/%01x", $dir, $i, $j);
    push @sorted_subdirs, $sub_dir;
  }
}
for my $d (@sorted_subdirs){
  unless(-d $d) { next }
  my @digs;
  opendir DIR, $d;
  while(my $f = readdir(DIR)){
    if($f =~ /^([1-9a-f]+)\.dcminfo$/){
      push @digs, $1;
    }
  }
  closedir DIR;
  for my $dig (sort @digs){
    print "$dig\n";
  }
}
