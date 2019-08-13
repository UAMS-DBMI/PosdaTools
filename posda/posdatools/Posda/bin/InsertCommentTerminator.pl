#!/usr/bin/perl -w
use strict;
my $f_name = $ARGV[0];
my $n_f_name = "$f_name.new";
open INPUT, "<$f_name";
open OUTPUT, ">$n_f_name";
for my $i (0 .. 5){
  my $line = <INPUT>;
  print OUTPUT $line;
}
print OUTPUT "--\n";
while(my $line = <INPUT>){
  print OUTPUT $line;
}
unlink $f_name;
link $n_f_name, $f_name;
unlink $n_f_name;
