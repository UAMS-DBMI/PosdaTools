#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/ChangeByte.pl,v $
#$Date: 2010/11/02 13:23:30 $
#$Revision: 1.1 $
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Fcntl;
unless($#ARGV == 2){
 die "usage: $0 <file> <offset> <value>";
}
sysopen(FILE, "$ARGV[0]", O_RDWR) or die "can't sysopen $ARGV[0]";
sysseek(FILE, $ARGV[1], 0);
my $value = pack("C", $ARGV[2]);
my $len = syswrite(FILE, $value, 1);
unless($len == 1) { die "can't write byte at $ARGV[1] in $ARGV[0]" }
