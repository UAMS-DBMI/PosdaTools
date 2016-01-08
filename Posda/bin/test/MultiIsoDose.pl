#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/MultiIsoDose.pl,v $
#$Date: 2013/06/07 11:56:16 $
#$Revision: 1.2 $
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
my($in, %out, $status, $bytes) = @_;
for my $i (@ARGV){
  unless($i =~ /^([^=]+)=([^=]+)$/) {
    die "$0: can't parse parameter $i";
  }
  my $key = $1;
  my $value = $2;
  if ($key =~ /^out/) {
    unless($value =~ /^(\d+),(\d+)/) { die "$0: bad value for out: $value" }
    my $fd = $1;
    my $level = $2;
    my $fh;
    unless(open $fh, ">&", $fd) { die "$0: can't open out = $fd ($!)" }
    $out{$fd} = {
      level => $level,
      polarity => 0,
      count => 0,
      fh => $fh,
    };
  } elsif ($key eq "in") { $in = $value }
  elsif ($key eq "status") { $status = $value }
  elsif ($key eq "bytes") { $bytes = $value }
  else { die "$0: unknown parameter: $key" }
}
unless(scalar keys %out){ die "$0: no output defined" }
unless($in){ die "$0: no input defined" }
unless($bytes) { die "$0: bytes undefined" }

open(INPUT, "<&", $in) or die "$0: Can't open in = $in ($!)";
#print "opened INPUT on fd $in\n";
my $buff;
my $total_pix_read = 0;
if($bytes == 2){
  byte:
  while(my $c = sysread(INPUT, $buff, 2)){
    $total_pix_read += 1;
    my $pol;
    my($dose) = unpack("v", $buff);
    for my $fd (keys %out){
      my $level = $out{$fd}->{level};
      if($dose <= $level) { $pol = 0 } else { $pol = 1 }
      if($pol == $out{$fd}->{polarity}) {
        $out{$fd}->{count} += 1;
      } else {
        my $o = ($out{$fd}->{polarity} ? 0x80 : 0) | $out{$fd}->{count};
        {
          no warnings;
          my $fh = $out{$fd}->{fh};
          print $fh  pack("c", $o);
        }
        $out{$fd}->{polarity} = $pol;
        $out{$fd}->{count} = 1;
      }
      if($out{$fd}->{count} > 127){
        my $o = ($out{$fd}->{polarity} ? 0x80 : 0) | 127;
        {
          no warnings;
          my $fh = $out{$fd}->{fh};
          print $fh pack("c", $o);
        }
        $out{$fd}->{count} -= 127;
      }
    }
  }
} elsif ($bytes == 4){
  while(my $c = read(INPUT, $buff, 4)){
$total_pix_read += 1;
    my $pol;
    my $dose = unpack("V", $buff);
    for my $fd (keys %out){
      my $level = $out{$fd}->{level};
      if($dose <= $level) { $pol = 0 } else { $pol = 1 }
      if($pol == $out{$fd}->{polarity}) {
        $out{$fd}->{count} += 1;
      } else {
        my $o = ($out{$fd}->{polarity} ? 0x80 : 0) | $out{$fd}->{count};
        {
          no warnings;
          my $fh = $out{$fd}->{fh};
          print $fh  pack("c", $o);
        }
        $out{$fd}->{polarity} = $pol;
        $out{$fd}->{count} = 1;
      }
      if($out{$fd}->{count} > 127){
        my $o = ($out{$fd}->{polarity} ? 0x80 : 0) | 127;
        {
          no warnings;
          my $fh = $out{$fd}->{fh};
          print $fh pack("c", $o);
        }
        $out{$fd}->{count} -= 127;
      }
    }
  }
} else {
  die "Only support 2 or 4 byte dose";
}
#print STDERR "MultiIsoDose.pl: total pixels read: $total_pix_read\n";
for my $fd (keys %out){
  if($out{$fd}->{count} > 0){
    my $o = ($out{$fd}->{polarity} ? 0x80 : 0) | $out{$fd}->{count};
    {
      no warnings;
      my $fh = $out{$fd}->{fh};
      print $fh pack("c", $o);
    }
  }
}

if(defined $status){
  open(STATUS, ">&", $status) or die "$0: Can't open status = $status ($!)";
  print STATUS "OK\n";
  close STATUS;
}
