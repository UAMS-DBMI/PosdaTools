#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Try;
use Debug;
my $dbg = sub { print STDERR @_ };
my $help = <<EOF;
 Pixel byte swapper: 
 usage: ByteSwapDicomPixelData.pl <from_file> <to_file>
  or 
        ByteSwapDicomPixelData.pl -h
 if successful a single line: "OK" to STDOUT
 if fails, writes "Error: <message>" to STDOUT
 may write a lot of stuff to STDERR (even if successful).
EOF
if($#ARGV !=  1){
  print $help;
  exit;
}
my $from_file = $ARGV[0];
my $to_file = $ARGV[1];
my $try = Posda::Try->new($from_file);
unless(exists $try->{dataset}) { 
  Error("file $from_file didn't parse", $try);
}
my $ds = $try->{dataset};
# do swap here
my $bits_alloc = $ds->Get("(0028,0100)");
unless($bits_alloc && $bits_alloc == 16){
  print "Error: $from_file doesn't have 16 bit pixels\n";
  exit;
}
my $pixels = $ds->Get("(7fe0,0010)");
my $swapped = pack("v*", unpack("n*", $pixels));
$ds->Insert("(7fe0,0010)", $swapped);
# swap done
eval { $ds->WritePart10($to_file, $try->{xfr_stx}, "POSDA") };
if($@){
  print "Error: $@\n";
} else {
  if(-f $to_file){
    print "OK\n";
  } else {
    print STDERR "To file ($to_file) doesn't exist\n";
    print "Error: file $to_file not created\n";
  }
}
