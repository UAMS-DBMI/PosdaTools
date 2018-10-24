#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Try;
use Posda::Resample;
use Posda::FlipRotate;
use VectorMath;

# Resamples Dose to be orthonormal to bounding box of dose

my $try = Posda::Try->new($ARGV[0]);
unless($try->{dataset}) {
  die "$ARGV[0] isn't a dicom file";
}
my $ds = $try->{dataset};
my $iop = $ds->Get("(0020,0037)");
my $ipp = $ds->Get("(0020,0032)");
my $gfov = $ds->Get("(3004,000c)");
my $pix_sp = $ds->Get("(0028,0030)");
my $bits_alloc = $ds->Get("(0028,0100)");
my $rows = $ds->Get("(0028,0010)");
my $cols = $ds->Get("(0028,0010)");
my $max_off = $gfov->[$#{$gfov}];
my($rtl, $rtr, $rbl, $rbr) = Posda::FlipRotate::ToCorners(
  $rows, $cols, $iop, $ipp, $pix_sp);
my $norm = VectorMath::cross([$iop->[0], $iop->[1], $iop->[2]],
  [$iop->[3], $iop->[4], $iop->[5]]);
my $scaled_norm = VectorMath::Scale($max_off, $norm);
my $l_ipp = VectorMath::Add($ipp, $scaled_norm);
my($ltl, $ltr, $lbl, $lbr) = Posda::FlipRotate::ToCorners(
  $rows, $cols, $iop, $l_ipp, $pix_sp);
my($min_x, $min_y, $min_z, $max_x, $max_y, $max_z);
for my $p ($rtl, $rtr, $rbl, $rbr, $ltl, $ltr, $lbl, $lbr){
  unless(defined $min_x) { $min_x = $p->[0] }
  unless(defined $min_y) { $min_y = $p->[1] }
  unless(defined $min_z) { $min_z = $p->[2] }
  unless(defined $max_x) { $max_x = $p->[0] }
  unless(defined $max_y) { $max_y = $p->[1] }
  unless(defined $max_z) { $max_z = $p->[2] }
  if($p->[0] < $min_x) { $min_x = $p->[0] }
  if($p->[1] < $min_y) { $min_y = $p->[1] }
  if($p->[2] < $min_z) { $min_z = $p->[2] }
  if($p->[0] > $max_x) { $max_x = $p->[0] }
  if($p->[1] > $max_y) { $max_y = $p->[1] }
  if($p->[2] > $max_z) { $max_z = $p->[2] }
}
my $pix_sp_x = ($max_x - $min_x) / ($cols - 1);
my $pix_sp_y = ($max_y - $min_y) / ($rows - 1);
my $frame_sp = ($max_z - $min_z) / $#{$gfov};

my $args = {
  max_x => $max_x,
  max_y => $max_y,
  max_z => $max_z,
  min_x => $min_x,
  min_y => $min_y,
  min_z => $min_z,
  pix_sp_x => $pix_sp_x,
  pix_sp_y => $pix_sp_y,
  frame_sp => $frame_sp,
  new_bits => $bits_alloc,
};
$ds = Posda::Resample::Dose($ds, $args);
my $new_file = "$ARGV[0].new";
$ds->WritePart10($new_file, $try->{xfr_stx}, "POSDA", undef, undef);

