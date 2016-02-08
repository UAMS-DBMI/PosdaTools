#!/usr/bin/perl -w
#
use strict;
my %Files;
for my $line (<STDIN>){
  chomp $line;
  my($file, $func) = split(/\|/, $line);
  $Files{$file}->{$func} = 1;
}
for my $f (sort keys %Files){
  print "File: $f\n";
  for my $func (sort keys %{$Files{$f}}){
    print "\t$func\n";
  }
}
