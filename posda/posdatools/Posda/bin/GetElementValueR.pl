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

Posda::Dataset::InitDD();

my $usage = sub {
	print "usage: GetElementValue.pl <file> <ele_sig>\n";
	exit(-1);
};
unless(
	$#ARGV == 1
) {
	&$usage();
}

my $file = $ARGV[0]; unless($file =~ /^\//) { $file = getcwd."/$file" }

my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($ARGV[0]);
unless($ds) { die "$file didn't parse into a dataset" }
my $ele_sig = $ARGV[1];
my $value = $ds->Get($ele_sig);
my $type = $Posda::Dataset::DD->get_type_by_sig($ele_sig);
if(ref($value) eq "ARRAY"){
  die "ARRAY value";
} else {
  print "$value";
}
