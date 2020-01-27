#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::Try;
use Posda::DB::NewModules;

my $usage = <<EOF;
PopulateFileStudy.pl <file_id>
or
PopulateFileStudy.pl -h

This file check to see if the file specified has a file_series row but no
file_study row.  If it does, then it gets the file_path, parses the file_path
and attempts to populate the file_study row for the file.

EOF
unless($#ARGV == 0) { die $usage };
if($ARGV[0] eq "-h"){ print $usage; exit }
my $file_id = $ARGV[0];
my $get_series = Query("GetSeriesByFileId");
my $get_study = Query("GetStudyByFileId");
my $get_path = Query("GetFilePath");
my $series;
my $study;
$get_series->RunQuery(sub {
  my($row) = @_;
  $series = $row->[0];
}, sub {}, $file_id);
$get_study->RunQuery(sub {
  my($row) = @_;
  $study = $row->[0];
}, sub {}, $file_id);
unless(defined $series) { die "No series row" }
unless(defined $study) { die "No study row" }
my $file;
$get_path->RunQuery(sub {
  my($row) = @_;
  $file = $row->[0];
}, sub {}, $file_id);
unless(defined $file){ die "No path found" }
my $try = Posda::Try->new($file);
unless(defined $try->{dataset}){ die "$get_path didn't parse as DICOM" }
my $ds = $try->{dataset};
