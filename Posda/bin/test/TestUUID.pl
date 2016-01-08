#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/TestUUID.pl,v $
#$Date: 2014/12/05 19:18:29 $
#$Revision: 1.2 $
#
#
#Copyright 2014, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
#
use strict;
use Posda::UUID;
use Digest::MD5;
my $str_to_dig = {
    0 => 0, 1 => 1, 2 => 2, 3 => 3,
    4 => 4, 5 => 5, 6 => 6, 7 => 7,
    8 => 8, 9 => 9, a => 10, b => 11,
    c => 12, d => 13, e => 14, f => 15,
  };

my $data = $ARGV[0];
my $ctx = Digest::MD5->new;
my $ctx1 = Digest::MD5->new;
$ctx->add($data);
$ctx1->add($data);
my $hex = $ctx->hexdigest;
my $bin = $ctx1->digest;
my $byFromDigest = Posda::UUID::FromDigest($bin);
my $byHex = Posda::UUID::DecimalFromHexDig($hex);
print "Hex digest:               $hex\n";
print "Decimal from hex:         $byHex\n";
print "Decimal from bin:         $byFromDigest\n";

for my $h ("1", "10", "100", "1000", "10000"){
  my $str = Posda::UUID::DecimalFromHexDig($h);
  print "$h\t$str\n";
}

#for my $i (0 .. 1000){
#  my $uuid = Posda::UUID::GetUUID;
#  print "UUID: $uuid\n";
#}
#Posda::UUID::PrintPowersOfTwo(129);
