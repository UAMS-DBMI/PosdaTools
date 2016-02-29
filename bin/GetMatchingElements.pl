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
	print "usage: $0 <file> <ele_sig_match>";
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
my $matches = $ds->NewSearch($ele_sig);

if(ref $matches eq "ARRAY"){
  for my $m (@$matches){
    my $sub_sig = $ele_sig;
    for my $i (0 .. $#{$m}){
      my $mn = "<$i>";
      $sub_sig =~ s/$mn/$m->[$i]/;
    }
    print "$sub_sig\n";
  }
}
