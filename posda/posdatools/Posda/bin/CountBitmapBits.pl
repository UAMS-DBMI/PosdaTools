#!/usr/bin/perl -w
#
#Copyright 2012, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
my $file = $ARGV[0];
open FILE, $file or die "can't open $file";
my $buff;
my $count = 0;
while(read FILE, $buff, 1){
  my $c = unpack("c", $buff);
  if($c & 0x80){
    $count += $c & 0x7f;
  }
}
print "$count\n";
