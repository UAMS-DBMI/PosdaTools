#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/InvertGfov.pl,v $
#$Date: 2013/11/14 20:32:09 $
#$Revision: 1.1 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use strict;
use Posda::Parser;
use Posda::Dataset;

my $usage = "usage: $0 <source> <destination>";
unless($#ARGV == 1) {die $usage}
my $from = $ARGV[0];
my $to = $ARGV[1];
unless($from =~ /^\//) {$from = getcwd."/$from"}
unless($to =~ /^\//) {$to = getcwd."/$to"}

Posda::Dataset::InitDD();

my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($ARGV[0]);
unless($ds) { die "$from didn't parse into a dataset" }
$ds->MapToConvertPvt();
my $gfov = $ds->Get("(3004,000c)");
unless(defined($gfov) && ref($gfov) eq "ARRAY"){
  die "Grid frame offset vector not present";
}
unless($gfov->[0] == 0){ die "Old style Grid frame offset vector" }
for my $i (1 .. $#{$gfov}){
  $gfov->[$i] = -$gfov->[$i];
}
$ds->WritePart10($to, $xfr_stx, "DICOM_TEST", undef, undef);
