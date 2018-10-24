#!/usr/bin/perl -w
use strict;
my $usage = <<EOF;
GetFilePart.pl <file> <offset> <length>
or 
GetFilePart.pl -h
EOF
unless($#ARGV == 2){ die $usage }
open FILE, "$ARGV[0]" or die "can't open $ARGV[0]";
unless(seek FILE, $ARGV[1], 0){
  die "[$!] can't seek to $ARGV[1]";
}
my $text;
my $len = read FILE, $text, $ARGV[2];
unless($len == $ARGV[2]){
  die "read wrong num bytes $ARGV[2] vs $len";
}
print $text;
