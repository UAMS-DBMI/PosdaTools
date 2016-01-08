#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/PixelPlaneGenerator.pm,v $
#$Date: 2012/02/07 13:41:44 $
#$Revision: 1.13 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package Posda::PixelPlaneGenerator;

my $DensityArray = sub {
  my($rows, $cols, $iop, $ipp, $pix_sp, $obj_list, $dens_gen) = @_;
  my @array;
  my $largest;
  my $smallest;
  my $r_sp = $pix_sp->[0];
  my $c_sp = $pix_sp->[1];
  for my $ri (0 .. $rows-1){
    for my $ci (0 .. $cols-1){
      my $r_dist = $ri * $r_sp;
      my $c_dist = $ci * $c_sp;
      my $x = $ipp->[0]
        + ($iop->[0] * $c_dist)
        + ($iop->[3] * $r_dist);
      my $y = $ipp->[1]
        + ($iop->[1] * $c_dist)
        + ($iop->[4] * $r_dist);
      my $z = $ipp->[2]
        + ($iop->[2] * $c_dist)
        + ($iop->[5] * $r_dist);
      my $point = [$x, $y, $z];
      my $density = $dens_gen->Density($obj_list, $point);
      unless(defined $largest) { $largest = $density };
      unless(defined $smallest) { $smallest = $density };
      if($density > $largest) { $largest = $density };
      if($density < $smallest) { $smallest = $density };
      my $index = ($cols * $ri) + $ci;
      $array[$index] = $density;
    }
  }

  return (\@array, $largest, $smallest);
};
my $DensityVec = sub {
  my($rows, $cols, $iop, $ipp, $pix_sp, $obj_list, $offset, $dens_gen) = @_;
print "DensityVec($rows, $cols, [$iop->[0], $iop->[1], $iop->[2], $iop->[3], $iop->[4], $iop->[5]], [$ipp->[0], $ipp->[1], $ipp->[2]], ...)\n";
  my $pix = "\0" x ($rows * $cols *2);
  my $r_sp = $pix_sp->[0];
  my $c_sp = $pix_sp->[1];
  for my $ri (0 .. $rows-1){
    for my $ci (0 .. $cols-1){
      my $r_dist = $ri * $r_sp;
      my $c_dist = $ci * $c_sp;
      my $x = $ipp->[0]
        + ($iop->[0] * $c_dist)
        + ($iop->[3] * $r_dist);
      my $y = $ipp->[1]
        + ($iop->[1] * $c_dist)
        + ($iop->[4] * $r_dist);
      my $z = $ipp->[2]
        + ($iop->[2] * $c_dist)
        + ($iop->[5] * $r_dist);
      my $point = [$x, $y, $z];
      my $density = $dens_gen->Density($obj_list, $point);
      my $index = ($cols * $ri) + $ci;
      vec($pix, $index, 16) = unpack("v", pack("n", $density + $offset));
    }
  }
  return $pix;
};
my $PlaneGen = {
  CT => sub {
    my($rows, $cols, $iop, $ipp, $pix_sp, $obj_list, $dens_gen) = @_;
    my $plane = &$DensityVec(
      $rows, $cols, $iop, $ipp, $pix_sp, $obj_list, 1024, $dens_gen);
    return ($plane, 0, 1, -1024);
  },
  MR => sub {
    my($rows, $cols, $iop, $ipp, $pix_sp, $obj_list, $dens_gen) = @_;
    my $plane = &$DensityVec(
      $rows, $cols, $iop, $ipp, $pix_sp, $obj_list, 0, $dens_gen);
    return ($plane, 0, undef, undef);
  },
  RTD => sub {
    my($rows, $cols, $iop, $ipp, $pix_sp, $bm_list, $dens_gen) = @_;
    my $plane = &$DensityVec(
      $rows, $cols, $iop, $ipp, $pix_sp, $bm_list, 0, $dens_gen);
    return ($plane, 0, undef, undef);
  },
  RTS => sub {
    my($rows, $cols, $iop, $ipp, $pix_sp, $obj_list, $dens_gen) = @_;
    my $plane = &$DensityVec(
      $rows, $cols, $iop, $ipp, $pix_sp, $obj_list, 0, $dens_gen);
    return ($plane, 0, 1, 0);
  },
  PT => sub {
    my($rows, $cols, $iop, $ipp, $pix_sp, $obj_list, $dens_gen) = @_;
    my($array, $largest, $smallest) = &$DensityArray(
      $rows, $cols, $iop, $ipp, $pix_sp, $obj_list, $dens_gen);
    my $plane = "\0" x ($rows * $cols * 2);
    my $slope = 1;
    if($largest > 0){
      $slope = $largest/32767;
      for my $i (0 .. $#{$array}){
        my $value = int ($array->[$i] * (32767 / $largest));
        vec($plane, $i, 16) = unpack("v", pack("n", $value));
      }
    }
    return ($plane, 0, $slope, 0);
  },
};
my $CPlaneGen = {
  CT => sub {
    my($rows, $cols, $iop, $ipp, $pix_sp, $c_cmd) = @_;
    open FILE, "$c_cmd $ipp->[0] $ipp->[1] $ipp->[2] 1024 |";
    my($slope, $largest, $smallest, $pixels);
    my $slope_l = <FILE>;
    my $largest_l = <FILE>;
    my $smallest_l = <FILE>;
    my $pixel_l = <FILE>;
    read(FILE, $pixels, $rows * $cols * 2);
    close FILE;
    if(Posda::Dataset::NativeMoto()){
      my $swapped = pack("v*", unpack("n*", $pixels));
      return ($swapped, 0, 1, -1024);
    } else {
      return ($pixels, 0, 1, -1024);
    }
  },
  MR => sub {
    my($rows, $cols, $iop, $ipp, $pix_sp, $c_cmd) = @_;
    open FILE, "$c_cmd $ipp->[0] $ipp->[1] $ipp->[2] 0 |";
    my($slope, $largest, $smallest, $pixels);
    my $slope_l = <FILE>;
    my $largest_l = <FILE>;
    my $smallest_l = <FILE>;
    my $pixel_l = <FILE>;
    read(FILE, $pixels, $rows * $cols * 2);
    close FILE;
    if(Posda::Dataset::NativeMoto()){
      my $swapped = pack("v*", unpack("n*", $pixels));
      return ($swapped, 0, undef, undef);
    } else {
      return ($pixels, 0, undef, undef);
    }
  },
  RTD => sub {
    my($rows, $cols, $iop, $ipp, $pix_sp, $c_cmd) = @_;
    open FILE, "$c_cmd $ipp->[0] $ipp->[1] $ipp->[2] 0 |";
    my($slope, $largest, $smallest, $pixels);
    my $slope_l = <FILE>;
    my $largest_l = <FILE>;
    my $smallest_l = <FILE>;
    my $pixel_l = <FILE>;
    read(FILE, $pixels, $rows * $cols * 2);
    close FILE;
    if(Posda::Dataset::NativeMoto()){
      my $swapped = pack("v*", unpack("n*", $pixels));
      return ($swapped, 0, undef, undef);
    } else {
      return ($pixels, 0, undef, undef);
    }
  },
  RTS => sub {
    my($rows, $cols, $iop, $ipp, $pix_sp, $c_cmd) = @_;
    open FILE, "$c_cmd $ipp->[0] $ipp->[1] $ipp->[2] 0 |";
    my($slope, $largest, $smallest, $pixels);
    my $slope_l = <FILE>;
    my $largest_l = <FILE>;
    my $smallest_l = <FILE>;
    my $pixel_l = <FILE>;
    read(FILE, $pixels, $rows * $cols * 2);
    close FILE;
    if(Posda::Dataset::NativeMoto()){
      my $swapped = pack("v*", unpack("n*", $pixels));
      return ($swapped, 0, 1, 0);
    } else {
      return ($pixels, 0, 1, 0);
    }
  },
  PT => sub {
    my($rows, $cols, $iop, $ipp, $pix_sp, $c_cmd) = @_;
    open FILE, "$c_cmd $ipp->[0] $ipp->[1] $ipp->[2] 0 |";
    my($slope, $largest, $smallest, $pixels);
    my $slope_l = <FILE>;
    my $largest_l = <FILE>;
    my $smallest_l = <FILE>;
    my $pixel_l = <FILE>;
    read(FILE, $pixels, $rows * $cols * 2);
    close FILE;
    if(Posda::Dataset::NativeMoto()){
      my $swapped = pack("v*", unpack("n*", $pixels));
      return ($swapped, 0, $slope, 0);
    } else {
      return ($pixels, 0, $slope, 0);
    }
  },
};
sub new{
  my($class, $type, $obj_list) = @_;
  my $this = {
    type => $type,
    dens_gen => Posda::DensityGenerator->new($type),
    objs => $obj_list,
  };
  unless(exists $PlaneGen->{$type}){
    die "no pixel plane generator function for $type";
  }
  $this->{plane_gen} = $PlaneGen->{$type};
  return bless $this, $class;
}
sub gen_plane {
  my($this, $rows, $cols, $iop, $ipp, $pix_sp) = @_;
  if(exists $CPlaneGen->{$this->{type}} && exists $this->{c_cmd}){
    return &{$CPlaneGen->{$this->{type}}}(
      $rows, $cols, $iop, $ipp, $pix_sp, $this->{c_cmd});
  } else {
    return &{$this->{plane_gen}}(
      $rows, $cols, $iop, $ipp, $pix_sp, $this->{objs}, $this->{dens_gen});
  }
}
my $header = <<EOF;
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
EOF
my $func_t = <<EOF;
main(int argc, char *argv[]){
EOF
my $globals_t = <<EOF;
float f_arry[<rows> * <cols>];
short arry[<rows> * <cols>];
EOF
my $locals_t = <<EOF;
  float ippx, ippy,ippz;  /* This is ipp */
  float x, y, z;  /* This is point */
  float offset;
  float smallest, largest;
  float density;
  float slope;
  char message[80];
  int ri;
  int ci;
  int index;
EOF
my $body_t = <<EOF;
  if(argc != 5){
     printf("has %d parameters\\n", argc);
     exit(1);
  }
  ippx = atof(argv[1]);
  ippy = atof(argv[2]);
  ippz = atof(argv[3]);
  offset = atof(argv[4]);
  largest = -1000000;
  smallest = 1000000;
  for (ri = 0; ri < <rows>; ri++){
    for (ci = 0; ci < <cols>; ci++){
      x = ippx + (<iop0> * ci * <c_sp>) +
          (<iop3> * ri * <r_sp>);
      y = ippy + (<iop1> * ci * <c_sp>) +
          (<iop4> * ri * <r_sp>);
      z = ippz + (<iop2> * ci * <c_sp>) +
          (<iop5> * ri * <r_sp>);
EOF
my $footer_t = <<EOF;
      density += offset;
      if(density > largest) {
        largest = density;
      }
      if(density < smallest) {
        smallest = density;
      }
      index = (ri * <cols>) + ci;
      f_arry[index] = density;
    }
  }
  if(largest > 32767){
    slope = largest/32767;
  } else {
    slope = 1;
  }
  for (ri = 0; ri < <rows>; ri++){
    for (ci = 0; ci < <cols>; ci++){
      index = (ri * <cols>) + ci;
      arry[index] = (f_arry[index]/slope);
    }
  }
  sprintf(message, "slope: %f\\n", slope);
  write(1, message, strlen(message));
  sprintf(message, "largest: %f\\n", largest);
  write(1, message, strlen(message));
  sprintf(message, "smallest: %f\\n", smallest);
  write(1, message, strlen(message));
  sprintf(message, "pixels:\\n");
  write(1, message, strlen(message));
  write(1, arry, <rows> * <cols> * 2);
}
EOF

