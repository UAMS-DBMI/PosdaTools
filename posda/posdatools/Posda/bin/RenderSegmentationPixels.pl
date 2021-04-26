#!/usr/bin/perl -w
use strict;
my $usage = <<EOF;
RenderSegmentationPixels.pl <path_to_rendering_inst> <path_of_dest_file>

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 1){
  my $num_args = @ARGV;
  die "wrong number of args ($num_args vs 2):\n$usage\n";
}
my($rend_path, $dest_path) = @ARGV;
my @lines;
open REND, "<$rend_path" or die "can't open $rend_path";
while(my $l = <REND>){
  chomp $l;
  push @lines, $l;
}
close REND;
open FILE, ">$dest_path" or die "Can't open $dest_path ($!)";
my $seq = 0;
my $pixel_bytes = 0;
for my $i (@lines){
  $seq += 1;
  my $cmd = "cat $i|CmdCtoRbm.pl";
  my $data = `$cmd`;
  my $len = length($data);
  print FILE $data;
  print "Wrote $len bytes ($seq)\n";
  $pixel_bytes += $len;
}
print "Total frames: $seq\n";
print "Pixel bytes: $pixel_bytes\n";
