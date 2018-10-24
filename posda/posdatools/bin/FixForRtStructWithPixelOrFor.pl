#!/usr/bin/perl -w 
use strict;
use Posda::Try;
use Storable;
my %Result;
my $usage = "FixForRtStructWithPixelOrFor.pl <file>";
unless($#ARGV == 0) { die "$usage\n" }
unless(-f $ARGV[0]) { die "$ARGV[0] is not a file\n" }
my $try = Posda::Try->new($ARGV[0]);
unless(exists $try->{dataset}){
  die "$ARGV[0] is not a dicom file\n";
}
my $sop_class = $try->{dataset}->Get("(0008,0016)");
my $is_struct = 1;
unless($sop_class eq "1.2.840.10008.5.1.4.1.1.481.3"){
  $is_struct = 0;
}
my $has_pix = 0;
my $pix = $try->{dataset}->Get("(7fe0,0010)");
if(defined $pix) {$has_pix = 1}
my $has_for = 0;
my $for = $try->{dataset}->Get("(0020,0052)");
if($for) {$has_for = 1}
my $has_bits_a = 0;
if(exists $try->{dataset}->{0x28}->{0x100}){ $has_bits_a = 1 }
if($is_struct && ($has_pix || $has_for || $has_bits_a)){
  if($has_pix) { $Result{$ARGV[0]}->{delete}->{"(7fe0,0010)"} = 1 }
  if($has_for) { $Result{$ARGV[0]}->{delete}->{"(0020,0052)"} = 1 }
  if($has_bits_a) { $Result{$ARGV[0]}->{delete}->{"(0028,0100)"} = 1 }
}
Storable::store_fd \%Result, \*STDOUT;
