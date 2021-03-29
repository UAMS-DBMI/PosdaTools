#!/usr/bin/perl -w
use strict;
use Posda::FlipRotate;
#use Math::Polygon;
my $usage = <<EOF;
ContourToBitmapPixCoordOnly.pl <rows> <cols> <dest_file>

Expects Contours on STDIN in the following format:
BEGIN
<x1>,<y2>
<x2>,<y2>
... <all points in contour 1>
END
BEGIN
<x1>,<y2>
<x2>,<y2>
... <all points in contour 1>
END
...


Points are in pixel coordinates and generally should have the 
range of -0.5 to <cols>.5 for x and -0.5 to <rows>.5 for y.
(That is to say, contours can extend half a pixel width outside
the pixel space ...)

Contour coordinates should not align with pixels, as this is 
ambiguous for inclusion of the pixel with which they align.

This will produce a compressed bitmap of the pixels enclosed by
the contours on STDOUT. (0,0) is the first pixel (top left hand
corner of the image), (<cols>, 0) is the top right hand corner),
(0,<rows>) is the bottom left hand corner, (<cols>, <rows>) is the
bottom right hand corner.

Compression is run-length.  A byte with a 1 in the most significant
bit indicates a run of 1 to 127 one bits, a byte with a 0 in the most 
significant bit indicates a run of zero bits.

EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 2){
  my $num_args = @ARGV;
  die "Wrong num args ($num_args vs 3)";
}

my($rows, $cols, $out_file) = @ARGV;

my @contours_2d;
my $contour = [];
my $mode = "scan";
while(my $line = <STDIN>){
  chomp $line;
  while($mode eq "scan" && $line ne "BEGIN") { next }
  if($mode eq "scan"){
    $mode = "contour";
    next;
  }
  if($line eq "END"){
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
    push @contours_2d, $contour;
    $contour = [];
    $mode = "scan";
    next;
  }
  my ($x, $y) = split(/,/, $line);
  my $point = [$x, $y];
  push(@{$contour}, $point);
}
unless($mode eq "scan") { die "$0: end of input in $mode mode" }
my @segments;
for my $c (@contours_2d){
  for my $i (0 .. $#{$c}- 1){
    my $seg = [$c->[$i], $c->[$i+1]];
    push(@segments, $seg);
  }
  push(@segments, [$c->[$#{$c}], $c->[0]]);
}

open SLICE, ">$out_file" or die "Can't open output file: $out_file";
my $total_ones = 0;
my $total_zeros = 0;
my $num_bits_accum = 0;
my $polarity = 0;
my $bytes_written = 0;
#my @array;
#my $array_i = 0;
for my $i (0 .. $rows - 1){
  my @cross_segs;
  for my $s (@segments){
    if(
      ($s->[0]->[1] <= $i && $s->[1]->[1] > $i) ||
      ($s->[1]->[1] <= $i && $s->[0]->[1] > $i)
    ){ push @cross_segs, calc_crossing($s, $i) }
  }
  @cross_segs = sort { $a <=> $b } @cross_segs;
  my $num_cross = @cross_segs;
  if($num_cross & 1) {
    print STDERR "$0: Odd number crossings (Not closed planar?)\n";
  }
  my $next_crossing;
  if($#cross_segs >= 0){
    $next_crossing = shift @cross_segs;
  }
  my $crossing_polarity = 0;
  for my $j (0 .. $cols - 1){
    while(defined($next_crossing) && $j > $next_crossing) {
      $crossing_polarity ^= 1;
      if($#cross_segs >= 0){
        $next_crossing = shift @cross_segs;
      } else {
        $next_crossing = undef;
      }
    }
#    $array[$array_i] = $crossing_polarity;
#    $array_i += 1;
    if($crossing_polarity == 1){
      $total_ones += 1;
    } else {
      $total_zeros += 1;
    }
    unless($crossing_polarity == $polarity) {
      purge_count();
      $polarity = $crossing_polarity;
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
exit;

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
