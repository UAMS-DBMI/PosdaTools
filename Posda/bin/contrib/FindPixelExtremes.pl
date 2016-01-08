#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/FindPixelExtremes.pl,v $
#$Date: 2011/06/23 15:31:26 $
#$Revision: 1.3 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
# This script was written to examine a series of PT images and find the largest
# and smallest pixel values.  It only handles 16 bit unsigned pixels, and 
# is specifically looking to see if any image has pixels scaled larger than
# 32767.
#
use Cwd;
use strict;
use Posda::Dataset;
use Posda::Find;
unless ($#ARGV == 0){
  die "usage: $0 <dir_name>\n";
}
my $dir = $ARGV[0];
unless($dir =~ /^\//) {$dir = getcwd."/$dir"}

sub handle {
  my($path, $df, $ds, $size, $xfr_stx, $errors) = @_;
  my $rows = $ds->Get("(0028,0010)");
  my $cols = $ds->Get("(0028,0011)");
  my $bits_alloc = $ds->Get("(0028,0100)");
  my $bits_stored = $ds->Get("(0028,0101)");
  my $high_bit = $ds->Get("(0028,0102)");
  my $pixel_rep = $ds->Get("(0028,0103)");
  if(
    $bits_alloc == 16 &&
    $bits_stored == 16 &&
    $high_bit == 15 &&
    $pixel_rep == 1
  ){
    my @pixel_data = unpack("s*", $ds->Get("(7fe0,0010)"));
    my $smallest = 0xffff;
    my $largest = 0;
    for my $i (@pixel_data){
      if($i < $smallest) { $smallest = $i }
      if($i > $largest) { $largest = $i }
    }
    if($largest > 32767) { die "$path has pixel value > 32767 ($largest)" }
    print "$path:\n\tSmallest: $smallest\n\tLargest: $largest\n";
  } elsif(
    $bits_alloc == 8 &&
    $bits_stored == 8 &&
    $high_bit == 7 &&
    $pixel_rep == 0
  ){
    my @pixel_data = unpack("c*", $ds->Get("(7fe0,0010)"));
    my $smallest = 127;
    my $largest = -127;
    for my $i (@pixel_data){
      if($i < $smallest) { $smallest = $i }
      if($i > $largest) { $largest = $i }
    }
#    if($largest > 255) { die "$path has pixel value > 255 ($largest)" }
    print "$path:\n\tSmallest: $smallest\n\tLargest: $largest\n";
  } else {
    print "Bits alloc: $bits_alloc\n";
    print "Bits stored: $bits_stored\n";
    print "High Bit: $high_bit\n";
    print "Pixel Rep: $pixel_rep\n";
    print STDERR 
      "only handling unsigned shorts with 16 bits stored and alloced";
    return;
  }
}
Posda::Find::SearchDir($dir, \&handle);
