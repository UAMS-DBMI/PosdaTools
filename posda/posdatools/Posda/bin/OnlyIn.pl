#!/usr/bin/perl -w
use strict;
my $usage = "OnlyIn.pl <left_name> <right_name>";
unless($#ARGV == 1 ){ die $usage }
my %In;
my $left = $ARGV[0];
my $right = $ARGV[1];
while (my $line = <STDIN>){
  chomp $line;
  my($on_left, $on_right) = split /,/, $line;
  $on_left =~ s/^\s*//;
  $on_right =~ s/^\s*//;
  $on_left =~ s/\s*$//;
  $on_right =~ s/^\s*$//;
  if(defined($on_left) && $on_left ne ""){
    $In{$left}->{$on_left} = 1;
  }
  if(defined($on_right) && $on_right ne ""){
    $In{$right}->{$on_right} = 1;
  }
}
my @only_on_left;
my @only_on_right;
for my $k (keys %{$In{$left}}){
  unless(exists $In{$right}->{$k}){ push @only_on_left, $k }
}
for my $k (keys %{$In{$right}}){
  unless(exists $In{$left}->{$k}){ push @only_on_right, $k }
}
print("\"OnlyIn$left\",\"OnlyIn$right\"\n");
my $max = $#only_on_left;
if($#only_on_right > $max) { $max = $#only_on_right }
for my $i (0 .. $max){
  if(defined $only_on_left[$i]){
    print "\"$only_on_left[$i]\"";
  } else {
    print '""';
  }
  print ",";
  if(defined $only_on_right[$i]){
    print "\"$only_on_right[$i]\"\n";
  } else {
    print '""' . "\n";
  }
}
