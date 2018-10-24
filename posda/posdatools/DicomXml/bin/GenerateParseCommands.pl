#!/usr/bin/perl -w
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
my $usage = <<EOF;
GenerateParseCommands.pl <xml_dir> <parsed_dir>
EOF
unless($#ARGV == 1) { die $usage }
my $from_dir = $ARGV[0];
my $to_dir = $ARGV[1];
my $cwd = getcwd;
unless($from_dir =~ /^\//) { $from_dir = "$cwd/$from_dir" }
unless($to_dir =~ /^\//) { $to_dir = "$cwd/$to_dir" }
my $finder = sub {
  my $file = $File::Find::name;
  unless(-f $file) { return }
  unless($file =~ /^$from_dir\/(.*)$/){ return }
  my $rel_file = $1;
  print "echo $rel_file\n";
  print "ParseIntoPerlStruct.pl \"$from_dir/$rel_file\" \"$to_dir/$rel_file.perl\"\n";
};
find($finder, $from_dir);
