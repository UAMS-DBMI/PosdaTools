#!/usr/bin/perl -w 
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Try;
unless($#ARGV == 1) { die "usage: $0 <file> <roi_num>\n" }
my $file = $ARGV[0]; unless($file=~/^\//){$file=getcwd."/$file"}
my $roi_num = $ARGV[1];
my $try = Posda::Try->new($file);
unless (exists $try->{dataset}){ die "$file is not a DICOM file" }
my $ds = $try->{dataset};
my $modality = $ds->Get("(0008,0060)");
unless($modality eq "RTSTRUCT") { die "$file is not an RTSTRUCT" }
my $match = $ds->Search("(3006,0020)[<0>](3006,0022)", $roi_num);
unless($match && ref($match) eq "ARRAY"){
  die "No entry in SS ROI seq with ROI Number $roi_num";
}
for my $i (@$match) {
  my $index = $i->[0];
  $ds->Delete("(3006,0020)[$index]");
}
$match = $ds->Search("(3006,0039)[<0>](3006,0084)", $roi_num);
for my $i (@$match) {
  my $index = $i->[0];
  $ds->Delete("(3006,0039)[$index]");
}
$match = $ds->Search("(3006,0080)[<0>](3006,0084)", $roi_num);
for my $i (@$match) {
  my $index = $i->[0];
  $ds->Delete("(3006,0080)[$index]");
}
#$ds->RemoveUndefItems("(3006,0020)");
#$ds->RemoveUndefItems("(3006,0039)");
#$ds->RemoveUndefItems("(3006,0080)");
my $dest_file = "$try->{filename}.new";
$ds->WritePart10($dest_file, $try->{xfr_stx}, "POSDA", undef, undef);
