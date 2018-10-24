#!/usr/bin/perl -w
#
#Copyright 2009, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use strict;
use DBI;

my $db = DBI->connect("dbi:Pg:dbname=new_dicom_dd", "", "");

my $q = $db->prepare("select * from ele where ele_sig like '%x%'");
$q->execute();
while (my $h = $q->fetchrow_hashref()){
  my $ele_sig = $h->{ele_sig};
  my($grp, $ele);
  if($h->{pvt}){
    unless($ele_sig =~ /^\((....),\"[^\"]+\",(..)\)$/){
      die "private foo";
    }
    $grp = $1;
    $ele = $2;
    if($ele =~ /x/) { die "$ele_sig looks fubar" }
    unless($grp =~ /x/) { next }
  } else {
    unless($ele_sig =~ /^\((....),(....)\)$/){
      die "public foo";
    }
    $grp = $1;
    $ele = $2;
  }
  my($pre, $exes, $post);
  if($grp =~ /x/){ 
    if($grp =~ /^([^x]*)(x+)(\d*)$/){
      $pre = $1;
      $exes = $2;
      $post = $3;
    } else { die "I've got a bug grp: $grp" }
    $exes =~ s/x/f/g;
    my $mask = 0xffff ^ hex($exes);
    my $shift = 1;
    my $zed = $exes;
    $zed =~ s/f/0/g;
    $grp = hex("${pre}${zed}");
    if($h->{pvt}){
      $grp += 1;
      $mask += 1;
    }
    my $q = $db->prepare(
      "update ele\n" .
      "  set grp_mask = ?,\n" .
      "      grp_shift = ?\n" .
      "where ele_sig = ?");
    $q->execute($mask, $shift, $ele_sig);
    print "Sig: $ele_sig grp: $grp mask: $mask shift: $shift\n";
    printf "grp: %04x mask: %04x\n", $grp, $mask;
  }
  if($ele =~ /x/){
    if($ele =~ /^(\d*)(x+)(\d*)$/){
      my $pre = $1;
      my $exes = $2;
      my $post = $3;
      my $shift = 0;
      if($post ne ""){
        $exes = "${exes}0";
        $shift = 4;
      }
      $exes =~ s/x/f/g;
      my $mask = 0xffff ^ hex($exes);
      $ele =~ s/x/f/g;
      $ele = hex($ele) & $mask;
      my $q = $db->prepare(
        "update ele\n" .
        "  set ele_mask = ?,\n" .
        "      ele_shift = ?\n" .
        "where ele_sig = ?");
      $q->execute($mask, $shift, $ele_sig);
      print "ele_sig: $ele_sig ele: $ele mask: $mask, shift: $shift\n";
      printf "ele %04x, mask: %04x, shift: %d\n", $ele, $mask, $shift;
    } else { die "I've got a bug" }
  }
}

$db->disconnect();

