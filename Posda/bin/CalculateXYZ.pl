#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use strict;
use Posda::Dataset;
use Cwd;

Posda::Dataset::InitDD();

my($file, $col, $row) = @ARGV;
unless(
  $file && $col && $row 
){
  die "usage: $0 <file> col row"
}
unless(
	$file =~ /^\//
) {
	$file = getcwd."/$file";
}
my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($file);
unless($ds) { die "$file didn't parse" }
my $iop = $ds->ExtractElementBySig("(0020,0037)");
my $ipp = $ds->ExtractElementBySig("(0020,0032)");
my $sp = $ds->ExtractElementBySig("(0028,0030)");
my $dxdc = $iop->[0];       # dx/dr
my $dydc = $iop->[1];       # dy/dr
my $dzdc = $iop->[2];       # dz/dr
my $dxdr = $iop->[3];       # dx/dc
my $dydr = $iop->[4];       # dy/dc
my $dzdr = $iop->[5];       # dz/dc

my $tlx = $ipp->[0];
my $tly = $ipp->[1];
my $tlz = $ipp->[2];

my $spc = $sp->[0];
my $spr = $sp->[1];

my $x = $tlx + ($dxdc * $col * $spc)
             + ($dxdr * $row * $spr);
my $y = $tly + ($dydc * $col * $spc)
             + ($dydr * $row * $spr);
my $z = $tlz + ($dzdc * $col * $spc)
             + ($dzdr * $row * $spr);

print "$x, $y, $z\n";
