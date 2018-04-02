#!/usr/bin/perl -w
use strict;
#use Text::CSV;
use Debug;
my $dbg = sub {print STDERR @_ };
use Storable qw( store_fd fd_retrieve );
use Encode;
my $usage = <<EOF;
PerlStructToCsvVanilla.pl <file>
PerlStructToCsvVanilla.pl -h

Accepts a perl struct on STDIN and produces a CSV on STDOUT

\$struct = [
  [ <cell, ... ],
  ...
};


EOF
if($#ARGV >= 0){ die $usage }
#my $csv = Text::CSV->new( { binary => 1 });

my $struct = fd_retrieve(\*STDIN);
unless(ref($struct) eq "ARRAY") { die "PerlStructToCsvVanilla.pl requires a HASH" }
for my $row (@$struct){
   for my $c (0 .. $#{$row}){
     my $v = $row->[$c];
     $v =~ s/\"/\"\"/g;
     $v = encode("utf8", $v);
     print "\"$v\"";
     unless($c eq $#{$row}){  print "," }
   }
   print "\r\n";
}
