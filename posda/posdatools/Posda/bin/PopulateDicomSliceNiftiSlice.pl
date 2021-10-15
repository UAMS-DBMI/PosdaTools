#!/usr/bin/perl -w
use strict;
use Posda::DB qw(Query);
my $usage = <<EOF;
PopulateDicomSliceNiftiSlice.pl <?bkgrnd_id?> <activity_id> <nifti_file_id>
EOF
