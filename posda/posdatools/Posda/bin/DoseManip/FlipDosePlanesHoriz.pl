#!/usr/bin/perl -w
#
#Copyright 2012, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Cwd;
use Posda::Try;
use Posda::FlipRotate;
use Posda::UUID;

# "Flips" a Dose matrix horizontally (i.e. reflects across center yz plane)
# and adjusts iop and ipp and gfov to offset the change in 
# the dose matrix. The resulting dose is a differently encoded 
# representation of the same dose grid, and should be interpreted the same.
#
# This transform does NOT change the frame of reference
#
my $file = $ARGV[0];unless($file=~/^\//){$file=getcwd."/$file"}
unless($#ARGV == 0){ die "usage: $0 <file>" }
my $try = Posda::Try->new($file);
unless(exists $try->{dataset}) { die "$file didn't parse" }
my $ds = $try->{dataset};
my $modality = $ds->Get("(0008,0060)");
unless($modality eq "RTDOSE") { die "$file is not a dose" }
my $rows = $ds->Get("(0028,0010)");
my $cols = $ds->Get("(0028,0011)");
my $frames = $ds->Get("(0028,0008)");
my $gfov = $ds->Get("(3004,000c)");
my $bits_alloc = $ds->Get("(0028,0100)");
my $ipp = $ds->Get("(0020,0032)");
my $iop = $ds->Get("(0020,0037)");
my $pix_spc = $ds->Get("(0028,0030)");
my($new_iop, $new_ipp, $new_rows, $new_cols, $new_pix_sp) =
  Posda::FlipRotate::FlipIopIppHorizontal($iop, $ipp, $rows, $cols, $pix_spc);
$ds->Insert("(0020,0032)", $new_ipp);
$ds->Insert("(0020,0037)", $new_iop);
my $new_gfov = Posda::FlipRotate::FlipGfov($gfov);
$ds->Insert("(3004,000c)", $new_gfov);
my $long_rows = $rows * $frames;
my $new_pixels = Posda::FlipRotate::FlipArrayHorizontal(
  $ds->Get("(7fe0,0010)"), $long_rows, $cols, $bits_alloc);
$ds->Insert("(7fe0,0010)", $new_pixels);
my $new_uid = Posda::UUID::GetUUID;
$ds->Insert("(0008,0018)", $new_uid);
$ds->WritePart10("$file.flip", $try->{xfr_stx}, "POSDA_FLIP", undef, undef);
