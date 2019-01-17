#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::DB 'Query';
use Posda::DataDict;
use Posda::GetElementNameChain;
my $dd = Posda::DataDict->new;
use Debug;
my $dbg = sub { print STDERR @_ };
my $help = <<EOF;
Usage: 
  UpdatePrivateElementNames.pl
or
  UpdatePrivateElementNames.pl -h

Selects All Private Elements in posda_phi_simple and
updates element_name based on information in posda_private_tag 
database
Also updates "is_private" to be true

EOF

if($#ARGV >= 0 && ($ARGV[0] eq "-h")){
  print $help;
  exit;
}

my $upd = Query("UpdPosdaPhiSimpleEleName");
my %ElementsInPosdaPhiSimple;
Query("GetPosdaPhiSimpleElementSigInfo")->RunQuery(sub {
  my($row) = @_;
  $ElementsInPosdaPhiSimple{$row->[0]}->{$row->[1]} = {
    is_private => $row->[2],
    private_disposition => $row->[3],
    name_chain => $row->[4],
  };
  my $info = $ElementsInPosdaPhiSimple{$row->[0]}->{$row->[1]};
  unless(defined($info->{name_chain})){ $info->{name_chain} = "<undef>" }
},
sub {
});
for my $sig(keys %ElementsInPosdaPhiSimple){
  for my $vr (keys %{$ElementsInPosdaPhiSimple{$sig}}){
    if($sig =~ /\"/){
      ProcessPrivateTag($sig, $vr, $ElementsInPosdaPhiSimple{$sig}->{$vr});
    } else {
      ProcessPublicTag($sig, $vr, $ElementsInPosdaPhiSimple{$sig}->{$vr});
    }
  }
}
unless(defined $upd) { die "Can't find UpdPosdaPhiSimpleEleName" }
sub ProcessPrivateTag{
  my($sig, $vr, $info) = @_;
  my $is_private = 1;
  my ($name_chain, $canon_vr) = Posda::GetElementNameChain::GetVrNameChain($sig);
  if(
    $name_chain ne $info->{name_chain} ||
    !defined($info->{is_private}) ||
    $is_private != $info->{is_private}
  ){
    unless(defined($info->{is_private})){ $info->{is_private} = "<undef>" }
    print "update($sig, $vr): $info->{name_chain} => $name_chain, $info->{is_private} => $is_private\n";
unless(defined $upd) { die "Can't find UpdPosdaPhiSimpleEleName" }
    $upd->RunQuery(sub{}, sub{}, $name_chain, $is_private,
      $sig, $vr);
  }
  if($canon_vr =~ /.*:(..)$/){
    $canon_vr = $1;
  }
  if($vr ne $canon_vr){
#    print "$sig has non-canon vr: $vr vs $canon_vr\n";
  }
}
sub ProcessPublicTag{
  my($sig, $vr, $info) = @_;
  my $is_private = 0;
  my($name_chain, $canon_vr) = Posda::GetElementNameChain::GetVrNameChain($sig);
  if(
    $name_chain ne $info->{name_chain} ||
    !defined($info->{is_private}) ||
    $is_private != $info->{is_private}
  ){
    unless(defined($info->{is_private})){ $info->{is_private} = "<undef>" }
    print "update($sig, $vr): $info->{name_chain} => $name_chain, $info->{is_private} => $is_private\n";
    $upd->RunQuery(sub{}, sub{}, $name_chain, $is_private,
      $sig, $vr);
  }
  if($canon_vr =~ /.*:(..)$/){
    $canon_vr = $1;
  }
  if($vr ne $canon_vr){
#    print "$sig has non-canon vr: $vr vs $canon_vr\n";
  }
}
