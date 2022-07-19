#!/usr/bin/perl -w
use strict;
my $usage = <<EOF;
TransposeGrayFile.pl <from_file> <rows> <cols> <to_file>
EOF
unless($#ARGV == 3) { die $usage }
if($#ARGV == 0 and $ARGV[0] = "-h"){
  print $usage;
  exit;
}
my($from_file, $rows, $cols, $to_file) = @ARGV;
open FROM, "<$from_file" or die "Can't open $from_file for read";
open TO, ">$to_file" or die "Can't open $to_file for writing";
my @rows;
for my $r (1 .. $rows){
  my @row;
  my $buff;
  my $br = read FROM, $buff, $cols;
  unless($br == $cols) { die "read $br vs $cols for $r" };
  @row = unpack("C*", $buff);
  push @rows, \@row;
}
my $num_rows = @rows;
print "read $num_rows rows (apparently correctly)\n";
my @cols;
for my $r (0 .. $rows - 1){
  my @col;
  for my $c (0 .. $cols - 1){
    $cols[$c]->[$r] = $rows[$r]->[$c];
  }
}
my $num_cols = @cols;
print "Got $num_cols\n";
for my $c (0 .. $cols - 1){
  my $col_packed = pack "C*", @{$cols[$c]};
  print TO $col_packed;
}
