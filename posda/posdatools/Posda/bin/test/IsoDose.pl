#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

# Streamed Dose Interpolation
# This program reads a DICOM RT Dose file and interpolates the
# data as specified by its parameters.  The interpolated dose is
# written to one or more fd's (opened by parent, number(s) passed as
# parameters).
#
# What to do is specified on the command line.
# All of the parameters on the command line are of the form:
#  <name>=<value> (no spaces)
# parameter order does not matter.
#
# Here are the parameters:
#  out<n>=<number of output n'th fd> (n zero based)
#  status=<number of status fd> app will write status to this fd when finished
#  level=<dose level to contour>
#  bytes=<bytes per dose sample>
#
use strict;
#use IO;
use HexDump;
my($in, $out, $status, $level, $bytes) = @_;
for my $i (@ARGV){
  unless($i =~ /^([^=]+)=([^=]+)$/) {
    die "$0: can't parse parameter $i";
  }
  my $key = $1;
  my $value = $2;
  if ($key =~ /out/) { $out = $value }
  elsif ($key eq "in") { $in = $value }
  elsif ($key eq "status") { $status = $value }
  elsif ($key eq "level") { $level = $value }
  elsif ($key eq "bytes") { $bytes = $value }
  else { die "$0: unknown parameter: $key" }
}
unless($out){ die "$0: no input defined" }
unless($in){ die "$0: no output defined" }
unless($level) { die "$0: level undefined" }
unless($bytes) { die "$0: bytes undefined" }

open(INPUT, "<&", $in) or die "$0: Can't open in = $in ($!)";
open(OUTPUT, ">&", $out) or die "$0: Can't open out = $out ($!)";

my $buff;
my $polarity = 0;
my $count = 0;
if($bytes == 2){
  while(my $c = read(INPUT, $buff, 2)){
    my $pol;
    my($dose) = unpack("v", $buff);
    if($dose <= $level) { $pol = 0 } else { $pol = 1 }
    if($pol == $polarity) { $count += 1 } else {
      $out = ($polarity ? 0x80 : 0) | $count;
      {
        no warnings;
        print OUTPUT pack("c", $out);
      }
      $polarity = $pol;
      $count = 1;
    }
    if($count > 127){
      $out = ($polarity ? 0x80 : 0) | 127;
      {
        no warnings;
        print OUTPUT pack("c", $out);
      }
      $count -= 127;
    }
  }
} elsif ($bytes == 4){
  while(my $c = read(INPUT, $buff, 4)){
    my $pol;
    my $dose = unpack("V", $buff);
    if($dose <= $level) { $pol = 0 } else { $pol = 1 }
    if($pol == $polarity) { $count += 1 } else {
      my $out = ($polarity ? 0x80 : 0) | $count;
      {
        no warnings;
        print OUTPUT pack("c", $out);
      }
      $polarity = $pol;
      $count = 1;
    }
    if($count > 127){
      my $out = ($polarity ? 0x80 : 0) | 127;
      {
        no warnings;
        print OUTPUT pack("c", $out);
      }
      $count -= 127;
    }
  }
} else {
  die "Only support 2 or 4 byte dose";
}
if($count > 0){
  my $out = ($polarity ? 0x80 : 0) | $count;
  {
    no warnings;
    print OUTPUT pack("c", $out);
  }
}

if(defined $status){
  open(STATUS, ">&", $status) or die "$0: Can't open status = $status ($!)";
  print STATUS "OK\n";
  close STATUS;
}
