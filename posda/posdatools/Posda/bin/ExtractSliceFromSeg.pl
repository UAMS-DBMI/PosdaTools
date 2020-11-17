#!/usr/bin/perl -w
use strict;
my $usage = <<EOF;
ExtractSliceFromSeg.pl <seg_file> <offset> <num_bytes> <rows> <cols> <slice_file>
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage ; exit }
unless($#ARGV == 5){
  my $num_args = @ARGV;
  die "Wrong num args ($num_args vs 6).  Usage:\n$usage";
}
my($seg_file, $offset, $num_bytes, $rows, $cols, $slice_file) = @ARGV;

my $total_ones = 0;
my $total_zeros = 0;
my $polarity;
my $bytes_written = 0;
my $num_bits_accum = 0;
open SEG, "<$seg_file";
seek SEG, $offset, 0;
open SLICE, ">$slice_file";
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
        print SLICE pack('c', 0x80 + $sub_count);
      } else {
        print SLICE pack('c', $sub_count);
      }
      $bytes_written += 1;
    }
  }
}
for my $i (0 .. $num_bytes - 1){
  my $tb;
  read(SEG, $tb, 1);
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

print "total ones: $total_ones\n";
print "total zeros: $total_zeros\n";
print "bytes written: $bytes_written\n";
my $comp_ratio = ($bytes_written / (($rows * $cols) /8 ) ) * 100;
print "compression: $comp_ratio%\n";

  # Here's the start of the code that produces the .points file
{
  my @points;
  for my $row_i (0 .. $rows - 1){
    for my $col_i (0 .. $cols - 1){
      my $index = $col_i + ($cols * $row_i);
      my($point_above, $point_left, $point_right, $point_below);
      my($point_ul, $point_ur, $point_ll, $point_lr);
      if(
        $row_i > 0 && $row_i < $rows &&
        $col_i > 0 && $col_i < $cols
      ){
        my $pa_index_above = $col_i + ($cols * ($row_i - 1));
        my $pa_index_below = $col_i + ($cols * ($row_i + 1));
        my $pa_index_left = ($col_i - 1) + ($cols * $row_i);
        my $pa_index_right = ($col_i + 1) + ($cols * $row_i);
        my $pa_index_ul =  ($col_i - 1) + ($cols * ($row_i - 1));
        my $pa_index_ur =  ($col_i + 1) + ($cols * ($row_i - 1));
        my $pa_index_ll =  ($col_i - 1) + ($cols * ($row_i + 1));
        my $pa_index_lr =  ($col_i + 1) + ($cols * ($row_i + 1));
        $point_above = $array[$pa_index_above];
        $point_below = $array[$pa_index_below];
        $point_left = $array[$pa_index_left];
        $point_right = $array[$pa_index_right];
        $point_ul = $array[$pa_index_ul];
        $point_ur = $array[$pa_index_ur];
        $point_ll = $array[$pa_index_ll];
        $point_lr = $array[$pa_index_lr];
      } elsif($row_i == 0 && $col_i < $cols && $cols > 0){
        my $pa_index_below = $col_i + ($cols * ($row_i + 1));
        my $pa_index_left = ($col_i - 1) + ($cols * $row_i);
        my $pa_index_right = ($col_i + 1) + ($cols * $row_i);
        my $pa_index_ll =  ($col_i - 1) + ($cols * ($row_i + 1));
        my $pa_index_lr =  ($col_i + 1) + ($cols * ($row_i + 1));
        $point_below = $array[$pa_index_below];
        $point_left = $array[$pa_index_left];
        $point_right = $array[$pa_index_right];
        $point_ll = $array[$pa_index_ll];
        $point_lr = $array[$pa_index_lr];
      } elsif($row_i == ($rows - 1) && $col_i < $cols && $cols < 0){
        my $pa_index_above = $col_i + ($cols * ($row_i - 1));
        my $pa_index_left = ($col_i - 1) + ($cols * $row_i);
        my $pa_index_right = ($col_i + 1) + ($cols * $row_i);
        my $pa_index_ul =  ($col_i - 1) + ($cols * ($row_i - 1));
        my $pa_index_ur =  ($col_i + 1) + ($cols * ($row_i - 1));
        $point_above = $array[$pa_index_above];
        $point_left = $array[$pa_index_left];
        $point_right = $array[$pa_index_right];
        $point_ul = $array[$pa_index_ul];
        $point_ur = $array[$pa_index_ur];
      } elsif($row_i > 0 && $row_i < $rows && $col_i == 0){
        my $pa_index_above = $col_i + ($cols * ($row_i - 1));
        my $pa_index_below = $col_i + ($cols * ($row_i + 1));
        my $pa_index_right = ($col_i + 1) + ($cols * $row_i);
        my $pa_index_ur =  ($col_i + 1) + ($cols * ($row_i - 1));
        my $pa_index_lr =  ($col_i + 1) + ($cols * ($row_i + 1));
        $point_above = $array[$pa_index_above];
        $point_below = $array[$pa_index_below];
        $point_right = $array[$pa_index_right];
        $point_ur = $array[$pa_index_ur];
        $point_lr = $array[$pa_index_lr];
      } elsif($row_i > 0 && $row_i < $rows && $col_i == ($cols - 1)){
        my $pa_index_above = $col_i + ($cols * ($row_i - 1));
        my $pa_index_below = $col_i + ($cols * ($row_i + 1));
        my $pa_index_left = ($col_i - 1) + ($cols * $row_i);
        my $pa_index_ul =  ($col_i - 1) + ($cols * ($row_i - 1));
        my $pa_index_ll =  ($col_i - 1) + ($cols * ($row_i + 1));
        $point_above = $array[$pa_index_above];
        $point_below = $array[$pa_index_below];
        $point_left = $array[$pa_index_left];
        $point_ul = $array[$pa_index_ul];
        $point_ll = $array[$pa_index_ll];
      } elsif($row_i == 0 && $col_i == 0){
        my $pa_index_below = $col_i + ($cols * ($row_i + 1));
        my $pa_index_left = ($col_i - 1) + ($cols * $row_i);
        my $pa_index_ll =  ($col_i - 1) + ($cols * ($row_i + 1));
        $point_below = $array[$pa_index_below];
        $point_left = $array[$pa_index_left];
        $point_ll = $array[$pa_index_ll];
      } elsif($row_i == ($rows - 1) && $col_i == ($cols - 1)){
        my $pa_index_above = $col_i + ($cols * ($row_i - 1));
        my $pa_index_left = ($col_i - 1) + ($cols * $row_i);
        my $pa_index_ul =  ($col_i - 1) + ($cols * ($row_i - 1));
        $point_above = $array[$pa_index_above];
        $point_left = $array[$pa_index_left];
        $point_ul = $array[$pa_index_ul];
      } else {
        die "Invalid rows, cols: $rows, $cols ($row_i, $col_i)";
      }
      unless(defined $point_right){ $point_right = 0}
      unless(defined $point_left){ $point_left = 0}
      unless(defined $point_above){ $point_above = 0}
      unless(defined $point_below){ $point_below = 0}
      unless(defined $point_ul){ $point_ul = 0}
      unless(defined $point_ur){ $point_ur = 0}
      unless(defined $point_ll){ $point_ll = 0}
      unless(defined $point_lr){ $point_lr = 0}
      my $point = $array[$index];
      if(
        ($point == 1) &&
        ($point_above == 0) &&
        ($point_below == 0) &&
        ($point_left == 0) &&
        ($point_right == 0) &&
        ($point_ul == 0) &&
        ($point_ur == 0) &&
        ($point_ll == 0) &&
        ($point_lr == 0)
      ){
        push @points, "bare point: ($col_i, $row_i)\n";
      }
    }
  }
  if($#points >= 0){
    my $num_points = @points;
    print "Found $num_points bare points\n";
    for my $i (@points){ print $i };
  }
}


