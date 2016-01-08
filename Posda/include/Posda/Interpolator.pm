#!usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/Interpolator.pm,v $
#$Date: 2011/12/21 13:50:42 $
#$Revision: 1.9 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package Posda::Interpolator;
sub gcd{
  my($x, $y) = @_;
  if($y == 0){
    return $x;
  } else {
    return gcd($y, $x % $y);
  }
}
my $epsilon = 0.0000000001;
sub CalcScale{
  my($from, $to) = @_;
  my $num = $from - 1;
  my $denom = $to - 1;
  my $gcd = gcd($num, $denom);
  my $quo = int($denom/$num);
  unless($gcd == 1 && $to > $from){
    die "Calc Scale called with illegal operands $from, $to (gcd == $gcd)"
  }
  my @first = (  0,    1,    0,    0);
  my @last = ($num,    0, $num,    1);
  my @list;
  push(@list, \@first);
  my $this_from_col = 0;
  my $output_row = 1;
  while($output_row < $denom){
    my $this_from_col_pos = $this_from_col * $denom;
    my $next_from_col_pos = $this_from_col_pos + $denom;
    my $output_row_pos = $output_row * $num;
    if(
      $this_from_col_pos <= $output_row_pos &&
      $output_row_pos < $next_from_col_pos
    ){
      my $left_dist = $output_row_pos - $this_from_col_pos;
      my $right_dist = $next_from_col_pos -$output_row_pos;
      unless($left_dist + $right_dist == $denom){
        die "$left_dist + $right_dist != $denom";
      }
      push(@list, 
        [$this_from_col, $right_dist / $denom, 
         $this_from_col + 1, $left_dist / $denom]);
      $output_row += 1;
    } elsif($output_row_pos > $next_from_col_pos){
      $this_from_col += 1;
    } else {
      die "oops";
    }
  }
  push(@list, \@last);
  return \@list;
}
sub new{
  my($class, $from, $to) = @_;
  my $num = $from - 1;
  my $denom = $to - 1;
  my $gcd = gcd($num, $denom);
  if($gcd == 1){ return bless CalcScale($from, $to), $class }
  if($gcd > 1){
    $denom = $denom / $gcd;
    $num = $num / $gcd;
  }
  my $inc = 1 + ($gcd % $denom);
  my $new_from = $num + 1;
  my $new_to = $denom + 1;
  my $list = CalcScale($new_from, $new_to);
  my $cur_inc = $num;
  for my $g (2 .. $gcd){
    for my $i (1 .. $denom){
      my @row = @{$list->[$i]};
      $row[0] += $cur_inc;
      $row[2] += $cur_inc;
      push(@{$list}, \@row);
    }
    $cur_inc += $num;
  }
  return bless $list, $class;
}
sub FancyNew{
  my($class, $from_offset, $to_offset, 
    $from_pix_space, $to_pix_space, $from_pix_num, $to_pix_num) = @_;
  my $to_end = $to_offset + ($to_pix_space * ($to_pix_num - 1));
  my $from_end = $from_offset + ($from_pix_space * ($from_pix_num - 1));
  unless(
    (($from_offset <= $to_offset && $to_offset <= $from_end) ||
    ($from_offset >= $to_offset && $to_offset >= $from_end)) &&
    (($from_offset <= $to_end && $to_end <= $from_end) ||
    ($from_offset >= $to_end && $to_end >= $from_end))
  ){
    die "new ends ($to_offset, $to_end) not within old ends ($from_offset, " .
      "$from_end";
  }
  my @rows;
  for my $i (0 .. $to_pix_num - 1){
    my $pix_off = $to_offset + ($i * $to_pix_space);
    my $old_pix_dist = (abs($pix_off - $from_offset))/$from_pix_space;
    my $old_pix_num = int $old_pix_dist;
    my $old_pix_frac = $old_pix_dist - $old_pix_num;
    if($old_pix_frac > $epsilon && $old_pix_num + 1 > $from_pix_num){
      my $message = "Error:\n" .
        "from_offset: $from_offset\n" .
        "to_offset: $to_offset\n" .
        "from_pix_space: $from_pix_space\n" .
        "to_pix_space: $to_pix_space\n" .
        "from_pix_num: $from_pix_num\n" .
        "to_pix_num: $to_pix_num";
      die "Hmm...  going past the end of a row:\n$message";
    }
    push(@rows, 
      [$old_pix_num, 1 - $old_pix_frac, $old_pix_num + 1, $old_pix_frac]
    );
  }
  return bless \@rows, $class;
}
sub InterpolateRow{
  my($this, $row) = @_;
  my @output;
  for my $i (0 .. $#{$this}){
    my $d = $this->[$i];
    push(@output, (($row->[$d->[0]] * $d->[1]) + ($row->[$d->[2]] * $d->[3])));
  }
  return \@output;
}
sub InterpolateColumns{
  my($this, $out_row_num, $row1_num, $row2_num, $row1, $row2) = @_;
  my @output;
  unless($#{$row1} == $#{$row2}) {
    die "non-matching row sizes $#{$row1} vs $#{$row2}";
  }
  my $d = $this->[$out_row_num];
  if($d->[0] == $row1_num && $d->[2] == $row2_num){
    for my $i (0 .. $#{$row1}){
      push(@output, (($row1->[$i] * $d->[1]) + ($row2->[$i] * $d->[3])));
    }
  } else {
    unless(
      $d->[0] == $d->[2] &&
      (  $d->[0] == $row1_num || $d->[2] == $row2_num )
    ){
      die "wrong row nums passed to Interpolate Columns: $out_row_num, " .
      "$row1_num, $row2_num";
    }
    if($row1_num == $d->[0]){
      @output = @$row1;
    } else {
      @output = @$row2;
    }
  }
  return \@output;
}
sub DebugDump{
  my($this) = @_;
  print "[\n";
  my $index = 0;
  for my $i (@$this){
    print("  [$i->[0] => $i->[1], $i->[2] => $i->[3],  #$index\n" );
    $index += 1;
  }
  print "];\n";
}
sub InterpolateArray{
  my($from_array, $to_array, $frac, $rows, $cols, $bits_alloc) = @_;
  unless(
    $frac <= 1 && $frac >= 0
  ){
    die "Bad frac: $frac\n";
  }
  if($frac < 0.001){ return $from_array }
  if(abs(1 - $frac) < 0.001){ return $to_array }
  my $int_array;
  if($bits_alloc == 16){
    $int_array = "\0" x ($rows * $cols * 2);
  } elsif ($bits_alloc == 32){
    $int_array = "\0" x ($rows * $cols * 4);
  } else {
    die "bad bits_alloc: $bits_alloc";
  }
  for my $i (0 .. $rows - 1){
    for my $j (0 .. $cols - 1){
      my $index = ($i * $cols) + $j;
      my($from, $to);
      if($bits_alloc == 16){
        $from = unpack("v", pack("n", vec($from_array, $index, $bits_alloc)));
        $to = unpack("v", pack("n", vec($to_array, $index, $bits_alloc)));
      } else {
        $from = unpack("V", pack("N", vec($from_array, $index, $bits_alloc)));
        $to = unpack("V", pack("N", vec($to_array, $index, $bits_alloc)));
      }
      my $int = ($to * $frac) + ($from * (1 - $frac));
      my $round = $int + .5;
      if($bits_alloc == 16){
        vec($int_array, $index, $bits_alloc) = unpack("n", pack("v", $round));
      } else {
        vec($int_array, $index, $bits_alloc) = unpack("N", pack("V", $round));
      }
    }
  }
  return $int_array;
}
my $Interp = sub {
  my($from, $to, $des, $from_val, $to_val, $level) = @_;
  my($c_x, $c_y, $c_z) = @{$des->[0]};  # Corner co-ords
  my $dxdr = $des->[1]->[0];       # dx/dr
  my $dydr = $des->[1]->[1];       # dy/dr
  my $dzdr = $des->[1]->[2];       # dz/dr
  my $dxdc = $des->[1]->[3];       # dx/dc
  my $dydc = $des->[1]->[4];       # dy/dc
  my $dzdc = $des->[1]->[5];       # dz/dc
  my ($p_y, $p_x) = @{$des->[2]};       # pixel_spacing
  my ($f_r, $f_c) = @$from;             # from rows, cols
  my ($t_r, $t_c) = @$to;               # to rows/cols

  my $f_x = $c_x + (($f_r * $p_x) * $dxdr) + (($f_c * $p_y) * $dxdc);
  my $f_y = $c_y + (($f_r * $p_x) * $dydr) + (($f_c * $p_y) * $dydc);
  my $f_z = $c_z + (($f_r * $p_x) * $dzdr) + (($f_c * $p_y) * $dzdc);

  my $t_x = $c_x + (($t_r * $p_x) * $dxdr) + (($t_c * $p_y) * $dxdc);
  my $t_y = $c_y + (($t_r * $p_x) * $dydr) + (($t_c * $p_y) * $dydc);
  my $t_z = $c_z + (($t_r * $p_x) * $dzdr) + (($t_c * $p_y) * $dzdc);

  unless(
    ($from_val <= $level && $level <= $to_val) ||
    ($to_val <= $level && $level <= $from_val)
  ){
    die "level must be between values at points: $level, ($from_val, $to_val)";
  }
  my $d = $to_val - $from_val;
  my $frac = ($level - $from_val) / $d;
  unless($frac >= 0 && $frac <= 1) { die "bad frac: $frac" }

  my $i_x = ($frac * ($t_x - $f_x)) + $f_x;
  my $i_y = ($frac * ($t_y - $f_y)) + $f_y;
  my $i_z = ($frac * ($t_z - $f_z)) + $f_z;
  return ("$i_x\\$i_y\\$i_z");
};
my $FindEnds = sub {
  my($Points) = @_;
  my %starts;
  my %ends;
  my %linked_to;
  for my $i (keys %$Points){
    unless(exists $Points->{$Points->{$i}}){
      $ends{$Points->{$i}} = 1;
    }
    $linked_to{$Points->{$i}} = 1;
  }
  for my $i (keys %$Points){
    unless(exists $linked_to{$i}){
      $starts{$i} = 1;
    }
  }
  my $num_start = scalar keys %starts;
  my $num_end = scalar keys %ends;
  unless ($num_start >= $num_end){
    die "num_start ($num_start) < num_end ($num_end)";
  }
  return(\%starts, \%ends, $num_start, $num_end);
};

