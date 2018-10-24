#!/usr/bin/perl -w
use strict;
my $usage = <<EOF;
ExtractPixelsFromDupSops.pl <db> <sop> <dir>
EOF
unless($#ARGV == 2) { die $usage }
unless(-d $ARGV[2]) { die "$ARGV[2] is not a directory\n" }
open FILES, "GetPixelRenderingInfoForDupSops.pl $ARGV[0] $ARGV[1]|" or
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
  my $width = $args[16];
  my $level = $args[17];
  my $black = 0;
  my $white = 1000;
  if(
    defined($width) && defined($level) &&
    $width ne "" && $level ne ""
  ){
    $black = ($level + 1000) - ($width/2);
    $white = ($level + 1000) + ($width/2);
  }
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
    my $cmd2 = "convert -endian LSB -size ${rows}x${cols} -depth 16 $file -level $black,$white $ARGV[2]/$file_id.png";
    `$cmd2`;
#    `rm $file`;
  } else {
    my $cmd2 = "convert  -size ${rows}x${cols} -depth 8 $file $ARGV[2]/$file_id.png";
    `$cmd2`;
#    `rm $file`;
  }
  print "$ARGV[2]/$file_id.png\n";
}
