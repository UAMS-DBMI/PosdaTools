#!/usr/bin/perl -w
use strict;
my $usage = <<EOF;
ExtractPixels.pl <file_id> <file_name> <offset> <size> <bits_stored> \\
 <bits_allocated> <pixel_representation> <number_frames> <samples_per_pixel> \\
 <pixel_rows> <pixel_cols> <photometric_interpretation> \\
 <planar_configuration> <modality> <slope> \\
 <intercept> <window_center> <window_depth> <dir>
EOF
unless($#ARGV == 18) { die $usage}
my $file_id = shift @ARGV;                    # 0
my $file_name = shift @ARGV;                  # 1
my $pix_offset = shift @ARGV;                 # 2
my $size = shift @ARGV;                       # 3
my $bits_store = shift @ARGV;                 # 4
my $bits_alloc = shift @ARGV;                 # 5
my $pixel_representation = shift @ARGV;       # 6
my $pix_rep = ($pixel_representation == 0) ? "unsigned" : "twos_comp";
my $number_of_frames = shift @ARGV;           # 7
my $samples_per_pixel = shift @ARGV;          # 8
my $rows = shift @ARGV;                       # 9
my $cols = shift @ARGV;                       # 10
my $photometric_interp = shift @ARGV;         # 11
my $planar_configuration = shift @ARGV;       # 12
my $modality = shift @ARGV;                   # 13
my $rescale_slope = shift @ARGV;              # 14
my $rescale_intercept = shift @ARGV;          # 15
my $window_center = shift @ARGV;              # 16
my $window_width = shift @ARGV;               # 17
my $dir = shift @ARGV;                        # 18
unless($number_of_frames) { $number_of_frames = 1 };
unless($number_of_frames > 1) { $number_of_frames = 1 }
if(
  $bits_alloc == 16 &&
  $photometric_interp eq "MONOCHROME2" &&
  $modality eq "CT"
){
  for my $i (1 .. $number_of_frames){
    unless($i == 1 && $number_of_frames == 1){ die "Not handling multiframe" }
    my $fn = "$dir/$file_id.gray";
    my $length = $size;
    my $offset = $pix_offset;
    open my $fh, $file_name or
      die "ExtractPixel.pl: can't open $file_name ($!)";
    seek $fh, $offset, 0;
    my $pixels;
    my $len = sysread($fh, $pixels, $length);
    unless($len == $length) {
      die "ExtractPixel.pl Incomplete read of $file_name: $len vs $length ($!)";
    }
    close($fh);
    my @buff = unpack("v*", $pixels);
    my @out;
    unless(defined $rescale_slope) { $rescale_slope = 1 }
    unless(defined $rescale_intercept) { $rescale_intercept = 0 }
    for my $i (0 .. $#buff) {
      $out[$i] = ($buff[$i] * $rescale_slope) + $rescale_intercept;
      $out[$i] += 1024;
      if($out[$i] < 0) { $out[$i] = 0 }
    }
    $pixels = pack "v*", @out;
    open FILE, ">$fn" or die "Error $! on opening of file: $fn";
    print FILE $pixels or die "Error $! on writing of file: $fn";
    close FILE or die "Error $! on closing of file: $fn";
    chmod 0664, "$fn" or print STDERR "Error $! on chmod of file: $fn";
    print "File: $fn\n";
  }
} elsif (
  $bits_alloc == 8 &&
  $photometric_interp eq "RGB" &&
  $samples_per_pixel == 3 &&
  $planar_configuration == 0
){
  for my $i (1 .. $number_of_frames){
    unless($i == 1 && $number_of_frames == 1){ die "Not handling multiframe" }
    my $fn = "$dir/$file_id.rgb";
    my $length = $size;
    my $offset = $pix_offset;
    open my $fh, $file_name or
      die "ExtractPixel.pl: can't open $file_name ($!)";
    seek $fh, $offset, 0;
    my $pixels;
    my $len = sysread($fh, $pixels, $length);
    unless($len == $length) {
      die "ExtractPixel.pl Incomplete read of $file_name: $len vs $length ($!)";
    }
    close($fh);
    open FILE, ">$fn" or die "Error $! on opening of file: $fn";
    # print header
#    my $magic = pack("v", 474);
#    print FILE $magic;
#    my $storage = pack("c", 0);
#    print FILE $storage;
#    my $bpc = pack("c", 3);
#    print FILE $bpc;
#    my $dim = pack("v", 3);
#    print FILE $dim;
#    my $x_size = pack("v", $cols);
#    print FILE $x_size;
#    my $y_size = pack("v", $rows);
#    print FILE $y_size;
#    my $z_size = pack("v", 3);
#    print FILE $z_size;
#    my $pixmin = pack("l", 0);
#    print FILE $pixmin;
#    my $pixmax = pack("l", 255);
#    print FILE $pixmax;
#    my $dummy = "\0" x 4;
#    print FILE $dummy;
#    my $image_name = " " x 80;
#    print FILE $image_name;
#    my $color_map = "\0" x 80;
#    print FILE $color_map;
#    my $filler = "\255" x 404;
#    print FILE $filler;
    # end header
    print FILE $pixels or die "Error $! on writing of file: $fn";
    close FILE or die "Error $! on closing of file: $fn";
    chmod 0664, "$fn" or print STDERR "Error $! on chmod of file: $fn";
    print "File: $fn\n";
  }
}

