#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/DoseManip/FindCenterOfDose.pl,v $
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
use Posda::FlipRotate;

# Finds the center of a Dose Matrix

my $file = $ARGV[0]; unless($file=~/^\//){$file=getcwd."/$file"}
unless($#ARGV == 0){ die "usage: $0 <file>" }
my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($file);
unless($ds) { die "$file didn't parse" }
my $modality = $ds->Get("(0008,0060)");
unless($modality eq "RTDOSE") { die "$file is not a dose" }
my $gfov = $ds->Get("(3004,000c)");
my $rows = $ds->Get("(0028,0010)");
my $cols = $ds->Get("(0028,0011)");
my $bytes = $ds->Get("(0028,0100)") / 8;
my $pix_sp = $ds->Get("(0028,0030)");
my $ipp = $ds->Get("(0020,0032)");
my $iop = $ds->Get("(0020,0037)");
my $norm = VectorMath::cross([$iop->[0], $iop->[1], $iop->[2]],
  [$iop->[3], $iop->[4], $iop->[5]]);
my $shift = VectorMath::Scale($gfov->[$#{$gfov}], $norm);
my $last_ipp = VectorMath::Add($ipp, $shift);
my($ftl, $ftr, $fbl, $fbr) =
  Posda::FlipRotate::ToCorners($rows, $cols, $iop, $ipp, $pix_sp);
my($btl, $btr, $bbl, $bbr) =
  Posda::FlipRotate::ToCorners($rows, $cols, $iop, $last_ipp, $pix_sp);
print "ftl: [$ftl->[0], $ftl->[1], $ftl->[2]]\n";
print "ftr: [$ftr->[0], $ftr->[1], $ftr->[2]]\n";
print "fbl: [$fbl->[0], $fbl->[1], $fbl->[2]]\n";
print "fbr: [$fbr->[0], $fbr->[1], $fbr->[2]]\n";
print "btl: [$btl->[0], $btl->[1], $btl->[2]]\n";
print "btr: [$btr->[0], $btr->[1], $btr->[2]]\n";
print "bbl: [$bbl->[0], $bbl->[1], $bbl->[2]]\n";
print "bbr: [$bbr->[0], $bbr->[1], $bbr->[2]]\n";
my $c_x = ($ftl->[0] + $bbr->[0]) / 2;
my $c_y = ($ftl->[1] + $bbr->[1]) / 2;
my $c_z = ($ftl->[2] + $bbr->[2]) / 2;
print "Center: [$c_x, $c_y, $c_z]\n";
