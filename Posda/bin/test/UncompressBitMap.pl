#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

# Take a compressed bitmap and uncompress it
#
use strict;

my $buff;
my $current_count = 0;
my $constr_byte = 0;
while(my $byte_count = sysread(STDIN, $buff, 1)){
  my $in = unpack("c", $buff);
  my $polarity = $in & 0x80;
  my $count = $in & 0x7f;
  my $mask;
  while(($count + $current_count) >= 8){
    if($polarity) { $mask = 0x01 } else { $mask = 0 };
    if($current_count){
      my $sub_count = 8 - $current_count;
      $mask <<= $current_count;
      for my $i (0 .. $sub_count){
        $constr_byte |= $mask;
        $mask <<= 1;
      }
      $count -= $sub_count;
      $current_count = 0;
      {
        no warnings;
        print pack("c", $constr_byte);
      }
    } else {
      $count -= 8;
      if($polarity){
        {
          no warnings;
          print pack("c", 0xff);
        }
      } else {
        {
          no warnings;
          print pack("c", 0);
        }
      }
    }
  }
  my $new_current = $current_count + $count;
  if($polarity) { $mask = 0x01 } else { $mask = 0 }
  if($current_count){
    for my $i (0 .. $current_count - 1){
      $mask <<= 1;
    }
  } else {
    $constr_byte = 0;
  }
  for my $i (0 .. $count - 1) {
    $constr_byte |= $mask;
    $mask <<= 1;
  }
  $current_count = $new_current;
}
