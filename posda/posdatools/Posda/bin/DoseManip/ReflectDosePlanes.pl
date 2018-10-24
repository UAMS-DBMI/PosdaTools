#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Dataset;
use VectorMath;
use Cwd;

# "Reflects" a Dose Matrix across the first slice in the Dose Matrix.  This
# is done by simply negating all the entries in the grid frame offset vector.
# No change is made to the dose grid, nor to Image Position Patient.
#
# This changes the position and orientatio of the DOSE grid (it really reflects
# it).

# This type of transformation will often "fix" an improperly encoded DOSE file.
# These files result from an early misinterpretation of the meaning of "offset"
# in the grid frame offset vector.  The standard has been updated to remove 
# ambiguity in this specification.

my $file = $ARGV[0]; unless($file =~ /^\//) { $file = getcwd."/$file" }
unless($#ARGV == 0){ die "usage: $0 <file>" }
my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($file);
unless($ds) { die "$file didn't parse" }
my $modality = $ds->Get("(0008,0060)");
unless($modality eq "RTDOSE") { die "$file is not a dose" }
my $gfov = $ds->Get("(3004,000c)");
my $new_gfov = [];
for my $i (0 .. $#{$gfov}){
  push @$new_gfov, -$gfov->[$i];
}
$ds->Insert("(3004,000c)", $new_gfov);
$ds->WritePart10("$file.reflect", $xfr_stx, "POSDA_FLIP", undef, undef);
