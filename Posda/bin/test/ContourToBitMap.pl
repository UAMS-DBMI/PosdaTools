#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/ContourToBitMap.pl,v $
#$Date: 2011/09/22 13:59:59 $
#$Revision: 1.9 $
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
#  rowdcosx=<x of row direction cosine>
#  rowdcosy=<y of row direction cosine>
#  rowdcosy=<z of row direction cosine>
#  coldcosx=<x of col direction cosine>
#  coldcosy=<y of col direction cosine>
#  coldcosz=<z of col direction cosine>
#  rowspc=<spacing between columns>
#  colspc=<spacing between rows>
#  ztol=<allowable z-distance from contour to image plane>
#
# On the input socket, the format of the contours is the following:
# BEGIN CONTOUR             - marks the beginning of a contour
# x1,y1,z                   - first point in contour
# x2,y2,y2                  - next point
# ...                       - and so on
# xn,yn,zn                  - last point
# END CONTOUR
# ...                       - repeat for as many contours as you have
#
use strict;
use Posda::FlipRotate;
use Math::Polygon;

my($in, $out, $status, $rows, $cols, $ulx, $uly, $ulz,
  $rowdcosx, $rowdcosy, $rowdcosz,
  $coldcosx, $coldcosy, $coldcosz,
  $rowspc, $colspc,
  $ztol
);
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
  elsif ($key eq "rowdcosx") { $rowdcosx = $value }
  elsif ($key eq "rowdcosy") { $rowdcosy = $value }
  elsif ($key eq "rowdcosz") { $rowdcosz = $value }
  elsif ($key eq "coldcosx") { $coldcosx = $value }
  elsif ($key eq "coldcosy") { $coldcosy = $value }
  elsif ($key eq "coldcosz") { $coldcosz = $value }
  elsif ($key eq "rowspc") { $rowspc = $value }
  elsif ($key eq "colspc") { $colspc = $value }
  elsif ($key eq "ztol") { $ztol = $value }
  else { die "$0: unknown parameter: $key" }
}
unless(defined $in) { die "$0: in is not defined" }
unless(defined $out) { die "$0: out is not defined" }
unless(defined $rows) { die "$0: cols is not defined" }
unless(defined $ulx) { die "$0: ulx is not defined" }
unless(defined $uly) { die "$0: uly is not defined" }
unless(defined $ulz) { die "$0: ulz is not defined" }
unless(defined $rowdcosx) { die "$0: rowdcosx is not defined" }
unless(defined $rowdcosy) { die "$0: rowdcosy is not defined" }
unless(defined $rowdcosz) { die "$0: rowdcosz is not defined" }
unless(defined $coldcosx) { die "$0: coldcosx is not defined" }
unless(defined $coldcosy) { die "$0: coldcosy is not defined" }
unless(defined $coldcosz) { die "$0: coldcosz is not defined" }
unless(defined $rowspc) { die "$0: rowspc is not defined" }
unless(defined $colspc) { die "$0: colspc is not defined" }
unless(defined $ztol) { die "$0: ztol is not defined" }
open(INPUT, "<&", $in) or die "$0: Can't open in = $in ($!)";
open(OUTPUT, ">&", $out) or die "$0: Can't open out = $out ($!)";

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
        $first->[1] eq $last->[1] &&
        $first->[2] eq $last->[2]
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
  unless($num_numbers % 3 == 0){
    die "$0: Number of numbers ($num_numbers) isn't divisible by 3";
  }
  my $num_points = $num_numbers / 3;
  for my $i (0 .. $num_points - 1){
    my $point = [$numbers[$i*3], $numbers[($i*3)+ 1], $numbers[($i*3) + 2]];
    push(@{$contour}, $point);
  }
}
#my $num_contours = @contours;
#for my $i (0 .. $#contours){
#  my $count = @{$contours[$i]};
#}
unless($mode eq "scan") { die "$0: end of input in scan mode" }
my @contours_2d;
my $ipp = [$ulx, $uly, $ulz];
my $iop = [$rowdcosx, $rowdcosy, $rowdcosz, $coldcosx, $coldcosy, $coldcosz];
my $pix_sp = [$rowspc, $colspc];
for my $i (0 .. $#contours){
  my $contour_2d = [];
  for my $j (@{$contours[$i]}){
    my $p = Posda::FlipRotate::ToPixCoords(
      $iop, $ipp, $rows, $cols, $pix_sp, $j);
    my($x, $y, $z) = @$p;
    if($z > $ztol) { 
      die "$0: point ($j->[0], $j->[1], $j->[2]) off plane by $z (> $ztol)"
    }
    push(@{$contour_2d}, [$x, $y]);
  }
  my $s = $contour_2d->[0];
  my $e = $contour_2d->[$#{$contour_2d}];
  if(
    sqrt(
      (($s->[0] - $e->[0]) **2) +
      (($s->[0] - $e->[0]) **2)
    ) < ((($rowspc + $colspc) / 2) / 2)
  ){
    $contour_2d->[$#{$contour_2d}] = $contour_2d->[0];
  } else {
    push(@{$contour_2d}, $contour_2d->[0]);
  }
  push(@contours_2d, $contour_2d);
}
my @segments;
for my $c (@contours_2d){
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
for my $i (0 .. $rows - 1){
  my @cross_segs;
  for my $s (@segments){
    if(
      ($s->[0]->[1] <= $i && $s->[1]->[1] > $i) ||
      ($s->[1]->[1] <= $i && $s->[0]->[1] > $i)
    ){ push @cross_segs, $s }
  }
  my $num_cross = @cross_segs;
  if($num_cross & 1) {
    print STDERR "$0: Odd number crossings (Not closed planar?)\n";
  }
  my $next_crossing;
  if($#cross_segs >= 0){
    $next_crossing = calc_crossing(shift(@cross_segs), $i);
  }
  my $crossing_polarity = 0;
  for my $j (0 .. $cols - 1){
    if(defined($next_crossing) && $j > $next_crossing) {
      $crossing_polarity ^= 1;
      if($#cross_segs >= 0){
        $next_crossing = calc_crossing(shift(@cross_segs), $i);
      } else {
        $next_crossing = undef;
      }
    }
    if($crossing_polarity) {
      $byte |= $mask;
    }
    $mask *= 2;
    $bit_count += 1;
    if($bit_count == 8){
      no warnings;
      print OUTPUT pack("c", $byte);
      $byte = 0;
      $bit_count = 0;
      $mask = 0x01;
    }
  }
}
if($bit_count > 0){
  no warnings;
  print OUTPUT pack("c", $byte);
}
if(defined $status){
  open(STATUS, ">&", $status) or die "$0: Can't open status = $status ($!)";
  print STATUS "OK\n";
  close STATUS;
}
sub calc_crossing{
  my($seg, $y) = @_;
  my $start;
  my $num;
  my $denom;
  my $dist;
  $start = $seg->[0]->[0];
  $dist = $seg->[1]->[0] - $seg->[0]->[0];
  $num = $y - $seg->[0]->[1];
  $denom = $seg->[1]->[1] - $seg->[0]->[1];
  return $start + ($dist * ($num/$denom));
}
