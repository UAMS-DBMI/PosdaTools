#!/usr/bin/perl -w
#
use strict;
use Cwd;
my $help =  <<EOF;
Usage:
SplitIsodoseContours.pl base_file_name=<base_file_name> in=<fd> status=<fd>
or
SplitIsodoseContours.pl -h 

The program splits a set of 2d isodose lines into a set of 2d contours in
files based upon a given file name.  The input is received on the file handle
designated by "in" and has the following format:
<begin>
BEGIN
x1, y1
x2, y2
...
END
...
<eof>
This stream represents multiple contours for a given isodose at a given slice.
This program will separate these into <n> different files named:
<base_file_name>_<n>
for each of the contours and encode the data for each contour as a single 
long line of the form:
<x1>\<y1>\<x2>\<y2>...

If there is no isodose data at the slice (i.e. the stream is empty), the
this program will create a single empty file:
<base_file_name>_0

When finished this program writes a single "OK" line to its STATUS fd.

Note: this program is generally meant to run as a subprocess.  Please see
IsoDoseExtraction.pl for an example of its invocation.  The second form of
its invocation (-h) produces this message.
EOF
unless($#ARGV == 0 || $#ARGV == 2) { die $help }
if($ARGV[0] eq "-h"){
  print $help;
  exit;
}
my($in, $status, $base_file);
for my $i (@ARGV){
  unless($i =~ /^([^=]+)=([^=]+)$/) {
    die "$0: can't parse parameter $i";
  }
  my $key = $1;
  my $value = $2;
  if ($key eq "in") { $in = $value }
  elsif ($key eq "status") { $status = $value }
  elsif ($key eq "base_file_name") { $base_file = $value }
  else { die "$0: unknown parameter: $key" }
}
unless($in){ die "$0: no input defined" }
unless($status){ die "$0: no input defined" }
unless($base_file) { die "$0: bytes undefined" }
open(INPUT, "<&", $in) or die "$0: Can't open in = $in ($!)";
open(STATUS, ">&", $status) or die "$0: Can't open status = $status ($!)";
my $fh;
my $index = 0;
my $cwd = getcwd;
unless($base_file =~ /^\//) { $base_file = "$cwd/$base_file" }
open $fh, ">${base_file}_$index" or die "can't open ${base_file}_$index";
my $file_open = 1;
my $state = "BEGIN_Search";
my $lines = [];
while (my $line = <INPUT>){
  chomp $line;
  if($state eq "BEGIN_Search"){
    if($line eq "BEGIN"){
      unless($file_open){
        open $fh, ">${base_file}_$index" 
          or die "can't open ${base_file}_$index";
      }
      $state = "END_Search";
    } else {
      die "Should have seen a BEGIN or EOF here";
    }
  } elsif($state eq "END_Search"){
    if($line eq "END"){
      for my $i (0 .. $#{$lines}){
        print $fh "$lines->[$i]->[0]\\$lines->[$i]->[1]";
        unless($i == $#{$lines}) { print $fh "\\" }
      }
      close $fh;
      $lines = [];
      $index += 1;
      $file_open = 0;
      $state = "BEGIN_Search";
    } elsif ($line =~ /^(.*), (.*)$/){
      push @{$lines}, [$1, $2];
    } else {
      die "Couldn't make sense of line: $line";
    }
  }
}
print STATUS "OK\n";
