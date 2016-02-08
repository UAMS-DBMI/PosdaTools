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
use VectorMath;
use Posda::FlipRotate;
use Cwd;

# Finds the center of a Dose Matrix

unless($#ARGV == 1){ die "usage: $0 <from> <to>" }
my $file = $ARGV[0]; unless($file=~/^\//){$file=getcwd."/$file"}
my $new_file = $ARGV[1]; unless($new_file=~/^\//){$new_file=getcwd."/$new_file"}
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
# Change IPP
my $norm = VectorMath::cross([$iop->[0], $iop->[1], $iop->[2]],
  [$iop->[3], $iop->[4], $iop->[5]]);
my $shift = VectorMath::Scale($gfov->[$#{$gfov}], $norm);
my $new_ipp = VectorMath::Add($ipp, $shift);
$ds->Insert("(0020,0032)", $new_ipp);
my $new_pix = "";
my $bytes_per_plane = $rows * $cols * $bytes;
my $pix_offset = $ds->FilePos("(7fe0,0010)");
print "Pixel offset: $pix_offset\n";
my $new_gfov = [];
open FILE, "<$file" or die "can't open $file";
for my $i (0 .. $#{$gfov}){
  my $to_offset = $pix_offset + ($i * $bytes_per_plane);
  my $from_offset = $pix_offset + (($#{$gfov} - $i) * $bytes_per_plane);
  $new_gfov->[$i] = $gfov->[$#{$gfov} - $i] - $gfov->[$#{$gfov}];
  print "$from_offset, $to_offset, ($new_gfov->[$i]) ($gfov->[$i])\n";
  seek FILE, $from_offset, 0;
  my $count = sysread FILE, $new_pix, $bytes_per_plane, length($new_pix);
  unless($count == $bytes_per_plane){
    die "short read on pixels $count vs bytes_per_plane";
  }
}
$ds->Insert("(3004,000c)", $new_gfov);
$ds->Insert("(7fe0,0010)", $new_pix);
print "Writing to $new_file\n";
$ds->WritePart10($new_file, $xfr_stx, "POSDA");
