#!/usr/bin/perl -w
use strict;
my $usage = <<EOF;
CmdRawBmToCbm.pl 

RawBitmap on STDIN
Compressed Bitmap to STDOUT
EOF

my $total_ones = 0;
my $total_zeros = 0;
my $polarity;
my $bytes_written = 0;
my $num_bits_accum = 0;
my @array;
my $array_i = 0;
sub purge_count {
  while($num_bits_accum > 0){
    my $sub_count = $num_bits_accum;
    if($num_bits_accum > 127){
      $sub_count = 127;
      $num_bits_accum -= 127;
    } else {
      $sub_count = $num_bits_accum;
      $num_bits_accum = 0;
    }
    {
      no warnings;
      if($polarity){
        print STDOUT pack('c', 0x80 + $sub_count);
      } else {
        print STDOUT pack('c', $sub_count);
      }
      $bytes_written += 1;
    }
  }
}
my $tb;
while (read(STDIN, $tb, 1) == 1){
  my $byte = unpack('c', $tb);
  my $mask = 1;
  for my $bitn (0 .. 7){
    my $bit = 0;
    if($byte & $mask){
      $bit = 1;
    }
    $array[$array_i] = $bit;
    $array_i += 1;
    $mask <<= 1;
    unless(defined $polarity){
      $polarity = $bit;
    }
    if($polarity) {
      $total_ones += 1;
    } else {
      $total_zeros += 1;
    }
    unless($bit == $polarity){
      purge_count();
      $polarity = $bit;
      $num_bits_accum = 0;
    }
    $num_bits_accum += 1;
  }
}
purge_count();

print STDERR "total ones: $total_ones\n";
print STDERR "total zeros: $total_zeros\n";
print STDERR "bytes written: $bytes_written\n";

