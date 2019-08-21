#!/usr/bin/perl -w
use strict;
use Posda::UUID;
use Posda::PrivateDispositions;
my $num = $ARGV[0];
my $root = $ARGV[1];
my $disp = Posda::PrivateDispositions->new($root);
for my $i (0 .. $num){
  my $uid = $disp->NewRandomUid;
  print "$uid\n";
}
