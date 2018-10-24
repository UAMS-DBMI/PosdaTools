#!/usr/bin/perl -w
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
# This script was writen to read in a dicom file with pixel data and 
# using the # rows, # cols & the bits allocated determine & correct the 
# length of the actual pixel data.
# 
#
use Cwd;
use strict;
use Posda::Dataset;
unless ($#ARGV == 1){
  die "usage: $0 <source file> <destination file>\n";
}

Posda::Dataset::InitDD();
  
my $from = $ARGV[0]; unless($from=~/^\//){$from=getcwd."/$from"}
my $to = $ARGV[1]; unless($to=~/^\//){$to=getcwd."/$to"}
 
my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($from);
unless($ds) { die "$from didn't parse into a dataset" }

my $rows = $ds->Get("(0028,0010)");
my $cols = $ds->Get("(0028,0011)");
my $frames = $ds->Get("(0028,0008)");
my $bits_alloc = $ds->Get("(0028,0100)");
my $bits_stored = $ds->Get("(0028,0101)");
my $high_bit = $ds->Get("(0028,0102)");
my $pixel_rep = $ds->Get("(0028,0103)");

my $pixel_data_num_bytes;
my @pixel_data;

if ($bits_alloc == 8 ) {
				$pixel_data_num_bytes = 1;
				@pixel_data = unpack("c*", $ds->Get("(7fe0,0010)"));
} elsif ($bits_alloc == 16 ) {
				$pixel_data_num_bytes = 2;
				@pixel_data = unpack("s*", $ds->Get("(7fe0,0010)"));
} elsif ($bits_alloc == 32 ) {
				$pixel_data_num_bytes = 4;
				@pixel_data = unpack("l*", $ds->Get("(7fe0,0010)"));
} else {
    print "  Bits alloc: $bits_alloc\n";
    print "  Bits stored: $bits_stored\n";
    print "  High Bit: $high_bit\n";
    print "  Pixel Rep: $pixel_rep\n";
	  die "  Bits Allocated: $bits_alloc invalid.\n"; 
}

my $pixel_data_length = $rows * $cols * $frames;
my @new_pixel_data;
for (my $i = 0; $i < $pixel_data_length; $i++) 
  { $new_pixel_data[$i] = $pixel_data[$i]; }

print "  Bits alloc: $bits_alloc\n";
print "  Bits stored: $bits_stored\n";
print "  High Bit: $high_bit\n";
print "  Pixel Rep: $pixel_rep\n";
print "  Pixel data length: $pixel_data_length\n";
print "  Size of new_pixel_data: $#new_pixel_data+1\n";

if ($bits_alloc == 8 ) {
				$ds->Insert("(7fe0,0010)", pack("c*",  @new_pixel_data));
} elsif ($bits_alloc == 16 ) {
				$ds->Insert("(7fe0,0010)", pack("s*",  @new_pixel_data));
} elsif ($bits_alloc == 32 ) {
				$ds->Insert("(7fe0,0010)", pack("l*",  @new_pixel_data));
} else {
    print "  Bits alloc: $bits_alloc\n";
    print "  Bits stored: $bits_stored\n";
    print "  High Bit: $high_bit\n";
    print "  Pixel Rep: $pixel_rep\n";
	  die "  Bits Allocated: $bits_alloc invalid.\n";
}

if($df){
  $ds->WritePart10($to, $xfr_stx, "DICOM_TEST", undef, undef);
} else {
  $ds->WriteRawDicom($to, $xfr_stx);
}

