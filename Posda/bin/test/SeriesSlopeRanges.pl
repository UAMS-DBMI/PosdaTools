#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Try;
use Posda::Find;
use Debug;
my $dbg = sub {print @_ };
my $Results;
my $usage = "usage: $0 <dir>";
unless($#ARGV == 0) {die $usage}
my %Series;
sub handle {
  my($try) = @_;
  my $ds = $try->{dataset};
  my $series_uid = $ds->Get("(0020,000e)");
  my $sop_uid = $ds->Get("(0008,0018)");
  my $modality = $ds->ExtractElementBySig("(0008,0060)");
  unless($modality eq "PT") { return }
  my $rows = $ds->ExtractElementBySig("(0028,0010)");
  my $cols = $ds->ExtractElementBySig("(0028,0011)");
  my $ipp = $ds->ExtractElementBySig("(0020,0032)");
  my $slope = $ds->ExtractElementBySig("(0028,1053)");
  my $intercept = $ds->ExtractElementBySig("(0028,1052)");
  my $units = $ds->ExtractElementBySig("(0054,1001)");
  my $bits_stored = $ds->ExtractElementBySig("(0028,0101)");
  my $pixel_representation = $ds->ExtractElementBySig("(0028,0103)");
  my $max_pix_value = 0x7fff;
  my $wc = $try->{dataset}->Get("(0028,1050)")->[0];
  my $ww = $try->{dataset}->Get("(0028,1051)")->[0];
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
  if(exists $Series{$series_uid}->{locations}->{$ipp->[2]}){
    print STDERR "Two images at location $ipp->[2] in $series_uid\n";
    return;
  }
  $Series{$series_uid}->{locations}->{$ipp->[2]} = {
    slope => $slope,
    intercept => $intercept,
    units => $units,
    bits => $bits_stored,
    max => $max_pix_value,
    wc => $wc,
    ww => $ww,
  };
}
Posda::Find::DicomOnly($ARGV[0], \&handle);
#print "Series: ";
#Debug::GenPrint($dbg, \%Series, 1);
#print "\n";
#exit;
for my $series (keys %Series){
  my @locations = sort {$a <=> $b} keys %{$Series{$series}->{locations}};
  my $max_max = 0;
  my $min_max;
  my %wc;
  my %ww;
  for my $z (@locations){
    my $h = $Series{$series}->{locations}->{$z};
    my $max = $h->{max} * $h->{slope};
    if($max > $max_max) { $max_max = $max }
    unless(defined $min_max) { $min_max = $max }
    if($max < $min_max) { $min_max = $max }
#    print "\tlocation $z:\t$h->{slope}\t$max_possible\n";
    $wc{$h->{wc}} = 1;
    $ww{$h->{ww}} = 1;
  }
  print "Series: $series\n" .
        "  max_max: $max_max\n" .
        "  min_max: $min_max\n";
  print "  wc:";
  for my $wc (keys %wc) { print " $wc" }
  print "\n";
  print "  ww:";
  for my $ww (keys %ww) { print " $ww" }
  print "\n";
}
