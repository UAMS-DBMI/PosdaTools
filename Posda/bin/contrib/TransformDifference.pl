#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use strict;
use Posda::Dataset;
use Posda::Find;
use Posda::FlipRotate;
Posda::Dataset::InitDD();

unless(
  $#ARGV == 2 &&
  -f $ARGV[0] &&
  -f $ARGV[1] &&
  -d $ARGV[2]
){ die "usage: $0 <reg1> <reg2> <dir>" }
my $dir = $ARGV[2];
unless($dir =~ /^\//) {$dir = getcwd."/$dir"}
my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($ARGV[0]);
unless($ds) { die "$ARGV[0] is not a DICOM file" }
my($df1, $ds1, $size1, $xfr_stx1, $errors1) = Posda::Dataset::Try($ARGV[1]);
unless($ds1) { die "$ARGV[1] is not a DICOM file" }
my $sc = $ds->ExtractElementBySig("(0008,0016)");
my $sc1 = $ds->ExtractElementBySig("(0008,0016)");
unless($sc eq "1.2.840.10008.5.1.4.1.1.66.1"){
  die "$ARGV[0] is not a Spatial Registration"
}
unless($sc1 eq "1.2.840.10008.5.1.4.1.1.66.1"){
  die "$ARGV[0] is not a Spatial Registration"
}
my $for = $ds->ExtractElementBySig("(0020,0052)");
my $for1 = $ds1->ExtractElementBySig("(0020,0052)");
unless($for eq $for1){
  die "$ARGV[0] and $ARGV[1] don't transform from the same frame of reference"
}
my $d_for = $ds->ExtractElementBySig("(0070,0308)[1](0020,0052)");
my $d_for1 = $ds->ExtractElementBySig("(0070,0308)[1](0020,0052)");
unless($d_for eq $d_for1){
  die "$ARGV[0] and $ARGV[1] don't tranform to the same frame of reference"
}
my $x_form = $ds->ExtractElementBySig(
  "(0070,0308)[1](0070,0309)[0](0070,030a)[0](3006,00c6)"
);
my $x_form1 = $ds1->ExtractElementBySig(
  "(0070,0308)[1](0070,0309)[0](0070,030a)[0](3006,00c6)"
);
my $max_x; 
my $min_x; 
my $max_y;
my $min_y;
my $max_z;
my $min_z;
my $reader = sub {
  my($f_name, $df, $ds, $size, $xfr_stx, $errors) = @_;
  my $rows = $ds->ExtractElementBySig("(0028,0010)");
  my $cols = $ds->ExtractElementBySig("(0028,0011)");
  my $iop = $ds->ExtractElementBySig("(0020,0037)");
  my $ipp = $ds->ExtractElementBySig("(0020,0032)");
  my $pix_sp = $ds->ExtractElementBySig("(0028,0030)");
  unless(
    defined $rows &&
    defined $cols &&
    defined $iop &&
    defined $ipp &&
    defined $pix_sp
  ){ return }
  my($tlhc, $trhc, $blhc, $brhc) =
    Posda::FlipRotate::ToCorners($rows, $cols, $iop, $ipp, $pix_sp);
  for my $point($tlhc, $trhc, $blhc, $brhc){
    unless(defined($max_x)) {$max_x = $point->[0]}
    unless(defined($max_y)) {$max_y = $point->[1]}
    unless(defined($max_z)) {$max_z = $point->[2]}
    unless(defined($min_x)) {$min_x = $point->[0]}
    unless(defined($min_y)) {$min_y = $point->[1]}
    unless(defined($min_z)) {$min_z = $point->[2]}
    if($point->[0] > $max_x) {$max_x = $point->[0]};
    if($point->[1] > $max_y) {$max_y = $point->[1]};
    if($point->[2] > $max_z) {$max_z = $point->[2]};
    if($point->[0] < $min_x) {$min_x = $point->[0]};
    if($point->[1] < $min_y) {$min_y = $point->[1]};
    if($point->[2] < $min_z) {$min_z = $point->[2]};
  }
};
Posda::Find::SearchDir($dir, $reader);
my $c0 = [$max_x, $max_y, $max_z];
my $c1 = [$max_x, $max_y, $min_z];
my $c2 = [$max_x, $min_y, $max_z];
my $c3 = [$max_x, $min_y, $min_z];
my $c4 = [$min_x, $max_y, $max_z];
my $c5 = [$min_x, $max_y, $min_z];
my $c6 = [$min_x, $min_y, $max_z];
my $c7 = [$min_x, $min_y, $min_z];
my $max_dist;
for my $point($c0, $c1, $c1, $c3, $c4, $c5, $c6, $c7){
  my $t1 = VectorMath::ApplyTransform($x_form, $point);
  my $t2 = VectorMath::ApplyTransform($x_form1, $point);
  my $d = VectorMath::Dist($t1, $t2);
  unless(defined $max_dist) { $max_dist = $d }
  if($d > $max_dist) { $max_dist = $d}
}
print "$max_dist\n";
