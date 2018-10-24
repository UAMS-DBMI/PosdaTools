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
#print "Num populated: $num_populated\n";
#print "Num not populated: $num_not_populated\n";
my %FileList;
my $rows_requested = $ARGV[0];
Query('RowsInDicomFileWithNoPixelInfoEarliest')->RunQuery(sub{
  my($row) = @_;
  my($file_id, $path) = @$row;
  $FileList{$file_id} = $path;
}, sub{}, $rows_requested);
my $rows_returned = keys %FileList;
#print "Rows returned: $rows_returned\n";
my $mark_no_pixels = Query('MarkDicomFileAsNotHavingPixelData');
my $insert_pixel_info = Query('PopulatePixelInfoInDicomFile');
for my $file_id (sort {$a <=> $b} keys %FileList){
  my $try = Posda::Try->new($FileList{$file_id});
  unless(exists $try->{dataset}) {
    die "File ($file_id): $FileList{$file_id} didn't parse";
  }
  my $ds = $try->{dataset};
  if(exists $ds->{0x7fe0}->{0x10}){
    my $pix = $ds->{0x7fe0}->{0x10};
    my $pixel_data_offset = $pix->{file_pos};
    my $pixel_data_length = length $pix->{value};
    my $ctx = Digest::MD5->new;
    $ctx->add($pix->{value});
    my $pixel_data_digest = $ctx->hexdigest;
    $insert_pixel_info->RunQuery(sub {}, sub {},
      $pixel_data_digest, $pixel_data_offset, $pixel_data_length, $file_id);
  } else {
    $mark_no_pixels->RunQuery(sub{}, sub{}, $file_id);
  }
}
