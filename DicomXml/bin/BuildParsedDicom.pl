#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/DicomXml/bin/BuildParsedDicom.pl,v $
#$Date: 2014/08/15 15:31:15 $
#$Revision: 1.1 $
#
#Copyright 2014, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use File::Find;
use Cwd;
my $cwd = getcwd;
my $usage = <<EOF;
usage: BuildParsedDicom.pl <source> <dest>
EOF
unless($#ARGV == 1) { die $usage };
my $from = $ARGV[0];
unless($from =~ /^\//){ $from = "$cwd/$from" }
my $to = $ARGV[1];
unless($to =~ /^\//){ $to = "$cwd/$to" }
unless(-d $from) { die "$from is not a directory" }
unless(-d $to) { die "$to is not a directory" }
my $finder = sub {
  my $file = $_;
  my $dir = $File::Find::dir;
  unless(-f "$dir/$file") { return }
  if($file =~ /^\./) { return }
  unless($dir =~ /^$from\/(.*)$/){ return }
  my $rel_dir = $1;
  my $to_dir = "$to/$rel_dir";
  unless(-d $to_dir) { CreateDir($to_dir) }
  my $cmd = 
  "ParseIntoPerlStruct.pl \"$File::Find::name\" \"$to_dir/$file" . ".perl\"";
  `$cmd`;
#  print "From file: $File::Find::name\n";
#  print "To file: $to_dir/$file\n";
#  print "################\n";
};
find($finder, $from);
sub CreateDir{
  my($dir) = @_;
#print "Creating Dir: $dir\n";
#  return;
  unless($dir =~ /^\//) { die "not starting at root" }
  my @path = split(/\//, $dir);
  my $root =  "";
  for my $p (@path) {
    if($p eq "") { next }
#print "item: $p\n";
    $root = "$root/$p";
    unless(-d $root) {
#       print "mkdir $root\n";
      my $count = mkdir($root);
      unless($count == 1){
        die "Failed to make $root";
      }
    }
  }
}
