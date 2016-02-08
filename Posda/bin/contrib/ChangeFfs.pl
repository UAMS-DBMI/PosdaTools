#!/usr/bin/perl -w
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
  my $pix_sp = $ds->ExtractElementBySig("(0028,0030)");
  my $rows = $ds->ExtractElementBySig("(0028,0010)");
  my $cols = $ds->ExtractElementBySig("(0028,0011)");
  my $bits_alloc = $ds->ExtractElementBySig("(0028,0100)");
  #$ipp->[2] = -$ipp->[2];

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

my $user = `whoami`;
chomp $user;
my $host = `hostname`;
chomp $host;
my $UidRoot = Posda::UID::GetPosdaRoot({
    package => "ChangeFfs.pl",
    user => $user,
    host => $host,
    purpose => "Initialize",
  });
my $StudyUID = "$UidRoot.1";
my $SeriesUID = "$UidRoot.1.1";
my $ForUID = "$UidRoot.2";

my $ImageNum = 0;
for my $z (sort { $a <=> $b } keys %ImagesByZ){
  $ImageNum += 1;
  my $file_name = $ImagesByZ{$z}->{file_name};
  my $new_iop = $ImagesByZ{$z}->{new_iop};
  my $new_ipp = $ImagesByZ{$z}->{new_ipp};
  my $rows = $ImagesByZ{$z}->{rows};
  my $cols = $ImagesByZ{$z}->{cols};
  my $bits_alloc = $ImagesByZ{$z}->{bits_alloc};
  my $ImageUID = "$SeriesUID.$ImageNum";
  my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($file_name);
  my $pix = $ds->ExtractElementBySig("(7fe0,0010)");
  my $new_pix = Posda::FlipRotate::FlipArrayHorizontal(
    $pix, $rows, $cols, $bits_alloc);
  $ds->InsertElementBySig("(0020,0052)", $ForUID);
  $ds->InsertElementBySig("(0020,000d)", $StudyUID);
  $ds->InsertElementBySig("(0020,000e)", $SeriesUID);
  $ds->InsertElementBySig("(0020,0013)", $ImageNum);
  $ds->InsertElementBySig("(0008,0018)", $ImageUID);
  $ds->InsertElementBySig("(0020,0032)", $new_ipp);
  $ds->InsertElementBySig("(0020,0037)", $new_iop);
  $ds->InsertElementBySig("(0018,5100)", "FFS");
  $ds->InsertElementBySig("(7fe0,0010)", $new_pix);
  my $dest_file = "$output_dir/CT_$ImageUID.dcm";
  $ds->WritePart10($dest_file, $xfr_stx, "POSDA_SCR", undef, undef);
}
