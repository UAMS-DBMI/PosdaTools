#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use File::Temp qw/ tempfile /;

use Debug;
my $dbg = sub { print STDERR @_ };

my $usage = <<EOF;
PopulateAllSegSliceToContour.pl 


EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
my @Conversions;
Query('SegSliceBitmapsForContourConversion')->RunQuery(sub{
  my($row) = @_;
  my($seg_bitmap_file_id, 
    $seg_slice_bitmap_file_id, $rows, $cols) = @$row;
  push @Conversions, {
    seg_slice_bitmap_file_id => $seg_slice_bitmap_file_id,
    rows => $rows,
    cols => $cols,
  };
}, sub{});
my $q = Query('GetFilePath');
conversion:
for my $c (@Conversions){
  my $path;
  $q->RunQuery(sub {
    my($row) = @_;
    $path = $row->[0];
  }, sub{}, $c->{seg_slice_bitmap_file_id});
  my $tmp_file_path;
  {
    my $t_fhs;
    ($t_fhs, $tmp_file_path) = tempfile();
  }
  unless(defined $path) {
    print STDERR "File $c->{seg_slice_bitmap_file_id}: path not found in db\n";
    next conversion;
  }
  my $cmd = "cat \"$path\"|CmdCompressedPixBitMapToContour.pl " .
    "$c->{rows} $c->{cols} >$tmp_file_path";
  `$cmd`;
  unless(open FILE, "<$tmp_file_path"){
    print "File $c->{seg_slice_bitmap_file_id} produced no contour file\n";
    next conversion;
  }
  my($num_contours, $num_points);
  while(my $line = <FILE>){
    chomp $line;
    if($line eq "BEGIN"){
      $num_contours += 1;
    } elsif($line =~ /^[-\d\.]+, [-\d\.]+$/){
      $num_points += 1;
    }
  }
  close FILE;
  my $i_cmd = "ImportSingleFileIntoPosdaAndReturnId.pl \"$tmp_file_path\" " .
    "\"contours($c->{seg_slice_bitmap_file_id}, $c->{rows}, $c->{cols})\"";
  open CMD, "$i_cmd|";
  my($contour_file_error, $contour_file_id);
  while(my $line = <CMD>){
    chomp $line;
    if($line =~ /^File id: (.*)$/){
      $contour_file_id = $1;
    }elsif($line =~ /^Error: (.*)$/){
      $contour_file_error = $1;
    }
  }
  close CMD;
  unlink $tmp_file_path;
  if(defined $contour_file_error){
    print STDERR "Error on import of contour file into posda: $contour_file_error\n";
  }
  unless(defined $contour_file_id){
    print STDERR "Contour file didn't importinto posda\n";
    next conversion;
  }
  Query('InsertIntoSegSliceToContour')->RunQuery(sub{},sub{},
    $c->{seg_slice_bitmap_file_id}, $c->{rows}, $c->{cols},
      $num_contours, $num_points, $contour_file_id);
}

