#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/Splitter.pl,v $
#$Date: 2011/10/06 16:13:07 $
#$Revision: 1.1 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

#
# What to do is specified on the command line.
# All of the parameters on the command line are of the form:
#  <name>=<value> (no spaces)
# parameter order does not matter.
#
# Here are the parameters:
#  out<n>=<number of output n'th fd> (n zero based)
#  in = <number of input fd>
#  status=<number of status fd> app will write status to this fd when finished
use strict;
use VectorMath;
my(@out, $in, $status);
for my $i (@ARGV){
  unless($i =~ /^([^=]+)=([^=]+)$/) {
    die "$0: can't parse parameter $i";
  }
  my $key = $1;
  my $value = $2;
  if ($key =~ /out(\d+)/) { $out[$1] = $value }
  elsif ($key eq "in") { $in = $value }
  elsif ($key eq "status") { $status = $value }
  else { die "$0: unknown parameter: $key" }
}
unless($#out >= 0){ die "$0: no outputs defined" }
unless($in) { die "$0: no input defined" }
unless($status) { die "$0: no status defined" }
open(INPUT, "<&", $in) or die "$0: can't open in = $in ($!)";
my @output_handles;
for my $i (0 .. $#out){
  unless(defined $out[$i]) { next }
  my $ind = $out[$i];
  open(my $fh, ">&", $ind) or die "$0: Can't open out = $ind ($!)";
  push(@output_handles, $fh);
}
my $buff;
while(my $count = sysread(INPUT, $buff, 1024)){
  for my $i (@output_handles){
    print $i $buff;
  }
}
if(defined $status){
  open(STATUS, ">&", $status) or die "$0: Can't open status = $status";
  print STATUS "OK\n";
  close STATUS;
}
