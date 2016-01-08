#!/usr/bin/perl -w 
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/CalculateBinWidth.pl,v $
#$Date: 2011/03/22 14:03:25 $
#$Revision: 1.1 $
use strict;
use Posda::Try;
my $file = $ARGV[0];
my $try = Posda::Try->new($file);
unless(exists $try->{dataset}) { die "$file isn't a DICOM file" }
my $ds = $try->{dataset};
my %bin_widths;
my $m = $ds->Search("(3004,0050)[<0>](3004,0056)");
my $total_bins = 0;
for my $i (@$m){
  my $index = $i->[0];
  my $num_bins = $ds->Get("(3004,0050)[$index](3004,0056)");
  print "num_bins: $num_bins\n";
  $total_bins += $num_bins;
  my $data = $ds->Get("(3004,0050)[$index](3004,0058)");
  unless(scalar(@$data) eq ($num_bins * 2)){
    my $num_nums = scalar @$data;
    print STDERR "Index $index has $num_bins bins, but $num_nums numbers\n";
  }
  for my $j (1 .. $num_bins){
    my $bindex = ($j - 1) * 2;
    $bin_widths{$data->[$bindex]} += 1;
  }
}
print "total bins: $total_bins\n";
for my $i (keys %bin_widths){
  print "bin_width: $i, count $bin_widths{$i}\n";
}
