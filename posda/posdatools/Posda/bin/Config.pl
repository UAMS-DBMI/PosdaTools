#!/usr/bin/env perl
#
# Config.pl - simple wrapper script to retrieve config values using 
# Posda::Config
#

use Modern::Perl;
use Posda::Config ('Config', 'DatabaseName');

unless($#ARGV == 1){
  die "Usage: $0 TYPE VALUE\n" . 
  " where TYPE is config or database\n";
}

my ($type, $value) = @ARGV;


if ($type eq 'config') {
  say Config($value);
}

if ($type eq 'database') {
  say DatabaseName($value);
}
