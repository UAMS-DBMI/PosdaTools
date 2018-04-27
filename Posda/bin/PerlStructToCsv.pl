#!/usr/bin/perl -w
use strict;
#use Text::CSV;
use Debug;
my $dbg = sub {print STDERR @_ };
use Storable qw( store_fd fd_retrieve );
my $usage = <<EOF;
PerlStructToCsv.pl <file>
PerlStructToCsv.pl -h

Accepts a perl struct on STDIN and produces a CSV on STDOUT

\$struct = {
  type => FromQuery | FromCsv,
  query => {
  },
  row =>  [ <cell>, ...],
  },
  ...
};


EOF
if($#ARGV >= 0){ die $usage }
#my $csv = Text::CSV->new( { binary => 1 });

my $struct = fd_retrieve(\*STDIN);
unless(ref($struct) eq "HASH" or 
       ref($struct) eq "DbIf::Table") { 
     die "PerlStructToCsv.pl requires a HASH or DbIf::Table";
}
if($struct->{type} eq "FromQuery"){
  for my $col (0 .. $#{$struct->{query}->{columns}}){
    print "\"$struct->{query}->{columns}->[$col]\"";
    unless($col eq $#{$struct->{query}->{columns}}){ print "," }
  } 
  print "\n";
}
for my $row (@{$struct->{rows}}){
   for my $c (0 .. $#{$row}){
     my $v = $row->[$c];
     $v =~ s/\"/\"\"/g;
     if($v =~ /^\(\d\d\d\d,\d\d\d\d\)$/){
       $v = "-$v-";
     }
     print "\"$v\"";
     unless($c eq $#{$row}){  print "," }
   }
   print "\n";
}
