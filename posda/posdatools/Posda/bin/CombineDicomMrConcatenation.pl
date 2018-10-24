#!/usr/bin/perl -w
use strict;
use Posda::Try;
use Posda::UUID; 
my $usage = <<EOF;
CombineDicomMrConcatenation.pl <dest_file>

expects a list of source files on STDIN

Reads all of the files specified on STDIN does the following:

  - It expects each file to have a "Per-Frame Functional Groups Sequence" (5200,9230)
    with a single item.  It will accumlate these into an Array indexed by 
    "Concatenation Frame Offset Number" (0020,9228)
  - It will similarly include all of the pixel data field into an array of pixel data
    indexed by the same.

When it has read the last image (and done the processing above), it will do the
following to the final dataset:

  - It will generate a new SOP Instance UID and replace "Sop Instance UID" with the
    new value
  - It will delete the following fields:
      "Concatenation UID" (0020,9161)
      "In-concatenation Number" (0020,9162)
      "In-concatenation Total Number" (0020,9163)
      "Concatenation Frame Offset Number" (0020,9228)
  - It will replace the value of the element "Per-FrameFunctional Groups Sequence"
    (5200,9230) with the array of items accumulated above.
  - It will replace the pixel data with a concatenation of the pixel data accumulated
    above.
  - It will then write this new data set into <dest_file>
EOF

my @function_groups;
my @pixel_data;
if($ARGV[0] eq "-h"){
  die $usage;
}
unless($#ARGV == 0){
  die $usage;
}
my $dest_file = $ARGV[0];
my @files;
while(my $line = <STDIN>){
  chomp $line;
  push @files, $line;
}
my $try;
file:
for my $f (@files){
  $try = Posda::Try->new($f);
  unless(exists $try->{dataset}){
    die "file: $f didn't parse";
  }
  my $f_idx = $try->{dataset}->Get("(0020,9228)");
  unless(defined $f_idx) {
    die "file: $f has no ConcatenationFrameOffset";
  }
  my $foo = $try->{dataset}->Get("(5200,9230)");
  unless(defined($foo) && ref($foo) eq "ARRAY" && $#{$foo} == 0){
    die "file: $f doesn't have a single functional group item";
  }
  $function_groups[$f_idx] = $foo->[0];
  $pixel_data[$f_idx] = $try->{dataset}->Get("(7fe0,0010)");
}
my $ds = $try->{dataset};
$ds->Insert("(0008,0018)", Posda::UUID::GetUUID());
for my $i ("(0020,9161)", "(0020,9162)", "(0020,9163)", "(0020,9228)"){
  $ds->Delete($i);
}
$ds->Insert("(5200,9230)", \@function_groups);
my $new_pix = join '', @pixel_data;
$ds->Insert("(7fe0,0010)", $new_pix);
$ds->WritePart10($dest_file, $try->{xfr_stx}, "DICOM_TEST", undef, undef);
