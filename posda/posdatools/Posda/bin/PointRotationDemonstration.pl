#!/usr/bin/perl -w
use strict;
# $eps is a very small float
my $eps = .00000001;

#
# cross takes the cross product of two vectors
# it is designed to accept an image_orientation_patient
#  formatted pair of vectors (6 numbers)
#
sub cross {
  my($a, $b) = @_;
  my $a_x = $a->[0];
  my $a_y = $a->[1];
  my $a_z = $a->[2];
  my $b_x = $b->[0];
  my $b_y = $b->[1];
  my $b_z = $b->[2];
  # (a2b3 - a3b2)i + (a3b1 - a1b3)j + (a1b2 - a2b1)k
  my $c_x = ($a_y * $b_z) - ($a_z * $b_y);
  my $c_y = ($a_z * $b_x) - ($a_x * $b_z);
  my $c_z = ($a_x * $b_y) - ($a_y * $b_x);
  return [$c_x, $c_y, $c_z];
}

#
# MatMul multiplies two 4x4 matrices
#   It is used for composing transforms
#   It may do m2 x m1 (i.e. reverse parameters)
sub MatMul{
  my($m1, $m2) = @_;
  my @m3 = ();
  for my $i (0 .. 3) {
    my @row = ();
    my $m1i = $m1->[$i];
    for my $j (0 .. 3) {
      my $val = 0;
      for my $k (0 .. 3) {
        $val += $m1i->[$k] * $m2->[$k]->[$j];
      }
      push(@row, $val);
    }
    push(@m3, \@row);
  }
  return(\@m3);
}
#
# ApplyTransform applies a transform to a point
#
sub ApplyTransform{
  my($x_form, $vec) = @_;
  my $n_x = (
    $vec->[0] * $x_form->[0]->[0] +
    $vec->[1] * $x_form->[0]->[1] +
    $vec->[2] * $x_form->[0]->[2] +
    1 * $x_form->[0]->[3]
  );
  my $n_y =  (
    $vec->[0] * $x_form->[1]->[0] +
    $vec->[1] * $x_form->[1]->[1] +
    $vec->[2] * $x_form->[1]->[2] +
    1 * $x_form->[1]->[3]
  );
  my $n_z = (
    $vec->[0] * $x_form->[2]->[0] +
    $vec->[1] * $x_form->[2]->[1] +
    $vec->[2] * $x_form->[2]->[2] +
    1 * $x_form->[2]->[3]
  );
  my $n_o = (
    $vec->[0] * $x_form->[3]->[0] +
    $vec->[1] * $x_form->[3]->[1] +
    $vec->[2] * $x_form->[3]->[2] +
    1 * $x_form->[3]->[3]
  );
  unless($n_o == 1){
    print STDERR "Error applying x_form: $n_o should be 1\n";
  }
  my $res = [$n_x, $n_y, $n_z];
  return $res;
}

