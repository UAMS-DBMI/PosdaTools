#!/usr/bin/env perl

use Modern::Perl;
$| = 1; # turn on autoflush of stdout

say "Background Button Test v1.0\n\n";

say "This script does not read from stdin";

say "Your params were:";

for my $i (@ARGV) {
  say $i;
}


say "And the program ends here.";
