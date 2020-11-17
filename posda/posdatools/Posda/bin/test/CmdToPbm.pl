#!/usr/bin/perl -w

# Take a bitmap on STDIN and turn it into a PBM on STDOUT
# This program accepts (presumably) pixel data on STDIN
# It produces a "PBM" format stream STDOUT
# All of the parameters on the command line are of the form:
#  <name>=<value> (no spaces)
# parameter order does not matter.
# Here are the possible parameters:
#  rows=<number of rows>
#  cols=<number of cols>
#
use strict;
my($rows, $cols);
for my $i (@ARGV){
  unless($i =~ /^([^=]+)=([^=]+)$/) {
    die "$0: can't parse parameter $i";
  }
  my $key = $1;
  my $value = $2;
  if ($key eq "rows") { $rows = $value }
  elsif ($key eq "cols") { $cols = $value }
  else { die "$0: unknown parameter: $key" }
}
unless(defined($rows)){ die "$0: rows undefined" }
unless(defined($cols)){ die "$0: cols undefined" }
print "P4 $cols $rows\n";
my $buff;
while(my $count = sysread(STDIN, $buff, 1)){
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
  print $char;
}
