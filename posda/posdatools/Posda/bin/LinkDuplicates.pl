#!/usr/bin/perl -w
#
#Copyright 2012, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
# Eliminate Duplicate files in a file system by linking files in second
# directory to identical files (with matching sub-path) in first directory.
#
use strict;
use File::Find;
use File::Path qw(make_path);
use Digest::MD5;
use Cwd;
my $usage = "$0 <first_dir> <second_dir>";
unless($#ARGV == 1) { die "$usage\n" }
my $first_dir = $ARGV[0];
my $second_dir = $ARGV[1];
my $cwd = getcwd;
unless($first_dir =~ /^\//){ $first_dir = "$cwd/$first_dir" }
unless($second_dir =~ /^\//){ $second_dir = "$cwd/$second_dir" }
unless(-d $first_dir) { die "$first_dir is not a directory" }
unless(-d $second_dir) { die "$second_dir is not a directory" }
my $finder = sub {
  my $cur_file = $File::Find::name;
  unless(-f $cur_file) { return }
  unless($cur_file =~ /\/([^\/]+)$/) { die "WTF?" }
  my $file_part = $1;
  if($file_part =~ /^\./) { return }
  unless($cur_file =~ /^$second_dir\/(.*)$/){
    print "Funny full path to file: $cur_file\n";
    return;
  }
  my $rel_path = $1;
  my $target_file = "$first_dir/$rel_path";
  if(-f $target_file) {
    my $ctx1 = Digest::MD5->new;
    open my $fh1, "<$cur_file" or die "can't open $cur_file";
    $ctx1->addfile($fh1);
    my $dig1 = $ctx1->hexdigest;
    my $ctx2 = Digest::MD5->new;
    open my $fh2, "<$target_file" or die "can't open $target_file";
    $ctx2->addfile($fh2);
    my $dig2 = $ctx2->hexdigest;
    if($dig1 eq $dig2) {
      #print "match:\n\t$cur_file\n\t$target_file\n";
      unless(unlink $cur_file) { die "couldn't unlink $cur_file" }
      unless(link $target_file, $cur_file) {
        die "couldn't link $cur_file to $target_file";
      }
    }
  }
};
find($finder, $second_dir);
