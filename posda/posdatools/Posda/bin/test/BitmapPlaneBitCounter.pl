#!/usr/bin/perl -w
#
#Copyright 2011, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use strict;
use PipeChildren;
my $file = $ARGV[0];
my $rows = $ARGV[1];
my $cols = $ARGV[2];
my $slices = $ARGV[3];
open INPUT, "<$file" or die "can't open $file";
my $slice_size = ($rows * $cols) / 8;
my $buff;
my $total_bits = 0;
for my $i (0 .. $slices - 1){
  my $len = read(INPUT, $buff, $slice_size);
  unless($len == $slice_size) { die "read $len vs $slice_size" }
  my @bytes = unpack("c*", $buff);
  my $bit_count = 0;
  for my $i (@bytes){
    my $mask = 1;
    for my $j (0 .. 7) {
      if($i & $mask) { $bit_count += 1 }
      $mask *= 2;
    }
  }
  if($bit_count > 0){
    print "Frame $i has $bit_count bits set\n";
    $total_bits += $bit_count;
  }
}
print "Total bits set = $total_bits\n";
