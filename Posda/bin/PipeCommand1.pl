#!/usr/bin/env perl

use Modern::Perl;

say "Test Pipe Command v1.0\n\n";


say "The following data is read from stdin:";
$| = 1; # turn on autoflush of stdout
while (<STDIN>) {
  say "PipeCommand read: $_";
  sleep 1;
}

say "And the program ends here.";
