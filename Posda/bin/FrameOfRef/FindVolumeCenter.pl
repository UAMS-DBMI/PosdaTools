#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/FrameOfRef/FindVolumeCenter.pl,v $
#$Date: 2011/06/23 15:31:25 $
#$Revision: 1.4 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use strict;
use Posda::Find;
use Posda::FlipRotate;
use VectorMath;


my $usage = "usage: $0 <dir> <modality>";
unless($#ARGV == 1) {die $usage}
my $cwd = getcwd;
my $dir = $ARGV[0];
my $mod = $ARGV[1];
unless($dir =~ /^\//) {$dir = "$cwd/$dir"}

my $batch_rows;
my $batch_cols;
my $batch_iop;
my $batch_ipp;
my $batch_pix_spacing;

my %FileByOffset;


my $finder = sub {
  my($file_name, $df, $ds, $size, $xfr_stx, $errors) = @_;
  if($file_name =~ /\/\.[^\/]+$/) {return}
  my $modality = $ds->Get("(0008,0060)");
  unless(defined $modality) { return }
  unless($modality eq $mod){ return }
  my $rows = $ds->Get("(0028,0010)");
  my $cols = $ds->Get("(0028,0011)");
  my $iop = $ds->Get("(0020,0037)");
  my $ipp = $ds->Get("(0020,0032)");
  my $pix_spacing = $ds->Get("(0028,0030)");
  my $normal = VectorMath::cross([$iop->[0], $iop->[1], $iop->[2]],
    [$iop->[3], $iop->[4], $iop->[5]]);
  unless(defined $batch_rows) { $batch_rows = $rows }
  unless(defined $batch_cols) { $batch_cols = $cols }
  unless(defined $batch_iop) { $batch_iop = $iop }
  unless(defined $batch_ipp) { $batch_ipp = $ipp }
  unless(defined $batch_pix_spacing) { $batch_pix_spacing  = $pix_spacing }

  unless($batch_rows == $rows) { die "Inconsistent rows" }
  unless($batch_cols == $cols) { die "Inconsistent cols" }
  unless(abs(VectorMath::Abs([$iop->[0], $iop->[1], $iop->[2]]) - 1) < .0001){
    die "IOP is not unit vector";
  }
  unless(abs(VectorMath::Abs([$iop->[3], $iop->[4], $iop->[5]]) - 1) < .0001){
    die "IOP is not unit vector";
  }
  unless(
    abs (
      VectorMath::Dot(
        [$batch_iop->[0], $batch_iop->[1], $batch_iop->[2]],
        [$iop->[0], $iop->[1], $iop->[2]]
      )  - 1
    ) < 0.0001
  ) { die "Inconsistent IOP" }
  unless(
    abs (
      VectorMath::Dot(
        [$batch_iop->[3], $batch_iop->[4], $batch_iop->[5]],
        [$iop->[3], $iop->[4], $iop->[5]]
      )  - 1
    ) < 0.0001
  ) { die "Inconsistent IOP" }
  

  unless(
    $batch_pix_spacing->[0] == $pix_spacing->[0] &&
    $batch_pix_spacing->[1] == $pix_spacing->[1]
  ) { 
    die "Inconsistent pixel spacing"
  }

  if ($modality eq "RTDOSE"){
    my $gfov = $ds->Get("(3004,000c)");
    for my $s_off (@$gfov){
      my $dist = VectorMath::Scale($s_off, $normal);
      my $e_ipp = VectorMath::Add($ipp, $dist);
      $FileByOffset{$s_off} = {
        iop => $iop,
        ipp => $e_ipp,
        rows => $rows,
        cols => $cols,
        pix_spc => $pix_spacing,
        file_name => $file_name,
      };
    }
  } else {
    my $offset = VectorMath::Dot($normal, $ipp);
    $FileByOffset{$offset} = {
      iop => $iop,
      ipp => $ipp,
      rows => $rows,
      cols => $cols,
      pix_spc => $pix_spacing,
      file_name => $file_name,
    };
  }
};
Posda::Find::SearchDir($dir, $finder);

my @offsets = sort { $a <=> $b} keys %FileByOffset;
my $front = $FileByOffset{$offsets[0]};
my $back = $FileByOffset{$offsets[$#offsets]};
my($ful, $fur, $fll, $flr) = Posda::FlipRotate::ToCorners(
  $front->{rows}, $front->{cols}, $front->{iop}, 
  $front->{ipp}, $front->{pix_spc}
);
my($bul, $bur, $bll, $blr) = Posda::FlipRotate::ToCorners(
  $back->{rows}, $back->{cols}, $back->{iop}, 
  $back->{ipp}, $back->{pix_spc}
);
my $c_x = ($ful->[0] + $blr->[0]) / 2;
my $c_y = ($ful->[1] + $blr->[1]) / 2;
my $c_z = ($ful->[2] + $blr->[2]) / 2;

printf "Center = (%0.5f, %0.5f, %0.5f)\n", $c_x, $c_y, $c_z;
