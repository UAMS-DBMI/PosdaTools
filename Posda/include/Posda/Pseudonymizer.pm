#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/Pseudonymizer.pm,v $
#$Date: 2012/02/07 13:41:44 $
#$Revision: 1.5 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
package Posda::Pseudonymizer;
use strict;
use Posda::UID;
use Posda::PseudoNym;

sub GenLast{
  my $name = Posda::PseudoNym::Get("male");
  my($last, $first) = split(/\^/, $name);
  return $last;
}
sub GenFirstInitialDotLast{
  my $name = Posda::PseudoNym::Get("male");
  my($last, $first) = split(/\^/, $name);
  $first =~ /^(.)/;
  return "$1.$last";
}
sub GetMap{
  my($map, $sig) = @_;
  return $map->{$sig};
}
sub GenInitial{
  my $name = Posda::PseudoNym::Get("male");
  my($last, $first) = split(/\^/, $name);
  $first =~ /^(.)/;
  my $fi = $1;
  $last =~ /^(.)/;
  my $li = $1;
  return "$fi$li";
}
sub GenName{
  my($type) = @_;
  unless(defined($type)){
    my $foo = rand(1);
    if($foo > 0.5){
      $type = "male";
    } else {
      $type = "female";
    }
  }
  return Posda::PseudoNym::Get($type);
}
sub GenFILast{
  my $name = GenName();
  my($last, $first) = split(/\^/, $name);
  $first =~ /^(.)/;
  my $fi = $1;
  $last =~ /^(.)(.*)$/;
  my $li = $1;
  my $ast = lc($2);
  return "$fi$li$ast";
}
sub RandYear{
  my($start, $range) = @_;
  my $inc = int(rand($range));
  return $start + $inc;
}
sub RandMonDay{
   my $mon = sprintf("%02d", int(rand(12)) + 1);
   my $day = sprintf("%02d", int(rand(27)) + 1);
   return "$mon$day";
}
sub RandDate{
   my ($start, $range) = @_;
   my $year = RandYear($start, $range);
   my $moday = RandMonDay();
   return "$year$moday";
}
sub DatePlus{
   my($date, $days) = @_;
   unless($date =~ /(....)(..)(..)/) { die "bad date:\"$date\"" }
   my $d = $3;
   my $m = $2;
   my $y = $1;
   $d += $days;
   while($d > 27){
     $d -= 27;
     $m += 1;
     while($m > 12){
       $m -= 12;
       $y += 1;
     }
   }
   return sprintf("%04d%02d%02d", $y, $m, $d);
}
sub RandMap{
  my($pat) = @_;
  my @chars = split("", $pat);
  my $ret = "";
  for my $c (@chars){
    if($c eq "a"){
      $ret .= RandomAlpha();
    } elsif ($c eq "n"){
      $ret .= RandomDigit();
    } else {
      die "bad pattern in RandMap";
    }
  }
  return $ret;
}
sub RandomAlpha{
  my @alpha = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", 
    "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z");
  my $index = int(rand($#alpha));
  return $alpha[$index];
}
sub RandomDigit{
  my $index = int(rand(9.99999));
  return $index;
}

sub FileReader{
  my($file_name, $to_file_name) = @_;
  my $uid;
  my $map = {};
  open FILE, "<", "$file_name" or die "Can't open $file_name (map file in)";
  open TO, ">", "$to_file_name" or die "Can't open $to_file_name (map file out)";
  while(my $line = <FILE>){
    chomp $line;
    my @values = split(/\|/, $line);
    if ($values[0] eq "set_eval"){
      my $value;
      eval $values[3];
      if($@){ die $@ }
      print TO "set|$values[1]|$values[2]|$value\n";
    } elsif ($values[0] eq "map_eval"){
      my $value = $values[3];
      eval $values[4];
      if($@){ die $@ }
      print TO "map|$values[1]|$values[2]| \"$values[3]\" => \"$value\"\n";
    } elsif ($values[0] eq "date_map_eval"){
      my $value;
      eval $values[2];
      if($@){ die $@ }
      print TO "date_map| \"$values[1]\" => \"$value\"\n";
    } else {
      die "bad line in map file: '$line'";
    }
  }
}
1;
