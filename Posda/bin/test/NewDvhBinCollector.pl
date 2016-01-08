#!/usr/bin/perl -w 
#$Source: /home/bbennett/pass/archive/Posda/bin/test/NewDvhBinCollector.pl,v $
#$Date: 2011/10/20 13:33:28 $
#$Revision: 1.3 $
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
#  in0=<number of input fd>      on which the Resampled Dose is read
#  in<n>=<number of input fd>    on which the ROI bitmap <n> is read
#                                (n >= 1)
#  out<n>=<number of output fd>  to which the histogram <n> is written
#                                (n >= 1 corresponds to ROI bitmap)
#  status=<number of output fd>  to which the status is written
#  binwidth = <bin_width>
#
use strict;
my($dose_in, $binwidth, $bytesperpix, $status);
my @bitmap_in;
my @dvh_out;
#my $debug;
for my $i (@ARGV){
  unless($i =~ /^([^=]+)=([^=]+)$/) {
    die "$0: can't parse parameter $i";
  }
  my $key = $1;
  my $value = $2;
  if($key eq "in0") { $dose_in = $value }
  elsif ($key =~ /in([\d]+)/) { $bitmap_in[$1] = $value }
  elsif ($key =~ /out([\d]+)/) { $dvh_out[$1] = $value }
  elsif ($key eq "status") { $status = $value }
  elsif ($key eq "binwidth") { $binwidth = $value }
  elsif ($key eq "bytesperpix") { $bytesperpix = $value }
#  elsif ($key eq "debug") { $debug = $value }
  else { die "$0: unknown parameter: $key" }
}
unless(defined($dose_in)){ die "$0: in0 undefined" }
unless(defined($status)){ die "$0: status undefined" }
unless(defined($binwidth)){ die "$0: binwidth undefined" }
unless(defined($bytesperpix)){ die "$0: bytesperpix undefined" }
open(INPUT, "<&", $dose_in) or die "$0: Can't open dose_in = $dose_in ($!)";
unless($#bitmap_in == $#dvh_out){ die "$0: number of bitmaps ($#bitmap_in) " .
  "doesn't match number of dvh's ($#dvh_out)" }
my @DvhStreams;
for my $i (0 .. $#bitmap_in){
  unless(defined($bitmap_in[$i]) && defined($dvh_out[$i])) {
    if(defined($bitmap_in[$i])){
      die "$0: bitmap_in[$i] defined, but dvh_out[$i] isn't";
    }
    if(defined($dvh_out[$i])){
      die "$0: dvh_out[$i] defined, but bitmap_in[$i] isn't";
    }
    next;
  }
  open my $fh_in, "<&", $bitmap_in[$i] 
    or die "$0: Can't open bitmap_in[$i] = $bitmap_in[$i] ($!)";
  open my $fh_out, ">&", $dvh_out[$i] 
    or die "$0: Can't open dvh_out[$i] = $dvh_out[$i] ($!)";
  my $item = {
    input_fh => $fh_in,
    output_fh => $fh_out,
    bits_expanded => 0,
    expanded_bits => [],
    bytes_read => 0,
    vol => 0,
    bins => [],
    is_open => 1,
  };
  push(@DvhStreams, $item);
}
my $pix_read = 0;
my $pix_processed = 0;
while(1){
  for my $i (@DvhStreams){
    while($i->{is_open} && $#{$i->{expanded_bits}} < 1024){
      my $buff;
      my $in = $i->{input_fh};
      my $ret = read $in, $buff, 1;
      unless($ret == 1){
        $i->{is_open} = 0;
        close $i->{input_fh};
        next;
      }
      $i->{bytes_read} += 1;
      my @in;
      {
        no warnings;
        @in = unpack("c", $buff);
      }
      my $polarity = $in[0] & 0x80;
      my $count = $in[0] & 0x7f;
      for my $j (0 .. $count - 1){
        push(@{$i->{expanded_bits}}, ($polarity ? "1" : 0));
      }
      $i->{bits_expanded} += $count;
    }
  }
  my $pix_buff;
  my $num_read = read(INPUT, $pix_buff, 1024 * $bytesperpix);
  if($num_read <= 0) {
    last;
  }
  $pix_read += ($num_read/$bytesperpix);
  my @pix;
  if($bytesperpix == 2){
    @pix = unpack("v*", $pix_buff);
  } elsif ($bytesperpix == 4){
    @pix = unpack("V*", $pix_buff);
  } else {
    die "$0: Only handle shorts and longs";
  }
  for my $i (@pix){
    $pix_processed += 1;
    stream:
    for my $j (@DvhStreams){
      my $bit = shift @{$j->{expanded_bits}};
      unless(defined $bit) {
        die "$0: out of bits before out of pixels";
      }
      unless($bit) { next stream }
      unless(defined $j->{smallest_dose}) { $j->{smallest_dose} = $i }
      unless(defined $j->{largest_dose}) { $j->{largest_dose} = $i }
      if($i > $j->{largest_dose}) { $j->{largest_dose} = $i }
      if($i < $j->{smallest_dose}) { $j->{smallest_dose} = $i }
      my $index =  int($i/$binwidth);
      $j->{bins}->[$index] += 1;
      $j->{vol} += 1;
    }
  }
}
for my $i (0 .. $#DvhStreams){
  my $s = $DvhStreams[$i];
  if($s->{is_open}){
    if($#{$s->{expanded_bits}} >= 0){
      my $count = @{$s->{expanded_bits}};
      print "$0: $count unprocessed bits on stream[$i]\n";
    }
  }
}
#process and output bins here
for my $s (0 .. $#DvhStreams){
  my $str = $DvhStreams[$s];
  my $out = $str->{output_fh};
  my $so_far = 0;
  for my $i (0 .. $#{$str->{bins}}){
    my $from_end = $#{$str->{bins}} - $i;
    $str->{bins}->[$from_end] += $so_far;
    $so_far = $str->{bins}->[$from_end];
  }
  print $out "Number of bins: $#{$str->{bins}}\n";
  print $out "Number of pixmap bits read: $str->{bits_expanded}\n";
  print $out "Total Volume: $str->{vol}\n";
  print $out "Smallest Dose: $str->{smallest_dose}, " .
    "largest: $str->{largest_dose}\n";
  my $volume = $str->{bins}->[0];
  for my $i (0 .. $#{$str->{bins}}){
    unless(defined $str->{bins}->[$i]) {$str->{bins}->[$i] = 0}
    my $percent = sprintf("%02d", 100 * $str->{bins}->[$i]/$volume);
    print $out "$i $str->{bins}->[$i] $percent\n";
  }
}
if(defined $status){
  open(STATUS, ">&", $status) or die "$0: Can't open status = $status";
  print STATUS "OK\n";
  close STATUS;
}
