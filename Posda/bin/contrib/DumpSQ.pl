#!/usr/bin/perl -w

use Cwd;
use strict;
use Posda::Dataset;

Posda::Dataset::InitDD();

unless($#ARGV == 1) { die "usage: $0 <file> <seq_ele>" }

my $max1 = 128;
my $max2 = 1024;
my $file = $ARGV[0]; unless($file=~/^\//){$file=getcwd."/$file"}
my $seq_ele = $ARGV[1];
unless(-r $file && -f $file){ die "Can't read $file" }
my ($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($file);
unless($ds) { 
  die "$file is not a DICOM file";
}
if($seq_ele =~ /(.*)\[(\d+)\]$/){
  my $root_seq = $1;
  my $index = $2;
  my $ds1 = $ds->Get($seq_ele);
  if($ds1 && ref($ds1) eq "Posda::Dataset"){
    print "####################\n";
    print "Dump of $seq_ele:\n";
    $ds1->DumpStyle0(\*STDOUT, $max1, $max2);
    print "####################\n";
    exit;
  } else {
    print "no item [$index] in $root_seq\n";
    exit;
  }
}
my $ele_desc = $Posda::Dataset::DD->get_ele_by_sig($seq_ele);
my $vr = $ele_desc->{VR};
unless(defined $vr) {$vr = "UN"}
unless($vr eq "SQ"){ print STDERR "$seq_ele does not have VR of SQ ($vr)\n" }
my $arry = $ds->Get($seq_ele);
if($arry && ref($arry) eq "ARRAY"){
  my $len = @$arry;
  if($vr eq "SQ"){
    print "Sequence $seq_ele has $len items\n";
  } else {
    print "Presumed sequence $seq_ele has $len items\n";
  }
  my $curr = 1;
  for my $i (0 .. $#{$arry}){
    if(ref($arry->[$i]) eq "Posda::Dataset"){
      print "####################\n";
      print "Dump of ${seq_ele}[$i]:\n";
      $arry->[$i]->DumpStyle0(\*STDOUT, $max1, $max2);
      print "####################\n";
    } else {
      print "####################\n";
      if(defined $arry->[$i]){
        print "ERROR: Item $i is not a dataset: $arry->[$i]\n";
      } else {
        print "Item ${seq_ele}[$i] is undefined, but present\n";
      }
      print "####################\n";
    }
  }
} else {
  print "no sequence $seq_ele\n";
}
