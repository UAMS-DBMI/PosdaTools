#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/VaxDumper.pl,v $
#$Date: 2013/02/06 20:00:55 $
#$Revision: 1.1 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use HexDump;
use IO;
unless($#ARGV == -1){ die "usage: $0 <no params>" }
my $len = read(STDIN, $buff, 1024);
unless(defined $len) { die "read failed: $!" }
while($len > 0){
  HexDump::PrintVax(\*STDOUT, $buff, $offset);
  $offset += 1024;
  $len = read(STDIN, $buff, 1024);
}
