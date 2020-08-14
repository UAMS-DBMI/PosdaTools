#!/usr/bin/perl -w
use strict;
use Posda::UUID;
my $num = $ARGV[0];
for my $i (0 .. $num){
  my $uuid = Posda::UUID::GetUUID();
  my $len = length($uuid);
  print "$uuid\n";
}
