#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/ExtractDvh.pl,v $
#$Date: 2011/06/23 15:31:26 $
#$Revision: 1.2 $
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
use Debug;
my $dbg = sub {print @_};
my $usage = "usage: $0 <file> <dvh number>";
unless($#ARGV == 0) {die $usage}
my $file = $ARGV[0];
unless($file =~ /^\//) {$file = getcwd."/$file"}
my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($file);
unless($ds) {die "$file isn't a DICOM file"}
my $match = $ds->Search("(3004,0050)[<0>](3004,0058)");
my @List;
for my $m (@$match){
  my $i = $m->[0];
  my $hash;
  $hash->{Type} = $ds->Get("(3004,0050)[$i](3004,0001)");
  $hash->{Units} = $ds->Get("(3004,0050)[$i](3004,0002)");
  $hash->{DoseType} = $ds->Get("(3004,0050)[$i](3004,0004)");
  $hash->{DoseScaling} = $ds->Get("(3004,0050)[$i](3004,0052)");
  $hash->{VolumeUnits} = $ds->Get("(3004,0050)[$i](3004,0054)");
  $hash->{NumBins} = $ds->Get("(3004,0050)[$i](3004,0056)");
  $hash->{Data} = $ds->Get("(3004,0050)[$i](3004,0058)");
  $hash->{RealLength} = scalar @{$hash->{Data}};
  my $match1 = $ds->Search("(3004,0050)[$i](3004,0060)[<0>](3004,0062)");
  for my $m1 (@$match1){
    my $j = $m1->[0];
    $hash->{struct}->[$j]->{ContributionType} =
      $ds->Get("(3004,0050)[$i](3004,0060)[$j](3004,0062)");
    $hash->{struct}->[$j]->{RoiNum} =
      $ds->Get("(3004,0050)[$i](3004,0060)[$j](3006,0084)");
  }
  $hash->{MinimumDose} = $ds->Get("(3004,0050)[$i](3004,0070)");
  $hash->{MaximumDose} = $ds->Get("(3004,0050)[$i](3004,0072)");
  $hash->{MeanDose} = $ds->Get("(3004,0050)[$i](3004,0074)");
  $List[$i] = $hash;
}
my $dvh_no = $ARGV[1];
my $data = $List[$dvh_no]->{Data};
my $num_points = (scalar @{$data}) / 2;
for my $i (0 .. $num_points - 1){
  print "$data->[$i * 2]\t$data->[($i * 2) + 1]\n";
}
