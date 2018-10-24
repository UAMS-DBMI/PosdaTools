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
use Posda::Parser;
use Posda::Dataset;

my $usage = "usage: DeletePrivateExceptCtp.pl <source> <destination>";
if($#ARGV == 0 && $ARGV[0] eq "-h") { print "$usage\n"; exit }
unless($#ARGV == 1) { die $usage }
Posda::Dataset::InitDD();

my $from = $ARGV[0];
my $to = $ARGV[1];
unless($from =~ /^\//) {$from = getcwd."/$from"}
unless($to =~ /^\//) {$to = getcwd."/$to"}

my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($ARGV[0]);
unless($ds) { die "$from didn't parse into a dataset" }
my $count = @ARGV;
unless(($count & 1) == 0){ 
  for my $i (0 .. $#ARGV){
    print "ARGV[$i] = $ARGV[$i]\n";
  }
  die "need an even number of args" 
};
$ds->MapPvt(sub {
  my($ele, $sig) = @_;
  if(
    ($sig =~ /\"/) &&
    ($sig ne '(0013,"CTP",10)') &&
    ($sig ne '(0013,"CTP",11)') &&
    ($sig ne '(0013,"CTP",12)')
  ){ $ds->Delete($sig) }
});
if($df){
  $ds->WritePart10($to, $xfr_stx, "DICOM_TEST", undef, undef);
} else {
  $ds->WriteRawDicom($to, $xfr_stx);
}