# 
# NormalizingImageOriention constructs a transform based on iop
#   to rotate the vectors to (1,0,0,0,1,0)
#   i.e. 
#      rows parallel to x-axis and increasing x,
#      columns parallel to y-axis and increasing y
#
sub NormalizingImageOrientation{
  my($iop) = @_;
  my $norm = cross([$iop->[0], $iop->[1], $iop->[2]],
                               [$iop->[3], $iop->[4], $iop->[5]]);
  my @xform;
  $xform[0]->[0] = $iop->[0];
  $xform[0]->[1] = $iop->[1];
  $xform[0]->[2] = $iop->[2];
  $xform[0]->[3] = 0;

  $xform[1]->[0] = $iop->[3];
  $xform[1]->[1] = $iop->[4];
  $xform[1]->[2] = $iop->[5];
  $xform[1]->[3] = 0;

  $xform[2]->[0] = $norm->[0];
  $xform[2]->[1] = $norm->[1];
  $xform[2]->[2] = $norm->[2];
  $xform[2]->[3] = 0;

  $xform[3]->[0] = 0;
  $xform[3]->[1] = 0;
  $xform[3]->[2] = 0;
  $xform[3]->[3] = 1;

  return \@xform;
}
# 
# NormalizingVolume constructs a transform based on iop and ipp
#   to both rotate the iop vectors to (1,0,0,0,1,0)
#   i.e. 
#      rows parallel to x-axis and increasing x,
#      columns parallel to y-axis and increasing y
#   and
#      move ipp to (0, 0, 0)
#
sub NormalizingVolume{
  my($iop, $ipp) = @_;
  my $xform = NormalizingImageOrientation($iop);
  my $rot_ipp = ApplyTransform($xform, $ipp);
  $xform->[0]->[3] = -$rot_ipp->[0];
  $xform->[1]->[3] = -$rot_ipp->[1];
  $xform->[2]->[3] = -$rot_ipp->[2];
  $xform->[3]->[3] =  1;
  return $xform;
}
# 
# AltNormalizingImageOriention constructs a transform based on iop
#   to rotate the vectors to (1,0,0,0,1,0)
#   i.e. 
#      rows parallel to x-axis and increasing x,
#      columns parallel to y-axis and increasing y
#   and
#      move iop to (0, 0, 0)
# But it does it a different way than NormalizingVolume
#   It constructs a translation and a rotation and
#   then does a matrix multiply to compose these operations
#
# It uses MakeTransToOrig to make the translation and
#    NormalizingImageOrientation to make the rotation
#
sub MakeTransToOrig{
  my($vec) = @_;
  my $trans = [
    [1, 0, 0, -$vec->[0] ],
    [0, 1, 0, -$vec->[1] ],
    [0, 0, 1, -$vec->[2] ],
    [ 0, 0, 0, 1]
  ];
  return $trans;
}
sub AltNormalizingVolume{
  my($iop, $ipp) = @_;
  my $translate = MakeTransToOrig($ipp);
  my $rotate = NormalizingImageOrientation($iop);
  my $norm = MatMul($rotate, $translate);
  return $norm;
}

#
# ScaleToPix scale the x and y coordinates to pixels rather than mm
#   based on pixel spacing
#   x coordinate remains in mm
#
sub ScaleToPix{
  my($point, $pix_sp) = @_;
  my($p_c, $p_r) = @$pix_sp;
  my @p;
  $p[0] = $point->[0] / $p_r;
  $p[1] = $point->[1] / $p_c;
  $p[2] = $point->[2];
  return \@p;
}

#
# PrintTransform prints a transform
#
sub PrintTransform{
  my($x_form) = @_;
  printf "%.16f\t%.16f\t\%.16f\t%.16f\n", $x_form->[0]->[0],$x_form->[0]->[1],
    $x_form->[0]->[2],$x_form->[0]->[3];
  printf "%.16f\t%.16f\t\%.16f\t%.16f\n", $x_form->[1]->[0],$x_form->[1]->[1],
    $x_form->[1]->[2],$x_form->[1]->[3];
  printf "%.16f\t%.16f\t\%.16f\t%.16f\n", $x_form->[2]->[0],$x_form->[2]->[1],
    $x_form->[2]->[2],$x_form->[2]->[3];
  printf "%.16f\t%.16f\t\%.16f\t%.16f\n", $x_form->[3]->[0],$x_form->[3]->[1],
    $x_form->[3]->[2],$x_form->[3]->[3];
}

