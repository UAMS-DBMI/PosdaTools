#!/usr/bin/perl -w

use Cwd;
use strict;
use Posda::Dataset;

Posda::Dataset::InitDD();

unless($#ARGV == 2) { die "usage: $0 <file> <offset> <words>\n" }
my $file = $ARGV[0]; unless($file=~/^\//){$file=getcwd."/$file"}
my $offset = $ARGV[1];
my $words = $ARGV[2];

my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($file);
unless($ds) { die "$file is not a DICOM file" }
my $pix_data = $ds->Get("(7fe0,0010)");
my $scale_factor = $ds->Get("(3004,000e)");

my $pix = ($words == 1) ? 
  unpack("v", pack("n", vec($pix_data, $offset/2, 16))) :
  unpack("V", pack("N", vec($pix_data, $offset/4, 32)));
print "Pixel: $pix\n";
my $gy = $pix * $scale_factor;
print "$gy GY\n";
