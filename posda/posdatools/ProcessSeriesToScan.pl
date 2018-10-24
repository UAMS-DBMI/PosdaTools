#!/usr/bin/perl -w
use strict;
while(my $line = <STDIN>){
  chomp $line;
  my @fields = split(/\t/, $line);
  print "$fields[0], $fields[2]\n";
}
