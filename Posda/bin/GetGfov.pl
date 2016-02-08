#!/usr/bin/perl -w
#
use strict;
use Digest::MD5;
my $usage =
  "GetGfov.pl <file> <offset> <len>";
unless($#ARGV == 2) { die $usage }
my $file = $ARGV[0];
my $offset = $ARGV[1];
my $len = $ARGV[2];
open my $fh, $file or die "can't open $file";
seek $fh, $offset, 0;
my $buff;
my $length = read($fh, $buff, $len);
unless($length == $len) { die "read $length vs $len" }
print "$buff\n";
