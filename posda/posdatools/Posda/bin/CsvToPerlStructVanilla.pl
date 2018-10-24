#!/usr/bin/perl -w
use strict;
use Text::CSV;
use Storable qw( store_fd fd_retrieve );
my $usage = <<EOF;
CsvToPerlStruct.pl <file>
CsvToPerlStruct.pl -h

Reads a csv file and produces a structure on STDOUT (serialized perl structure)

\$struct = [
  [ <cell>, ...],
  ...
};

EOF
if($#ARGV != 0 || $ARGV[0] eq "-h"){ die $usage }

my $csv = Text::CSV->new( { binary => 1 });
open my $fh, "<:encoding(utf_8)", $ARGV[0] or die "ARGV[0]: $!";
my @rows;
while(my $row = $csv->getline($fh)){
  push @rows, $row;
}
store_fd(\@rows, \*STDOUT);
