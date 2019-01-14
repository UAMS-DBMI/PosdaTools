#!/usr/bin/perl -w
use strict;
use Text::CSV;
use Storable qw( store_fd fd_retrieve );
my $usage = <<EOF;
CsvToPerlStruct.pl
CsvToPerlStruct.pl -h

Reads a csv strean on STDIN and produces a structure on STDOUT (serialized perl structure)

\$struct = {
  status => Error | OK,
  message => <message>,      # if error
  rows => [                  # otherwise
    [ <cell>, ...],
    ...
  ]
};

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){ die $usage }
if($#ARGV != -1){die "wrong num args $#ARGV vs -1\n$usage" }

my $csv = Text::CSV->new( { binary => 1 });
my @rows;
while(my $row = $csv->getline(*STDIN)){
  push @rows, $row;
}
my $result = {
  status => 'OK',
  rows => \@rows,
};
store_fd($result, \*STDOUT);
