#!/usr/bin/perl -w 
use strict;
my $usage = "ExtractUpload.pl <file> <dir>\n";
unless($#ARGV == 1) { die $usage };
unless(-f $ARGV[0]) { die "$ARGV[0] is not a file" }
unless(-d $ARGV[1]) { die "$ARGV[1] is not a directory" }
open FILE, "<$ARGV[0]" or die "Can't open $ARGV[1]";
binmode FILE;
my $boundry_has_cr = 0;
my $line = <FILE>;
chomp $line;
if($line =~ /\r$/) { $boundry_has_cr = 1 };
$line =~ s/\r$//;
my $boundary = $line;
unless($boundary =~ /^\-+\w+$/) {
  die "$boundary doesn't look like a boundary";
}
my %header;
while(1){
  my $line = <FILE>;
  chomp $line;
  $line =~ s/\r$//;
  if($line eq ""){ last }
  unless($line =~ /^([^:]+):\s*(.*)$/){
    print STDERR "Not a header line: $line\n";
    next;
  }
  my $key = $1; my $value = $2;
  $header{$key} = $value;
}
my $buff = "";
while(read FILE, $buff, 1000, length($buff)) {};
my $remain = $buff;
unless (exists $header{"Content-Disposition"}){
  die "no content-disposition";
}
unless (exists $header{"Content-Type"}){
  die "no content-type";
}
my $length_of_buff = length($buff);
my @files;
my $pattern = "^(.*)\n$boundary(.*)\$";
if($boundry_has_cr) {
  $pattern = "^(.*)\r\n$boundary(.*)\$";
}
my $i_length = length($remain);
while($remain =~ /$pattern/s){
  my $content = $1; $remain = $2;
  if($remain =~ /^--\s*$/){
    $remain = "";
  }
  my $length = length($content);
  my @fields = split(/;/, $header{"Content-Disposition"});
  my $disp = $fields[0];
  my %disp_d;
  for my $i (1 .. $#fields){
    my $f = $fields[$i];
    if($f =~ /\s*(.*)=(.*)/){
      my $k = $1; my $v = $2;
      $v =~ s/^\"//;
      $v =~ s/\"$//;
      $disp_d{$k} = $v;
    }
  }
  my $out_file_base = "$ARGV[1]/$disp_d{filename}";
  my $out_file = $out_file_base;
  my $out_inc = 0;
  while(-f $out_file){
    $out_inc += 1;
    $out_file = "$out_file_base" . "[$out_inc]";
  }
  print "Output file: $out_file\nmime-type: " . $header{"Content-Type"} .
    "\nlength: $length\n";
  open OUT, ">$out_file"
    or die "Can't open $out_file"; 
  print OUT $content;
  close OUT;
} 
if($remain) { print "Remaining: $remain\n" }
else {
}
