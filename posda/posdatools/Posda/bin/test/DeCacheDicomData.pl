#!/usr/bin/perl -w
use strict;
#
#Copyright 2015, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
my $usage = <<EOF;
DeCacheDicomData.pl <cache_root> <digest>
EOF
my $root = $ARGV[0];
my $dig = $ARGV[1];
unless($dig =~ /^(.)(.)/) { die "can't get first two hex dig" }
my $h1 = $1;
my $h2 = $2;
my $cache_file = "$root/$h1/$h2/$dig.dcminfo";
if(-f $cache_file) { print "rm $cache_file\n" }
else { print "$cache_file doesn't exist\n" }
