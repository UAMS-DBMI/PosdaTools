#!/usr/bin/perl -w
use strict;
use Posda::Try;
my $file = $ARGV[0];
my $try = Posda::Try->new($file);
unless(exists $try->{dataset}){ die "$file didn't parse" }
my $rows = $try->{dataset}->Get("(0028,0010)");
my $cols = $try->{dataset}->Get("(0028,0011)");
print "<$rows" ."x$cols>\n";
