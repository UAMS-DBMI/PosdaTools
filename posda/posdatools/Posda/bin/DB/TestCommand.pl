#!/usr/bin/env perl

use Modern::Perl;
use Data::Dumper;

say "Test command!";
say Dumper(\@ARGV);
sleep 1;

while (<STDIN>) {
	chomp;
	say "Read line: $_";
}
