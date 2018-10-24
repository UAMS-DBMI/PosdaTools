#!/usr/bin/perl -w
#
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
package Posda::UUID;
use strict;
use Data::UUID;
sub GetUUID{
  my $guid = GetGuid();
  return "2.25.$guid";
}
sub GetGuid{
  my $ug = new Data::UUID;
  my $uuid = $ug->create();
  my $guid = FromDigest($uuid);
  return $guid;
}
sub FromDigest{
  my($uuid) = @_;
  my $two_to_128 = "340282366920938463463374607431768211456";
  my @t128 = split("", $two_to_128);
  my @sum;
  for my $j (0 .. $#t128){ $sum[$j] = 0 }
  my @bytes = unpack("C16", $uuid);
  for my $b (0 .. 15){
    my $bit = 1;
    for my $t (0 .. 7) {
      if($bytes[$#bytes - $b] & $bit){
        add(\@t128, \@sum);
      }
      halve(\@sum);
      $bit <<= 1;
    }
  }
  my $guid = join("", @sum);
  $guid =~ s/^0+//;
  return "$guid";
}
sub DecimalFromHexDig{
  my($hex_dig) = @_;
  my $str_to_dig = {
    0 => 0, 1 => 1, 2 => 2, 3 => 3,
    4 => 4, 5 => 5, 6 => 6, 7 => 7,
    8 => 8, 9 => 9, a => 10, b => 11,
    c => 12, d => 13, e => 14, f => 15,
  };
  my @digits = split(//, $hex_dig);
  my @result;
  for my $i (0 .. $#digits){
    my $dig = $str_to_dig->{$digits[$i]};
    for my $j (0 .. 3){ double(\@result) }
    add_dig(\@result, $dig);
  }
  my $res = join("", @result);
  $res =~ s/^0+//;
  if($res eq "") { $res = 0 }
  return reverse $res;
}
sub add {
  my($from, $into) = @_;
  my $carry_in = 0;
  for my $i (0 .. $#{$from}){
    my $indx = $#{$from} - $i;
    $into->[$indx] = $into->[$indx] + $from->[$indx] + $carry_in;
    $carry_in = 0;
    if($into->[$indx] > 9){
      $into->[$indx] -= 10;
      $carry_in = 1;
      if($indx == 0) { die "Overflow\n" }
    }
  }
}
sub halve {
  my($list) = @_;
  my $carry_in = 0;
  for my $i (0 .. $#{$list}){
    $list->[$i] = $list->[$i] + (10 * $carry_in);
    $carry_in = $list->[$i] & 1;
    $list->[$i] = int ( ($list->[$i]) / 2 );
  }
  if($carry_in) { die "shifting out at bottom\n" }
}
sub double{
  my($list) = @_;
  my $carry = 0;
  for my $i (0 .. $#{$list}){
    my $result = $list->[$i] + $list->[$i] + $carry;
    $carry = 0;
    while($result >= 10){
      $result -= 10;
      $carry += 1;
    }
    $list->[$i] = $result;
  }
  if($carry) { push @$list, $carry };
}
sub add_dig{
  my($list, $digit) = @_;
  unless(@$list) { push @$list, $digit; return }
  $list->[0] += $digit;
  my $carry = 0;
  while($list->[0] >= 10){
    $list->[0] -= 10;
    $carry += 1;
  }
  if($#{$list} == 0) { push @$list, $carry; return }
  my $cur_dig = 1;
  while($carry && $cur_dig <= $#{$list}){
    $list->[$cur_dig] += $carry;
    $carry = 0;
    while($list->[$cur_dig] >= 10){
      $list->[$cur_dig] -= 10;
      $carry += 1;
    }
    $cur_dig += 1;
  }
  if($carry) { push @$list, $carry }
}
sub PrintPowersOfTwo{
  my($max) = @_;
  my @result = (1);
  for my $i (0 .. $max) {
    my $res = join("", reverse @result);
    $res =~ s/^0+//;
    print "$i\t$res\n";
    double(\@result);
  }
}
1
