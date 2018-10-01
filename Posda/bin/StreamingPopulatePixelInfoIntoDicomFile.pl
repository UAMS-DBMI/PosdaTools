#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::Try;
use Digest::MD5;

my $mark_no_pixels = Query('MarkDicomFileAsNotHavingPixelData');
my $insert_pixel_info = Query('PopulatePixelInfoInDicomFile');
while(my $line = <STDIN>){
  chomp $line;
  my($file_id, $path) = split(/&/, $line);
  my $try = Posda::Try->new($path);
  unless(exists $try->{dataset}) {
    die "File ($file_id): $path didn't parse";
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
