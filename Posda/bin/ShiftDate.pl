#!/usr/bin/perl -w
use strict;
use Time::Piece;
use Time::Seconds;
my $usage = <<EOF;
ShiftDate.pl yyyy-mm-dd <date_inc>
  date_inc is seconds.   May be negative.
EOF
unless($#ARGV == 1) { die $usage }
unless($ARGV[0] =~ /(....)-(..)-(..)/){
  die "date must be yyyy-mm-dd";
}
my $date = Time::Piece->strptime($ARGV[0], "%Y-%m-%d");
$date += (ONE_DAY / 2);
$date += (ONE_DAY * $ARGV[1]);
my $val = $date->strftime("%Y-%m-%d");
print "Shifted: $val\n";
