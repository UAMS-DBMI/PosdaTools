#!/usr/bin/perl -w 
use strict;
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use Posda::Try;
#use Debug;
#my $dbg = sub {print @_ };
my $usage = "Usage: $0 <file> <roi_name> <coin_thickness>";

unless($#ARGV == 2){ die "$usage\n" }
my $file = $ARGV[0];
my $roi_name = $ARGV[1];
my $thickness = $ARGV[2];
unless($file =~/^\//){ $file = getcwd . "/$file" };
my $try = Posda::Try->new($file);
unless(exists $try->{dataset}) { die "$file didn't parse as DICOM file" }
my $ds = $try->{dataset};
my $modality = $ds->Get("(0008,0060)");
unless($modality eq "RTSTRUCT") {
  die "$file doesn't have RTSTRUCT as modality"
}
my $sop_class = $ds->Get("(0008,0016)");
unless($sop_class eq "1.2.840.10008.5.1.4.1.1.481.3"){
  die "$file has wrong sop_class ($sop_class) for RTSTRUCT"
}
my $m = $ds->Search("(3006,0020)[<0>](3006,0026)", $roi_name);
unless($#{$m} == 0){
  die "$file has multiple ROIs named $roi_name";
}
my $roi_i = $m->[0]->[0];
my $roi_number = $ds->Get("(3006,0020)[$roi_i](3006,0022)");
$m = $ds->Search("(3006,0039)[<0>](3006,0084)", $roi_number);
unless($#{$m} == 0){
  die "$file has multiple ROI Contour Elements for roi $roi_number";
}
my $roi_index = $m->[0]->[0];
$m = $ds->Search("(3006,0039)[$roi_index](3006,0040)[<0>](3006,0042)",
 "CLOSED_PLANAR");
my @raw_contours;
for my $i (@$m){
  push(@raw_contours,
    $ds->Get("(3006,0039)[$roi_index](3006,0040)[$i->[0]](3006,0050)"));
}
my %contours_by_z;
for my $c (@raw_contours){
  my @points_3d;
  my @points_2d;
  my $common_z;
  my $num_points = int(scalar(@$c) / 3);
  unless($num_points * 3 == scalar(@$c)) {
    die "contour not composed of 3d points"
  }
  for my $i (0 .. $num_points - 1){
    my($x, $y, $z) = ($c->[$i * 3], $c->[($i*3)+1], $c->[($i*3)+2]);
    push @points_3d, [$x, $y, $z];
    push @points_2d, [$x, $y];
    unless(defined $common_z) { $common_z = $z }
    if($common_z != $z) {
      die "$z != $common_z";
    }
  }
  unless(exists $contours_by_z{$common_z}){$contours_by_z{$common_z} = []};
  push(@{$contours_by_z{$common_z}},\@points_2d);
  my $f = $points_2d[0];
  my $l = $points_2d[$#points_2d];
  unless($f->[0] == $l->[0] && $f->[1] == $l->[1]){
    die "Contour is not closed"
  }
}
my %areas_by_z;
for my $z (keys %contours_by_z){
  my $area = 0;
  for my $i (@{$contours_by_z{$z}}){
    $area += ComputeArea($i);
  }
  $areas_by_z{$z} = $area;
}
my $tot_area;
for my $z (keys %areas_by_z){
  $tot_area += $areas_by_z{$z} * $thickness;
}
#print "result: ";
#Debug::GenPrint($dbg, \%areas_by_z, 1);
#print "\n";
$tot_area /= 1000;
print "Total Area: $tot_area CM3\n";
sub ComputeArea{
  my($points) = @_;
  my $tot;
  for my $i (0 .. $#{$points}){
    my $from_i = $i;
    my $to_i = $i + 1;
    if($to_i > $#{$points}){ $to_i -= $#{$points} + 1 }
    my $f = $points->[$from_i];
    my $t = $points->[$to_i];
    $tot += ($f->[0] * $t->[1]) - ($f->[1] * $t->[0]);
  }
  return abs($tot / 2);
}
