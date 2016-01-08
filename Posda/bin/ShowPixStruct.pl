#!/usr/bin/perl -w 
#$Source: /home/bbennett/pass/archive/Posda/bin/ShowPixStruct.pl,v $
#$Date: 2014/07/23 14:42:20 $
#$Revision: 1.1 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use Posda::Parser;
use Posda::Dataset;

my $usage = "Usage: $0 <file> [<len>] [<len>]";
unless ($#ARGV >= 0) {die $usage;}

my $dir = getcwd;
my $infile = $ARGV[0];
unless($infile =~ /^\//) {
	$infile = "$dir/$infile";
}
my $max_len1 = $ARGV[1];
my $max_len2 = $ARGV[2];
unless(defined $max_len1) {$max_len1 = 64}
unless(defined $max_len2) {$max_len2 = 300}

Posda::Dataset::InitDD();
my $dd = $Posda::Dataset::DD;

my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($infile);
  if(exists($ds->{0x7fe0}) && exists($ds->{0x7fe0}->{0x10})){
    my $pix_ele = $ds->{0x7fe0}->{0x10};
    for my $i (sort keys %$pix_ele){
      if(ref($pix_ele->{$i}) eq "ARRAY"){
        for my $j (0 .. $#{$pix_ele->{$i}}){
          print $i . "[$j]: \n";
          HexDump::PrintVax(\*STDOUT, $pix_ele->{$i}->[$j]);
        }
      } else {
        if($i eq "value"){
          print "$i: \n";
          HexDump::PrintVax(\*STDOUT, $pix_ele->{$i});
        } else {
          print "$i: $pix_ele->{$i}\n";
        }
      }
    }
  }
if($ds){
} else {
  for my $i(@$errors){
     print "$i\n";
  }
}
