#!/usr/bin/perl -w
use strict;
use Text::CSV;
use Storable qw( store_fd fd_retrieve );
my $usage = <<EOF;
CsvToPerlStruct.pl <file>
CsvToPerlStruct.pl -h

Reads a csv file and produces a structure on STDOUT (serialized perl structure)

\$struct = {
  status => Error | OK,
  message => <message>,      # if error
  rows => [                  # otherwise
    [ <cell>, ...],
    ...
  ]
};

EOF
if($#ARGV != 0 || $ARGV[0] eq "-h"){ die $usage }

my $csv = Text::CSV->new( { binary => 1, decode_utf8 => 0 });
open my $fh, "<:encoding(utf_8)", $ARGV[0] or die "ARGV[0]: $!";
my @rows;
while(my $row = $csv->getline($fh)){
  push @rows, $row;
}
my $result = {
  status => 'OK',
  rows => \@rows,
};
store_fd($result, \*STDOUT);
