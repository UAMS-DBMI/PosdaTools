#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use Cwd;
use strict;
use Posda::Dataset;

my $usage = "Usage: $0 <file>";
unless($#ARGV == 0) {die $usage}
Posda::Dataset::InitDD;

my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($ARGV[0]);
$ds->MapPvt(sub {
  my($ele, $sig) = @_;
  my $ele_info = $Posda::Dataset::DD->get_ele_by_sig($sig);
  unless(defined($ele_info)){
    $ele_info = {
      Name => "<Unknown Priv Ele>",
      VR => 'UN',
      VM => 1,
      type => "raw",
    };
  }
  my $vr = $ele->{VR};
  if(
    $vr eq "OW" ||
    $vr eq "OB" ||
    $vr eq "OF" ||
    $vr eq "SQ" ||
    $vr eq "UT" ||
    $vr eq "UN"
  ){
    return;
  }
  if($ele->{type} eq "text"){
    unless(defined $ele->{value}) { return };
    if(ref($ele->{value}) eq "ARRAY"){
      my $len = 0;
      for my $i (0 .. $#{$ele->{value}}){
        $len += length($ele->{value}->[$i]);
        unless($i == $#{$ele->{value}}){
          $len += 1;
        }
      }
      if($len > 0xffff){
        print "$sig: $vr: $len\n";
      }
    } else {
      my $len = length $ele->{value};
      if($len > 0xffff){
        print "$sig: $vr: $len\n";
      }
    }
  }
  
});
