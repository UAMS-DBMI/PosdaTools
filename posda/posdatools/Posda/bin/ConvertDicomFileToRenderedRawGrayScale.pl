#!/usr/bin/perl -w
#
use strict;
use Posda::DB qw( Query );
#use Debug;
#my $dbg = sub {print STDERR @_ };
my $usage = <<EOF;
ConvertDicomFileToRenderedRawGrayScale.pl <dicom_file_id> <window_c> <window_w> <dest_file>

Fetches/Computes the following from the Posda database based on dicom_file_id:
  source_file_name
  pixel_offset
  pixel_length
  slope
  intercept
  bytes (based on bits allocated/stored)
  signed 
  rows
  cols

Then it invokes "ExtractPixel.pl" to write an 8 bit grayscale file with
properly scaled, windowed and leveled pixel data into dest_file.

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 3){
  my $num_args = @ARGV;
  print STDERR "Error: CacheDicomAsJpeg.pl requires 3 args, had $num_args\n";
  print "Error: CacheDicomAsJpeg.pl requires 3 args, had $num_args\n";
  exit 1;
}
my($file_id, $win_ctr, $win_w, $dest_file) = @ARGV;
my %file_paths;
my %pixel_data_offsets;
my %data_set_starts;
my %pixel_lengths;
my %slopes;
my %intercepts;
my %windows;
my %pixel_rowss;
my %pixel_columnss;
my %bits_allocateds;
my %bits_storeds;
my %high_bits;
my %pixel_representations;
my %photometric_interpretations;
my %samples_per_pixels;
my %number_of_framess;
my %planar_configurations;
Query('GetFileRenderingInfo')->RunQuery(sub{
  my($row) = @_;
  my $row_num = 0;
  my(
    $file_path, $pixel_data_offset, $data_set_start, $pixel_data_length,
    $slope, $intercept, $window_center, $window_width, $win_lev_desc,
    $pixel_rows, $pixel_columns, $bits_allocated, $bits_stored,
    $high_bit, $pixel_representation, $photometric_interpretation,
    $samples_per_pixel, $number_of_frames, $planar_configuration
  ) = @$row;
  $file_paths{$file_path} = 1;
  $pixel_data_offsets{$pixel_data_offset} = 1;
  $data_set_starts{$data_set_start} = 1;
  $pixel_lengths{$pixel_data_length} = 1;
  $slopes{$slope} = 1;
  $intercepts{$intercept} = 1;
  unless(defined $win_lev_desc) { $win_lev_desc = "" }
  my $win_desc = "$row_num:$win_ctr:$win_w:$win_lev_desc";
  $row_num += 1;
  $windows{$win_desc} = 1;
  $pixel_rowss{$pixel_rows} = 1;
  $pixel_columnss{$pixel_columns} = 1;
  $bits_allocateds{$bits_allocated} = 1;
  $bits_storeds{$bits_stored} = 1;
  $high_bits{$high_bit} = 1;
  $pixel_representations{$pixel_representation} = 1;
  $photometric_interpretations{$photometric_interpretation} = 1;
  $samples_per_pixels{$samples_per_pixel} = 1;
  if(defined $number_of_frames){
    $number_of_framess{$number_of_frames} = 1;
  }
  if(defined $planar_configuration){
    $planar_configurations{$planar_configuration} = 1;
  }
}, sub{}, $file_id);
my $num_file_paths = keys %file_paths;
unless($num_file_paths == 1){
  print STDERR "Error: found $num_file_paths file_paths for file_id $file_id\n";
  print "Error: found $num_file_paths file_paths for file_id $file_id\n";
  exit 1;
}

my $source_file_name = [ keys %file_paths ]->[0];

my $num_pixel_offsets = keys %pixel_data_offsets;
unless($num_pixel_offsets == 1){
  print STDERR "Error: found $num_pixel_offsets pixel_offsets for file_id $file_id\n";
  print "Error: found $num_pixel_offsets pixel_offsets for file_id $file_id\n";
  exit 1;
}
my $pixel_data_offset = [ keys %pixel_data_offsets ]->[0];

my $num_data_set_starts = keys %data_set_starts;
unless($num_data_set_starts == 1){
  print STDERR "Error: found $num_data_set_starts data_set_starts " .
  print "Error: found $num_data_set_starts data_set_starts " .
    "for file_id $file_id\n";
  exit 1;
}
my $data_set_start = [ keys %data_set_starts ]->[0];
   

my $pixel_offset = $pixel_data_offset;

