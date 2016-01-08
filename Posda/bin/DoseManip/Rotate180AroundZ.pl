#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/DoseManip/Rotate180AroundZ.pl,v $
#$Date: 2011/06/23 15:28:45 $
#$Revision: 1.3 $
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Dataset;
use VectorMath;
use Posda::FlipRotate;
use Cwd;

# "Rotates" a Dose matrix 180 degrees around the z-axis
# Also adjusts iop and ipp to reflect the change.  
# The resulting dose is a differently encoded representation of the 
# same dose grid, and should be interpreted the same.

my $file = $ARGV[0]; unless($file =~ /^\//) { $file = getcwd."/$file" }
unless($#ARGV == 0){ die "usage: $0 <file>" }
my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($file);
unless($ds) { die "$file didn't parse" }
my $modality = $ds->Get("(0008,0060)");
unless($modality eq "RTDOSE") { die "$file is not a dose" }
my $gfov = $ds->Get("(3004,000c)");
my $rows = $ds->Get("(0028,0010)");
my $cols = $ds->Get("(0028,0011)");
my $pix_sp = $ds->Get("(0028,0030)");
my $bits_alloc = $ds->Get("(0028,0100)");
unless($bits_alloc == 8 || $bits_alloc == 16 || $bits_alloc == 32){
  die "bits_alloc = $bits_alloc";
}
my $bytes = $bits_alloc / 8;
my $iop = $ds->Get("(0020,0037)");
my $ipp = $ds->Get("(0020,0032)");
my ($tlhc, $trhc, $blhc, $brhc) = Posda::FlipRotate::ToCorners(
  $rows, $cols, $iop, $ipp, $pix_sp);
my $new_iop = 
  [-$iop->[0], $iop->[1], $iop->[2], $iop->[3], -$iop->[4], $iop->[5]];
my $slice_size = $rows * $cols * $bytes;
my $start_of_dose = $ds->file_pos("(7fe0,0010)");
my $max_ind = $#{$gfov};
my $new_pix = "";
open FILE, "<$file";
for my $i (0 .. $max_ind){
  my $file_offset = $start_of_dose + ($i * $slice_size);
  seek FILE, $file_offset, 0;
  my $buff;
  my $len = read(FILE, $buff, $slice_size);
  unless($len = $slice_size) { die "incomplete read: $len vs $slice_size" }
  my $new_buff = Posda::FlipRotate::RotArray180($buff, $rows, $cols,
    $bits_alloc);
  $new_pix .= $new_buff;
}
close FILE;
$ds->Insert("(0020,0037)", $new_iop);
$ds->Insert("(7fe0,0010)", $new_pix);
$ds->Insert("(0020,0032)", $blhc);
$ds->WritePart10("$file.rot180xy", $xfr_stx, "POSDA_ROT", undef, undef);
