#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/DvhBinCollector.pl,v $
#$Date: 2011/10/14 20:08:20 $
#$Revision: 1.2 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

# 
# All of the parameters on the command line are of the form:
#  <name>=<value> (no spaces)
# parameter order does not matter.
# Here are the possible parameters:
#  in1=<number of input fd>      on which the ROI bitmap is read
#  in2=<number of input fd>      on which the Resampled Dose is read
#  out=<number of output fd>     to which the histogram is written
#  status=<number of output fd>  to which the status is written
#  binwidth = <bin_width>
#
use strict;
my($in1, $in2, $out, $binwidth, $bytesperpix, $status);
#my $debug;
for my $i (@ARGV){
  unless($i =~ /^([^=]+)=([^=]+)$/) {
    die "$0: can't parse parameter $i";
  }
  my $key = $1;
  my $value = $2;
  if($key eq "in1") { $in1 = $value }
  elsif ($key eq "in2") { $in2 = $value }
  elsif ($key eq "out") { $out = $value }
  elsif ($key eq "status") { $status = $value }
  elsif ($key eq "binwidth") { $binwidth = $value }
  elsif ($key eq "bytesperpix") { $bytesperpix = $value }
#  elsif ($key eq "debug") { $debug = $value }
  else { die "$0: unknown parameter: $key" }
}
unless(defined($in1)){ die "$0: in1 undefined" }
unless(defined($in2)){ die "$0: in2 undefined" }
unless(defined($out)){ die "$0: out undefined" }
unless(defined($status)){ die "$0: status undefined" }
unless(defined($binwidth)){ die "$0: binwidth undefined" }
unless(defined($bytesperpix)){ die "$0: bytesperpix undefined" }
open(INPUT, "<&", $in1) or die "$0: Can't open in1 = $in1 ($!)";
open(INPUT1, "<&", $in2) or die "$0: Can't open in2 = $in2 ($!)";
open(OUTPUT, ">&", $out) or die "$0: Can't open out = $out ($!)";
#if($debug) {
# print "$0: DEBUG\n";
# print "\tbinwidth: $binwidth\n";
# print "\tbytesperpix: $bytesperpix\n";
#}
my $buff;
my $pixbuff;
my @bins;
my $vol = 0;
my $pix_bytes_read = 0;
my $bit_map_bytes_read = 0;
my $smallest_dose;
my $largest_dose;
while(my $count = sysread(INPUT, $buff, 1)){
  unless($count == 1) { die "$0: Bad read on bitmap socket ($count, $!)" }
  $bit_map_bytes_read += 1;
  no warnings;
  my @in = unpack("c", $buff);
  my $numpix = 8 * $bytesperpix;
  my $numread = sysread(INPUT1, $pixbuff, $numpix);
  unless($numread == $numpix) {
     die "$0: incomplete read";
  }
  $pix_bytes_read += $numread;
  # unpack pixels and fill bins here
  my @pix;
  if($bytesperpix == 2) {
    @pix = unpack("v8", $pixbuff);
  } elsif ($bytesperpix == 4){
    @pix = unpack("V8", $pixbuff);
  } else {
    die "$0: Only handle shorts and longs";
  }
  my $mask = 0x01;
  for my $i (0 .. 7){
    if($in[0] & $mask) {
      unless(defined $smallest_dose) { $smallest_dose = $pix[$i] }
      unless(defined $largest_dose) { $largest_dose = $pix[$i] }
      if($pix[$i] > $largest_dose) { $largest_dose = $pix[$i] }
      if($pix[$i] < $smallest_dose) { $smallest_dose = $pix[$i] }
      my $index =  int($pix[$i]/$binwidth);
      $bins[$index] += 1;
      $vol += 1;
    }
    $mask *= 2;
  }
}
#process and output bins here
my $so_far = 0;
for my $i (0 .. $#bins){
  my $from_end = $#bins - $i;
  $bins[$from_end] += $so_far;
  $so_far = $bins[$from_end];
}
print OUTPUT "Number of bins: $#bins\n";
print OUTPUT "Number of pixmap bytes read: $bit_map_bytes_read\n";
print OUTPUT "Total Volume: $vol\n";
print OUTPUT "Smallest Dose: $smallest_dose, largest: $largest_dose\n";
my $volume = $bins[0];
for my $i (0 .. $#bins){
  unless(defined $bins[$i]) {$bins[$i] = 0}
  my $percent = sprintf("%02d", 100 * $bins[$i]/$volume);
  print OUTPUT "$i $bins[$i] $percent\n";
}
if(defined $status){
  open(STATUS, ">&", $status) or die "$0: Can't open status = $status";
  print STATUS "OK\n";
  close STATUS;
}
