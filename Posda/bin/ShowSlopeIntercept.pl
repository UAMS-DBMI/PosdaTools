#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::DataSet;
my %Locations;
Posda::Dataset::InitDD();
for my $file (`ls`){
  chomp $file;
  unless(-f $file && -r $file) { next }
  my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($file);
  unless(defined $ds) { next }
  my $modality = $ds->ExtractElementBySig("(0008,0060)");
  my $rows = $ds->ExtractElementBySig("(0028,0010)");
  my $cols = $ds->ExtractElementBySig("(0028,0011)");
  my $ipp = $ds->ExtractElementBySig("(0020,0032)");
  my $slope = $ds->ExtractElementBySig("(0028,1053)");
  my $intercept = $ds->ExtractElementBySig("(0028,1052)");
  my $units = $ds->ExtractElementBySig("(0054,1001)");
  my $bits_stored = $ds->ExtractElementBySig("(0028,0101)");
  my $pixel_representation = $ds->ExtractElementBySig("(0028,0103)");
  my $max_pix_value = 0x7fff;
  if($bits_stored == 12){
    if($pixel_representation == 0){
      $max_pix_value = 0xfff;
    } else {
      $max_pix_value = 0x7ff;
    }
  } elsif($bits_stored == 16){
    if($pixel_representation == 0){
      $max_pix_value = 0xffff;
    }
  }
  unless($modality eq "PT") {next}
  $Locations{$ipp->[2]} = {
    slope => $slope,
    intercept => $intercept,
    units => $units,
    bits => $bits_stored,
    max => $max_pix_value,
  };
}
my @locations = sort { $a <=> $b} keys %Locations;
for my $z (@locations){
  my $max_possible = ($Locations{$z}->{max} * $Locations{$z}->{slope}) +
    $Locations{$z}->{intercept};
  print "Location $z:\t$Locations{$z}->{units} ($Locations{$z}->{bits}) " .
    "$Locations{$z}->{slope} $Locations{$z}->{intercept} $max_possible\n";
}
