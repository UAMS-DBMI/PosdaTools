#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use File::Temp qw/ tempfile /;
my $usage = " CompareDicomFiles.pl <file1> <file2>";
unless($#ARGV == 1 && -r $ARGV[0] && -r $ARGV[1]){ die $usage }
my $file_one = $ARGV[0];
my $file_two = $ARGV[1];
my $dump_one = File::Temp::tempnam("/tmp", "one");
my $dump_two = File::Temp::tempnam("/tmp", "two");
my $cmd1 = "DumpDicom.pl $file_one > $dump_one";
my $cmd2 = "DumpDicom.pl $file_two > $dump_two";
`$cmd1`;
`$cmd2`;
my $fh;
open $fh, "diff $dump_one $dump_two|";
while(my $line = <$fh>){
  print $line;
}
unlink $dump_one;
unlink $dump_two;
