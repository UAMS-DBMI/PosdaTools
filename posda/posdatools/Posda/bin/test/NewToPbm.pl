#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

# Take a compressed bitmap and turn it into a PBM based on args ...
# This program accepts (presumably) pixel data on one fd
# It produces a "PBM" format stream on the output fd
# All of the parameters on the command line are of the form:
#  <name>=<value> (no spaces)
# parameter order does not matter.
# Here are the possible parameters:
#  in=<number of input fd>
#  out=<number of output fd>
#  rows=<number of rows>
#  cols=<number of cols>
#
use strict;
my($in, $out, $rows, $cols, $status);
for my $i (@ARGV){
  unless($i =~ /^([^=]+)=([^=]+)$/) {
    die "$0: can't parse parameter $i";
  }
  my $key = $1;
  my $value = $2;
  if($key eq "in") { $in = $value }
  elsif ($key eq "out") { $out = $value }
  elsif ($key eq "status") { $status = $value }
  elsif ($key eq "rows") { $rows = $value }
  elsif ($key eq "cols") { $cols = $value }
  else { die "$0: unknown parameter: $key" }
}
unless(defined($in)){ die "$0: in undefined" }
unless(defined($out)){ die "$0: out undefined" }
unless(defined($rows)){ die "$0: rows undefined" }
unless(defined($cols)){ die "$0: cols undefined" }
open(INPUT, "<&", $in) or die "$0: Can't open in = $in ($!)";
open(OUTPUT, ">&", $out) or die " Can't open out = $out ($!)";
print OUTPUT "P4 $cols $rows\n";
my $buff;
my $current_count = 0;
my $constr_byte = 0;

while(my $byte_count = sysread(INPUT, $buff, 1)){
  no warnings;
  my $in = unpack("c", $buff);
  my $polarity = $in & 0x80;
  my $count = $in & 0x7f;
  my $mask;
  while(($count + $current_count) >= 8){
    if($polarity) { $mask = 0x80 } else { $mask = 0 };
    if($current_count){
      my $sub_count = 8 - $current_count;
      $mask >>= $current_count;
      for my $i (0 .. $sub_count){
        $constr_byte |= $mask;
        $mask >>= 1;
      }
      $count -= $sub_count;
      $current_count = 0;
      print OUTPUT pack("c", $constr_byte);
    } else {
      $count -= 8;
      if($polarity){
        print OUTPUT pack("c", 0xff);
      } else {
        print OUTPUT pack("c", 0);
      }
    }
  }
  my $new_current = $current_count + $count;
  if($polarity) { $mask = 0x80 } else { $mask = 0 }
  if($current_count){
    for my $i (0 .. $current_count - 1){
      $mask >>= 1;
    }
  } else {
    $constr_byte = 0;
  }
  for my $i (0 .. $count - 1) {
    $constr_byte |= $mask;
    $mask >>= 1;
  }
  $current_count = $new_current;
}
if(defined $status){ 
  open(STATUS, ">&", $status) or die "$0: Can't open status = $status";
  print STATUS "OK\n";
  close STATUS;
}
