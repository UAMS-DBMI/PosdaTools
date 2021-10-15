#!/usr/bin/perl -w
use strict;
use Cwd;
use Nifti::Parser;
use Debug;
my $dbg = sub { print @_ };
my $dir = getcwd;
my $usage = <<EOF;
ExtractNiftiSlice.pl <file_id> <file> <vol> <slice> <f> <to_file_dir>
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 5){
  my $num_args = @ARGV;
  die "Wrong number args ($num_args vs 6)\n$usage";
}
my($file_id, $file,$v, $s, $f, $to_dir) = @ARGV;
unless ($file =~ /^\//){
  $file = "$dir/$file";
}
my $nifti;
$nifti = Nifti::Parser->new($file, $file_id);
#my($dig, $max, $min) = $nifti->SliceDigest($v, $s);
my $to_root = "nifti_$file_id" . "_$v" . "_$s";
if($f eq "f"){
  $to_root .= "_f";
} else {
  $to_root .= "_n";
}
if($nifti->{parsed}->{datatype} == 128){
  my $rgb_file = "$to_dir/$to_root.rgb";
  my $jpeg_file = "$to_dir/$to_root.jpeg";
  print "RGB: $rgb_file\n";
  print "Jpeg: $jpeg_file\n";
  unless(open OUT, ">$rgb_file"){
    die "Can't open $rgb_file for write ($!)";
  }
  if($f eq "f"){
    $nifti->PrintRgbSliceFlipped($v, $s, *OUT);
  } else {
    $nifti->PrintRgbSlice($v, $s, *OUT);
  }
  close OUT;
  my($rows,$cols,$bytes) = $nifti->RowsColsAndBytes;
  my $cmd = "convert -endian MSB -size $rows" . 'x' . "$cols " .
    "-depth 8 rgb:$rgb_file $jpeg_file";
  `$cmd`;
  print "Convert:\n$cmd\n";
#  unlink $rgb_file;
  exit;
}
my $gray_file = "$to_dir/$to_root.gray";
my $jpeg_file = "$to_dir/$to_root.jpeg";
print "Gray: $gray_file\n";
print "Jpeg: $jpeg_file\n";
unless(open OUT, ">$gray_file"){
  die "Can't open $gray_file for write ($!)";
}
if($f eq "f"){
  $nifti->PrintSliceFlippedScaled($v, $s, *OUT);
} else {
  $nifti->PrintSliceScaled($v, $s, *OUT);
}
close OUT;
my($rows,$cols,$bytes) = $nifti->RowsColsAndBytes;
my $cmd = "convert -endian MSB -size $rows" . 'x' . "$cols " .
  "-depth 8 gray:$gray_file $jpeg_file";
`$cmd`;
print "Convert:\n$cmd\n";
unlink $gray_file;
