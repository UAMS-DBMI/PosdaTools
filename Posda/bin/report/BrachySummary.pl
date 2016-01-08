#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/report/BrachySummary.pl,v $
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
use Posda::Dataset;

unless($#ARGV == 0){
  die "usage: $0 <file>\n";
}
my $file = $ARGV[0];
unless($file =~ /^\//) {$file = getcwd."/$file"}

my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($file);
unless(defined $ds) { die "Can't parse $file" }

my $m = $ds->Search("(300a,0210)[<0>](300a,0212)");
unless(
  defined($m) && 
  ref($m) eq "ARRAY" &&
  $#{$m} >= 0
){
  print "$file has no brachy sources defined\n";
  exit;
}
source:
for my $i (@$m){
  my $in = $i->[0];
  my $source_number = $ds->Get("(300a,0210)[$in](300a,0212)");
  my $source_type = $ds->Get("(300a,0210)[$in](300a,0214)");
  my $source_isotope_name = $ds->Get("(300a,0210)[$in](300a,0226)");
  my $source_isotope_half_life = $ds->Get("(300a,0210)[$in](300a,0228)");
  my $reference_air_kerma_rate = $ds->Get("(300a,0210)[$in](300a,022a)");
  my $reference_air_kerma_ref_date = $ds->Get("(300a,0210)[$in](300a,022c)");
  my $reference_air_kerma_ref_time = $ds->Get("(300a,0210)[$in](300a,022e)");
  print "Source: $source_number, type: $source_type, isotope:" .
    " $source_isotope_name half life: $source_isotope_half_life\n";
  print "Air Kerma Rate: $reference_air_kerma_rate U at " .
    "$reference_air_kerma_ref_date $reference_air_kerma_ref_time\n";
  my $m1 = $ds->Search("(300a,0230)[<0>](300a,0280)[<1>](300c,000e)", 
    $source_number);
  unless(
    defined($m1) && 
    ref($m1) eq "ARRAY" &&
    $#{$m1} >= 0
  ){
    print "No seeds found using this source\n\n";
    next source;
  }
  my $count = scalar @{$m1};
  print "$count seeds found using this source:\n\n";
  print "App #\t3DPosition (x, y, z)\n";
  for my $s (@$m1){
    my $app_i = $s->[0];
    my $chan_i = $s->[1];
    my $app_num = $ds->Get("(300a,0230)[$app_i](300a,0234)");
    my $app_type = $ds->Get("(300a,0230)[$app_i](300a,0232)");
    my $chan_num = $ds->Get(
      "(300a,0230)[$app_i](300a,0280)[$chan_i](300a,0282)");
    my $movement_type = $ds->Get(
      "(300a,0230)[$app_i](300a,0280)[$chan_i](300a,0288)");
    my $chan_time = $ds->Get(
      "(300a,0230)[$app_i](300a,0280)[$chan_i](300a,0286)");
    my $pos = $ds->Get(
      "(300a,0230)[$app_i](300a,0280)[$chan_i](300a,02d0)[0](300a,02d4)");
    print "$app_num\t";
    if($movement_type eq "FIXED"){
      print "($pos->[0], $pos->[1], $pos->[2])\n";
    } else {
      print "Error - movement type is not fixed\n";
    }
  }
  print "\n";
}
