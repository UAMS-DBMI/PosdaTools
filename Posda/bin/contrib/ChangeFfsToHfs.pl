#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/ChangeFfsToHfs.pl,v $
#$Date: 2011/02/18 20:01:03 $
#$Revision: 1.2 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Find;
use Posda::FlipRotate;
use Posda::UID;

my %ImagesByZ;        #  Map a z-value to an Image file_name
#
# Callback to populate Data structures
#
my $finder = sub {
  my($file_name, $df, $ds, $size, $xfr_stx, $errors) = @_;
  my $ipp = $ds->ExtractElementBySig("(0020,0032)");
  my $iop = $ds->ExtractElementBySig("(0020,0037)");
  unless($ipp && $iop) { return };
  my $patient_pos = $ds->Get("(0018,5100)");
  unless($patient_pos && $patient_pos eq "FFS") { return };
  my $pix_sp = $ds->ExtractElementBySig("(0028,0030)");
  my $rows = $ds->ExtractElementBySig("(0028,0010)");
  my $cols = $ds->ExtractElementBySig("(0028,0011)");
  my $bits_alloc = $ds->ExtractElementBySig("(0028,0100)");

  my($tlhc, $trhc, $blhc, $brhc) = Posda::FlipRotate::ToCorners(
    $rows, $cols, $iop, $ipp, $pix_sp
  );
  my($new_iop, $new_ipp) = Posda::FlipRotate::FromCorners(
    $trhc, $tlhc, $brhc, $blhc
  );
  $ImagesByZ{$ipp->[2]} = {
    file_name => $file_name,
    new_iop => $new_iop,
    new_ipp => $new_ipp,
    rows => $rows,
    cols => $cols,
    bits_alloc => $bits_alloc,
    new_patient_pos => "HFS",
  }
};

unless($#ARGV == 1){ die "usage: $0 <input_dir> <output_dir>" }
my $input_dir = $ARGV[0];
my $output_dir = $ARGV[1];
opendir DIR, $output_dir or die "can't opendir $output_dir";
dir:
while(my $file = readdir(DIR)){
  if($file eq ".") { next dir }
  if($file eq "..") { next dir }
  die "$output_dir is not empty (and I'm afraid to 'rm -rf $output_dir/*'";
}
closedir DIR;

#
# Populate Data structures by finding files and Calling Callback
#
Posda::Find::SearchDir($input_dir, $finder);

my $ImageNum = 0;
for my $z (sort { $a <=> $b } keys %ImagesByZ){
  $ImageNum += 1;
  my $file_name = $ImagesByZ{$z}->{file_name};
  my $new_iop = $ImagesByZ{$z}->{new_iop};
  my $new_ipp = $ImagesByZ{$z}->{new_ipp};
  my $rows = $ImagesByZ{$z}->{rows};
  my $cols = $ImagesByZ{$z}->{cols};
  my $bits_alloc = $ImagesByZ{$z}->{bits_alloc};
  my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($file_name);
  my $ImageUID = $ds->Get("(0008,0018)");
  my $Modality = $ds->Get("(0008,0060)");
  my $dest_file = "$output_dir/${Modality}_$ImageUID.dcm";
  if($file_name =~ /\/([^\/]*)$/){
    $dest_file = "$output_dir/$1";
  }
  print "Translating $file_name to $dest_file\n";
  my $pix = $ds->ExtractElementBySig("(7fe0,0010)");
  my $new_pix = Posda::FlipRotate::FlipArrayHorizontal(
    $pix, $rows, $cols, $bits_alloc);
  $ds->InsertElementBySig("(0020,0013)", $ImageNum);
  $ds->InsertElementBySig("(0020,0032)", $new_ipp);
  $ds->InsertElementBySig("(0020,0037)", $new_iop);
  $ds->InsertElementBySig("(0018,5100)", "HFS");
  $ds->InsertElementBySig("(7fe0,0010)", $new_pix);
  $ds->WritePart10($dest_file, $xfr_stx, "POSDA_SCR", undef, undef);
}
