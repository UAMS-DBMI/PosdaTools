#!/usr/bin/perl -w
use strict;
use Time::HiRes;
use Time::Piece;
my $usage = <<EOF;
ShiftDate.pl <epoch> 
EOF
unless($#ARGV == 0) { die $usage }
my $d = $ARGV[0];
my $frac = "";
if($d =~ /^([\+\-]*\d+)(\.\d+)$/){
  $d = $1;
  $frac = $2;
  if($d < 0){
    $d -=  1;
    $frac = 1 - $frac;
    if($frac =~ /(\.\d+)$/){
      $frac = $1;
    } else {
      $frac = "";
    }
  }
}
my $date = Time::Piece->new($d);
my $val = $date->strftime("%Y%m%d%H%M%S");
print "Date: $val$frac\n";