sub Corners {
  my($id, $rows, $cols) = @_;
  my @tlhc = @{$id->[0]};
  my ($dxdc, $dydc, $dzdc, $dxdr, $dydr, $dzdr) = @{$id->[1]};
  my ($pix_y, $pix_x) = @{$id->[2]};
  my $dxc = $pix_x * $dxdc * ($cols - 1);
  my $dyc = $pix_x * $dydc * ($cols - 1);
  my $dzc = $pix_x * $dzdc * ($cols - 1);
  my $dxr = $pix_y * $dxdr * ($rows - 1);
  my $dyr = $pix_y * $dydr * ($rows - 1);
  my $dzr = $pix_y * $dzdr * ($rows - 1);
  my @trhc;
  $trhc[0] = $tlhc[0] + $dxc;
  $trhc[1] = $tlhc[1] + $dyc;
  $trhc[2] = $tlhc[2] + $dzc;
  my @blhc;
  $blhc[0] = $tlhc[0] + $dxr;
  $blhc[1] = $tlhc[1] + $dyr;
  $blhc[2] = $tlhc[2] + $dzr;
  my @brhc;
  $brhc[0] = $tlhc[0] + $dxr + $dxc;
  $brhc[1] = $tlhc[1] + $dyr + $dyc;
  $brhc[2] = $tlhc[2] + $dzr + $dzc;

  return (\@tlhc, \@trhc, \@brhc, \@blhc);
}

