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
use Posda::Dvh;
unless($#ARGV == 3){
  die "usage DumpDVH.pl <dose_file> <ss_file> <vol_units> <image_file>\n";
}
my $dbg = sub {print @_};
my $dose_file = $ARGV[0];
my $ss_file = $ARGV[1];
my $VolumeUnits = $ARGV[2];
my $file_name = $ARGV[3];
my($dose_df, $dose_ds, $dose_size, $dose_xfr_stx, $dose_errors) = 
  Posda::Dataset::Try($dose_file);
my($ss_df, $ss_ds, $ss_size, $ss_xfr_stx, $ss_errors) = 
  Posda::Dataset::Try($ss_file);
unless($dose_ds) {die "$dose_file isn't a DICOM file"}
unless($ss_ds) {die "$ss_file isn't a DICOM file"}
my $ss_map = Posda::Dvh::RoiStructMap->new($ss_ds);
my $dvh = Posda::Dvh->new_from_dose_ss($dose_ds, $ss_map);
my $ip_dose = Posda::IpDose->new_from_dose($dose_ds);
my $List = $dvh->{List};
if(defined $dvh->{NormPoint} && defined $dvh->{NormValue}){
  print "Normalization $dvh->{NormValue} at ($dvh->{NormPoint}->[0], " .
    "$dvh->{NormPoint}->[1], $dvh->{NormPoint}->[2])\n";
}
my $min_dose = 0;
my $max_dose = 0;
my $min_vol = 0;
my $max_vol = 0;
for my $i (0 .. $#{$List}){
  my $item = $List->[$i];
  unless($item->{VolumeUnits} eq $VolumeUnits){ next }
  my $high_dose = $item->{MaximumDose} * 100;
  my $low_dose = $item->{MinimumDose} * 100;
  if($high_dose > $max_dose) { $max_dose = $high_dose }
  if($low_dose < $min_dose) { $min_dose = $low_dose }
  my $vol = 0;
  for my $j (0 .. $#{$item->{struct}}){
    if($item->{struct}->[$j]->{ContributionType} eq "INCLUDED"){
      $vol += $item->{struct}->[$j]->{Roi}->{vol};
    }
  }
  if($vol > $max_vol) { $max_vol = $vol }
}
$max_dose += 100;
$max_dose = ((int ($max_dose / 100)) + 1) * 100;
$max_vol = ((int ($max_vol / 100)) + 1) * 100;
if($min_dose < 100) { $min_dose = 0 }
my $max_x = $max_dose;
my $min_x = $min_dose;
my $max_y = 0;
my $min_y = 0;
if($VolumeUnits eq "PERCENT"){
  $min_y = 0;
  $max_y = 100;
} elsif ($VolumeUnits eq "CM3"){
  $min_y = $min_vol;
  $max_y = $max_vol;
} else {
  die "Unhandled VolumeUnits $VolumeUnits";
}
my $g = Posda::Dvh::Graph->new();
$g->DrawHorizScale(5);
$g->DrawVertScale(5);
$g->SetXScale(0, $max_x);
$g->SetYScale(0, $max_y);
$g->MarkHorizScale(0, $max_y);
$g->MarkVertScale(0, $max_x);
my $color_index = 0;
my $caption_index = 0;
my $color_list = ["red", "green", "blue", "violet", "yellow", "pink"];
for my $i (0 .. $#{$List}){
  my $item = $List->[$i];
  unless($item->{VolumeUnits} eq $VolumeUnits){ next }
  my $color = $color_list->[$color_index];
  $color_index += 1;
  if($color_index > $#{$color_list}){ $color_index = 0 }
  $g->DrawDvh($item->{Data}, $color);
  my $Caption = "$item->{Type} - ";
  print "$item->{Type}|$item->{Units}|$item->{DoseType}|$item->{DoseScaling}";
  print "|$item->{VolumeUnits}|$item->{NumBins}" ;
  print "|$item->{RealLength}|min:$item->{MinimumDose}";
  print "|max:$item->{MaximumDose}|mean:$item->{MeanDose}\n";
  for my $j (0 .. $#{$item->{struct}}){
    my $struct = $item->{struct};
    $Caption .= "$struct->[$j]->{ContributionType}(" .
      "$struct->[$j]->{Roi}->{desc}) ";
    print "\t$struct->[$j]->{ContributionType}|" .
      "$struct->[$j]->{Roi}->{desc}|" .
      "$struct->[$j]->{Roi}->{gen}|" .
      "$struct->[$j]->{Roi}->{type}|" .
      "$struct->[$j]->{Roi}->{vol}\n";
  }
  $g->AddCaption($caption_index, 15, $Caption, $color);
  $caption_index += 1;
 # print "\tData: ";
 # my $printed = 0;
 # for my $i (@{$item->{Data}}){
 #   print "$i ";
 #   $printed += 1;
 #   if($printed >= 10){ $printed = 0; print "\n\t      ";}
 # }
 # print "\n";
}
print "Interest Points:\n";
for my $ip_name (sort keys %$ip_dose){
  print "$ip_name $ip_dose->{$ip_name}->{Alg} " .
    "($ip_dose->{$ip_name}->{Point}->[0],".
    "$ip_dose->{$ip_name}->{Point}->[1]," .
    "$ip_dose->{$ip_name}->{Point}->[2]) " .
    "$ip_dose->{$ip_name}->{Value} " .
    "$ip_dose->{$ip_name}->{Units}\n";
}
$g->Render($file_name);
