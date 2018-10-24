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
my $usage = "$0 <comment> <source_dir> <archive_dir>";
unless($#ARGV == 2) { die "$usage\n" }
my $comment = $ARGV[0];
my $source_dir = $ARGV[1];
my $archive_dir = $ARGV[2];
my $cwd = getcwd;
my @rel_paths;
my %rel_dirs;
unless($source_dir =~ /^\//) { $source_dir = "$cwd/$source_dir" }
unless(-d $source_dir) { die "$source_dir is not a directory" }
unless($archive_dir =~ /^\//) { $archive_dir = "$cwd/$archive_dir" }
unless(-d $archive_dir) { die "$archive_dir is not a directory" }
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
  push(@rel_paths, $rel_path);
};
find($finder, $source_dir);
## create rel_dirs 
for my $rel (@rel_paths) {
  unless($rel =~ /^(.*)\/([^\/]+)$/) {
    next;
  }
  my $dir = $1;
  my $file = $2;
  $rel_dirs{$dir} = 1;
}
for my $dir (keys %rel_dirs){
  my $archive_dir_path = "$archive_dir/$dir";
  unless(-e $archive_dir_path){
    make_path($archive_dir_path, { mode => 0771 });
  }
}
## Now generate the commands to check everything in
my @commands;
for my $i (@rel_paths){
  my $source = "$source_dir/$i";
  my $archive = "$archive_dir/$i" . ",v";
  if(-e $archive) { next }
  my $cmd = "ci -t-\"$comment\" \"$source\" \"$archive\"";
  print "$cmd\n";
  $cmd = "co \"$source\" \"$archive\"";
  print "$cmd\n";
}
