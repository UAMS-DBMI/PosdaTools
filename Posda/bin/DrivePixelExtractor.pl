#!/usr/bin/perl -w
use strict;
my $usage = <<EOF;
DrivePixelExtractor.pl <db> <series> <dir>
EOF
open FILES, "GetPixelRenderingInfoForSeries.pl $ARGV[0] $ARGV[1]|" or
  die "Can't get pixel rendering info";
my $total = 0;
my $num_bad = 0;
line:
while(my $line = <FILES>){
  chomp $line;
  my @args = split(/\|/, $line);
  my $count = $#args;
  unless($#args == 18) {
    print STDERR "Bad line count: $count\n$line\n";
    for my $i (0 .. $#args) {
      print STDERR "$i: $args[$i]\n";
    }
    exit;
    next line;
  }
  $total += 1;
  my $file_id = $args[0];
  my $rows = $args[9];
  my $cols = $args[10];
  my $cmd1 = "ExtractPixels.pl";
  for my $i (0 .. 17){
    $cmd1 .= " \"$args[$i]\"";
  }
  $cmd1 .= " \"$ARGV[2]\"";
  open CMD1, "$cmd1|";
  my $line = <CMD1>;
  chomp $line;
  unless($line =~ /File:\s*(.*)/) { die "bad line: $line" }
  my $file = $1;
  if($file =~ /\.gray/){
    my $cmd2 = "convert -endian LSB -size ${rows}x${cols} -depth 16 $file -level 0,1000 $ARGV[2]/$file_id.png";
    `$cmd2`;
    `rm $file`;
  } else {
    my $cmd2 = "convert  -size ${rows}x${cols} -depth 8 $file $ARGV[2]/$file_id.png";
    `$cmd2`;
#    `rm $file`;
  }
  open FOO, "tesseract $ARGV[2]/$file_id.png stdout|" or die "foo";
  my $is_bad;
  while(my $line = <FOO>){
    chomp $line;
    unless($line =~ /^\s*$/){
#      print "Line: \"$line\"\n";
      unless($is_bad){
#        print "$file_id has PHI\n";
        $is_bad = 1;
        $num_bad += 1;
      }
    }
  }
  if($is_bad) { print "$file_id has PHI\n" }
  else { print "$file_id has no PHI\n"}
#  `rm $ARGV[2]/$file_id.png`;
}
if ($num_bad > 0){
  print "Series $ARGV[1] has $num_bad (of $total) images with indicated PHI\n";
} else {
  print "Series $ARGV[1] has none of $total) images with indicated PHI\n";
}