# This subroutine characterizes a start or end point relative to the
# corners of a (3-D) rectangle:
#  0, 0 - The point is the upper left hand corner
#  0, x (where 0 < x < 1) - the point is on the top edge of the rectangle.
#                           x is the fraction of the way from ul to ur.
#  1, 0 - The point is the upper right hand corner
#  1, x (where 0 < x < 1) - the point is on the right edge of the rectangle.
#                           x says how far down.
#  2, 0 - The point is the bottom right hand corner
#  2, x - etc.
#
#  3, 0 - The point is the bottom left hand corner.
#  3, x - etc.
#
#  This routine will die if the point is not coincident with one of the edges
#
#  It will also die if x turns up greater than 1 (point not in rectangle?)
#
sub CharacterizeSEPoint{
  my($point, $tlhc, $trhc, $brhc, $blhc) = @_;
  my $epsilon = 0.0000001;
  my($cat, $x);
  if(VectorMath::Dist($point, $tlhc) < $epsilon){
    $cat = 0;
    $x = 0;
  } elsif(VectorMath::Dist($point, $trhc) < $epsilon){
    $cat = 1;
    $x = 0;
  } elsif(VectorMath::Dist($point, $brhc) < $epsilon){
    $cat = 2;
    $x = 0;
  } elsif(VectorMath::Dist($point, $blhc) < $epsilon){
    $cat = 3;
    $x = 0;
  } elsif(VectorMath::Collinear($point, $tlhc, $trhc)){
    $cat = 0;
    $x = VectorMath::Dist($tlhc, $point) / VectorMath::Dist($tlhc, $trhc);
  } elsif(VectorMath::Collinear($point, $trhc, $brhc)){
    $cat = 1;
    $x = VectorMath::Dist($trhc, $point) / VectorMath::Dist($trhc, $brhc);
  } elsif(VectorMath::Collinear($point, $brhc, $blhc)){
    $cat = 2;
    $x = VectorMath::Dist($brhc, $point) / VectorMath::Dist($brhc, $blhc);
  } elsif(VectorMath::Collinear($point, $blhc, $tlhc)){
    $cat = 3;
    $x = VectorMath::Dist($blhc, $point) / VectorMath::Dist($blhc, $tlhc);
  } else {
    return 4, 4;
    die "point ($point->[0], $point->[1], $point->[2]) is not collinear with " .
      "any side of rectangle:\n($tlhc->[0], $tlhc->[1], $tlhc->[2]), " .
      "($trhc->[0], $trhc->[1], $trhc->[2])\n" .
      "($brhc->[0], $brhc->[1], $brhc->[2]), " .
      "($blhc->[0], $blhc->[1], $blhc->[2])\noccured"
  }
  unless($x < 1) {
    die "point ($point->[0], $point->[1], $point->[2]) has x > 1 ($x) with " .
      "rectangle:\n($tlhc->[0], $tlhc->[1], $tlhc->[2]), " .
      "($trhc->[0], $trhc->[1], $trhc->[2])\n" .
      "($brhc->[0], $brhc->[1], $brhc->[2]), " .
      "($blhc->[0], $blhc->[1], $blhc->[2])\noccured"
  }
  return $cat, $x;
}

