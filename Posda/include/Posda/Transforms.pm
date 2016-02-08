#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Math::Trig;
use VectorMath;
package Posda::Transforms;
my $eps = .00000001;
sub MakeRotZ{
  my($theta) = @_;
  my $rot = [
    [ cos($theta), -sin($theta), 0, 0 ],
    [ sin($theta), cos($theta), 0, 0 ],
    [ 0, 0, 1, 0 ],
    [ 0, 0, 0, 1]
  ];
  return $rot;
}
sub MakeRotY{
  my($theta) = @_;
  my $rot = [
    [ cos($theta), 0, sin($theta), 0 ],
    [ 0, 1, 0, 0 ],
    [ -sin($theta), 0, cos($theta), 0 ],
    [ 0, 0, 0, 1]
  ];
  return $rot;
}
sub MakeRotX{
  my($theta) = @_;
  my $rot = [
    [ 1, 0, 0, 0 ],
    [ 0, cos($theta), -sin($theta), 0 ],
    [ 0, sin($theta), cos($theta), 0 ],
    [ 0, 0, 0, 1]
  ];
  return $rot;
}
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
sub MakeTransFromOrig{
  my($vec) = @_;
  my $trans = [
    [1, 0, 0, $vec->[0] ],
    [0, 1, 0, $vec->[1] ],
    [0, 0, 1, $vec->[2] ],
    [ 0, 0, 0, 1]
  ];
  return $trans;
}
sub MakeFromDicomXform{
  my($dic) = @_;
  my @xform;
  $xform[0]->[0] = $dic->[0];
  $xform[0]->[1] = $dic->[1];
  $xform[0]->[2] = $dic->[2];
  $xform[0]->[3] = $dic->[3];
  $xform[1]->[0] = $dic->[4];
  $xform[1]->[1] = $dic->[5];
  $xform[1]->[2] = $dic->[6];
  $xform[1]->[3] = $dic->[7];
  $xform[2]->[0] = $dic->[8];
  $xform[2]->[1] = $dic->[9];
  $xform[2]->[2] = $dic->[10];
  $xform[2]->[3] = $dic->[11];
  $xform[3]->[0] = $dic->[12];
  $xform[3]->[1] = $dic->[13];
  $xform[3]->[2] = $dic->[14];
  $xform[3]->[3] = $dic->[15];
  return \@xform;
}
sub NormalizeTransform{
  my($x_form) = @_;
print STDERR "###############\n" .
  "NormalizeTransform being called\n" .
  "###############\n";
  my @n_form;
  for my $i (0 .. 3){
    for my $j (0 ..3){
      if(abs($x_form->[$i]->[$j]) < $eps){
        $n_form[$i]->[$j] = 0;
      } elsif(abs($x_form->[$i]->[$j] - 1) < $eps){
        if($x_form->[$i]->[$j] < 0){
          $n_form[$i]->[$j] = -1;
        } else {
          $n_form[$i]->[$j] = 1;
        }
      } else {
        $n_form[$i]->[$j] = $x_form->[$i]->[$j];
      }
    }
  }
  return \@n_form;
}
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
sub PrintErrorTransform{
  my($x_form) = @_;
  printf STDERR "%.16f\t%.16f\t\%.16f\t%.16f\n", $x_form->[0]->[0],$x_form->[0]->[1],
    $x_form->[0]->[2],$x_form->[0]->[3];
  printf STDERR "%.16f\t%.16f\t\%.16f\t%.16f\n", $x_form->[1]->[0],$x_form->[1]->[1],
    $x_form->[1]->[2],$x_form->[1]->[3];
  printf STDERR "%.16f\t%.16f\t\%.16f\t%.16f\n", $x_form->[2]->[0],$x_form->[2]->[1],
    $x_form->[2]->[2],$x_form->[2]->[3];
  printf STDERR "%.16f\t%.16f\t\%.16f\t%.16f\n", $x_form->[3]->[0],$x_form->[3]->[1],
    $x_form->[3]->[2],$x_form->[3]->[3];
}
sub ApplyTransform{
  my($x_form, $vec) = @_;
  unless(
    ref($x_form) eq "ARRAY" && $#{$x_form} == 3 &&
    ref($x_form->[0]) eq "ARRAY" && $#{$x_form->[0]} == 3 &&
    ref($x_form->[1]) eq "ARRAY" && $#{$x_form->[1]} == 3 &&
    ref($x_form->[2]) eq "ARRAY" && $#{$x_form->[2]} == 3 &&
    ref($x_form->[3]) eq "ARRAY" && $#{$x_form->[3]} == 3
  ){
    print STDERR "Xform:\n";
    for my $i (@$x_form){
      for my $j (@$i){
        print STDERR "$j ";
      }
      print STDERR "\n";
    }
    die "x_form is not 4x4 array";
  }
  unless(ref($vec) eq "ARRAY" && $#{$vec} == 2){
    my $i = 0;
    print "Backtrace:\n";
    while(caller($i)){
      my @foo = caller($i);
      $i++;
      my $file = $foo[1];
      my $line = $foo[2];
      print "\tline $line of $file\n";
    }
    die "vec is not a 3D vector";
  }
  unless(
    abs($x_form->[3]->[0]) < $eps &&
    abs($x_form->[3]->[1]) < $eps &&
    abs($x_form->[3]->[2]) < $eps &&
    abs($x_form->[3]->[3] - 1) < $eps
  ){
    print STDERR "Apply tranform: This may not be a legal DICOM transform:\n";
    print STDERR "$x_form->[0]->[0]\t$x_form->[0]->[1]," . 
      " $x_form->[0]->[2]\t$x_form->[0]->[3]\n";
    print STDERR "$x_form->[1]->[0]\t$x_form->[1]->[1]," . 
      " $x_form->[1]->[2]\t$x_form->[1]->[3]\n";
    print STDERR "$x_form->[2]->[0]\t$x_form->[2]->[1]," . 
      " $x_form->[2]->[2]\t$x_form->[2]->[3]\n";
    print STDERR "$x_form->[3]->[0]\t$x_form->[3]->[1]," . 
      " $x_form->[3]->[2]\t$x_form->[3]->[3]\n";
  }
  my $n_x = sprintf("%0.6f", 
    (
       $vec->[0] * $x_form->[0]->[0] +
       $vec->[1] * $x_form->[0]->[1] +
       $vec->[2] * $x_form->[0]->[2] +
       1 * $x_form->[0]->[3]
    )
  );
  my $n_y = sprintf("%0.6f", 
    (
      $vec->[0] * $x_form->[1]->[0] +
      $vec->[1] * $x_form->[1]->[1] +
      $vec->[2] * $x_form->[1]->[2] +
      1 * $x_form->[1]->[3]
    ),
  );
  my $n_z = sprintf("%0.6f", 
    (
      $vec->[0] * $x_form->[2]->[0] +
      $vec->[1] * $x_form->[2]->[1] +
      $vec->[2] * $x_form->[2]->[2] +
      1 * $x_form->[2]->[3]
    )
  );
  my $n_o = sprintf("%0.6f", 
    (
      $vec->[0] * $x_form->[3]->[0] +
      $vec->[1] * $x_form->[3]->[1] +
      $vec->[2] * $x_form->[3]->[2] +
      1 * $x_form->[3]->[3]
    )
  );
  unless($n_o == 1){
    print STDERR "Error applying x_form: $n_o should be 1\n";
  }
  my $res = [$n_x, $n_y, $n_z];
  return $res;
}
sub ApplyTransformList{
  my($t_l, $vec) = @_;
  my $n_vec = $vec;
  for my $x (@$t_l){
    $n_vec = ApplyTransform($x, $n_vec);
  }
  return $n_vec;
}
sub InvertTransform{
  my($x_form) = @_;
  my @inv;
  unless(
    ref($x_form) eq "ARRAY" && $#{$x_form} == 3 &&
    ref($x_form->[0]) eq "ARRAY" && $#{$x_form->[0]} == 3 &&
    ref($x_form->[1]) eq "ARRAY" && $#{$x_form->[1]} == 3 &&
    ref($x_form->[2]) eq "ARRAY" && $#{$x_form->[2]} == 3 &&
    ref($x_form->[3]) eq "ARRAY" && $#{$x_form->[3]} == 3
  ){
    print STDERR "Xform:\n";
    for my $i (@$x_form){
      for my $j (@$i){
        print STDERR "$j ";
      }
      print STDERR "\n";
    }
    die "x_form is not 4x4 array";
  }
  unless(
    $x_form->[3]->[0] == 0 &&
    $x_form->[3]->[1] == 0 &&
    $x_form->[3]->[2] == 0 &&
    abs($x_form->[3]->[3] - 1) < $eps &&
    abs(
      ($x_form->[0]->[0] * $x_form->[0]->[0]) +
      ($x_form->[0]->[1] * $x_form->[0]->[1]) +
      ($x_form->[0]->[2] * $x_form->[0]->[2])
    ) - 1 < $eps &&
    abs(
      ($x_form->[1]->[0] * $x_form->[1]->[0]) +
      ($x_form->[1]->[1] * $x_form->[1]->[1]) +
      ($x_form->[1]->[2] * $x_form->[1]->[2])
    ) - 1 < $eps &&
    abs(
      ($x_form->[2]->[0] * $x_form->[2]->[0]) +
      ($x_form->[2]->[1] * $x_form->[2]->[1]) +
      ($x_form->[2]->[2] * $x_form->[2]->[2])
    ) - 1 < $eps
  ){
    print STDERR "Invert tranform:\n";
    print STDERR "$x_form->[0]->[0]\t$x_form->[0]->[1]," . 
      " $x_form->[0]->[2]\t$x_form->[0]->[3]\n";
    print STDERR "$x_form->[1]->[0]\t$x_form->[1]->[1]," . 
      " $x_form->[1]->[2]\t$x_form->[1]->[3]\n";
    print STDERR "$x_form->[2]->[0]\t$x_form->[2]->[1]," . 
      " $x_form->[2]->[2]\t$x_form->[2]->[3]\n";
    print STDERR "$x_form->[3]->[0]\t$x_form->[3]->[1]," . 
      " $x_form->[3]->[2]\t$x_form->[3]->[3]\n";
    die "Only invert rigid tranforms"; 
  }
  $inv[0]->[0] = $x_form->[0]->[0];
  $inv[0]->[1] = $x_form->[1]->[0];
  $inv[0]->[2] = $x_form->[2]->[0];
  $inv[0]->[3] = -(($x_form->[0]->[0] * $x_form->[0]->[3]) +
                   ($x_form->[1]->[0] * $x_form->[1]->[3]) +
                   ($x_form->[2]->[0] * $x_form->[2]->[3])
                  ); 
  $inv[1]->[0] = $x_form->[0]->[1];
  $inv[1]->[1] = $x_form->[1]->[1];
  $inv[1]->[2] = $x_form->[2]->[1];
  $inv[1]->[3] = -(($x_form->[0]->[1] * $x_form->[0]->[3]) +
                   ($x_form->[1]->[1] * $x_form->[1]->[3]) +
                   ($x_form->[2]->[1] * $x_form->[2]->[3])
                  ); 

  $inv[2]->[0] = $x_form->[0]->[2];
  $inv[2]->[1] = $x_form->[1]->[2];
  $inv[2]->[2] = $x_form->[2]->[2];
  $inv[2]->[3] = -(($x_form->[0]->[2] * $x_form->[0]->[3]) +
                   ($x_form->[1]->[2] * $x_form->[1]->[3]) +
                   ($x_form->[2]->[2] * $x_form->[2]->[3])
                  ); 

  $inv[3]->[0] = 0;
  $inv[3]->[1] = 0;
  $inv[3]->[2] = 0;
  $inv[3]->[3] = 1;

  return \@inv;
}
sub NormalizingImageOrientation{
  my($iop) = @_;
  my $norm = VectorMath::cross([$iop->[0], $iop->[1], $iop->[2]],
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
sub TransformBoundingBox{
  my($xform, $bb) = @_;
  my @list;
  for my $p ($bb->[0], $bb->[1]){
    push(@list, ApplyTransform($xform, $p));
  }
  return BoundingBox(@list) ;
}
sub IsIdentity{
  my($xform) = @_;
  if(
    abs($xform->[0]->[0] - 1) < $eps &&
    abs($xform->[0]->[1]) < $eps &&
    abs($xform->[0]->[2]) < $eps &&
    abs($xform->[0]->[3]) < $eps &&
    abs($xform->[1]->[0]) < $eps &&
    abs($xform->[1]->[1] - 1) < $eps &&
    abs($xform->[1]->[2]) < $eps &&
    abs($xform->[1]->[3]) < $eps &&
    abs($xform->[2]->[0]) < $eps &&
    abs($xform->[2]->[1]) < $eps &&
    abs($xform->[2]->[2] - 1) < $eps &&
    abs($xform->[2]->[3]) < $eps &&
    abs($xform->[3]->[0]) < $eps &&
    abs($xform->[3]->[1]) < $eps &&
    abs($xform->[3]->[2]) < $eps &&
    abs($xform->[3]->[3] - 1) < $eps
  ){
    return 1;
  }
  return 0;
}
sub SeparateRotationXlation{
  my($x) = @_;
  my $rot = [
    [$x->[0]->[0], $x->[0]->[1], $x->[0]->[2], 0],
    [$x->[1]->[0], $x->[1]->[1], $x->[1]->[2], 0],
    [$x->[2]->[0], $x->[2]->[1], $x->[2]->[2], 0],
    [$x->[3]->[0], $x->[3]->[1], $x->[3]->[2], 1]
  ];
  my $xlate = [
    [1, 0, 0, $x->[0]->[3]],
    [0, 1, 0, $x->[1]->[3]],
    [0, 0, 1, $x->[2]->[3]],
    [0, 0, 0, 1]
  ];
  return($rot, $xlate);
}
#sub CollapseTransformList{
#  my($vec) = @_;
#  my $trans = shift(@$vec);
#  while(my $next_xform = shift(@$vec)){
#    $trans = MatMul($trans, $next_xform);
#  }
#  return $trans;
#}
sub CollapseTransformList{
  my($vec) = @_;
  my $trans = shift(@$vec);
  while(my $next_xform = shift(@$vec)){
    $trans = MatMul($next_xform, $trans);
  }
  return $trans;
}
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
sub MakeTransformPair {
  my($commands) = @_;
  my @x_form_list;
  for my $i (@$commands) {
    if($i->[0] eq "rx"){
      my $r = Math::Trig::deg2rad($i->[1]);
      push(@x_form_list, MakeRotX($r));
    }elsif($i->[0] eq "ry"){
      my $r = Math::Trig::deg2rad($i->[1]);
      push(@x_form_list, MakeRotY($r));
    }elsif($i->[0] eq "rz"){
      my $r = Math::Trig::deg2rad($i->[1]);
      push(@x_form_list, MakeRotZ($r));
    }elsif($i->[0] eq "shift"){
      unless($i->[1] =~ /^\((.*),(.*),(.*)\)$/) { die "bad shift" }
      my $x = $1;
      my $y = $2;
      my $z = $3;
      push(@x_form_list, [
        [1, 0, 0, $x],
        [0, 1, 0, $y],
        [0, 0, 1, $z],
        [0, 0, 0, 1],
      ]);
    }
  }
  my $x_form = CollapseTransformList(\@x_form_list);
  my $rev_rot = [
    [$x_form->[0]->[0], $x_form->[1]->[0], $x_form->[2]->[0], 0],
    [$x_form->[0]->[1], $x_form->[1]->[1], $x_form->[2]->[1], 0],
    [$x_form->[0]->[2], $x_form->[1]->[2], $x_form->[2]->[2], 0],
    [$x_form->[3]->[0], $x_form->[3]->[1], $x_form->[3]->[2], 1],
  ];
  my $tlhc = [0,0,0];
  my $r_tlhc = ApplyTransform($x_form, $tlhc);
  my $f_tlhc = ApplyTransform($rev_rot, $r_tlhc);
  $rev_rot->[0]->[3] = -$f_tlhc->[0];
  $rev_rot->[1]->[3] = -$f_tlhc->[1];
  $rev_rot->[2]->[3] = -$f_tlhc->[2];
  return($x_form, $rev_rot);
}
sub BoundingBox{
  my($min_x, $min_y, $min_z, $max_x, $max_y, $max_z);
  for my $p (@_){
    unless(defined $max_x) { $max_x = $p->[0] }
    unless(defined $max_y) { $max_y = $p->[1] }
    unless(defined $max_z) { $max_z = $p->[2] }
    unless(defined $min_x) { $min_x = $p->[0] }
    unless(defined $min_y) { $min_y = $p->[1] }
    unless(defined $min_z) { $min_z = $p->[2] }
    if($p->[0] > $max_x) { $max_x = $p->[0] }
    if($p->[1] > $max_y) { $max_y = $p->[1] }
    if($p->[2] > $max_z) { $max_z = $p->[2] }
    if($p->[0] < $min_x) { $min_x = $p->[0] }
    if($p->[1] < $min_y) { $min_y = $p->[1] }
    if($p->[2] < $min_z) { $min_z = $p->[2] }
  }
  return [[$min_x, $min_y, $min_z], [$max_x, $max_y, $max_z]];
}

1;
