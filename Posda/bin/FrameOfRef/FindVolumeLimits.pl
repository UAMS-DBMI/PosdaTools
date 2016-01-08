#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/FrameOfRef/FindVolumeLimits.pl,v $
#$Date: 2011/06/23 15:31:25 $
#$Revision: 1.5 $
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

my $usage = "usage: $0 <directory> <modality>";
unless($#ARGV == 1) {die $usage}
my $cwd = getcwd;
my $dir = $ARGV[0];
unless($dir =~ /^\//) {$dir = "$cwd/$dir"}
my $mod = $ARGV[1];

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
Posda::Find::SearchDir($ARGV[0], $finder);

my @offsets = sort { $a <=> $b} keys %FileByOffset;
my($max_x, $min_x, $max_y, $min_y, $max_z, $min_z);
for my $offset (@offsets){
  my $front = $FileByOffset{$offset};
  my($ul, $ur, $ll, $lr) = Posda::FlipRotate::ToCorners(
    $front->{rows}, $front->{cols}, $front->{iop}, 
    $front->{ipp}, $front->{pix_spc}
  );
  unless(defined $max_x) { $max_x = $ul->[0] }
  if($ul->[0] > $max_x) { $max_x = $ul->[0] }
  if($ur->[0] > $max_x) { $max_x = $ur->[0] }
  if($ll->[0] > $max_x) { $max_x = $ll->[0] }
  if($lr->[0] > $max_x) { $max_x = $lr->[0] }
  unless(defined $min_x) { $min_x = $ul->[0] }
  if($ul->[0] < $min_x) { $min_x = $ul->[0] }
  if($ur->[0] < $min_x) { $min_x = $ur->[0] }
  if($ll->[0] < $min_x) { $min_x = $ll->[0] }
  if($lr->[0] < $min_x) { $min_x = $lr->[0] }
  unless(defined $max_y) { $max_y = $ul->[1] }
  if($ul->[1] > $max_y) { $max_y = $ul->[1] }
  if($ur->[1] > $max_y) { $max_y = $ur->[1] }
  if($ll->[1] > $max_y) { $max_y = $ll->[1] }
  if($lr->[1] > $max_y) { $max_y = $lr->[1] }
  unless(defined $min_y) { $min_y = $ul->[1] }
  if($ul->[1] < $min_y) { $min_y = $ul->[1] }
  if($ur->[1] < $min_y) { $min_y = $ur->[1] }
  if($ll->[1] < $min_y) { $min_y = $ll->[1] }
  if($lr->[1] < $min_y) { $min_y = $lr->[1] }
  unless(defined $max_z) { $max_z = $ul->[2] }
  if($ul->[2] > $max_z) { $max_z = $ul->[2] }
  if($ur->[2] > $max_z) { $max_z = $ur->[2] }
  if($ll->[2] > $max_z) { $max_z = $ll->[2] }
  if($lr->[2] > $max_z) { $max_z = $lr->[2] }
  unless(defined $min_z) { $min_z = $ul->[2] }
  if($ul->[2] < $min_z) { $min_z = $ul->[2] }
  if($ur->[2] < $min_z) { $min_z = $ur->[2] }
  if($ll->[2] < $min_z) { $min_z = $ll->[2] }
  if($lr->[2] < $min_z) { $min_z = $lr->[2] }
}

printf("%0.5f < x < %0.5f\n", $max_x, $min_x);
printf("%0.5f < y < %0.5f\n", $max_y, $min_y);
printf("%0.5f < z < %0.5f\n", $max_z, $min_z);
