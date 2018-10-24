#!/usr/bin/perl -w
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

#   Adds <increment> to meta-header group length in the file
#   The group length is always a little endian long at file offset 0x8c
#

use Cwd;
use strict;
use Fcntl;
unless($#ARGV == 1){
  die "usage: $0 <file> <length_increment>";
}
my $file = $ARGV[0];
unless($file =~ /^\//) {$file = getcwd."/$file"}
my $len_inc = $ARGV[1];
sysopen FILE, "$file", O_RDWR or die "can't open $file";
my $pos = sysseek FILE, 0x8c, 0;
my $buff;
sysread(FILE, $buff, 4);
my @foo = unpack("V", $buff);
$foo[0] += $len_inc;
my $val = pack("V", $foo[0]);
my $new_pos = sysseek FILE, 0x8c, 0;
my $len = syswrite(FILE, $val, 4);
$new_pos = sysseek FILE, 0, 1;
close FILE;
