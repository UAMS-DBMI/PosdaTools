#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use strict;
use Posda::Try;
unless($#ARGV == 0){ die "usage: $0 <dose_file>\n" }
my $file = $ARGV[0];
my $try = Posda::Try->new($file);
unless(defined $try->{dataset}){ die "$file didn't parse as DICOM" };
my $ds = $try->{dataset};
my $rows = $ds->Get("(0028,0010)");
my $cols = $ds->Get("(0028,0011)");
my $frames = $ds->Get("(0028,0008)");
my $stored = $ds->Get("(0028,0101)");
unless($stored == 32){ die "not 32 bit dose" }
my $pix_len = $rows * $cols * $frames * 4;
my $pix = $ds->Get("(7fe0,0010)");
my $act_pix_len = length($pix);
unless($pix_len == $act_pix_len) { die "$act_pix_len vs $pix_len" }
my @Pix = unpack("V*", $pix);
my $largest = 0;
for my $i (@Pix){
  if($i > $largest) {$largest = $i}
}
print "largest: $largest\n";
my $scale = 65535 / $largest;
print "$scale = $scale\n";
my $scaled_largest = $scale * $largest;
print "scaled = $scaled_largest\n";
my @NewPix;
for my $i (@Pix){
  push(@NewPix, $i * $scale);
}
my $new_pix = pack("v*", @NewPix);
my $new_pix_len = length($new_pix);
my $expected_new_pix_len = $pix_len / 2;
unless($new_pix_len == $expected_new_pix_len) { 
  die "$new_pix_len vs $expected_new_pix_len" 
}
$ds->Insert("(0028,0100)", 16);
$ds->Insert("(0028,0101)", 16);
$ds->Insert("(0028,0102)", 15);
$ds->Insert("(7fe0,0010)", $new_pix);
$ds->WritePart10("$file.new", $try->{xfr_stx}, "POSDA", undef, undef);
