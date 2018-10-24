#!/usr/bin/perl -w
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Fcntl;
unless($#ARGV == 1){
 die "usage: $0 <file> <offset";
}
sysopen(FILE, "$ARGV[0]", O_RDWR) or die "can't sysopen $ARGV[0]";
sysseek(FILE, $ARGV[1], 0);
my $buff;
my $len = sysread(FILE, $buff, 1);
unless($len == 1) { die "can't read byte at $ARGV[1] in $ARGV[0]" }
my @foo = unpack("C", $buff);
print "Value = $foo[0]\n";
