#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/ToPbm.pl,v $
#$Date: 2011/09/02 01:16:59 $
#$Revision: 1.3 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

# Take a bitmap and turn it into a PBM based on args ...
# This program accepts (presumably) pixel data on one fd
# It produces a "PBM" format stream on the outpu fd
# All of the parameters on the command line are of the form:
#  <name>=<value> (no spaces)
# parameter order does not matter.
# Here are the possible parameters:
#  in=<number of input fd>
#  out=<number of output fd>
#  rows=<number of rows>
#  cols=<number of cols>
#
use strict;
my($in, $out, $rows, $cols, $status);
for my $i (@ARGV){
  unless($i =~ /^([^=]+)=([^=]+)$/) {
    die "$0: can't parse parameter $i";
  }
  my $key = $1;
  my $value = $2;
  if($key eq "in") { $in = $value }
  elsif ($key eq "out") { $out = $value }
  elsif ($key eq "status") { $status = $value }
  elsif ($key eq "rows") { $rows = $value }
  elsif ($key eq "cols") { $cols = $value }
  else { die "$0: unknown parameter: $key" }
}
unless(defined($in)){ die "$0: in undefined" }
unless(defined($out)){ die "$0: out undefined" }
unless(defined($rows)){ die "$0: rows undefined" }
unless(defined($cols)){ die "$0: cols undefined" }
open(INPUT, "<&", $in) or die "$0: Can't open in = $in ($!)";
open(OUTPUT, ">&", $out) or die " Can't open out = $out ($!)";
print OUTPUT "P4 $cols $rows\n";
my $buff;
while(my $count = sysread(INPUT, $buff, 1)){
  no warnings;
  my $in = unpack("c", $buff);
  my $out = "\0";
  my $im = 0x01;
  my $outm = 0x80;
  for my $i (0 .. 7){
    if($in & $im){
      $out |= $outm;
    }
    $im *= 2;
    $outm /= 2;
  }
  my $char = pack("c", $out);
  print OUTPUT $char;
}
if(defined $status){
  open(STATUS, ">&", $status) or die "$0: Can't open status = $status";
  print STATUS "OK\n";
  close STATUS;
}
