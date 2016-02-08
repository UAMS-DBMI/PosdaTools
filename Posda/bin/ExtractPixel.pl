#!/usr/bin/perl -w
#
use strict;
use Digest::MD5;
my $usage = 
  "usage: ExtractPixel.pl <from_file> <offset> <length> <bytes> " .
    "<slope> <intercept> <center> <width> <signed> <to_file>";
unless($#ARGV == 9) { die $usage }
my $from_file = $ARGV[0];
my $offset = $ARGV[1];
my $length = $ARGV[2];
my $bytes = $ARGV[3];
my $slope = $ARGV[4];
my $intercept = $ARGV[5];
my $center = $ARGV[6];
my $width = $ARGV[7];
my $signed = $ARGV[8];
my $to_file = $ARGV[9];
my $white = $center - ($width / 2);
my $black = $center + ($width / 2);
unless($bytes == 1 || $bytes == 2 || $bytes == 4) {
  die "ExtractPixel.pl: invalid number of bytes ($bytes)";
}
if($signed && $bytes == 1){
  die "ExtractPixel.pl: not supporting signed bytes";
}
open my $fh, $from_file or die "ExtractPixel.pl: can't open $from_file ($!)";
seek $fh, $offset, 0;
my $buff;
my $len = sysread($fh, $buff, $length);
unless($len == $length) {
  die "ExtractPixel.pl Incomplete read of $from_file: $len vs $length ($!)";
}
close($fh);
my $output = "\0" x ($length/2);
for my $i (0 .. ($length/2) - 1){
  my $pix;
  if($signed){
    if ($bytes == 2){
      $pix = unpack("s", pack("s", unpack("v", pack("n", vec($buff, $i, 16)))));
    } else{ # bytes == 4
      $pix = unpack("l", pack("l", unpack("V", pack("N", vec($buff, $i, 32)))));
    }
  } else {
    if($bytes == 1){
      $pix = vec($buff, $i, 8);
    } elsif ($bytes == 2){
      $pix = unpack("v", pack("n", vec($buff, $i, 16)));
    } else{ # bytes == 4
      $pix = unpack("V", pack("N", vec($buff, $i, 32)));
    }
  }
  my $scaled_pix = ($pix * $slope) + $intercept;
  if($scaled_pix <= $white){
    $scaled_pix = 0;
  } elsif($scaled_pix > $black){
    $scaled_pix = 255;
  } else {
    $scaled_pix = ($scaled_pix - $white) * (255 / $width);
    if($scaled_pix > 255) { $scaled_pix = 255 }
  }
  $scaled_pix = int($scaled_pix + 0.5);
  vec($output, $i, 8) = $scaled_pix;
}
open $fh, ">$to_file" or die "ExtractPixel.pl can't open >$to_file ($!)";
print $fh $output;
print "wrote $to_file\n";
