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
my %Locations;
Posda::Dataset::InitDD();
file:
for my $file (`ls`){
  chomp $file;
  unless(-f $file && -r $file) { next }
  my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($file);
  unless(defined $ds) { next file }
  my $modality = $ds->ExtractElementBySig("(0008,0060)");
  unless($modality eq "CT") { next file }
  my $rows = $ds->ExtractElementBySig("(0028,0010)");
  my $cols = $ds->ExtractElementBySig("(0028,0011)");
  my $iop = $ds->ExtractElementBySig("(0020,0037)");
  my $ipp = $ds->ExtractElementBySig("(0020,0032)");
  my $pix_size_x = $ds->ExtractElementBySig("(0028,0030)[0]");
  my $pix_size_y = $ds->ExtractElementBySig("(0028,0030)[1]");
  my $dxdc = $iop->[0];
  my $dydc = $iop->[1];
  my $dzdc = $iop->[2];
  my $dxdr = $iop->[3];
  my $dydr = $iop->[4];
  my $dzdr = $iop->[5];
  my $x = $ipp->[0];
  my $y = $ipp->[1];
  my $z = $ipp->[2];
  my $tlhc = [$x, $y, $z];
  my $trhc = [
     $x + ($dxdc * ($cols - 1) * $pix_size_y),
     $y + ($dydc * ($cols - 1) * $pix_size_y),
     $z + ($dzdc * ($cols - 1) * $pix_size_y)
  ];
  my $blhc = [
     $x + ($dxdr * ($rows - 1) * $pix_size_x),
     $y + ($dydr * ($rows - 1) * $pix_size_x),
     $z + ($dzdr * ($rows - 1) * $pix_size_x)
  ];
  my $brhc = [
     $x + ($dxdc * ($cols - 1) * $pix_size_y) +
          ($dxdr * ($rows - 1) * $pix_size_x),
     $y + ($dydc * ($cols - 1) * $pix_size_y) +
          ($dydr * ($rows - 1) * $pix_size_x),
     $z + ($dzdc * ($cols - 1) * $pix_size_y) +
          ($dzdr * ($rows - 1) * $pix_size_x)
  ];
  $Locations{$tlhc->[2]} = {
    trhc => $trhc,
    tlhc => $tlhc,
    brhc => $brhc,
    blhc => $blhc
  };
}
my @locations = sort { $a <=> $b} keys %Locations;
my $min_z = $locations[0];
my $max_z = $locations[$#locations];
my $min_x = $Locations{$min_z}->{tlhc}->[0];
my $min_y = $Locations{$min_z}->{tlhc}->[1];
my $max_x = $Locations{$min_z}->{brhc}->[0];
my $max_y = $Locations{$min_z}->{brhc}->[1];
print "$min_x < x < $max_x\n";
print "$min_y < y < $max_y\n";
print "$min_z < z < $max_z\n";
