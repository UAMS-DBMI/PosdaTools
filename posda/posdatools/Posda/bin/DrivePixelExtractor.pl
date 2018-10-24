#!/usr/bin/perl -w
# TODO TODO  TODO TODO  TODO TODO  TODO TODO  TODO TODO  TODO TODO 
# Rename this to something else, don't commit with this name!
# TODO TODO  TODO TODO  TODO TODO  TODO TODO  TODO TODO  TODO TODO 
use Modern::Perl;

my $usage = <<EOF;
DrivePixelExtractor.pl <series> <dir>
EOF

my $series = $ARGV[0];
my $output_dir = $ARGV[1];

open FILES, "GetPixelRenderingInfoForSeries.pl junk $series|" or
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
  $cmd1 .= " \"$output_dir\"";

  open CMD1, "$cmd1|";
  my $line = <CMD1>;

  chomp $line;
  unless($line =~ /File:\s*(.*)/) { die "bad line: $line" }
  my $file = $1;
  if($file =~ /\.gray/){
    my $cmd2 = "convert -endian LSB -size ${rows}x${cols} -depth 16 $file -level 0,1000 $output_dir/$file_id.png";
    `$cmd2`;
    `rm $file`;
  } else {
    my $cmd2 = "convert  -size ${rows}x${cols} -depth 8 $file $output_dir/$file_id.png";
    `$cmd2`;
     `rm $file`;
  }
  # open FOO, "tesseract $output_dir/$file_id.png stdout|" or die "foo";
  # my $is_bad;
  # while(my $line = <FOO>){
  #   chomp $line;
  #   unless($line =~ /^\s*$/){
# #      print "Line: \"$line\"\n";
  #     unless($is_bad){
# #        print "$file_id has PHI\n";
  #       $is_bad = 1;
  #       $num_bad += 1;
  #     }
  #   }
  # }
  # if($is_bad) { print "$file_id has PHI\n" }
  # else { print "$file_id has no PHI\n"}
#  `rm $output_dir/$file_id.png`;
}
# if ($num_bad > 0){
#   print "Series $series has $num_bad (of $total) images with indicated PHI\n";
# } else {
#   print "Series $series has none of $total) images with indicated PHI\n";
# }
