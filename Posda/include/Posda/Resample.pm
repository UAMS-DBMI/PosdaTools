#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/Resample.pm,v $
#$Date: 2012/03/15 19:28:17 $
#$Revision: 1.5 $
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package Posda::Resample;
use Posda::FlipRotate;
sub Dose{
  my($ds, $args) = @_;
  #extract args
  my $min_x = $args->{min_x};
  my $max_x = $args->{max_x};
  my $min_y = $args->{min_y};
  my $max_y = $args->{max_y};
  my $min_z = $args->{min_z};
  my $max_z = $args->{max_z};
  my $pix_sp_x = $args->{pix_sp_x};
  my $pix_sp_y = $args->{pix_sp_y};
  my $frame_sp = $args->{frame_sp};
  my $new_bits = $args->{new_bits};

  #check args for sanity
  unless(defined($min_x) && defined($max_x) && $min_x < $max_x
  ){ die "need both max and min and min < max  ($min_x !< $max_x)"; }
  unless(defined($min_y) && defined($max_y) && $min_y < $max_y
  ){ die "need both max and min and min < max  ($min_y !< $max_y)"; }
  unless(defined($min_z) && defined($max_z) && $min_z < $max_z
  ){ die "need both max and min and min < max  ($min_z !< $max_z)"; }
  unless(
    defined($pix_sp_x) && $pix_sp_x > 0 && 
    defined($pix_sp_y) && $pix_sp_y > 0 &&
    defined($frame_sp) && $frame_sp > 0
  ) { 
    die "need positive pixel/frame spacing: " .
      "have ($pix_sp_x, $pix_sp_y, $frame_sp)";
  }

  # get relevant stuff from dataset
  my $modality = $ds->Get("(0008,0060)");
  unless($modality eq "RTDOSE") { die 'not a dose' }
  my $rows = $ds->Get("(0028,0010)");
  my $cols = $ds->Get("(0028,0011)");
  my $frames = $ds->Get("(0028,0008)");
  my $iop = $ds->Get("(0020,0037)");
  my $ipp = $ds->Get("(0020,0032)");
  my $pix_sp = $ds->Get("(0028,0030)");
  my $gfov = $ds->Get("(3004,000c)");
  my $bits = $ds->Get("(0028,0100)");
  unless(defined $new_bits){ 
    $new_bits = $bits 
  }
  my $pix = $ds->Get("(7fe0,0010)");
  my @OldPix;
  if($bits == 16) {
    @OldPix = unpack("v*", $pix);
  } elsif ($bits == 32){
    @OldPix = unpack("V*", $pix);
  } else {
    die "unsupported bits_allocated: $bits";
  }
  my @NewPix;
  my $start_x = $min_x;
  my $start_y = $min_y;
  my $start_z = $min_z;

  my $x_inc = $pix_sp_x;
  my $y_inc = $pix_sp_y;
  my $z_inc = $frame_sp;
  my $new_rows = ($max_x - $min_x) / $x_inc;
  my $new_cols = ($max_y - $min_y) / $y_inc;
  my $new_frames = int(($max_z - $min_z) / $z_inc);
  #print "Inc = ($x_inc, $y_inc, $z_inc)\n";
  my $old_z_inc = ($gfov->[$#{$gfov}] - $gfov->[0]) / $#{$gfov};
  #print "OldInc = ($pix_sp->[0], $pix_sp->[1], $old_z_inc)\n";
  my @new_gfov;

  for my $k (0 .. $new_frames - 1){
    for my $j (0 .. $new_rows - 1) {
      for my $i (0 .. $new_cols - 1){
        my $x = $start_x + ($x_inc * $i);
        my $y = $start_y + ($y_inc * $j);
        my $z = $start_z + ($z_inc * $k);
        my($p) = Posda::FlipRotate::ToPixCoords(
          $iop, $ipp, $rows, $cols, $pix_sp, [$x, $y, $z]);
        my $is_in_row = ($p->[0] >= 0) && ($p->[0] < $cols-1);
        my $is_in_col = ($p->[1] >= 0) && ($p->[1] < $rows-1);
        my $is_in_plane = ($p->[2] >= $gfov->[0]) &&
          ($p->[2] < $gfov->[$#{$gfov}]);
        #print "($is_in_row, $is_in_col, $is_in_plane)\n";
        if($is_in_row && $is_in_col && $is_in_plane){
          my $l_x = int($p->[0]);
          my $h_x = $l_x + 1;
          my $r_x = ($p->[0] - $l_x)/($h_x - $l_x);
          my $l_y = int($p->[1]);
          my $h_y = $l_y + 1;
          my $r_y = ($p->[1] - $l_y)/($h_y - $l_y);
          my($r_z, $l_z, $h_z, $l_z_i, $h_z_i);
          for my $f (0 .. $#{$gfov} - 1){
            if(
              $gfov->[$f] <= $p->[2] &&
              $gfov->[$f + 1] >= $p->[2]
            ){
              $l_z = $gfov->[$f];
              $h_z = $gfov->[$f + 1];
              $r_z = ($p->[2] - $l_z)/($h_z - $l_z);
              $l_z_i = $f;
              $h_z_i = $f + 1;
            }
          }
#          print "($i, $j, $k):\ninterpolate x: $r_x from $l_x to $h_x\n";
#          print "interpolate y: $r_y from $l_y to $h_y\n";
#          print "interpolate z: $r_z from $l_z_i to $h_z_i\n";
          my $Plxlyl = $OldPix[($l_z_i * $rows * $cols) +
            ($l_y * $cols) + $l_x];
          my $Plxlyh = $OldPix[($l_z_i * $rows * $cols) +
            ($h_y * $cols) + $l_x];
          my $Plxhyl = $OldPix[($l_z_i * $rows * $cols) +
            ($l_y * $cols) + $h_x];
          my $Plxhyh = $OldPix[($l_z_i * $rows * $cols) +
            ($h_y * $cols) + $h_x];
          my $Phxlyl = $OldPix[($h_z_i * $rows * $cols) +
            ($l_y * $cols) + $l_x];
          my $Phxlyh = $OldPix[($h_z_i * $rows * $cols) +
            ($h_y * $cols) + $l_x];
          my $Phxhyl = $OldPix[($h_z_i * $rows * $cols) +
            ($l_y * $cols) + $h_x];
          my $Phxhyh = $OldPix[($h_z_i * $rows * $cols) +
            ($h_y * $cols) + $h_x];
  
          my $Plxhyc = $Plxhyl + (($Plxhyh - $Plxhyl)*$r_y);
          my $Plxlyc = $Plxlyh + (($Plxlyl - $Plxlyh)*$r_y);
          my $Phxhyc = $Phxhyl + (($Phxhyh - $Phxhyl)*$r_y);
          my $Phxlyc = $Phxhyl + (($Phxlyh - $Phxhyl)*$r_y);
  
          my $Plxc = $Plxlyc + (($Plxhyc - $Plxlyc)*$r_x);
          my $Phxc = $Phxlyc + (($Phxhyc - $Phxlyc)*$r_x);
  
          my $Pc = $Plxc + (($Phxc - $Plxc)*$r_z);
          push @NewPix, $Pc;
        } else {
          push @NewPix, 0;
        }
      }
    }
    push(@new_gfov, $k * $z_inc);
  }
  my $new_pix;
  if($bits == 32 && $new_bits == 16){
    my $largest = 0;
    for my $i (@NewPix){
      if($i > $largest) {$largest = $i}
    }
    print "largest: $largest\n";
    my $scale = 65535 / $largest;
    print "$scale = $scale\n";
    my $scaled_largest = $scale * $largest;
    print "scaled = $scaled_largest\n";
    for my $i (0 .. $#NewPix){
      $NewPix[$i] = $NewPix[$i] * $scale;
    }
  }
  if($new_bits == 16){
    $new_pix = pack("v*", @NewPix);
  } else {
    $new_pix = pack("V*", @NewPix);
  }
  unless($bits == $new_bits){
    $ds->Insert("(0028,0100)", $new_bits);
    $ds->Insert("(0028,0101)", $new_bits);
    $ds->Insert("(0028,0102)", $new_bits - 1);
  }
  $ds->Insert("(0020,0037)", [1,0,0,0,1,0]);
  $ds->Insert("(0020,0032)", [$start_x, $start_y, $start_z]);
  $ds->Insert("(0028,0010)", $new_rows);
  $ds->Insert("(0028,0011)", $new_cols);
  $ds->Insert("(0028,0008)", $new_frames);
  $ds->Insert("(0028,0030)", [$y_inc, $x_inc]);
  $ds->Insert("(7fe0,0010)", $new_pix);
  $ds->Insert("(3004,000c)", \@new_gfov);
  return $ds;
}
1;
