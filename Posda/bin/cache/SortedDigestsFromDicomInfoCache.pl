#!/usr/bin/perl -w
#
#Copyright 2015, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Cwd;
my $cur_dir = getcwd;
my $dir = $ARGV[0];
unless($dir =~ /^\//){ $dir = "$cur_dir/$dir" }
unless(-d $dir) { die "$ARGV[0] is not a directory" }
my @sorted_subdirs;
for my $i (0 .. 255){
  push @sorted_subdirs, sprintf("%02x", $i);
}
for my $one (@sorted_subdirs){
  inner:
  for my $two (@sorted_subdirs){
    my $subdir = "$dir/$one/$two";
#    unless(-e $subdir) { next inner}
    if(-d $subdir){
      my @digs;
#      opendir DIR, $subdir or next inner;
      opendir DIR, $subdir or next inner;
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
  }
}