sub CCodeGen {
  my($this, $rows, $cols, $iop, $pix_sp) = @_;
  my $cc = Posda::CCgen->new();
  my $locals = $locals_t;
  my $globals = $globals_t;
  my $body = $body_t;
  my $footer = $footer_t;
  $globals =~ s/<rows>/$rows/g;
  $globals =~ s/<cols>/$cols/g;
  $locals =~ s/<rows>/$rows/g;
  $locals =~ s/<cols>/$cols/g;
  $footer =~ s/<rows>/$rows/g;
  $footer =~ s/<cols>/$cols/g;
  $body =~ s/<rows>/$rows/g;
  $body =~ s/<cols>/$cols/g;
  $body =~ s/<iop0>/$iop->[0]/g;
  $body =~ s/<iop1>/$iop->[1]/g;
  $body =~ s/<iop2>/$iop->[2]/g;
  $body =~ s/<iop3>/$iop->[3]/g;
  $body =~ s/<iop4>/$iop->[4]/g;
  $body =~ s/<iop5>/$iop->[5]/g;
  $body =~ s/<r_sp>/$pix_sp->[0]/g;
  $body =~ s/<c_sp>/$pix_sp->[1]/g;
  $cc->add_header($header);
  $cc->add_func($func_t);
  $cc->add_globals($globals);
  $cc->add_locals($locals);
  $cc->add_body($body);
  $cc->add_footer($footer);
  $cc->add_indent("      ");
  $cc->add_body("/* ****   Start Density Generator *** */\n");
  eval {
    $this->{dens_gen}->CodeGen($this->{objs}, $cc);
#    die "don't do it";
  };
  if($@){
    print STDERR "Error $@ generating pixel plane generator\n";
  } else {
    $cc->add_body("/* ****  End of Density Generator *** */\n");
    $cc->sub_indent("      ");
    if($^O eq "MSWin32" || $^O eq "MSWin64"){
      `del posda_series_gen*`;
    } else {
      `rm posda_series_gen*`;
    }
    open FILE, ">", "posda_series_gen.c";
    print FILE $cc->render();
    close FILE;
    if($^O eq "MSWin32" || $^O eq "MSWin64"){
      if(-f "posda_series_gen.exe"){
        `rm -f posda_series_gen.exe`;
      }
      `cl -o posda_series_gen posda_series_gen.c`;
      if(-x "posda_series_gen.exe"){
        $this->{c_cmd} = "./posda_series_gen";
      }
    } else {
      if(-f "posda_series_gen"){
        `rm -f posda_series_gen`;
      }
      `gcc -o posda_series_gen -lm -O3 posda_series_gen.c`;
      if(-x "posda_series_gen"){
        $this->{c_cmd} = "./posda_series_gen";
      }
    }
  }
  return $cc;
}
1;
