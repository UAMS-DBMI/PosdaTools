#!/usr/bin/perl -w
#
#Copyright 2012, Bill Bennett and Erik Strom
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use File::Find;
use File::Path qw(make_path);
use Cwd;
my $usage = "$0 <source_dir> <dest_dir> <rm_pvt_yn> " .
   "[\"<sig>\" \"<value>\" ...]";
unless($#ARGV > 1) { die "$usage\n" }
my $source_dir = shift @ARGV;
my $dest_dir = shift @ARGV;
my $rm_pvt_yn = shift @ARGV;
my $cwd = getcwd;
unless($source_dir =~ /^\//) { $source_dir = "$cwd/$source_dir" }
unless(-d $source_dir) { die "$source_dir is not a directory" }
unless($dest_dir =~ /^\//) { $dest_dir = "$cwd/$dest_dir" }
unless(-d $dest_dir) { die "$dest_dir is not a directory" }
my $finder = sub {
  my $cur_file = $File::Find::name;
  unless(-f $cur_file && -w $cur_file) { return }
  unless($cur_file =~ /\/([^\/]+)$/) { die "WTF?" }
  my $file_part = $1;
  if($file_part =~ /^\./) { return }
  unless($cur_file =~ /^$source_dir\/(.*)$/){
    print "Funny full path to file: $cur_file\n";
    return;
  }
  my $rel_path = $1;
  my $dest_file = "$dest_dir/$rel_path";
  my $cmd;
  if($rm_pvt_yn){
    $cmd = 'DeletePvtAndChangeDicomElements.pl';
  } else {
    $cmd = 'ChangeDicomElements.pl';
  }
  $cmd = $cmd . ' "' . $cur_file . '" "' . $dest_file . '"';
  for my $i (@ARGV){
    $cmd .= ' "' . $i . '"';
  }
  print "$cmd\n";
};
find($finder, $source_dir);