my $num_pixel_lengths = keys %pixel_lengths;
unless($num_pixel_lengths == 1){
  print STDERR "Error: found $num_pixel_lengths pixel_lengths for file_id $file_id\n";
  print "Error: found $num_pixel_lengths pixel_lengths for file_id $file_id\n";
  exit 1;
}
my $pixel_length = [ keys %pixel_lengths ]->[0];


my $gray_file_name = $dest_file;

my $num_slopes = keys %slopes;
unless($num_slopes == 1){
  print STDERR "Error: found $num_slopes slopes for file_id $file_id\n";
  print "Error: found $num_slopes slopes for file_id $file_id\n";
  exit 1;
}
my $slope = [ keys %slopes ]->[0];

my $num_intercepts = keys %intercepts;
unless($num_intercepts == 1){
  print STDERR "Error: found $num_intercepts intercepts for file_id $file_id\n";
  print "Error: found $num_intercepts intercepts for file_id $file_id\n";
  exit 1;
}
my $intercept = [ keys %intercepts ]->[0];

unless(
  defined($slope) && defined($intercept) &&
  $slope != 0 && $intercept != 0
){
  $slope = 1;
  $intercept = 0;
}

my $num_bits_allocateds = keys %bits_allocateds;
unless($num_bits_allocateds == 1){
  print STDERR "Error: found $num_bits_allocateds bits_allocated " .
  print "Error: found $num_bits_allocateds bits_allocated " .
    "for file_id $file_id\n";
  exit 1;
}
my $bits_allocated = [ keys %bits_allocateds ]->[0];
if($bits_allocated == 8){
    $win_ctr = 128;
    $win_w = 256;
}

my $num_bits_storeds = keys %bits_storeds;
unless($num_bits_storeds == 1){
  print STDERR "Error: found $num_bits_storeds bits_stored " .
  print "Error: found $num_bits_storeds bits_stored " .
    "for file_id $file_id\n";
  exit 1;
}
my $bits_stored = [ keys %bits_storeds ]->[0];

my $num_high_bits = keys %high_bits;
unless($num_high_bits == 1){
  print STDERR "Error: found $num_high_bits high_bits " .
  print "Error: found $num_high_bits high_bits " .
    "for file_id $file_id\n";
  exit 1;
}
my $high_bit = [ keys %high_bits ]->[0];

my $bytes;
if($bits_allocated == 16){
  $bytes = 2;
} elsif($bits_allocated == 8){
  $bytes = 1;
} elsif($bits_allocated == 32){
  $bytes = 4;
} else {
  print STDERR "Error: unknown bits_allocated: $bits_allocated\n";
  print "Error: unknown bits_allocated: $bits_allocated\n";
  exit 1;
}

my $num_pixel_representations = keys %pixel_representations;
unless($num_pixel_representations == 1){
  print STDERR "Error: found $num_pixel_representations pixel_representations " .
  print "Error: found $num_pixel_representations pixel_representations " .
    "for file_id $file_id\n";
  exit 1;
}
my $signed = [ keys %pixel_representations ]->[0];

#  $photometric_interpretations{$photometric_interpretation} = 1;
#  $samples_per_pixels{$samples_per_pixel} = 1;
#  $number_of_framess{$number_of_frames} = 1;
#  $planar_configurations{$planar_configurations} = 1;

my $num_pixel_rowss = keys %pixel_rowss;
unless($num_pixel_rowss == 1){
  print STDERR "Error: found $num_pixel_rowss rows " .
  print "Error: found $num_pixel_rowss rows " .
    "for file_id $file_id\n";
  exit 1;
}
my $rows = [ keys %pixel_rowss ]->[0];

my $num_pixel_columnss = keys %pixel_columnss;
unless($num_pixel_columnss == 1){
  print STDERR "Error: found $num_pixel_columnss rows " .
  print "Error: found $num_pixel_columnss rows " .
    "for file_id $file_id\n";
  exit 1;
}
my $cols = [ keys %pixel_columnss ]->[0];

my $cmd = "ExtractPixel.pl " .
  "\"$source_file_name\" " .
  "$pixel_offset $pixel_length $bytes \"$slope\" \"$intercept\" " .
  "\"$win_ctr\" \"$win_w\" \"$signed\" " .
  "\"$gray_file_name\"";
#print STDERR "Cmd: $cmd\n";
open my $fh, "$cmd|" or die "Can't open $cmd|\n($!)";
my @lines;
while (my $line = <$fh>){
  push @lines, $line;
}
for my $i (@lines) { 
  print $i;
  if($i =~ /^Error:/){
   exit 1;
  }
}
close $fh;
exit(0);