#
# If you prefer calculus to linear algebra, ToPixCoords translates 3d points
#   to pixel coordinates based on differential rather than transforms
#   dxdc = differential of x relative to column (i.e. change in x per change in col
#   dydc = differential of y relative to column (i.e. change in y per change in col
#   dzdc = differential of z relative to column (i.e. change in z per change in col
#
#   dxdr = differential of x relative to row (i.e. change in x per change in row
#   dydr = differential of y relative to row (i.e. change in y per change in row
#   dzdr = differential of z relative to row (i.e. change in z per change in row
#
#   dxdp = differential of x relative to normal (i.e. change in x per change in normal
#   dydp = differential of y relative to normal (i.e. change in y per change in normal
#   dzdp = differential of z relative to normal (i.e. change in z per change in normal
#
# No matrix operations (except that there really are, if you look hard enough)
#
sub ToPixCoords{
  my($iop, $ipp, $rows, $cols, $pix_sp, $point) = @_;
  my($c_x, $c_y, $c_z) = @$ipp;  # Corner co-ords
  my $dxdc = $iop->[0];       # dx/dc
  my $dydc = $iop->[1];       # dy/dc
  my $dzdc = $iop->[2];       # dz/dc
  my $dxdr = $iop->[3];       # dx/dr
  my $dydr = $iop->[4];       # dy/dr
  my $dzdr = $iop->[5];       # dz/dr
  my ($p_c, $p_r) = @$pix_sp;       # pixel_spacing
  my ($x, $y, $z) = @$point;
  my $normal = cross(
    [$dxdc, $dydc, $dzdc], [$dxdr, $dydr, $dzdr]
  );
  my($dxdp, $dydp, $dzdp) = @$normal;

  my $DistC = $x - $c_x;
  my $DistR = $y - $c_y;
  my $DistP = $z - $c_z;

  my $deltaR = (($DistC * $dxdr) + ($DistR * $dydr) + ($DistP * $dzdr)) / $p_r;
  my $deltaC = (($DistC * $dxdc) + ($DistR * $dydc) + ($DistP * $dzdc)) / $p_c;
  my $deltaP = ($DistC * $dxdp) + ($DistR * $dydp) + ($DistP * $dzdp);
  return [$deltaC, $deltaR, $deltaP];
}


#################################################
#
# Here is test data.  We select a structure set, and based on dump, get a particular contour and linked MR
my $struct_set = "/nas/public/posda/storage/02/5c/5b/025c5bca7f3a922ee98b45e892bd7105";
#(3006,0039)[0](3006,0040)[17](3006,0016):(SQ, 1):Contour Image Sequence:
#(3006,0039)[0](3006,0040)[17](3006,0016)[0](0008,1150):(UI, 1):Referenced SOP Class UID:"1.2.840.10008.5.1.4.1.1.4" (MR Image Storage)
#(3006,0039)[0](3006,0040)[17](3006,0016)[0](0008,1155):(UI, 1):Referenced SOP Instance UID:"1.3.6.1.4.1.14519.5.2.1.5168.1900.239187870435323339811217409919"
#(3006,0039)[0](3006,0040)[17](3006,0042):(CS, 1):Contour Geometric Type:"CLOSED_PLANAR"
#(3006,0039)[0](3006,0040)[17](3006,0046):(IS, 1):Number of Contour Points:"575"
#(3006,0039)[0](3006,0040)[17](3006,0050):(DS, 1725):Contour Data:"-14.611\-53.268\88.76\-14.622\-5 ... .534\88.494\-14.6\-53.401\8
#
# Then we get the MR path and select geometric information from dump
my $linked_mr = "/nas/public/posda/storage/fc/ea/58/fcea58d8ec3641a9bd4e531d4860bb61";
#(0020,0032):(DS, 3):Image Position (Patient):"-3.59993e-1\-223.741\261.634"
#(0020,0037):(DS, 6):Image Orientation (Patient):"-8.3346015e-2\9.9652019e-1\-9.79 ... 2e-4\-9.7318472e-4\-9.9999952e-1 (81 f610e88
#(0028,0010):(US, 1):Rows:"512"
#(0028,0011):(US, 1):Columns:"512"
#(0028,0030):(DS, 2):Pixel Spacing:"8.008e-1\8.008e-1"
#
#################################################
# Here's the geometric information
my $iop = [-8.3346015e-2,9.9652019e-1,-9.7995078e-4,1.2180652e-4,-9.7318472e-4,-9.9999952e-1];
my $ipp = [-3.59993e-1,-223.741,261.634];
my $pix_sp = [8.008e-1,8.008e-1];
my $rows = 512;
my $cols = 512;

