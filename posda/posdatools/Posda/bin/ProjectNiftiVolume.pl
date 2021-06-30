#!/usr/bin/perl -w
use strict;
use Cwd;
use Nifti::Parser;
use Debug;
my $dbg = sub { print @_ };
my $dir = getcwd;
my $usage = <<EOF;
ProjectNiftiVolume.pl <file_id> <file_name> <vol> <to_dir>
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 3){
  my $num_args = @ARGV;
  die "Wrong number args ($num_args vs 4)\n$usage";
}
my($file_id, $file, $v, $to_dir) = @ARGV;
unless ($file =~ /^\//){
  $file = "$dir/$file";
}
my $nifti = Nifti::Parser->new($file);
my($rows, $cols, $depth) = $nifti->RowsColsAndBytes;
my $gray_avg = "$to_dir/nifti_$file_id" . "_$v" . "_p_avg.gray";
my $gray_min = "$to_dir/nifti_$file_id" . "_$v" . "_p_min.gray";
my $gray_max = "$to_dir/nifti_$file_id" . "_$v" . "_p_max.gray";
my $jpeg_avg = "$to_dir/nifti_$file_id" . "_$v" . "_p_avg.jpeg";
my $jpeg_min = "$to_dir/nifti_$file_id" . "_$v" . "_p_min.jpeg";
my $jpeg_max = "$to_dir/nifti_$file_id" . "_$v" . "_p_max.jpeg";
open FILE, ">$gray_avg" or die "Can't open $gray_avg ($!0)";
open FILE1, ">$gray_min" or die "Can't open $gray_min ($!0)";
open FILE2, ">$gray_max" or die "Can't open $gray_max($!0)";
$nifti->PrintNormalizedVolumeProjections($v, \*FILE, \*FILE1, \*FILE2);
close FILE;
close FILE1;
close FILE2;
my $cmd1 = "convert -endian MSB -size $rows" . 'x' . "$cols " .
  "-depth 8 $gray_avg $jpeg_avg";
my $cmd2 = "convert -endian MSB -size $rows" . 'x' . "$cols " .
  "-depth 8 $gray_max $jpeg_max";
my $cmd3 = "convert -endian MSB -size $rows" . 'x' . "$cols " .
  "-depth 8 $gray_min $jpeg_min";
`$cmd1`;
`$cmd2`;
`$cmd3`;
unlink $gray_avg;
unlink $gray_max;
unlink $gray_min;
print "Jpeg avg: $jpeg_avg\n";
print "Jpeg max: $jpeg_max\n";
print "Jpeg min: $jpeg_min\n";
