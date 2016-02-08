#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use IO;
use HexDump;
my $usage = "usage: $0 <file>";
unless ($#ARGV == 0) {die $usage}
my $file = $ARGV[0];
unless($file =~ /^\//) {$file = getcwd."/$file"}
open FILE, "<$file" or die "Can't open $file";
my $offset = 0;
my $len = read(FILE, $buff, 1024);
while($len > 0){
  HexDump::PrintBigEndian(\*STDOUT, $buff, $offset);
  $offset += 1024;
  $len = read(FILE, $buff, 1024);
}
close FILE;
