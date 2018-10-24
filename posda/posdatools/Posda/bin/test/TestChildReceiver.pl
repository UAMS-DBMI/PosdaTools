#!/usr/bin/perl -w
use strict;
my $line_count = 0;
while(my $line = <STDIN>){
  sleep 1;
  $line_count += 1;
}
