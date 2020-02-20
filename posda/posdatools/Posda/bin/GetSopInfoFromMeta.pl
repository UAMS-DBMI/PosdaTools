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
	print "usage: GetSopInfoFromMeta.pl <file>\n";
	exit(-1);
};
unless(
	$#ARGV == 0
) {
	&$usage();
}

my $file = $ARGV[0]; unless($file =~ /^\//) { $file = getcwd."/$file" }

my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($ARGV[0]);
unless($df) { die "$file didn't parse into a dataset with metaheader" }
my $sop_class = $df->{metaheader}->{"(0002,0002)"};
my $sop_inst = $df->{metaheader}->{"(0002,0003)"};
print "SOP Class: $sop_class\n";
print "SOP Instance: $sop_inst\n";
