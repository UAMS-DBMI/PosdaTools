#!/usr/bin/perl -w
use strict;
my $buff;
while (my $len = read(STDIN, $buff, 10000)){
  $buff =~ s/\r/\n/g;
  print STDOUT $buff;
}
