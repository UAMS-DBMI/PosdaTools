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
$ds->WritePart10($to, "1.2.840.10008.1.2.1", "DICOM_TEST", undef, undef);
