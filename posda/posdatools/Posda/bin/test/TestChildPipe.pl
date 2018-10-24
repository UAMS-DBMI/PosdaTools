#!/usr/bin/perl -w
use strict;
open CHILD, "|TestChildReceiver.pl";
for my $i (0 .. 10){
  print CHILD "This is line $i\n";
}
close CHILD;
