#!/usr/bin/perl -w
use strict;
my $path = $ARGV[0];
my $digest = $ARGV[1];
print "update dicom_edit_compare set to_file_path = '$path' where to_file_digest = '$digest';\n";
