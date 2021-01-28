#!/usr/bin/perl -w

# Take a compressed bitmap and turn it into a PBM based on args ...
# This program accepts (presumably) pixel data on STDIN
# It produces a "PBM" format stream on STDOUT
# All of the parameters on the command line are of the form:
#  <name>=<value> (no spaces)
# parameter order does not matter.
# Here are the possible parameters:
#  rows=<number of rows>
#  cols=<number of cols>
#
use strict;
my($rows, $cols);
for my $i (@ARGV){
  unless($i =~ /^([^=]+)=([^=]+)$/) {
    die "$0: can't parse parameter $i";
  }
  my $key = $1;
  my $value = $2;
  if ($key eq "rows") { $rows = $value }
  elsif ($key eq "cols") { $cols = $value }
  else { die "$0: unknown parameter: $key" }
}
unless(defined($rows)){ die "$0: rows undefined" }
unless(defined($cols)){ die "$0: cols undefined" }
print "P4 $cols $rows\n";
my $buff;
my $current_count = 0;
my $constr_byte = 0;

while(my $byte_count = sysread(STDIN, $buff, 1)){
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
      print pack("c", $constr_byte);
    } else {
      $count -= 8;
      if($polarity){
        print pack("c", 0xff);
      } else {
        print pack("c", 0);
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
