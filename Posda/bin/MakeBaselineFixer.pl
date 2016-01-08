#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/MakeBaselineFixer.pl,v $
#$Date: 2013/03/25 13:28:19 $
#$Revision: 1.1 $
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
# Eliminate Duplicate files in a file system by linking files in second
# directory to identical files (with matching sub-path) in first directory.
#
use strict;
use Cwd;
my $usage = "$0 <BaselineDir>";
unless($#ARGV == 0) { die "$usage\n" }
my $baseline = $ARGV[0];
my $cwd = getcwd;
unless($baseline =~ /^\//){ $baseline = "$cwd/$baseline" }
unless(-d $baseline) { die "$baseline is not a dir" }
opendir DIR, $baseline or die "Can't opendir $baseline";
my @subdirs;
while (my $dir = readdir(DIR)){
  if($dir =~ /^\./) { next }
  unless(-d "$baseline/$dir") { next }
  push @subdirs, $dir;
}
@subdirs = sort @subdirs;
for my $i (0 .. $#subdirs - 1){
  print "LinkDuplicates.pl \"$baseline/$subdirs[$i]\" " .
   "\"$baseline/$subdirs[$i+1]\"\n";
}
