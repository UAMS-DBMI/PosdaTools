#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/NewContourToBitMap.pl,v $
#$Date: 2011/10/18 16:37:40 $
#$Revision: 1.5 $
#
#Copyright 2011, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

# Streamed Pixel operations
# This program accepts contours on an fd and writes a bitmap
# on another fd of the points contained within the contours
# The fd's have been opened by the parent process...

# What to do is specified on the command line.
# All of the parameters on the command line are of the form:
#  <name>=<value> (no spaces)
# parameter order does not matter.
# Here are the possible parameters:
#  in=<number of first input fd>
#  out=<number of output fd>
#  status=<number of status fd>
#  rows=<number of rows in bitmap output>
#  cols=<number of cols in bitmap output>
#  ulx=<x coordinate of upper left point>
#  uly=<y coordinate of upper left point>
#  ulz=<z coordinate of upper left point>
#  rowspc=<spacing between columns>
#  colspc=<spacing between rows>
#
# On the input socket, the format of the contours is the following:
# BEGIN CONTOUR             - marks the beginning of a contour
# row1,col1                     - first point in contour
# row2,col2                     - next point
# ...                           - and so on
#                               -   not necessarily integer
#                               -   may be negative
# rown,coln                     - last point
# END CONTOUR
# ...                       - repeat for as many contours as you have
#
use strict;
use Posda::FlipRotate;
use Math::Polygon;

my($in, $out, $status, $rows, $cols, $ulx, $uly, $ulz, $rowspc, $colspc);
my $debug;
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
  elsif ($key eq "ulx") { $ulx = $value }
  elsif ($key eq "uly") { $uly = $value }
  elsif ($key eq "ulz") { $ulz = $value }
  elsif ($key eq "rowspc") { $rowspc = $value }
  elsif ($key eq "colspc") { $colspc = $value }
  elsif ($key eq "debug") { $debug = $value }
  else { die "$0: unknown parameter: $key" }
}
unless(defined $in) { die "$0: in is not defined" }
unless(defined $out) { die "$0: out is not defined" }
unless(defined $rows) { die "$0: rows is not defined" }
unless(defined $cols) { die "$0: cols is not defined" }
unless(defined $ulx) { die "$0: ulx is not defined" }
unless(defined $uly) { die "$0: uly is not defined" }
unless(defined $ulz) { die "$0: ulz is not defined" }
unless(defined $rowspc) { die "$0: rowspc is not defined" }
unless(defined $colspc) { die "$0: colspc is not defined" }
if($debug){
  print "$0: DEBUG\n";
  print "\trows: $rows\n";
  print "\tcols: $cols\n";
  print "\tul: ($ulx, $uly, $ulz)\n";
  print "\tspc: ($rowspc, $colspc)\n";
}

open(INPUT, "<&", $in) or die "$0: Can't open in = $in ($!)";
open(OUTPUT, ">&", $out) or die "$0: Can't open out = $out ($!)";

#print "$0:\n\trows: $rows, cols: $cols, ul: ($ulx, $uly, $ulz) " .
#  "spc: ($rowspc, $colspc)\n";
my @contours;
my $contour = [];
my $mode = "scan";
while(my $line = <INPUT>){
  chomp $line;
  while($mode eq "scan" && $line ne "BEGIN CONTOUR") { next }
  if($mode eq "scan"){
    $mode = "in contour";
    next;
  }
  if($line eq "END CONTOUR"){
    if($#{$contour} >= 0){
      my $first = $contour->[0];
      my $last = $contour->[$#{$contour}];
       unless(
        $first->[0] eq $last->[0] &&
        $first->[1] eq $last->[1]
      ){
        push(@{$contour}, $first);
      }
    }
    push @contours, $contour;
    $contour = [];
    $mode = "scan";
    next;
  }
  my @numbers = split(/\\/, $line);
  my $num_numbers = @numbers;
  unless($num_numbers % 2 == 0){
    die "$0: Number of numbers ($num_numbers) isn't divisible by 2";
  }
  my $num_points = $num_numbers / 2;
  for my $i (0 .. $num_points - 1){
    my $point = [$numbers[$i*2], $numbers[($i*2)+ 1]];
    push(@{$contour}, $point);
  }
}

my @segments;
for my $c (@contours){
  for my $i (0 .. $#{$c}- 1){
    my $seg = [$c->[$i], $c->[$i+1]];
    push(@segments, $seg);
  }
  push(@segments, [$c->[$#{$c}], $c->[0]]);
}

@segments = sort { $a->[0]->[0] <=> $b->[0]->[0] } @segments;
my $bit_count = 0;
my $byte = 0;
my $mask = 0x01;
my $total_bits = 0;
my $total_ones = 0;
my $total_zeros = 0;
my $y = $uly;
for my $i (0 .. $rows - 1){
  my @cross_segs;
  for my $s (@segments){
    if(
      ($s->[0]->[1] <= $y && $s->[1]->[1] > $y) ||
      ($s->[1]->[1] <= $y && $s->[0]->[1] > $y)
    ){ push @cross_segs, $s }
  }
  my $num_cross = @cross_segs;
  if($num_cross & 1) {
    print STDERR "$0: Odd number crossings (Not closed planar?)\n";
  }
  my $next_crossing;
  if($#cross_segs >= 0){
    $next_crossing = calc_crossing(shift(@cross_segs), $y);
  }
  my $crossing_polarity = 0;
  my $bit_count = 0;
  my $x = $ulx;
  for my $j (0 .. $cols - 1){
    my $bef_x_pol = $crossing_polarity;
    if(defined($next_crossing) && $x > $next_crossing) {
      $crossing_polarity ^= 1;
      if($#cross_segs >= 0){
        $next_crossing = calc_crossing(shift(@cross_segs), $y);
      } else {
        $next_crossing = undef;
      }
    }
    if($bef_x_pol != $crossing_polarity){
      output_bits($bef_x_pol, $bit_count, $y, $x, $i, $j);
      $bit_count = 0;
    }
    $bit_count += 1;
    $x += $rowspc;
  }
  if($bit_count > 0){
    output_bits($crossing_polarity, $bit_count, $y, 0, $i, 0);
  }
  $bit_count = 0;
  $y += $colspc;
}
if(defined $status){
  open(STATUS, ">&", $status) or die "$0: Can't open status = $status ($!)";
  print STATUS "OK\n";
  close STATUS;
}
sub output_bits{
  my($polarity, $count, $row, $col, $i, $j) = @_;
  while($count > 0){
    my $sub_count = $count;
    if($count > 127) {
      $count -= 127;
      $sub_count = 127;
    } else {
      $sub_count = $count;
      $count = 0;
    }
    {
      no warnings;
      if($polarity){
        print OUTPUT pack("c", 0x80 + $sub_count);
      } else {
        print OUTPUT pack("c", $sub_count);
      }
    }
  }
}
sub calc_crossing{
  my($seg, $x) = @_;
  unless(defined $seg) { return undef }
  my $start;
  my $num;
  my $denom;
  my $dist;
  $start = $seg->[0]->[0];
  $dist = $seg->[1]->[0] - $seg->[0]->[0];
  $num = $x - $seg->[0]->[1];
  $denom = $seg->[1]->[1] - $seg->[0]->[1];
  return $start + ($dist * ($num/$denom));
}
