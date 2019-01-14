#!/usr/bin/perl -w
use strict;
my $fn = $ARGV[0];
unless($fn =~ /.*\/([^\/]*)$/) { die "can't make sense of $fn"}
$fn = $1;
my($pat, $study, $series, $img);
if($fn =~ /^([A-Z][A-Z])(\d+)_(\d+)$/){
  $pat = $1;
  my $stser = $2;
  $img = $3;
  if(length($stser) == 6){
    $stser =~ /(...)(...)/;
    $study = $1;
    $series = $2;
  } elsif(length($stser) == 7){
    $stser =~ /(....)(...)/;
    $study = $1;
    $series = $2;
  }
} elsif($fn =~ /^([A-Z][A-Z])(\d+)$/){
  $img = 1;
  $pat = $1;
  my $stser = $2;
  if(length($stser) == 6){
    $stser =~ /(...)(...)/;
    $study = $1;
    $series = $2;
  } elsif(length($stser) == 7){
    $stser =~ /(....)(...)/;
    $study = $1;
    $series = $2;
  }
} else {
  die "can't make sense of $fn";
}
$series =~ s/^0+//;
$img =~ s/^0+//;
#print "$pat:$series:$study:$img\n";
print "$pat,$series,$study\n";