# Here we construct the normalizing volume two different ways:
my $NormXformTwo = NormalizingVolume($iop, $ipp);
my $NormXformOne = AltNormalizingVolume($iop, $ipp);
print "From NomalizingVolume:\n";
PrintTransform($NormXformOne);
print "From AltNomalizingVolume:\n";
PrintTransform($NormXformTwo);

# verify that they are the same

# verify that the transform maps ipp to (0, 0, 0)
my $new_ipp = ApplyTransform($NormXformOne, $ipp);
print "New ipp = ($new_ipp->[0], $new_ipp->[1], $new_ipp->[2])\n";

# Normalize the IOP and verify that it is (1, 0, 0, 0, 1, 0)
#   (requires rounding)
#
my $NormIop = NormalizingImageOrientation($iop);
my $norm_iop_x = ApplyTransform($NormIop, [$iop->[0], $iop->[1], $iop->[2]]);
print "Normalized iop[x] = [$norm_iop_x->[0], $norm_iop_x->[1], $norm_iop_x->[2]]\n";
my $norm_iop_y = ApplyTransform($NormIop, [$iop->[3], $iop->[4], $iop->[5]]);
print "Normalized iop[x] = [$norm_iop_y->[0], $norm_iop_y->[1], $norm_iop_y->[2]]\n";
for my $i (0 .. 2){
  $norm_iop_x->[$i] = sprintf("%0.06f", $norm_iop_x->[$i]);
  $norm_iop_y->[$i] = sprintf("%0.06f", $norm_iop_y->[$i]);
}
print "(Rounded) Normalized iop[y] = [$norm_iop_x->[0], $norm_iop_x->[1], $norm_iop_x->[2]]\n";
print "(Rounded) Normalized iop[y] = [$norm_iop_y->[0], $norm_iop_y->[1], $norm_iop_y->[2]]\n";


#  Here we go get the contour data
#
my $cont_str = `GetElementValue.pl $struct_set '(3006,0039)[0](3006,0040)[17](3006,0050)'`;
my @nums = split(/\\/, $cont_str);
my $num_nums = @nums;

# and turn it into points
#
unless(($num_nums % 3) == 0){
  die "number of numbers ($num_nums) isn't divisible by three (so not 3d points);\n";
}
my @points;
for my $i (0 .. ($num_nums / 3) - 1){
  push(@points, [$nums[$i * 3], $nums[($i * 3) + 1], $nums[($i + 3) + 2]]);
}
my $num_points = @points;

#  And print the first and last ten
#
print "Points:\n";
for my $i (0 .. $#points){
  if(($i < 10) || $i > ($num_points - 10)){
    my $pt = $points[$i];
    print "[$pt->[0], $pt->[1], $pt->[2]]\n";
  } elsif ($i == 10){
    print "...\n";
  }
}

# Here we map to pixel coordinates of the image using calculus
#
my @mapped_by_ToPixCoords;
for my $i (@points){
  push(@mapped_by_ToPixCoords, ToPixCoords($iop, $ipp, $rows, $cols, $pix_sp, $i));
}
print "Points mapped by ToPixCoords:\n";
for my $i (0 .. $#points){
  if(($i < 10) || $i > ($num_points - 10)){
    my $pt = $mapped_by_ToPixCoords[$i];
    print "[$pt->[0], $pt->[1], $pt->[2]]\n";
  } elsif ($i == 10){
    print "...\n";
  }
}

# Here we map to pixel coordinates of the image using the transform constructed earlier
#
my @mapped_by_ScaleToPix;
for my $i (@points){
  push(@mapped_by_ScaleToPix, ScaleToPix(ApplyTransform($NormXformTwo, $i), $pix_sp));
}
print "Points mapped by Transform, ScaleToPix\n";
for my $i (0 .. $#points){
  if(($i < 10) || $i > ($num_points - 10)){
    my $pt = $mapped_by_ScaleToPix[$i];
    print "[$pt->[0], $pt->[1], $pt->[2]]\n";
  } elsif ($i == 10){
    print "...\n";
  }
}

# verify the mappings are the same, and that the distance from the plane is small ( < .01 mm)
