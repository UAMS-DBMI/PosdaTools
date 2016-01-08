#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/SumDose.pl,v $
#$Date: 2012/01/12 18:18:12 $
#$Revision: 1.1 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

# Streamed Compressed Bitmap operations
#
# This program accepts pixel streams on multiple
# fds, scales and sums them, and
# outputs the results to another stream.
# The fd's have been opened by the parent process...
#
# What to do is specified on the command line.
# All of the parameters on the command line are of the form:
#  <name>=<value> (no spaces)
#
#
# Here are the possible parameters which make up the rp specification:
#  in=<number of an input fd>,<bits>,<scaling>,<units>,<weighting>
#  out=<number of output fd>,<bits>,<scaling>,<units>
#
#
#
use strict;
my $out;
my $out_scale;
my $out_units;
my $out_bits;
my @input_streams;
my $status;
for my $i (@ARGV){
print "$0: $i\n";
  unless($i =~ /^([^=]+)=([^=]+)$/) {
    die "$0: can't parse parameter $i";
  }
  my $key = $1;
  my $value = $2;
  if($key eq "in"){
    my($fd, $bits, $scale, $units, $weight) = split(/,/, $value);
    my $in_fd = open(my $foo, "<&", $fd);
    push(@input_streams, {
      fd => $foo,
      bits => $bits,
      file_no => $fd,
      scale => $scale,
      units => $units,
      weighting => $weight,
      is_open => 1,
    });
  } elsif($key eq "out"){
    my($fd, $bits, $scale, $units) = split(/,/, $value);
    $out = $fd;
    $out_bits = $bits;
    $out_scale = $scale;
    $out_units = $units;
  } elsif ($key eq "status") {
    $status = $value;
  } else {
    die "Unknown parameter: $key\n";
  }
}
unless(defined $out) { die "$0: out is undefined" }
open(OUTPUT, ">&", $out) or die "$0: can't open out = $out ($!)";
my $pix_read = 0;
my $pix_value = 0;
my $num_open = 0;
my $in_stream = 1;
my $pix_written = 0;
outer:
while($in_stream){
  stream:
  for my $i (@input_streams){
    unless($i->{is_open}) { next stream }
    my $buff;
    my $value;
    if($i->{bits} == 16){
      my $count = read($i->{fd}, $buff, 2);
      unless($count == 2){
        $i->{is_open} = 0;
        next stream;
      }
      $value = unpack("v", $buff);
    } elsif($i->{bits} == 32){
      my $count = read($i->{fd}, $buff, 4);
      unless($count == 4){
        $i->{is_open} = 0;
        next stream;
      }
      $value = unpack("V", $buff);
    } else {
      die "unknown bits: $i->{bits}";
    }
    $pix_read += 1;
    $num_open += 1;
    $value *= $i->{scale};
    if($i->{units} eq "GRAY"){ $value *= 100 }
    $pix_value = $pix_value + ($value * $i->{weighting});
  }
  if($num_open == 0){ $in_stream = 0; next outer }
  unless(
    $num_open == scalar(@input_streams) &&
    $pix_read == $num_open
  ){
    die "$0: unbalanced inputs";
  }
  $pix_value /= $out_scale;
  if($out_units eq "CGRAY") { $pix_value /= 100 }
  my $v;
  if($out_bits == 16){
    $v = pack("v", $pix_value);
  } elsif($out_bits == 32){
    $v = pack("V", $pix_value);
  } else {
    die "unknown bits: $out_bits";
  }
  print OUTPUT $v;
  $pix_written += 1;
  $pix_read = 0;
  $pix_value = 0;
  $num_open = 0;
}
#print "$0: $pix_written pixels written\n";
if(defined $status){
  open(STATUS, ">&", $status) or die "$0: Can't open status = $status";
  print STATUS "OK\n";
  close STATUS;
}
