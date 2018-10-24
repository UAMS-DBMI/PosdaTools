#!/usr/bin/perl -w
#
use strict;
use Storable qw( store_fd fd_retrieve );
use Posda::Try;
use Cwd;
use Debug;
my $dbg = sub { print STDERR @_ };
my $usage = "MakeIsoDoseFiles.pl <image_file> <dose_file> <base_name> " .
  "<level0> [<level1> .. ]\n";
unless($#ARGV >= 2) { die $usage }
my $image_file = shift @ARGV;
my $dose_file = shift @ARGV;
my $base_file = shift @ARGV;
my $cwd = getcwd();
unless($image_file =~ /^\//) { $image_file = "$cwd/$image_file" }
unless($dose_file =~ /^\//) { $dose_file = "$cwd/$dose_file" }
unless($base_file =~ /^\//) { $base_file = "$cwd/$base_file" }
unless(-f $image_file) { die "$image_file not found" }
unless(-f $dose_file) { die "$dose_file not found" }
my $i_try = Posda::Try->new($image_file);
unless($i_try && exists($i_try->{dataset})){
  die "$image_file isn't a DICOM file";
}
my $i_ds = $i_try->{dataset};
my $d_try = Posda::Try->new($dose_file);
unless($d_try && exists($d_try->{dataset})){
  die "$dose_file isn't a DICOM file";
}
my $d_ds = $d_try->{dataset};
my $supported_images = {
  "1.2.840.10008.5.1.4.1.1.2" => 1,
};
my $supported_doses = {
  "1.2.840.10008.5.1.4.1.1.481.2" => 1,
};
my $image_sop = $i_ds->Get("(0008,0016)");
my $dose_sop = $d_ds->Get("(0008,0016)");
unless(exists $supported_images->{$image_sop}) {
  die "Don't support image sop class of $image_sop\n";
}
unless(exists $supported_doses->{$dose_sop}) {
  die "Don't support dose sop class of $dose_sop\n";
}
my $slice_iop = $i_ds->Get("(0020,0037)");
my $dose_iop = $d_ds->Get("(0020,0037)");
my $slice_ipp = $i_ds->Get("(0020,0032)");
my $dose_ipp = $d_ds->Get("(0020,0032)");
my $slice_rows = $i_ds->Get("(0028,0010)");
my $dose_rows = $d_ds->Get("(0028,0010)");
my $slice_cols = $i_ds->Get("(0028,0011)");
my $dose_cols = $d_ds->Get("(0028,0011)");
my $slice_pix_sp = $i_ds->Get("(0028,0030)");
my $dose_pix_sp = $d_ds->Get("(0028,0030)");
my $dose_ba = $d_ds->Get("(0028,0100)");
my $dose_bytes = $dose_ba == 16 ? 2 : 4;

my $dose_scaling = $d_ds->Get("(3004,000e)");
my $dose_units = $d_ds->Get("(3004,0002)");
if($dose_units eq "GY") { $dose_units = "GRAY" }
my $dose_pix_offset = $d_ds->FilePos("(7fe0,0010)");
my $dose_pix_length = $d_ds->EleLenInFile("(7fe0,0010)");
my $dose_gfov_offset = $d_ds->FilePos("(3004,000c)");
my $dose_gfov_length = $d_ds->EleLenInFile("(3004,000c)");
my $args = {
  slice_iop => [
    [$slice_iop->[0], $slice_iop->[1], $slice_iop->[2]],
    [$slice_iop->[3], $slice_iop->[4], $slice_iop->[5]],
  ],
  slice_ipp => $slice_ipp,
  slice_rows => $slice_rows,
  slice_cols => $slice_cols,
  slice_pix_sp => $slice_pix_sp,
  dose_iop => [
    [$dose_iop->[0], $dose_iop->[1], $dose_iop->[2]],
    [$dose_iop->[3], $dose_iop->[4], $dose_iop->[5]],
  ],
  dose_ipp => $dose_ipp,
  dose_rows => $dose_rows,
  dose_cols => $dose_cols,
  dose_pix_sp => $dose_pix_sp,
  dose_pix_offset => $dose_pix_offset,
  dose_pix_length => $dose_pix_length,
  dose_gfov_offset => $dose_gfov_offset,
  dose_gfov_length => $dose_gfov_length,
  dose_scaling => $dose_scaling,
  dose_units => $dose_units,
  dose_bytes => $dose_bytes,
  dose_file_name => $dose_file,
  base_isodose_file_name => $base_file,
  levels => \@ARGV,
};
#print STDERR "args: ";
#Debug::GenPrint($dbg, $args, 1);
#print STDERR "\n";
open my $fh, "|IsoDoseExtraction.pl" or die "Can't open |IsoDoseExtraction.pl";
store_fd($args, $fh);
