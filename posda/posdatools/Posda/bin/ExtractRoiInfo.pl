#!/usr/bin/perl -w
#
use strict;
use Digest::MD5;
use Posda::Try;
my $usage = "ExtractRoiInfo.pl <file>";
my $file = shift @ARGV;
my $try = Posda::Try->new($file);
unless(exists $try->{dataset}) { die "$file isn't a DICOM file" }
my $ds = $try->{dataset};
my $m = $ds->Search("(3006,0020)[<0>](3006,0022)");
my %Roi;
for my $i (@$m){
  my $roi_num = $ds->Get("(3006,0020)[$i->[0]](3006,0022)");
  my $ref_for = $ds->Get("(3006,0020)[$i->[0]](3006,0024)");
  my $roi_name = $ds->Get("(3006,0020)[$i->[0]](3006,0026)");
  my $roi_alg = $ds->Get("(3006,0020)[$i->[0]](3006,0036)");
  $Roi{$roi_num} = {
    roi_num => $roi_num,
    ref_for => $ref_for,
    roi_name => $roi_name,
    gen_alg => $roi_alg,
  };
  print "$roi_num|roi_num|$roi_num\n";
  print "$roi_num|ref_for|$ref_for\n";
  print "$roi_num|roi_name|$roi_name\n";
  print "$roi_num|gen_alg|$roi_alg\n";
}
$m = $ds->Search("(3006,0080)[<0>](3006,0084)");
observ:
for my $i (@$m){
  my $roi_num = $ds->Get("(3006,0080)[$i->[0]](3006,0084)");
  unless(defined $roi_num) { next observ }
  my $roi_obser_label = $ds->Get("(3006,0080)[$i->[0]](3006,0085)");
  if(defined $roi_obser_label) {
    print "$roi_num|roi_obser_label|$roi_obser_label\n";
  }
  my $roi_obser_desc = $ds->Get("(3006,0080)[$i->[0]](3006,0085)");
  if(defined $roi_obser_desc) {
    print "$roi_num|roi_obser_desc|$roi_obser_desc\n";
  }
  my $roi_interpreted_type = $ds->Get("(3006,0080)[$i->[0]](3006,00A4)");
  unless(defined $roi_interpreted_type) { $roi_interpreted_type = "" }
  print "$roi_num|roi_interpreted_type|$roi_interpreted_type\n";
}
for my $i (keys %Roi){
  my $tot_points = 0;
  my $tot_contours = 0;
  my %contour_types;
  my @sop_refs;
  my $color;
  my ($max_x, $min_x, $max_y, $min_y, $max_z, $min_z);
  $m = $ds->Search("(3006,0039)[<0>](3006,0084)", $i);
  for my $j (@$m){
    $color = $ds->Get("(3006,0039)[$j->[0]](3006,002a)");
    if (defined $color) {
      for my $j (0 .. $#{$color}){
        print "$i|color|$j|$color->[$j]\n";
      }
    }
    my $m1 = $ds->Search("(3006,0039)[$j->[0]](3006,0040)[<0>](3006,0050)");
    for my $k (@$m1){
      my $type = $ds->Get(
        "(3006,0039)[$j->[0]](3006,0040)[$k->[0]](3006,0042)");
      my $num_pts = $ds->Get(
        "(3006,0039)[$j->[0]](3006,0040)[$k->[0]](3006,0046)");
      my $data = $ds->Get(
        "(3006,0039)[$j->[0]](3006,0040)[$k->[0]](3006,0050)");
      my $ref = $ds->Get(
        "(3006,0039)[$j->[0]](3006,0040)[$k->[0]](3006,0016)[0](0008,1155)");
      $tot_contours += 1;
      $tot_points += $num_pts;
      $contour_types{$type} += 1;
      if(defined $ref){ push @sop_refs, $ref }
      for my $n (0 .. $num_pts - 1){
        my $xi = ($n * 3);
        my $yi = ($n * 3) + 1;
        my $zi = ($n * 3) + 2;
        my $x = $data->[$xi];
        my $y = $data->[$yi];
        my $z = $data->[$zi];
        unless(defined $max_x) {$max_x = $x}
        unless(defined $min_x) {$min_x = $x}
        unless(defined $max_y) {$max_y = $y}
        unless(defined $min_y) {$min_y = $y}
        unless(defined $max_z) {$max_z = $z}
        unless(defined $min_z) {$min_z = $z}
        if($x > $max_x) {$max_x = $x}
        if($x < $min_x) {$min_x = $x}
        if($y > $max_y) {$max_y = $y}
        if($y < $min_y) {$min_y = $y}
        if($z > $max_z) {$max_z = $z}
        if($z < $min_z) {$min_z = $z}
      }
    }
  }
  print "$i|tot_points|$tot_points\n";
  print "$i|tot_contours|$tot_contours\n";
  for my $j (keys %contour_types){
    print"$i|contour_types|$j|$contour_types{$j}\n";
  }
  for my $j (0 .. $#sop_refs){
    print "$i|sop_refs|$j|$sop_refs[$j]\n";
  }
  if ($tot_points > 2) {
    print "$i|max_x|$max_x\n";
    print "$i|min_x|$min_x\n";
    print "$i|max_y|$max_y\n";
    print "$i|min_y|$min_y\n";
    print "$i|max_z|$max_z\n";
    print "$i|min_z|$min_z\n";
  }
}

