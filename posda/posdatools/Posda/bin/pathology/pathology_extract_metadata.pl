#!/usr/bin/env perl

use strict;
use warnings;
use 5.10.0;
use File::Temp 'tempdir';
use File::Basename 'fileparse';

use Posda::File::Import;


# build the input params
my $SCRIPT = '/home/posda/posdatools/Posda/bin/pathology/quip_wsi_metadata.py';
my $OUTDIR = tempdir(CLEANUP => 0);


my ($input_file, $digest) = @ARGV;
my ($filename, $dir) = fileparse($input_file);


# Execute the python script
my $cmd = qq{python3 $SCRIPT --inpdir $dir --outdir $OUTDIR --slide '{"path":"$filename", "file_uuid": "$digest"}'};
my $result = `$cmd`;

say $result;

# collect the output artifacts
my $artifacts = `find $OUTDIR -type f -not -iname '*manifest*'`;
my @files = split(" ", $artifacts);



# add the files to Posda
for my $file (@files) {
  say $file;
  my $import_response = Posda::File::Import::insert_file $file;

  if (not $import_response->is_error) {
    say "File inserted, file_id: " . $import_response->file_id;
  } else {
    say "There was an error:";
    say $import_response->message;
  }
}

# generate email report with links to artifacts

