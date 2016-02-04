#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/FindUniqueWords.pl,v $
#$Date: 2016/01/26 19:38:18 $
#$Revision: 1.5 $
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Try;
my $file = $ARGV[0];
sub MakeEleFun{
  my($file, $values) = @_;
  my $sub = sub {
    my($ele, $n_sig) = @_;
    if($n_sig eq "(7fe0,0010)") { return }
    unless($ele->{type} eq "text" || $ele->{type} eq "raw") { return }
    my @values;
    if(ref($ele->{value}) eq ""){
      push(@values, $ele->{value});
    } else {
      for my $v (@{$ele->{value}}) {
        push(@values, $v);
      }
    }
    value:
    for my $v (@values){
      unless(defined $v) { next value }
      if($v eq "") { next value }
      unless($v =~ /^[[:print:][:cntrl:]]+$/){ next value }
#      if($v =~ /^[0-9\.\+\-Ee ]+$/) { next value }
      if($v =~ /\n/){
        my @values = split(/[\n,']/, $v);
        value1:
        for my $i (@values){
          $i =~ tr/\000-\037/ /;
          $i =~ s/\s*$//g;
          $i =~ s/^\s*//g;
          $i =~ s/\s*$/ /; 
          $i =~ s/\|/ /g;
          if ($i eq "") { next value1 }
          if($i =~ /[^[:print:]]/){
            my @foo = split(/[^[:print:]]+/, $i);
            foo:
            for my $j (@foo){
              $i =~ tr/\000-\037/ /;
              $i =~ s/\s*$//g;
              $i =~ s/^\s*//g;
              $i =~ s/\s*$/ /; 
              if($j eq "") { next foo }
              $values->{$j}->{$n_sig}->{$ele->{VR}} = 1;
            }
          } else {
            $values->{$i}->{$n_sig}->{$ele->{VR}} = 1;
          }
        }
      } elsif(length($v) > 64) {
        my @values = split(/\s*/, $v);
        value2:
        for my $i (@values){
          $i =~ tr/\000-\037/ /;
          $i =~ s/\|/ /g;
          $i =~ s/\s*$//g;
          $i =~ s/^\s*//g;
          if($i eq "" ) { next value2 }
          $values->{$i}->{$n_sig}->{$ele->{VR}} = 1;
        }
      } else {
        $v =~ tr/\000-\037/ /;
        $v =~ s/\|/ /g;
        $v =~ s/\s*$//g;
        $v =~ s/^\s*//g;
        if($v eq "") { next value }
        $values->{$v}->{$n_sig}->{$ele->{VR}} = 1;
      }
    }
  };
  return $sub;
}
my %Values;
my $try = Posda::Try->new($file);
unless(exists $try->{dataset}) { die "$file isn't a DICOM file" }
$try->{dataset}->MapPvt(MakeEleFun($file, \%Values));
for my $v (sort {$a cmp $b} keys %Values){
  for my $sig (sort {$a cmp $b} keys %{$Values{$v}}){
    my $type;
    for my $vr (keys %{$Values{$v}->{$sig}}){
      my $enc_v = $v;
      $enc_v =~ s/(\n)/"%" . unpack("H2", $1)/eg;
      print "$enc_v|$sig|$vr\n";
    }
  }
}
