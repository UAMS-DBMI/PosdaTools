#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Parser;
use Posda::Dataset;
use Cwd;

my $usage = "usage: $0 <source> <destination> <sig> [<sig> ...]\n";
unless($#ARGV >= 1) {die $usage}
Posda::Dataset::InitDD();

my $from = shift @ARGV;
my $to = shift @ARGV;
unless($from =~ /^\//) {$from = getcwd."/$from"}
unless($to =~ /^\//) {$to = getcwd."/$to"}

my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($from);
unless($ds) { die "$from didn't parse into a dataset\n" }
if($#ARGV >= 0){
  for my $i (0 .. $#ARGV){
    my $sig = $ARGV[$i];
    print "deleting $sig\n";
    $ds->Delete($sig);
  }
}
if($df){
  $ds->WritePart10($to, $xfr_stx, "DICOM_TEST", undef, undef);
} else {
  $ds->WriteRawDicom($to, $xfr_stx);
}
