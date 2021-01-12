#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use File::Temp qw/ tempfile /;

use Debug;
my $dbg = sub { print STDERR @_ };

my $usage = <<EOF;
PopulateSegSliceToContour.pl  <rows> <cols> <seg_slice_bitmap_file_id>


EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 2) { die "wrong # args $#ARGV vs 2:\n$usage" }
my ($rows, $cols, $seg_slice_bitmap_file_id) = @ARGV;

my $q = Query('GetFilePath');
my $path;
$q->RunQuery(sub {
  my($row) = @_;
  $path = $row->[0];
}, sub{}, $seg_slice_bitmap_file_id);
my $tmp_file_path;
{
  my $t_fhs;
  ($t_fhs, $tmp_file_path) = tempfile();
}
unless(defined $path) {
  die "File $seg_slice_bitmap_file_id: path not found in db";
}
my $cmd = "cat \"$path\"|CmdCompressedPixBitMapToContour.pl " .
  "$rows $cols >$tmp_file_path";
print STDERR "Command: $cmd\n";
`$cmd`;
unless(open FILE, "<$tmp_file_path"){
  die "File $seg_slice_bitmap_file_id produced no contour file";
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
  "\"contours($seg_slice_bitmap_file_id, $rows, $cols)\"";
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
if(defined $contour_file_error){
  print STDERR "Error on import of contour file into posda: $contour_file_error\n";
}
unless(defined $contour_file_id){
  die "Contour file didn't import into posda\n";
}
Query('InsertIntoSegSliceToContour')->RunQuery(sub{},sub{},
  $seg_slice_bitmap_file_id, $rows, $cols,
  $num_contours, $num_points, $contour_file_id);
