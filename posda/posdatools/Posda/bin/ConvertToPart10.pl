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
use Posda::Try;

my $usage = "usage: $0 <source> <destination> [ <xfr_stx> [<max_ele_size>]]";
unless(
 $#ARGV == 1 ||
 $#ARGV == 2 ||
 $#ARGV == 3
) {die $usage}
my $from = $ARGV[0];
my $to = $ARGV[1];
my $new_xfr_stx = $ARGV[2];
my $max_ele_size = $ARGV[3];
unless($from =~ /^\//) {$from = getcwd."/$from"}
unless($to =~ /^\//) {$to = getcwd."/$to"}

Posda::Dataset::InitDD();

#my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($ARGV[0],$ARGV[3]);
my $try = Posda::Try->new($ARGV[0], $ARGV[3]);
print "Try:\n";
for my $k (keys %{$try}){
  print "$k = $try->{$k}\n";
}
my $xfr_stx = $try->{xfr_stx};
my $ds = $try->{dataset};
unless(defined($new_xfr_stx)) { $new_xfr_stx = $xfr_stx }
unless($ds) { die "$from didn't parse into a dataset" }
$ds->MapToConvertPvt();
my $offset = $ds->WritePart10($to, $new_xfr_stx, "DICOM_TEST", undef, undef);
#print "Dataset offset: $offset\n";
