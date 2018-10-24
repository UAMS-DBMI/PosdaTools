#!/usr/bin/perl -w
#
#Copyright 2014, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
use Storable qw( freeze nfreeze store );
my $test_data = {
  foo => "fie",
  few => "fum"
};
my $file_name = $ARGV[0];
my $file_1 = "$file_name.freeze";
my $file_2 = "$file_name.nfreeze";

store $test_data, $file_name;
my $freeze =  freeze $test_data;
open FILE, ">$file_1";
print FILE $freeze;
close FILE;
my $nfreeze = nfreeze $test_data;
open FILE, ">$file_2";
print FILE $freeze;
close FILE;
