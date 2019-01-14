#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package Posda::GetElementNameChain;
use Posda::DB 'Query';
#######################################################
# All of this is juat to implement GetVrNameChain
my $ptdh = Query("GetPrivateTagFeaturesBySignature");
sub get_private_info{ my($tag) = @_;
  my($name,$vr);
  $ptdh->RunQuery(
    sub {
      my($row) = @_;
      $name = $row->[0];
      $vr = $row->[1];
    }, sub {
    },
    $tag
  );
  unless(defined $name) { $name = "Unknown" }
  unless(defined $vr) { $vr = "UN" }
  return ($name, $vr);
}
my $tdh = Query("GetPublicTagNameAndVrBySignature");
sub get_public_info{
  my($tag) = @_;
  my($name, $vr);
  $tdh->RunQuery(
     sub{
       my($row) = @_;
       $name = $row->[0];
       $vr = $row->[1];
     },
     sub {
     },
     $tag
  );
  unless(defined $name) { 
    if($tag =~ /^\(([56].)..,([^\"]...)/){
      my $new_tag = "($1xx,$2)";
      $tdh->RunQuery(
         sub{
           my($row) = @_;
           $name = $row->[0];
           $vr = $row->[1];
         },
         sub {
         },
         $new_tag
      );
    }
    unless(defined $name){
      $name = "<undef>";
    }
  }
  unless(defined $vr) { $vr = "<undef>" }
  return ($name, $vr);
}
sub GetVrNameChain{
  my($sig) = @_;
  my @sig_comp = split /\[<\d+>\]/, $sig;
  my $final_vr = "";
  my $final_name = "";
  for my $i (0 .. $#sig_comp){
    my($dd_name, $dd_vr);
    my $si = $sig_comp[$i];
    my($name, $vr);
    if($si =~ /,\"/){
      ($name, $vr) = get_private_info($si);
    } else {
      ($name, $vr) = get_public_info($si);
    }
    $final_name .= $name;
    $final_vr .= $vr;
    unless($i == $#sig_comp){
      $final_name .= ":";
      $final_vr .= ":";
    }
  }
  return $final_name, $final_vr;
}
# GetVrNameChain Finally implemented
#######################################################
1;
