#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/DoseInterp.pl,v $
#$Date: 2011/10/18 13:42:21 $
#$Revision: 1.11 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

# Streamed Dose Interpolation
# This program reads a DICOM RT Dose file and interpolates the
# data as specified by its parameters.  The interpolated dose is
# written to one or more fd's (opened by parent, number(s) passed as
# parameters).
#
# What to do is specified on the command line.
# All of the parameters on the command line are of the form:
#  <name>=<value> (no spaces)
# parameter order does not matter.
#
# Here are the parameters:
#  out<n>=<number of output n'th fd> (n zero based)
#  status=<number of status fd> app will write status to this fd when finished
#  source_dose_file_name=<name of dicom dose file>
#  source_rowdcosx=<iop[0] of dose file>  [normalized]
#  source_rowdcosy=<iop[1] of dose file>  [normalized]
#  source_rowdcosz=<iop[2] of dose file>  [normalized]
#  source_coldcosx=<iop[3] of dose file>  [normalized]
#  source_coldcosy=<iop[4] of dose file>  [normalized]
#  source_coldcosz=<iop[5] of dose file>  [normalized]
#  source_ulx=<ipp[0] of dose file>
#  source_uly=<ipp[1] of dose file>
#  source_ulz=<ipp[2] of dose file>
#  source_rows=<number of rows in dose grid>
#  source_cols=<number of cols in dose grid>
#  source_rowspc=<pixel spacing in rows in dose grid>
#  source_colspc=<pixel spacing in cols in dose grid>
#  source_pixel_offset=<offset of pixel data in dicom dose file>
#  source_gfov_offset=<offset of grid frame offset vector in dicom dose file>
#  source_gfov_length=<length of grid frame offset vector in dicom dose file>
#  source_bits_alloc=<bits allocated per pixel in dicom dose file>
#  source_dose_units=[GRAY, CGRAY]
#  source_dose_scaling=<scale factor in dose file>
#  resamp_rowdcosx=<iop[0] for resampling>  [normalized]
#  resamp_rowdcosy=<iop[1] for resampling>  [normalized]
#  resamp_rowdcosz=<iop[2] for resampling>  [normalized]
#  resamp_coldcosx=<iop[3] for resampling>  [normalized]
#  resamp_coldcosy=<iop[4] for resampling>  [normalized]
#  resamp_coldcosz=<iop[5] for resampling>  [normalized]
#  resamp_ulx=<ipp[0] for resampling>
#  resamp_uly=<ipp[1] for resampling>
#  resamp_ulz=<ipp[2] for resampling>
#  resamp_rows=<rows for resampling>
#  resamp_cols=<cols for resampling>
#  resamp_frames=<frames for resampling>
#  resamp_spc=<rows, col, frame spacing for resampling>
#  resamp_bits_alloc=<bits allocated for resampling>
#  resamp_dose_units=[GRAY, CGRAY]
#  resamp_dose_scaling=<scale factor in resampled dose>
use strict;
use VectorMath;
use Posda::Transforms;
#use IO;
use HexDump;
my(@out, $status, $source_dose_file_name,
  $source_rows, $source_cols,
  $source_ulx, $source_uly, $source_ulz,
  $source_rowdcosx, $source_rowdcosy, $source_rowdcosz,
  $source_coldcosx, $source_coldcosy, $source_coldcosz,
  $source_rowspc, $source_colspc,
  $source_gfov_offset, $source_gfov_length,
  $source_pixel_offset,
  $source_bits_alloc,
  $source_dose_units, $source_dose_scaling,
  $resamp_rows, $resamp_cols, $resamp_frames,
  $resamp_ulx, $resamp_uly, $resamp_ulz,
  $resamp_rowdcosx, $resamp_rowdcosy, $resamp_rowdcosz,
  $resamp_coldcosx, $resamp_coldcosy, $resamp_coldcosz,
  $resamp_spc,
  $resamp_bits_alloc,
  $resamp_dose_units, $resamp_dose_scaling
);
for my $i (@ARGV){
  unless($i =~ /^([^=]+)=([^=]+)$/) {
    die "$0: can't parse parameter $i";
  }
  my $key = $1;
  my $value = $2;
  if ($key =~ /out(\d+)/) { $out[$1] = $value }
  elsif ($key eq "status") { $status = $value }
  elsif ($key eq "source_dose_file_name") { $source_dose_file_name = $value }
  elsif ($key eq "source_rows") { $source_rows = $value }
  elsif ($key eq "source_cols") { $source_cols = $value }
  elsif ($key eq "source_ulx") { $source_ulx = $value }
  elsif ($key eq "source_uly") { $source_uly = $value }
  elsif ($key eq "source_ulz") { $source_ulz = $value }
  elsif ($key eq "source_rowdcosx") { $source_rowdcosx = $value }
  elsif ($key eq "source_rowdcosy") { $source_rowdcosy = $value }
  elsif ($key eq "source_rowdcosz") { $source_rowdcosz = $value }
  elsif ($key eq "source_coldcosx") { $source_coldcosx = $value }
  elsif ($key eq "source_coldcosy") { $source_coldcosy = $value }
  elsif ($key eq "source_coldcosz") { $source_coldcosz = $value }
  elsif ($key eq "source_rowspc") { $source_rowspc = $value }
  elsif ($key eq "source_colspc") { $source_colspc = $value }
  elsif ($key eq "source_pixel_offset") { $source_pixel_offset = $value }
  elsif ($key eq "source_gfov_offset") { $source_gfov_offset = $value }
  elsif ($key eq "source_gfov_length") { $source_gfov_length = $value }
  elsif ($key eq "source_bits_alloc") { $source_bits_alloc = $value }
  elsif ($key eq "source_dose_units") { $source_dose_units = $value }
  elsif ($key eq "source_dose_scaling") { $source_dose_scaling = $value }
  elsif ($key eq "resamp_rows") { $resamp_rows = $value }
  elsif ($key eq "resamp_cols") { $resamp_cols = $value }
  elsif ($key eq "resamp_frames") { $resamp_frames = $value }
  elsif ($key eq "resamp_ulx") { $resamp_ulx = $value }
  elsif ($key eq "resamp_uly") { $resamp_uly = $value }
  elsif ($key eq "resamp_ulz") { $resamp_ulz = $value }
  elsif ($key eq "resamp_rowdcosx") { $resamp_rowdcosx = $value }
  elsif ($key eq "resamp_rowdcosy") { $resamp_rowdcosy = $value }
  elsif ($key eq "resamp_rowdcosz") { $resamp_rowdcosz = $value }
  elsif ($key eq "resamp_coldcosx") { $resamp_coldcosx = $value }
  elsif ($key eq "resamp_coldcosy") { $resamp_coldcosy = $value }
  elsif ($key eq "resamp_coldcosz") { $resamp_coldcosz = $value }
  elsif ($key eq "resamp_spc") { $resamp_spc = $value }
  elsif ($key eq "resamp_bits_alloc") { $resamp_bits_alloc = $value }
  elsif ($key eq "resamp_dose_units") { $resamp_dose_units = $value }
  elsif ($key eq "resamp_dose_scaling") { $resamp_dose_scaling = $value }
  else { die "$0: unknown parameter: $key" }
}
unless($#out >= 0){ die "$0: no outputs defined" }
unless($source_dose_file_name) { die "$0: source file undefined" }
unless(-f $source_dose_file_name) { die "no source file: $source_dose_file_name" }
unless(defined $source_rows){ die "$0: source_rows undefined" }
unless(defined $source_cols){ die "$0: source_cols undefined" }
unless(defined $source_ulx){ die "$0: source_ulx undefined" }
unless(defined $source_uly){ die "$0: source_uly undefined" }
unless(defined $source_ulz){ die "$0: source_ulz undefined" }
unless(defined $source_rowdcosx){ die "$0: rowdcosx undefined" }
unless(defined $source_rowdcosy){ die "$0: rowdcosy undefined" }
unless(defined $source_rowdcosz){ die "$0: rowdcosz undefined" }
unless(defined $source_coldcosx){ die "$0: coldcosx undefined" }
unless(defined $source_coldcosy){ die "$0: coldcosy undefined" }
unless(defined $source_coldcosz){ die "$0: coldcosz undefined" }
unless(defined $source_rowspc){ die "$0: source_rowspc undefined" }
unless(defined $source_colspc){ die "$0: source_colspc undefined" }
unless(defined $source_gfov_offset){ die "$0: source_gfov_offset undefined" }
unless(defined $source_gfov_length){ die "$0: source_gfov_length undefined" }
unless(defined $source_pixel_offset){ die "$0: source_pixel_offset undefined" }
unless(defined $source_bits_alloc){ die "$0: source_bits_alloc undefined" }
unless(defined $source_dose_units){ die "$0: source_dose_units undefined" }
unless(defined $source_dose_scaling,){ die "$0: source_dose_scaling undefined" }
unless(defined $resamp_rows){ die "$0: source_rows undefined" }
unless(defined $resamp_cols){ die "$0: source_cols undefined" }
unless(defined $resamp_frames){ die "$0: source_frames undefined" }
unless(defined $resamp_ulx){ die "$0: source_ulx undefined" }
unless(defined $resamp_uly){ die "$0: source_uly undefined" }
unless(defined $resamp_ulz){ die "$0: source_ulz undefined" }
unless(defined $resamp_rowdcosx){ die "$0: source_rowdcosx undefined" }
unless(defined $resamp_rowdcosy){ die "$0: source_rowdcosy undefined" }
unless(defined $resamp_rowdcosz){ die "$0: source_rowdcosz undefined" }
unless(defined $resamp_coldcosy){ die "$0: source_coldcosy undefined" }
unless(defined $resamp_coldcosz){ die "$0: source_coldcosz undefined" }
unless(defined $resamp_spc){ die "$0: resapm_spc undefined" }
unless(defined $resamp_bits_alloc){ die "$0: source_bits_alloc undefined" }
unless(defined $resamp_dose_units){ die "$0: source_dose_units undefined" }
unless(defined $resamp_dose_scaling){ die "$0: source_dose_scaling undefined" }
unless(
  $source_rowdcosx eq $resamp_rowdcosx &&
  $source_rowdcosy eq $resamp_rowdcosy &&
  $source_rowdcosz eq $resamp_rowdcosz &&
  $source_coldcosx eq $resamp_coldcosx &&
  $source_coldcosy eq $resamp_coldcosy &&
  $source_coldcosz eq $resamp_coldcosz
){
  die "$0: geometry inconsistent";
}
my $bytes_per_pixel;
if($source_bits_alloc == 16){ $bytes_per_pixel = 2 }
elsif($source_bits_alloc == 32){ $bytes_per_pixel = 4 }
else { die "$0: don't handle bits_alloc of $source_bits_alloc" }
my $plane_size = $source_rows * $source_cols * $bytes_per_pixel;
my $iop = [$source_rowdcosx, $source_rowdcosy, $source_rowdcosz,
  $source_coldcosx, $source_coldcosy, $source_coldcosz];
my $source_ul = [$source_ulx, $source_uly, $source_ulz];
my $resamp_ul = [$resamp_ulx, $resamp_uly, $resamp_ulz];
unless(
  $source_rowdcosx == 1 && $source_rowdcosy == 0 && $source_rowdcosz == 0 &&
  $source_coldcosx == 1 && $source_coldcosy == 0 && $source_coldcosz == 0
){
  my $xfm = Posda::Transforms::NormalizingVolume($iop, $source_ul);
  $source_ul = Posda::Transforms::ApplyTransform($xfm, $source_ul);
  $resamp_ul = Posda::Transforms::ApplyTransform($xfm, $resamp_ul);
}
open INPUT, "<$source_dose_file_name" or die "$0: Can't open dicom dose $source_dose_file_name";
seek INPUT, $source_gfov_offset, 0;
my $gfov_text;
my $len = read(INPUT, $gfov_text, $source_gfov_length);
unless($len == $source_gfov_length) {
  die "$0: read wrong length for gfov ($len vs $source_gfov_length)"
}
my @output_handles;
for my $i (0 .. $#out){
  unless(defined $out[$i]) { next }
  my $in = $out[$i];
  open(my $fh, ">&", $in) or die "$0: Can't open out = $in ($!)";
  push(@output_handles, $fh);
}
my @gfov = split(/\\/, $gfov_text);


my $resamp_rowspc = $resamp_spc;
my $resamp_colspc = $resamp_spc;

my($f_pix_plane, $t_pix_plane, $f_pix_plane_i, $t_pix_plane_i, $interp_fac);
my $current_p_i = 0;
my $current_p_z = $gfov[0];
my $next_p_i = 1;
my $next_p_z = $gfov[1];
my $last_p_z = $gfov[$#gfov];
my $current_resamp_z = $resamp_ul->[2];
my $bytes_per_resamp_pix = 2;
if($resamp_bits_alloc == 32){ $bytes_per_resamp_pix = 4 };
my $bytes_per_row = $resamp_cols * $bytes_per_resamp_pix;
my $bytes_per_plane = $resamp_rows * $bytes_per_row;
my $debug = 0;
my $row_y_b = $resamp_ul->[1];
my $col_x_b = $resamp_ul->[0];
plane:
for my $plane (0 .. $resamp_frames - 1){ # outer loop
  my $debug = 0;
  if($plane == int($resamp_frames / 2)){ $debug = 1 }
  if(
    $current_resamp_z < $current_p_z ||
    $current_resamp_z > $last_p_z
  ){
    for my $fh (@output_handles){
      print $fh "\0" x $bytes_per_plane;
    }
    $current_resamp_z += $resamp_spc;
    next plane;
  }
  while($current_resamp_z > $next_p_z){
    $current_p_i += 1;
    $next_p_i = $current_p_i + 1;
    $current_p_z = $next_p_z;
    $next_p_z = ($next_p_i <= $#gfov) ? $gfov[$next_p_i] : undef;
    $f_pix_plane = $t_pix_plane;
    $t_pix_plane = undef;
  }
  if($current_resamp_z > $last_p_z){
    for my $fh (@output_handles){
      print $fh "\0" x $bytes_per_plane;
    }
    $current_resamp_z += $resamp_spc;
    next plane;
  }
  unless(defined $f_pix_plane) { $f_pix_plane = GetPixelPlane($current_p_i) }
  unless(defined $t_pix_plane) { $t_pix_plane = GetPixelPlane($next_p_i) }
  my $p_int_frac = ($current_resamp_z - $current_p_z) / 
                   ($next_p_z - $current_p_z);
#
# At this point:
#  $row_y_b = uly of the resampling space
#  $resamp_rowspc = resampling interval between rows
#  $source_rowspc = source interval between rows
#  
#  $col_x_b = ulx of the resampling space
#  $resamp_colspc = sampling interval between columns
#  $source_colspc = source interval between columns
#
  middle:
  for my $row (0 .. $resamp_rows - 1){  ## middle loop
    my $row_y = ($row_y_b + ($row * $resamp_rowspc))/$source_rowspc;
    my($row_i_f, $row_i_t, $row_int_frac);
    if($row_y >= 0){
      $row_i_f = int($row_y);
      $row_int_frac = $row_y - $row_i_f;
      if($row_i_f + 1 <= $source_rows){
        $row_i_t = $row_i_f + 1;
      }
    }
    #######
    # if $row_int_frac is not defined, just send an empty row
    unless(defined $row_int_frac){
      for my $fh (@output_handles){
        print $fh "\0" x $bytes_per_row;
      }
      next middle;
    }
    inner:
    for my $col (0 .. $resamp_cols - 1) { ## inner loop
      my $col_x = ($col_x_b + ($col * $resamp_spc))/$source_colspc;
      my($col_i_f, $col_i_t, $col_int_frac);
      $col_int_frac = 0;
      if($col_x >= 0){
        $col_i_f = int($col_x);
        $col_int_frac = $col_x - $col_i_f;
        if($col_i_f + 1 <= $source_cols){
          $col_i_t = $col_i_f + 1;
        }
      } 
      #######
      # interpolate here!!
      # $col_i_f = from column index
      # $col_i_t = to column index
      # $col_int_frac = column interpolation fraction
      # $row_i_f = from row index
      # $row_i_t  = to row index
      # $row_int_frac = row interpolation fraction
      # $p_int_frac = plane interpolation fraction
      #######
      my($r1c1_i, $r1c2_i, $r2c1_i, $r2c2_i);
      if(defined($row_i_f) && defined($col_i_f)){
        $r1c1_i = ($row_i_f * $source_cols) + $col_i_f;
      }
      if(defined($row_i_f) && defined($col_i_t)){
        $r1c2_i = ($row_i_f * $source_cols) + $col_i_t;
      }
      if(defined($row_i_t) && defined($col_i_f)){
        $r2c1_i = ($row_i_t * $source_cols) + $col_i_f;
      }
      if(defined($row_i_t) && defined($col_i_t)){
        $r2c2_i = ($row_i_t * $source_cols) + $col_i_t;
      }
      #value from, from, front
      my $vfff = 0;
      if(defined $r1c1_i) {
         $vfff = $f_pix_plane->[$r1c1_i];
      }
      #value to, from, front
      my $vtff = 0;
      if(defined $r2c1_i) {
        $vtff = $f_pix_plane->[$r2c1_i];
      }
      #value from, to, front
      my $vftf = 0;
      if(defined $r1c2_i) {
        $vftf = $f_pix_plane->[$r1c2_i];
      }
      #value to, to, front
      my $vttf = 0;
      if(defined $r2c2_i) {
        $vttf = $f_pix_plane->[$r2c2_i];
      }
      #value to, to, next
      my $vffn = 0;
      if(defined $r1c1_i) {
        $vffn = $f_pix_plane->[$r1c1_i];
      }
      #value to, from, next
      my $vtfn = 0;
      if(defined $r2c1_i) {
        $vtfn = $f_pix_plane->[$r2c1_i];
      }
      #value from, to, next
      my $vftn = 0;
      if(defined $r1c2_i) {
        $vftn = $f_pix_plane->[$r1c2_i];
      }
      #value to, to, next
      my $vttn = 0;
      if(defined $r2c2_i) {
        $vttn = $f_pix_plane->[$r2c2_i];
      }
      # value interp from front
      my $viff = $vfff + $row_int_frac * ($vtff - $vfff);
      # value interp to front
      my $vitf = $vftf + $row_int_frac * ($vttf - $vftf);
      # value interp from next
      my $vifn = $vffn + $row_int_frac * ($vtfn - $vffn);
      # value interp to next
      my $vitn = $vftn + $row_int_frac * ($vttn - $vftn);

      # value interp interp front
      my $viif = $viff + $col_int_frac * ($vitn - $viff);
      # value interp interp next
      my $viin = $vifn + $col_int_frac * ($vitn - $vifn);
      # fully interpreted value
      my $value = $viif + $p_int_frac * ($viin - $viif);

      ######### Scale and output value
      if($source_dose_scaling ne $resamp_dose_scaling) {
        $value = $value * ($source_dose_scaling / $resamp_dose_scaling);
      }
      if($source_dose_units ne $resamp_dose_units){
        if(
          $source_dose_units eq "GRAY" && $resamp_dose_units eq "CGRAY"
        ){
          $value *= 100;
        } elsif(
          $source_dose_units eq "CGRAY" && $resamp_dose_units eq "GRAY"
        ){
          $value /= 100;
        } else {
          die "Unknown dose units " .
            "(source = $source_dose_units, resamp = $resamp_dose_units)";
        }
      }
      my $v;
      if($resamp_bits_alloc == 16) {
        $v = pack("v", $value);
      } else {
        $v = pack("V", $value);
      }
      for my $fh (@output_handles){
        print $fh $v;
      }
      ######### end interpolation
      $col_x += $resamp_spc;
    } # end inner loop
    $row_y += $resamp_spc;
  } # end middle loop
  $current_resamp_z += $resamp_spc;
} # end outer loop




sub GetPixelPlane{
  my($i) = @_;
  my $plane_offset = $i * $plane_size;
  my $file_offset = $source_pixel_offset + $plane_offset;
  seek(INPUT, $file_offset, 0);
  my $plane;
  my $len = read(INPUT, $plane, $plane_size);
  unless($len == $plane_size) {
    die "$0: incomplete pixel read plane $i ($len vs $plane_size ($!))";
  }
  my @pixels;
  if($bytes_per_pixel == 2){
    @pixels = unpack("v*", $plane);
  } else {
    @pixels = unpack("V*", $plane);
  }
  return \@pixels;
}


if(defined $status){
  open(STATUS, ">&=", $status) or die "$0: Can't open status = $status";
  print STATUS "OK\n";
  close STATUS;
}
