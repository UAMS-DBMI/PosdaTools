#!/usr/bin/perl -w

# Take an uncompressed bitmap and turn it into a PBM based on args ...
# This program accepts (presumably) pixel data on STDIN
# It produces a "PBM" format stream on STDOUT
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
syswrite STDOUT, "P4 $cols $rows\n";
my $buff;
my $current_count = 0;
my $constr_byte = 0;

while(my $byte_count = sysread(STDIN, $buff, 1)){
  syswrite(STDOUT, $buff, $byte_count);
}
