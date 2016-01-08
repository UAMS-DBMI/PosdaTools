#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/AnalyzeRoi.pl,v $
#$Date: 2013/04/09 15:48:44 $
#$Revision: 1.1 $
#
use strict;
my $usage = 
  "AnalyzeRoi.pl <file> <offset> <len> <num_pts>";
unless($#ARGV == 3) { die $usage }
my $file = $ARGV[0];
my $offset = $ARGV[1];
my $length = $ARGV[2];
my $num_pts = $ARGV[3];
my ($max_x, $min_x, $max_y, $min_y, $max_z, $min_z);
open my $fh, $file or die "can't open $file";
seek $fh, $offset, 0;
my $buff;
my $read = read $fh, $buff, $length;
unless($read == $length) { die "read wrong length $read vs $length" }
my @data = split(/\\/, $buff);
for my $n (0 .. $num_pts - 1){
  my $xi = ($n * 3);
  my $yi = ($n * 3) + 1;
  my $zi = ($n * 3) + 2;
  my $x = $data[$xi];
  my $y = $data[$yi];
  my $z = $data[$zi];
  unless(defined $max_x) {$max_x = $x}
  unless(defined $min_x) {$min_x = $x}
  unless(defined $max_y) {$max_y = $y}
  unless(defined $min_y) {$min_y = $y}
  unless(defined $max_z) {$max_z = $z}
  unless(defined $min_z) {$min_z = $z}
  if($x > $max_x) {$max_x = $x}
  if($x < $min_x) {$min_x = $x}
  if($y > $max_y) {$max_y = $y}
  if($y < $min_y) {$min_y = $y}
  if($z > $max_z) {$max_z = $z}
  if($z < $min_z) {$min_z = $z}
}
print "$max_x|$min_x|$max_y|$min_y|$max_z|$min_z\n";
