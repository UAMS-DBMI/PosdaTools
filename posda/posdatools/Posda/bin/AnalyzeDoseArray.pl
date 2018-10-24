#!/usr/bin/perl -w
#
use strict;
use Digest::MD5;
my $usage = 
  "AnalyzeDoseArray.pl <file> <offset> <#frames> <#rows> <#cols> <#bytes>";
unless($#ARGV == 5) { die $usage }
my $file = $ARGV[0];
my $offset = $ARGV[1];
my $num_frames = $ARGV[2];
my $num_rows = $ARGV[3];
my $num_cols = $ARGV[4];
my $num_bytes = $ARGV[5];
my $max_dose = 0;
my $min_dose = 0xffffffff;
my $max_dose_at;
open my $fh, $file or die "can't open $file";
seek $fh, $offset, 0;
my $buff;
for my $f (0 .. $num_frames - 1){
  for my $r  (0 .. $num_rows - 1){
    for my $c (0 .. $num_cols - 1){
      my $count = read($fh, $buff, $num_bytes);
      unless($count == $num_bytes) { die "read $count vs $num_bytes" }
      my $value = ($num_bytes == 2) ?  unpack("v", $buff) : unpack("V", $buff);
      unless(defined($max_dose)){ $max_dose = $value }
      unless(defined($min_dose)){ $min_dose = $value }
      if($value > $max_dose){
	$max_dose_at = $f;
	$max_dose = $value;
      }
      if($value < $min_dose){
	$min_dose = $value;
      }
    }
  }
}
print "$max_dose_at|$max_dose|$min_dose\n";
