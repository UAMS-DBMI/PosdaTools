#!/usr/bin/perl -w
#
use strict;
my $usage = "FindRoutingEndPoints.pl <name>";
unless($#ARGV == 0){
  die $usage;
}
my $PosdaRoot = "/home/bbennett/Posda";
my $NewItcToolsRoot = "/home/bbennett/Alpha/NewItcTools";
my $inv_search_1 = "grep \"\\\"$ARGV[0]\\\"\" -r $PosdaRoot";
my $inv_search_2 = "grep \"\\\"$ARGV[0]\\\"\" -r $NewItcToolsRoot";
my $exp_search_1 = "grep \"sub *$ARGV[0] *{\" -r $PosdaRoot";
my $exp_search_2 = "grep \"sub *$ARGV[0] *{\" -r $NewItcToolsRoot";
my @inv_lines;
my @exp_lines;
open FOO, "$inv_search_1|";
while (my $line = <FOO>) { push @inv_lines, $line }
open FOO, "$inv_search_2|";
while (my $line = <FOO>) { push @inv_lines, $line }
open FOO, "$exp_search_1|";
while (my $line = <FOO>) { push @exp_lines, $line }
open FOO, "$exp_search_2|";
while (my $line = <FOO>) { push @exp_lines, $line }
my %Imports;
#print "--------------- Routed Function $ARGV[0] -------------\n";
for my $i (@inv_lines){
  chomp $i;
  unless($i =~ /^([^:]*):(.*)$/) { next }
  my $file = $1; my $remain = $2;
  if($remain =~ /->(\w*)\("$ARGV[0]"\)/) {
    my $func = $1;
    $Imports{$func}->{$file} = 1;
  } elsif($remain =~ /->(\w*)\("$ARGV[0]"\s*,/) {
    my $func = $1;
    $Imports{$func}->{$file} = 1;
  }
}
#for my $i (sort keys %Imports){
#  print "Invoked via $i:\n";
#  for my $j (keys %{$Imports{$i}}){
#    print "\t$j\n";
#  }
#}
my %Defs;
for my $i (@exp_lines){
  if($i =~/^([^:]*):\s*sub\s*$ARGV[0]\s*{/){ $Defs{$1} = 1 }
}
my %FileDefs;
for my $i (keys %Defs){
  print "$i|$ARGV[0]\n";
}
