#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/DumpEles.pl,v $
#$Date: 2011/06/23 15:31:25 $
#$Revision: 1.7 $

use Cwd;
use strict;
use Posda::Dataset;

Posda::Dataset::InitDD();


unless($#ARGV >0) { die "usage: $0 <file> <ele> ...\n" }
my $max1 = 65535;
my $max2 = 65535;
my $file = $ARGV[0];
unless(
	$file =~ /^\//
) {
	$file = getcwd."/$file";
}
my %ele_map;
for my $i (1 .. $#ARGV){
  my $seq_ele = $ARGV[$i];
  #if($seq_ele =~ /[A-F]/){ $seq_ele =~ tr/A-F/a-f/ }
  $ele_map{$seq_ele} = 1;
}
unless(-r $file && -f $file){ die "Can't read $file" }
my ($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($file);
unless($ds) { 
  die "$file is not a DICOM file";
}
ele_sig:
for my $seq_ele (sort keys %ele_map){
  if($seq_ele =~ /\[(\d+)\]$/){
    my $index = $1;
    my $ds1 = $ds->Get($seq_ele);
    if($ds1 && ref($ds1) eq "Posda::Dataset"){
      print STDERR 
        "$seq_ele is a sequence element: you probably want to use DumpSQ.pl\n";
    }
    next ele_sig;
  }
  my $ele_desc = $Posda::Dataset::DD->get_ele_by_sig($seq_ele);
  unless (defined $ele_desc){
    print STDERR "$seq_ele is not in Data Dictionary\n";
    next;
  }
  my $vr = $ele_desc->{VR};
  unless (defined $vr){
    print STDERR "VR for $seq_ele is unknown\n";
    next;
  }
  if($vr eq "SQ"){ 
    print STDERR
      "$seq_ele is sequence: you probably want to use DumpSQ.pl\n" 
  }
}
my %seen_eles;
$ds->MapPvt(sub {
    my($ele, $sig) = @_;
    my $test_sig;
    if($sig =~ /(\(....,....\))$/){ 
      $test_sig = "...$1" 
    } elsif($sig =~ /(\(....,\"[^\"]*\",..\))$/){
      $test_sig = "...$1"
    }
    unless(
      (defined($test_sig) && exists($ele_map{$test_sig})) ||
      exists($ele_map{$sig})
    ){ return }
    if(defined($test_sig) && exists($ele_map{$test_sig})){
      $seen_eles{$test_sig} = 1;
    } else {
      $seen_eles{$sig} = 1;
    }
    my $ele_info = $Posda::Dataset::DD->get_ele_by_sig($sig);
    unless(defined($ele_info)){
      $ele_info = {
        Name => "<Unknown Priv Ele>",
        VR => 'UN',
        VM => 1,
      };
    }
    unless(defined($ele_info->{Name})){
       $ele_info->{Name} = "<Unknown (probably repeating) Ele>";
    }
    my $vr = $ele->{VR};
    my $vm = 1;
    if(ref($ele->{value}) eq "ARRAY"){
      $vm = @{$ele->{value}};
    }
    print STDOUT "$sig:($vr, $vm):$ele_info->{Name}:";
    #print STDOUT "$ele->{file_pos}:$sig:($vr, $vm):$ele_info->{Name}:";
    &Posda::Dataset::DumpEle(\*STDOUT, $ele, $max1);
    print STDOUT "\n";
    if(
      defined($ele->{type}) &&
      $ele->{type} eq "raw" &&
      defined $ele->{value} &&
      $ele->{VR} ne "OF"
    ){
      my $len = length($ele->{value});
      if($len < $max2){
        if(exists $ele->{big_endian}){
          HexDump::PrintBigEndian(\*STDOUT, $ele->{value});
        } else {
          HexDump::PrintVax(\*STDOUT, $ele->{value});
        }
      }
    }
});
for my $sig (sort keys %ele_map){
  unless(exists($seen_eles{$sig})){
    print "Element $sig was not found\n";
  }
}
