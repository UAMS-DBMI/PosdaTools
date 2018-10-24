#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use strict;
use Posda::Dataset;
use Posda::Interpolator;
use Debug;
my $dbg = sub {print @_};
my $usage = sub {
	print "usage: $0 <source> <destination>";
	exit -1;
};
unless($#ARGV == 1) { &$usage() }
my $from = $ARGV[0]; unless($from=~/^\//){$from=getcwd."/$from"}
my $to = $ARGV[1]; unless($to=~/^\//){$to=getcwd."/$to"}

my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($ARGV[0]);

# First file must parse into a dataset
unless($ds) { die "$from didn't parse into a dataset" }

#
# Get the info for doing the interpolation of dose
#
my $pixel_data_offset = $ds->{0x7fe0}->{0x10}->{file_pos};
my $sop_class = $ds->Get("(0008,0016)");
# if its not a dose file, get out
unless($sop_class eq "1.2.840.10008.5.1.4.1.1.481.2") { die "not an RT_DOSE" }
my $gfov = $ds->Get("(3004,000c)");
my $rows = $ds->Get("(0028,0010)");
my $cols = $ds->Get("(0028,0011)");
my $bits_alloc = $ds->Get("(0028,0100)");


#
# The following code populates $new_gfov which will (eventually) replace 
#  $gfov (but be evenly spaced)
#
my $num_slices = scalar @$gfov;
my $first = $gfov->[0];
my $last = $gfov->[$#{$gfov}];
my $dist = $last - $first;
my $spacing = $dist/($num_slices - 1);
my $new_gfov = [];
my $offset = 0;
for my $i (0 .. $num_slices - 1){
  $new_gfov->[$i] = $offset;
  $offset += $spacing;
}
my $new_last = $new_gfov->[$#{$new_gfov}];

#
# @sample commands is a list of "sample commands"
#  $sample_commands[$i] = {
#     start => <starting frame index>,
#     end => <ending frame index>,
#     ratio => <fraction of distance from start to end>
#  };
#
my @sample_commands;
for my $i (0 .. ($num_slices - 1)){
  $sample_commands[$i] = FindInterpolationPlace($new_gfov->[$i], $gfov);
}

#print "Num slices: $num_slices ($first - $last ($new_last)) " .
#  "spacing: $spacing\n";

#
# Interpolate new pixel data into file pix.temp
#
open PIX, ">pix.temp" or die "can't open pix.temp";
for my $i (0 .. $#sample_commands){
  my $item = $sample_commands[$i];
#  print "$i: $sample_commands[$i]->{ratio} from " .
#    "$sample_commands[$i]->{start} to $sample_commands[$i]->{end}\n";
  my $from_array = FetchSliceFromFile($from, $pixel_data_offset,
    $rows, $cols, $bits_alloc, $item->{start});
  unless(defined $from_array) { die "from_array undefined" }
  my $to_array = FetchSliceFromFile($from, $pixel_data_offset,
    $rows, $cols, $bits_alloc, $item->{end});
  unless(defined $to_array) { die "to_array undefined" }
  my $interp_array = Posda::Interpolator::InterpolateArray(
    $from_array, $to_array, $item->{ratio}, $rows, $cols, $bits_alloc
  );
  print PIX $interp_array;
}
close PIX;

#
# Read in interpolated pixel data (die if its the wrong length)
#
open PIX, "<pix.temp";
my $new_pix;
my $len = read(PIX, $new_pix, $rows * $cols * 2 * $num_slices);
unless($len == $rows * $cols * 2 * $num_slices){
  my $expected = $rows * $cols * 2 *$num_slices;
  die "Error - read $len vs $expected";
}
close PIX;

# 
# Replace gfov and pixel data, and write new file
#
$ds->{0x3004}->{0x0c}->{value} = $new_gfov;
$ds->{0x7fe0}->{0x10}->{value} = $new_pix;
#print "Writing to $to\n";
$ds->WritePart10($to, $xfr_stx, "DICOM_TEST", undef, undef);
#print "Written to $to\n";

#
# FindInterpolationPlace
#  given an offset, it returns the indices of the old
#  planes which the offset is between, and the fraction
#  of the distance between the planes.  This fraction will
#  be 0 or 1 if the new_offset coincides with one of the
#  old planes...
#
#  dies if you pass it an offset that isn't in any of the
#  plane intervals...
#
sub FindInterpolationPlace{
  my($new_offset, $old_gfov) = @_;
  for my $i (0 .. $#{$old_gfov} - 1){
    if(
      $new_offset >= $old_gfov->[$i] &&
      $new_offset <= $old_gfov->[$i + 1]
    ){
      my $command = {
        start => $i,
        end => $i + 1,
        ratio => ($new_offset - $old_gfov->[$i]) / 
          ($old_gfov->[$i + 1] - $old_gfov->[$i]),
      };
      return $command;
    }
  }
  die "didn't find interpolation interval";
}

#
# FetchSliceFromFile
#   Given a sufficient description of the dose pixel data in
#   a file, and the frame number desired, fetches a dose plane
#
sub FetchSliceFromFile{
  my($file, $offset, $rows, $cols, $bits, $frame_no) = @_;
  unless($bits == 16) {die "maybe $bits later"}
  my $frame_size = $rows * $cols * 2;
  my $frame_offset = $frame_size * $frame_no;
  my $total_offset = $offset + $frame_offset;
  open FILE, "<$file" or die "can't open $file";
  seek FILE, $total_offset, 0;
  my $buff;
  my $len = read FILE, $buff, $frame_size;
  close FILE;
  unless($len == $frame_size) { die "incomplete read" }
  return $buff;
}
