#!/usr/bin/perl -w
use strict;
use Posda::DB qw( Query );
use File::Temp qw/ tempfile /;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
$| = 1; # this should probably be at the top of the script, maybe in the lib?

my $usage = <<EOF;
PopulateSegBitmaps.pl <bkgrnd_id> <notify>
  or
PopulateSegBitmaps.pl -h
Expects no lines on STDIN.

Finds all rows in seg_slice_bitmap_file with some bits which don't have a
rendered png, renders the png, and imports into posda.
EOF

unless($#ARGV == 1) { print $usage; exit }
my($invoc_id, $notify) = @ARGV;
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->Daemonize;

$background->WriteToEmail("Processing Seg Bitmaps...\n");


my $gpath = Query("GetFilePath");
my $ins_png = Query("AddPngToSegSliceBitmap");
Query("SegSliceBitmapsWithoutPng")->RunQuery(sub{
  my($row) = @_;
  my($seg_bitmap_file_id,
    $seg_slice_bitmap_file_id,
    $rows,
    $cols
  ) = @$row;
  my($pbm_path, $png_path);
  {
    my($pbm_fhs, $png_fhs);
    ($pbm_fhs, $pbm_path) = tempfile();
    ($png_fhs, $png_path) = tempfile();
    $png_path = "$png_path.png";
    $pbm_path = "$pbm_path.pbm";
  }
  my $cbm_path;
  $gpath->RunQuery(sub {
    my($row) = @_;
    $cbm_path = $row->[0];
  }, sub {}, $seg_slice_bitmap_file_id);
  if(defined $cbm_path){
    my $cmd = "cat $cbm_path|CmdCtoPbm.pl rows=$rows cols=$cols >$pbm_path";
    `$cmd`;
    $cmd = "convert $pbm_path $png_path";
    `$cmd`;
    $cmd = "ImportSingleFileIntoPosdaAndReturnId.pl $png_path 'Extracted Segmenation'";
    my $res = `$cmd`;
    my $png_file_id;
    if($res =~ /File id: (.*)/){
      $png_file_id = $1;
      $ins_png->RunQuery(sub{
      }, sub {}, $png_file_id, $seg_slice_bitmap_file_id);
      print "inserted png ($png_file_id) for slice_bitmap " .
        "($seg_slice_bitmap_file_id)\n";
    } else {
      print STDERR "Couldn't insert png_file into Posda\n";
    }
  } else {
    print STDERR "Found no path for slice_bitmap: $seg_slice_bitmap_file_id\n";
  }
  unlink $pbm_path;
  unlink $png_path;
}, sub{});


$background->Finish;
