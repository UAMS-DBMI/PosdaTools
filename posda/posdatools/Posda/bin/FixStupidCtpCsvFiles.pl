#!/usr/bin/perl -w
use strict;
while(my $l = <STDIN>){
  $l =~ s/=\(//g;
  $l =~ s/\),/,/g;
  print $l;
}
