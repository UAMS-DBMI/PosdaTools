#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/PixArray.pm,v $
#$Date: 2008/04/30 19:17:35 $
#$Revision: 1.3 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package Posda::PixArray;

sub new{
  my($class, $rows, $cols, $bits_alloc, $pix_rep, $array) = @_;
  my $this = {
    rows => $rows,
    cols => $cols,
    bits_alloc => $bits_alloc,
    array => $array,
    pixel_rep => $pix_rep,
  };
  return bless $this, $class;
}
sub set_pixel{
  my($this, $row, $col, $value) = @_;
  if(
    $row > $this->{rows} - 1 ||
    $col > $this->{cols} - 1 ||
    $row < 0 ||
    $col < 0 ||
    $row != int $row ||
    $col != int $col
  ){
    die "invalid parms";
  }
  my $index = ($row * $this->{cols}) + $col;
  if($this->{bits_alloc} == 8){
    if($this->{pixel_rep}){
      $value = unpack("C", pack("c", $value));
    }
    vec($this->{array}, $index, $this->{bits_alloc}) = $value;
  } elsif($this->{bits_alloc} == 16){
    if($this->{pixel_rep}){
      $value = unpack("S", pack("s", $value));
    }
    vec($this->{array}, $index, $this->{bits_alloc}) = 
      unpack("n", pack("v", $value));
  } elsif($this->{bits_alloc} == 32){
    if($this->{pixel_rep}){
      $value = unpack("L", pack("l", $value));
    }
    vec($this->{array}, $index, $this->{bits_alloc}) = 
      unpack("N", pack("V", $value));
  } else {
    die "bits allocated: $this->{bits_alloc}???";
  }
}
sub get_pixel{
  my($this, $row, $col) = @_;
  if(
    $row > ($this->{rows} - 1) ||
    $col > ($this->{cols} - 1) ||
    $row < 0 ||
    $col < 0 ||
    $row != int $row ||
    $col != int $col
  ){
    die "invalid parms";
  }
  my $index = ($row * $this->{cols}) + $col;
  my $value;
  if($this->{bits_alloc} == 8){
    $value = vec($this->{array}, $index, $this->{bits_alloc});
    if($this->{pixel_rep}){
      $value = unpack("c", pack("C", $value))
    }
  } elsif($this->{bits_alloc} == 16){
    $value = unpack("v",
       pack("n", vec($this->{array}, $index, $this->{bits_alloc})));
    if($this->{pixel_rep}){
      $value = unpack("s", pack("S", $value));
    }
  } elsif($this->{bits_alloc} == 32){
    $value = unpack("V", 
      pack("N", vec($this->{array}, $index, $this->{bits_alloc})));
    if($this->{pixel_rep}){
      $value = unpack("l", pack("L", $value));
    }
  } else {
    die "bits allocated: $this->{bits_alloc}???";
  }
  return $value;
}
sub interp_pixel{
  my($this, $row, $col) = @_;
  my $l_row = int $row;
  my $r_frac = $row - $l_row;
  my $l_col = int $col;
  my $c_frac = $col - $l_col;
  if(
    ($l_row + 1 > $this->{rows} - 1) ||
    ($l_col + 1 > $this->{cols} - 1)
  ){
    die "point outside interpolation area";
  }
  my $vcr = get_pixel($this, $l_row, $l_col);
  my $vc1r = get_pixel($this, $l_row, $l_col + 1);
  my $vcr1 = get_pixel($this, $l_row + 1, $l_col + 1);
  my $vc1r1 = get_pixel($this, $l_row + 1, $l_col + 1);
 
  my $vcr_frac = (1 - $r_frac) * (1 - $c_frac);
  my $vc1r_frac = (1 - $r_frac) *  $c_frac;
  my $vcr1_frac = (1 - $c_frac) *  $r_frac;
  my $vc1r1_frac = $c_frac *  $r_frac;
  my $frac_sum = $vcr_frac + $vc1r_frac + $vcr1_frac + $vc1r1_frac;
  my $value =
    $vcr * $vcr_frac +
    $vc1r * $vc1r_frac +
    $vcr1 * $vcr1_frac +
    $vc1r1 * $vc1r1_frac;
  return $value;
}
1;
