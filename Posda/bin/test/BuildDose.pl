#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/BuildDose.pl,v $
#$Date: 2013/03/04 12:55:40 $
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
#  in1=<number of input fd>      on which the DICOM elements are read
#  in2=<number of input fd>      on which the Resampled Dose is read
#  file=<file name>              to which the DICOM file is written
#  bytes=<bytes in dose>
#  status=<number of output fd>  to which the status is written
#
use strict;
use Posda::Dataset;
Posda::Dataset::InitDD;
my($in1, $in2, $file, $status, $bytes);
#my $debug;
for my $i (@ARGV){
  unless($i =~ /^([^=]+)=([^=]+)$/) {
    die "$0: can't parse parameter $i";
  }
  my $key = $1;
  my $value = $2;
  if($key eq "in1") { $in1 = $value }
  elsif ($key eq "in2") { $in2 = $value }
  elsif ($key eq "file") { $file = $value }
  elsif ($key eq "status") { $status = $value }
  elsif ($key eq "bytes") { $bytes = $value }
#  elsif ($key eq "debug") { $debug = $value }
  else { die "$0: unknown parameter: $key" }
}
unless(defined($in1)){ die "$0: in1 undefined" }
unless(defined($in2)){ die "$0: in2 undefined" }
unless(defined($status)){ die "$0: status undefined" }
unless(defined($bytes)){ die "$0: bytes undefined" }
open(INPUT, "<&", $in1) or die "$0: Can't open in1 = $in1 ($!)";
open(INPUT1, "<&", $in2) or die "$0: Can't open in2 = $in2 ($!)";
my $ds = Posda::Dataset->new_blank;
while(my $line = <INPUT>){
  if($line =~ /^([^:]+):(.*)$/){
    chomp $line;
    my $tag = $1;
    my $t_val = $2;
    my $value;
    if($t_val ne "<undef>") { $value = $t_val }
    my @list = split(/\\/, $value);
    if($#list > 0) {
      $ds->Insert($tag, \@list);
    } else {
      $ds->Insert($tag, $value);
    }
  } else {
    print STDERR "$0: unrecognized line:\n\t$line\n";
  }
}
my $pix;
my $count = read(INPUT1, $pix, $bytes);
unless($count == $bytes) { die "$0: read $count vs $bytes pix" }
$ds->Insert("(7fe0,0010)", $pix);
$ds->WritePart10($file, "1.2.840.10008.1.2", "POSDA", undef, undef);
if(defined $status){
  open(STATUS, ">&", $status) or die "$0: Can't open status = $status";
  print STATUS "OK\n";
  close STATUS;
}
