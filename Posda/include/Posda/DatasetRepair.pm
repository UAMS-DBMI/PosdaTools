#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/DatasetRepair.pm,v $
#$Date: 2010/12/21 13:19:14 $
#$Revision: 1.1 $
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

############################################
############################################
#   NOT YET WORKING  -- NEEDS TO BE A FULL RECURSIVE PARSER
#   No comitment to ever get back to this
############################################
############################################
use strict;
package Posda::DatasetRepair;
my $vrs = {
  AE => 0, AS => 0, AT => 0, CS => 0, DA => 0, DS => 0, DT => 0, FD => 0, FL => 0,
  IS => 0, LO => 0, LT => 0, OB => 1, OF => 1, OW => 1, PN => 0, SH => 0, SL => 0,
  SQ => 1, SS => 0, ST => 0, TM => 0, UI => 0, UL => 0, UN => 1, US => 0, UT => 1,
};
sub RepairExplicitDataset{
  my($fhi, $fho, $len_ra) = @_;
  my $len_r = $len_ra;
  while($len_r > 0){
    my($grp, $ele, $vr, $len) = ReadElementHeader($fhi, \$len_r);
    if($len > $len_r) {
      my $pos = $fhi->tell();
      die "len: $len vs $len_r at $pos"
    }
    if(defined($vr) && $vr eq "DS") { 
      ($len, $vr) = CheckBadDS($fhi, $len, \$len_r);
    }
    my $value = "";
    if($grp == 0xfffe || $vr eq "SQ"){ $len = 0xffffffff }
    if($len != 0 && $len != 0xffffffff){
      my $read = $fhi->read($value, $len);
      unless($read == $len) {
        my $pos = $fhi->tell();
        die "read $len, got $read at $pos";
      }
      $len_r -= $read;
    }
    PrintElement($fho, $grp, $ele, $vr, $len, $value);
  }
}
sub ReadElementHeader{
  my($fhi, $lrp) = @_;
  my $buf;
  if($$lrp < 4) {
    my $pos = $fhi->tell();
    die "need 4 have $$lrp at $pos";
  }
my $here = $fhi->tell();
  my $r = $fhi->read($buf, 4);
  unless($r == 4) { die "read 4, got $r" }
  $$lrp -= 4;
  my($grp, $ele) = unpack("vv", $buf);
  my $vr;
  if($grp != 0xfffe){
    if($$lrp < 2) {
      my $pos = $fhi->tell();
      die "need 2 have $$lrp at $pos";
    }
    $r = $fhi->read($vr, 2);
    unless($r == 2) { 
      my $pos = $fhi->tell();
      die "read 2, got $r at $pos";
    }
    $$lrp -= 2;
    unless(exists $vrs->{$vr}) {
      my $pos = $fhi->tell();
      die sprintf("Unknown VR \"$vr\" grp: 0x%04x at $pos", $grp);
    }
  }
  my $length;
  my $len_len = 2;
  if($grp != 0xfffe && $vrs->{$vr}){
    $len_len = 6
  } elsif ($grp == 0xfffe) {
    $len_len = 4
  }
  if($$lrp < $len_len) {
    my $pos = $fhi->tell();
    die "need $len_len have $$lrp at $pos";
  }
  $r = $fhi->read($buf, $len_len);
  unless($r == $len_len) { 
    my $pos = $fhi->tell();
    die "read $len_len, got $r at $pos";
  }
  $$lrp -= $len_len;
  if($len_len == 2) { ($length) = unpack("v", $buf);
  } elsif($len_len == 4){ ($length) = unpack("V", $buf);
  } elsif($len_len == 6){
    my $foo;
    ($foo, $length) = unpack("vV", $buf);
  } else {
    die "No valid length: $len_len\n";
  }
  return($grp, $ele, $vr, $length);
}
sub PrintElement{
  my($fho, $grp, $ele, $vr, $len, $value) = @_;
  my $grpele = pack("vv", $grp, $ele);
  $fho->print($grpele);
  if($grp == 0xfffe){
    my $foo = pack("V", $len);
    $fho->print($foo);
    return;
  }
  $fho->print($vr);
  my $enc_len;
  if($vrs->{$vr}){
    ($enc_len) = pack("vV", 0, $len);
  } else {
    ($enc_len) = pack("v", $len);
  }
  $fho->print($enc_len);
  $fho->print($value);
}
sub CheckBadDS{
  my($fhi, $len, $lrp) = @_;
  my $temp_lr = $$lrp;
  my $file_pos = $fhi->tell();
  while($len < $$lrp){
    $fhi->seek($len, 1);
    my($grp, $ele, $vr, $ele_len);
    eval {
      ($grp, $ele, $vr, $ele_len) = ReadElementHeader($fhi, \$temp_lr)
    };
    if($@){
      $len += 0x10000;
      $fhi->seek($file_pos, 0);
      next;
    }
    $fhi->seek($file_pos, 0);
    return($len, "UN");
  }
  die "DS looks really bad at $file_pos";
} 
1;
