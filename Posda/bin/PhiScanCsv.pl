#!/usr/bin/perl -w
use strict;
use Text::CSV;
use Debug;
my $dbg = sub { print @_ };

my $usage = <<EOF;
PhiScanCsv.pl <file> [highest row]
CsvToPerlStruct.pl -h

Reads a csv file and produces a set of path: values for all
the paths with values


EOF

my $high_row;
if($ARGV[0] eq "-h"){ die $usage; exit }
if($#ARGV == 0 ){
  unless(-f $ARGV[0]) {
    die "$ARGV[0] doesn't exist";
  }
  $high_row = 0;
} elsif ($#ARGV == 1 && -f $ARGV[0]){
  $high_row = $ARGV[1];
} else {
  die $usage;
}

my $csv = Text::CSV->new( { binary => 1 });
open my $fh, "<:encoding(utf_8)", $ARGV[0] or die "ARGV[0]: $!";
my @rows;
while(my $row = $csv->getline($fh)){
  push @rows, $row;
}


PrintValues(\@rows, "");
sub PrintValues{
  my($struct, $path) = @_;
  if(ref($struct) eq "HASH"){
    for my $k (sort keys %{$struct}){
      PrintValues($struct->{$k}, "$path" . "{$k}");
    }
  } elsif (ref($struct) eq "ARRAY"){
    my $num_eles = @$struct;
    my $fmt = "[%04d]";
#    if($num_eles > 9) {$fmt = "[%02d]" }
#    if($num_eles > 99) {$fmt = "[%03d]" }
#    if($num_eles > 999) {$fmt = "[%04d]" }
#    if($num_eles > 9999) {$fmt = "[%05d]" }
#    if($num_eles > 99999) {$fmt = "[%06d]" }
    for my $i (0 .. @{$struct}){
      if($path eq "" && $high_row > 0 && $i > $high_row){ return }
      PrintValues($struct->[$i], "$path" . sprintf($fmt, $i));
    }
  } else {
    if(defined $struct && $struct){
      if($struct =~ /\n/){
        my @foo = split /\n/, $struct;
        for my $f (@foo){
          if($f){
            print "$path|$f\n";
          }
        }
      } else {
        print "$path|$struct\n";
      }
    }
  }
}
