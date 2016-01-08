#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/FrameOfRef/FlipGovSign.pl,v $
#$Date: 2011/08/03 19:56:38 $
#$Revision: 1.1 $
#
#Copyright 2011, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Try;
unless($#ARGV == 0) { die "usage: $0 <dose_file" }
my $file = $ARGV[0];
my $try = Posda::Try->new($file);
unless(exists $try->{dataset}){
  die "$file didn't parse as DICOM file"
}
my $modality = $try->{dataset}->Get("(0008,0060)");
unless($modality eq "RTDOSE"){
  die "$file modality isn't RTDOSE"
}
my $gfov = $try->{dataset}->Get("(3004,000c)");
unless(defined $gfov && ref($gfov) eq "ARRAY"){
  die "$file doesn't have good GFOV"
}
my @new_gfov;
for my $i (@$gfov){
  push(@new_gfov, -$i);
}
$try->{dataset}->Insert("(3004,000c)", \@new_gfov);
$try->{dataset}->WritePart10(
  "$file.new", $try->{xfr_stx}, "POSDA", undef, undef);