sub MarchingSquares {
  my($id, $rows, $cols, $array, $bits_alloc, $level) = @_;
  my %PointsTo;
  for my $j (0 .. ($rows - 2)){
    for my $i (0 .. ($cols - 2)){
      my $uli = ($cols * $j) + $i;
      my $uri = ($cols * $j) + $i + 1;
      my $lli = ($cols * ($j + 1)) + $i;
      my $lri = ($cols * ($j + 1)) + $i + 1;
      my($ul, $ur, $ll, $lr);
      if($bits_alloc == 16){
        $ul = unpack("v", pack("n", vec($array, $uli, $bits_alloc)));
        $ur = unpack("v", pack("n", vec($array, $uri, $bits_alloc)));
        $ll = unpack("v", pack("n", vec($array, $lli, $bits_alloc)));
        $lr = unpack("v", pack("n", vec($array, $lri, $bits_alloc)));
      } elsif($bits_alloc == 32) {
        $ul = unpack("V", pack("N", vec($array, $uli, $bits_alloc)));
        $ur = unpack("V", pack("N", vec($array, $uri, $bits_alloc)));
        $ll = unpack("V", pack("N", vec($array, $lli, $bits_alloc)));
        $lr = unpack("V", pack("N", vec($array, $lri, $bits_alloc)));
      } else {
        die "Sorry we only handle 16 or 32 bits alloc in MarchingSquares";
      }
     
      my $MarchingSquaresCase = 0; 
      if($ul > $level) {$MarchingSquaresCase += 8}
      if($ur > $level) {$MarchingSquaresCase += 4}
      if($ll > $level) {$MarchingSquaresCase += 2}
      if($lr > $level) {$MarchingSquaresCase += 1}
      if($MarchingSquaresCase == 0)      # 0 0
                                         #
      {                                  # 0 0
        #nothing to do here
      } elsif($MarchingSquaresCase == 1) # 0 0
                                         #   b
      {                                  # 0a1
        my $a = &$Interp([$i,   $j+1], [$i+1, $j+1], $id, $ll, $lr, $level);
        my $b = &$Interp([$i+1, $j  ], [$i+1, $j+1], $id, $ur, $lr, $level);
        unless($a eq $b){
          $PointsTo{$a} = $b;
        }
      } elsif($MarchingSquaresCase == 2) # 0 0
                                         # a
      {                                  # 1b0
        my $a = &$Interp([$i,   $j  ], [$i,   $j+1], $id, $ul, $ll, $level);
        my $b = &$Interp([$i,   $j+1], [$i+1, $j+1], $id, $ll, $lr, $level);
        unless($a eq $b){
          $PointsTo{$a} = $b;
        }
      } elsif($MarchingSquaresCase == 3) # 0 0
                                         # a b
      {                                  # 1 1
        my $a = &$Interp([$i,   $j  ], [$i  , $j+1], $id, $ul, $ll, $level);
        my $b = &$Interp([$i+1, $j  ], [$i+1, $j+1], $id, $ur, $lr, $level);
        unless($a eq $b){
          $PointsTo{$a} = $b;
        }
      } elsif($MarchingSquaresCase == 4) # 0b1
                                         #   a
      {                                  # 0 0
        my $a = &$Interp([$i+1,   $j], [$i+1, $j+1], $id, $ur, $lr, $level);
        my $b = &$Interp([$i,   $j  ], [$i+1, $j  ], $id, $ul, $ur, $level);
        unless($a eq $b){
          $PointsTo{$a} = $b;
        }
      } elsif($MarchingSquaresCase == 5) # 0b1
                                         #
      {                                  # 0a1
        my $a = &$Interp([$i,   $j+1], [$i+1, $j+1], $id, $ll, $lr, $level);
        my $b = &$Interp([$i,   $j  ], [$i+1, $j  ], $id, $ul, $ur, $level);
        unless($a eq $b){
          $PointsTo{$a} = $b;
        }
      } elsif($MarchingSquaresCase == 6) # 0b1
                                         # a c
      {                                  # 1d0
        my $a = &$Interp([$i,   $j  ], [$i,   $j+1], $id, $ul, $ll, $level);
        my $b = &$Interp([$i,   $j  ], [$i+1, $j  ], $id, $ul, $ur, $level);
        my $c = &$Interp([$i+1, $j  ], [$i+1, $j+1], $id, $ur, $lr, $level);
        my $d = &$Interp([$i,   $j+1], [$i+1, $j+1], $id, $ll, $lr, $level);
        unless($a eq $b){
          $PointsTo{$a} = $b;
        }
        unless($c eq $d){
          $PointsTo{$c} = $d;
        }
      } elsif($MarchingSquaresCase == 7) # 0b1
                                         # a 
      {                                  # 1 1
        my $a = &$Interp([$i,   $j  ], [$i,   $j+1], $id, $ul, $ll, $level);
        my $b = &$Interp([$i,   $j  ], [$i+1, $j  ], $id, $ul, $ur, $level);
        unless($a eq $b){
          $PointsTo{$a} = $b;
        }
      } elsif($MarchingSquaresCase == 8) # 1a0
                                         # b
      {                                  # 0 0
        my $a = &$Interp([$i,   $j  ], [$i+1, $j  ], $id, $ul, $ur, $level);
        my $b = &$Interp([$i,   $j  ], [$i,   $j+1], $id, $ul, $ll, $level);
        unless($a eq $b){
          $PointsTo{$a} = $b;
        }
      } elsif($MarchingSquaresCase == 9) # 1a0
                                         # d b
      {                                  # 0c1
        my $a = &$Interp([$i,   $j  ], [$i+1, $j  ], $id, $ul, $ur, $level);
        my $b = &$Interp([$i+1, $j  ], [$i+1, $j+1], $id, $ur, $lr, $level);
        my $c = &$Interp([$i,   $j+1], [$i+1, $j+1], $id, $ll, $lr, $level);
        my $d = &$Interp([$i,   $j  ], [$i  , $j+1], $id, $ul, $ll, $level);
        unless($a eq $b){
          $PointsTo{$a} = $b;
        }
        unless($c eq $d){
          $PointsTo{$c} = $d;
        }
      } elsif($MarchingSquaresCase == 10)# 1a0
                                         #
      {                                  # 1b0
        my $a = &$Interp([$i,   $j  ], [$i+1, $j  ], $id, $ul, $ur, $level);
        my $b = &$Interp([$i,   $j+1], [$i+1, $j+1], $id, $ll, $lr, $level);
        unless($a eq $b){
          $PointsTo{$a} = $b;
        }
      } elsif($MarchingSquaresCase == 11)# 1a0
                                         #   b
      {                                  # 1 1
        my $a = &$Interp([$i,   $j  ], [$i+1, $j  ], $id, $ul, $ur, $level);
        my $b = &$Interp([$i+1, $j  ], [$i+1, $j+1], $id, $ur, $lr, $level);
        unless($a eq $b){
          $PointsTo{$a} = $b;
        }
      } elsif($MarchingSquaresCase == 12)# 1 1
                                         # b a
      {                                  # 0 0
        my $a = &$Interp([$i+1, $j  ], [$i+1, $j+1], $id, $ur, $lr, $level);
        my $b = &$Interp([$i,   $j  ], [$i,   $j+1], $id, $ul, $ll, $level);
        unless($a eq $b){
          $PointsTo{$a} = $b;
        }
      } elsif($MarchingSquaresCase == 13)# 1 1
                                         # b
      {                                  # 0a1
        my $a = &$Interp([$i,   $j+1], [$i+1, $j+1], $id, $ll, $lr, $level);
        my $b = &$Interp([$i,   $j  ], [$i,   $j+1], $id, $ul, $ll, $level);
        unless($a eq $b){
          $PointsTo{$a} = $b;
        }
      } elsif($MarchingSquaresCase == 14)# 1 1
                                         #   a
      {                                  # 1b0
        my $a = &$Interp([$i+1, $j  ], [$i+1, $j+1], $id, $ur, $lr, $level);
        my $b = &$Interp([$i,   $j+1], [$i+1, $j+1], $id, $ll, $lr, $level);
        unless($a eq $b){
          $PointsTo{$a} = $b;
        }
      } elsif($MarchingSquaresCase == 15)# 1 1
                                         #
      {                                  # 1 1
        #nothing to do here
      } else {
        die "Internal error - invalid case $MarchingSquaresCase";
      }
    }
  }

  #
  #  Close any open Contours
  #
  my($tlhc, $trhc, $brhc, $blhc) = Corners($id, $rows, $cols);
  my($start_p, $end_p, $num_start, $num_end) = &$FindEnds(\%PointsTo);
  my %BareStarts;
  my %ClosedHeads;
  while($num_start != 0){
    my %bare_starts;
    for my $i (keys %$start_p){
      my @p = split(/\\/, $i);
      my($t, $x) = CharacterizeSEPoint(\@p, $tlhc, $trhc, $brhc, $blhc);
      if($t == 4){
        delete $start_p->{$i};
        $bare_starts{$i} = 1;
      } else {
        $start_p->{$i} = {
          type => $t,
          dist => $x,
        };
      }
    }
    for my $i (keys %$end_p){
      my @p = split(/\\/, $i);
      my($t, $x) = CharacterizeSEPoint(\@p, $tlhc, $trhc, $brhc, $blhc);
      if($t == 4){
        die "bare end point";
        delete $end_p->{$i};
        $bare_starts{$i} = 1;
      } else {
        $end_p->{$i} = {
          type => $t,
          dist => $x,
        };
      }
    }
    my @end_keys = keys %$end_p;
    if($#end_keys < 0){
      for my $be (keys %bare_starts){
        $BareStarts{$be} = 1;
      }
      last;
    }
    my $first_end = $end_keys[0];
    # Connect the first end 
    my $t = $end_p->{$first_end}->{type};
    my $x = $end_p->{$first_end}->{dist};
    my $start;
    for my $i (keys %$start_p){
      if(
        $start_p->{$i}->{type} eq $t &&
        $start_p->{$i}->{dist} > $x
      ){
        unless(defined $start){
          $start = $i;
        }
        if($start_p->{$i}->{dist} < $start_p->{$start}->{dist}){
          $start = $i;
        }
      }
    }
    if(defined $start){
      $PointsTo{$first_end} = $start;
      $ClosedHeads{$start} = 1;
    } elsif ($t == 0){
      $PointsTo{$first_end} = "$trhc->[0]\\$trhc->[1]\\$trhc->[2]";
    } elsif ($t == 1){
      $PointsTo{$first_end} = "$brhc->[0]\\$brhc->[1]\\$brhc->[2]";
    } elsif ($t == 2){
      $PointsTo{$first_end} = "$blhc->[0]\\$blhc->[1]\\$blhc->[2]";
    } elsif ($t == 3){
      $PointsTo{$first_end} = "$tlhc->[0]\\$tlhc->[1]\\$tlhc->[2]";
    }
    ($start_p, $end_p, $num_start, $num_end) = &$FindEnds(\%PointsTo);
  }
  #
  # Collect Contours
  #
  my @Contours;
  contour:
  my @StartPoints = keys %ClosedHeads;
  my %Visited;
  point:
  for my $point (@StartPoints){
    my @contour;
    $Visited{$point} = 1;
    push(@contour, $point);
    while(!exists($Visited{$PointsTo{$point}})){
      $Visited{$PointsTo{$point}} = 1;
      $point = $PointsTo{$point};
      push(@contour, $point);
    }
    $point = $PointsTo{$point};
    push(@contour, $point);
    push(@Contours, \@contour);
  }
  for my $point (keys %BareStarts){
    my @contour;
    push(@contour, $point);
    $Visited{$point} = 1;
    while(!exists($Visited{$PointsTo{$point}})){
      $Visited{$point} = 1;
      $point = $PointsTo{$point};
      push(@contour, $point);
    }
    $point = $PointsTo{$point};
    $Visited{$point} = 1;
    push(@contour, $PointsTo{$point});
    push(@Contours, \@contour);
  }
  my @Unvisited;
  for my $i (keys %PointsTo){
    unless(exists $Visited{$i}){
      push(@Unvisited, $i);
    }
  }
  unvisited:
  for my $point (@Unvisited){
    if(exists $Visited{$point}) { next unvisited }
    my $start = $point;
    my @contour;
    push(@contour, $point);
    $Visited{$point} = 1;
    while(!exists($Visited{$PointsTo{$point}})){
      $point = $PointsTo{$point};
      $Visited{$point} = 1;
      push(@contour, $point);
    }
    if($start eq $PointsTo{$point}){
      push(@contour, $start);
    }
    push(@Contours, \@contour);
  }
  return \@Contours;
};

1;
