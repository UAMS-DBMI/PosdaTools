#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/DoseManip/FlipDosePlanes.pl,v $
#$Date: 2011/06/23 15:28:45 $
#$Revision: 1.2 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Dataset;
use VectorMath;

# "Flips" a Dose matrix and adjusts gfov in to offset the change in 
# the dose matrix.  Also adjusts ipp to reflect the change.  The resulting
# dose is a differently encoded representation of the same dose grid, and
# should be interpreted the same.

my $file = $ARGV[0];unless($file=~/^\//){$file=getcwd."/$file"}
unless($#ARGV == 0){ die "usage: $0 <file>" }
my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($file);
unless($ds) { die "$file didn't parse" }
my $modality = $ds->Get("(0008,0060)");
unless($modality eq "RTDOSE") { die "$file is not a dose" }
my $gfov = $ds->Get("(3004,000c)");
my $rows = $ds->Get("(0028,0010)");
my $cols = $ds->Get("(0028,0011)");
my $bytes = $ds->Get("(0028,0100)") / 8;
my $slice_size = $rows * $cols * $bytes;
my $start_of_dose = $ds->file_pos("(7fe0,0010)");
my $max_ind = $#{$gfov};
my $new_pix = "";
my $new_gfov = [];
open FILE, "<$file";
for my $j (0 .. $max_ind){
my $i = $max_ind - $j;
  my $offset = $gfov->[$i];
  my $new_offset = $offset - $gfov->[$max_ind];
  push(@$new_gfov, $new_offset);
  my $file_offset = $start_of_dose + ($i * $slice_size);
  seek FILE, $file_offset, 0;
  my $buff;
  my $len = read(FILE, $buff, $slice_size);
  unless($len = $slice_size) { die "incomplete read: $len vs $slice_size" }
  $new_pix .= $buff;
}
close FILE;
$ds->Insert("(3004,000c)", $new_gfov);
$ds->Insert("(7fe0,0010)", $new_pix);
my $ipp = $ds->Get("(0020,0032)");
my $iop = $ds->Get("(0020,0037)");
my $norm = VectorMath::cross([$iop->[0], $iop->[1], $iop->[2]],
  [$iop->[3], $iop->[4], $iop->[5]]);
my $shift = VectorMath::Scale($gfov->[$max_ind], $norm);
my $new_ipp = VectorMath::Add($ipp, $shift);
$ds->Insert("(0020,0032)", $new_ipp);
$ds->WritePart10("$file.flip", $xfr_stx, "POSDA_FLIP", undef, undef);
