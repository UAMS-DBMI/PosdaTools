#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/MakeExportHash.pl,v $
#$Date: 2013/06/21 20:05:28 $
#$Revision: 1.1 $
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
