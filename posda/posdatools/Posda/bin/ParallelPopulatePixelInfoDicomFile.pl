#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::Try;
use Digest::MD5;

my $num_populated;
my $num_not_populated;
Query('CountRowsInDicomFileWithPopulatedPixelInfo')->RunQuery(sub{
  my($rows) = @_;
  $num_populated = $rows->[0];
},sub {});
Query('CountRowsInDicomFileWithUnpopulatedPixelInfo')->RunQuery(sub{
  my($rows) = @_;
  $num_not_populated = $rows->[0];
},sub {});
Query('UpdateFileIsPresent')->RunQuery(sub{}, sub{});

my %FileList;
my $rows_requested = $ARGV[0];
Query('RowsInDicomFileWithNoPixelInfoEarliest')->RunQuery(sub{
  my($row) = @_;
  my($file_id, $path) = @$row;
  $FileList{$file_id} = $path;
}, sub{}, $rows_requested);
my @file_ids = keys %FileList;
open SCRIPT1, "|StreamingPopulatePixelInfoIntoDicomFile.pl";
open SCRIPT2, "|StreamingPopulatePixelInfoIntoDicomFile.pl";
open SCRIPT3, "|StreamingPopulatePixelInfoIntoDicomFile.pl";
open SCRIPT4, "|StreamingPopulatePixelInfoIntoDicomFile.pl";
open SCRIPT5, "|StreamingPopulatePixelInfoIntoDicomFile.pl";
open SCRIPT6, "|StreamingPopulatePixelInfoIntoDicomFile.pl";
open SCRIPT7, "|StreamingPopulatePixelInfoIntoDicomFile.pl";
open SCRIPT8, "|StreamingPopulatePixelInfoIntoDicomFile.pl";
open SCRIPT9, "|StreamingPopulatePixelInfoIntoDicomFile.pl";
open SCRIPT10, "|StreamingPopulatePixelInfoIntoDicomFile.pl";
filelist:
while (1){
  my $file_id = shift @file_ids;
  unless(defined $file_id) { last filelist }
  print SCRIPT1 "$file_id" . "&" . "$FileList{$file_id}\n";
  $file_id = shift @file_ids;
  unless(defined $file_id) { last filelist }
  print SCRIPT2 "$file_id" . "&" . "$FileList{$file_id}\n";
  $file_id = shift @file_ids;
  unless(defined $file_id) { last filelist }
  print SCRIPT3 "$file_id" . "&" . "$FileList{$file_id}\n";
  $file_id = shift @file_ids;
  unless(defined $file_id) { last filelist }
  print SCRIPT4 "$file_id" . "&" . "$FileList{$file_id}\n";
  $file_id = shift @file_ids;
  unless(defined $file_id) { last filelist }
  print SCRIPT5 "$file_id" . "&" . "$FileList{$file_id}\n";
  $file_id = shift @file_ids;
  unless(defined $file_id) { last filelist }
  print SCRIPT6 "$file_id" . "&" . "$FileList{$file_id}\n";
  $file_id = shift @file_ids;
  unless(defined $file_id) { last filelist }
  print SCRIPT7 "$file_id" . "&" . "$FileList{$file_id}\n";
  $file_id = shift @file_ids;
  unless(defined $file_id) { last filelist }
  print SCRIPT8 "$file_id" . "&" . "$FileList{$file_id}\n";
  $file_id = shift @file_ids;
  unless(defined $file_id) { last filelist }
  print SCRIPT9 "$file_id" . "&" . "$FileList{$file_id}\n";
  $file_id = shift @file_ids;
  unless(defined $file_id) { last filelist }
  print SCRIPT10 "$file_id" . "&" . "$FileList{$file_id}\n";
}
close SCRIPT1;
close SCRIPT2;
close SCRIPT3;
close SCRIPT4;
close SCRIPT5;
close SCRIPT6;
close SCRIPT7;
close SCRIPT8;
close SCRIPT9;
close SCRIPT10;
