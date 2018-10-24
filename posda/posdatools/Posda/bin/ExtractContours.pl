#!/usr/bin/perl -w
#
use strict;
use Digest::MD5;
use Posda::Try;
my $usage = "ExtractContours.pl <file> <base_dir>";
unless($#ARGV == 1) { die $usage }
my $file = $ARGV[0];
my $contour_dir = $ARGV[1];
my $try = Posda::Try->new($file);
unless(exists $try->{dataset}) { die "$file isn't a DICOM file" }
my @results;
my $rl = $try->{dataset}->Search("(3006,0039)[<0>](3006,0084)");
my $c_id = 0;
for my $r (@$rl){
  my $roi_i = $r->[0];
  my $roi_num = $try->{dataset}->Get("(3006,0039)[$roi_i](3006,0084)");
  my $m = $try->{dataset}->Search(
    "(3006,0039)[$roi_i](3006,0040)[<0>](3006,0016)[0](0008,1155)");
  for my $i (@$m){
    $c_id += 1;
    my $ct_sop =
      $try->{dataset}->Get(
        "(3006,0039)[$roi_i](3006,0040)[$i->[0]]" .
        "(3006,0016)[0](0008,1155)");
    my $contour = $try->{dataset}->Get(
      "(3006,0039)[$roi_i](3006,0040)[$i->[0]](3006,0050)");
    my $num_pts = $try->{dataset}->Get(
      "(3006,0039)[$roi_i](3006,0040)[$i->[0]](3006,0046)");
    if(defined($contour) && ref($contour) eq "ARRAY"){
      my $bfn = "$try->{digest}_${roi_num}_$c_id.contour";
      my $str_dir = "$contour_dir/" . substr($bfn,0,1) . "/" .
                       substr($bfn,1,1) . "/" . $try->{digest};
      unless(-d $str_dir){
        my $count = mkdir($str_dir);
        unless($count == 1) { die "bad mkdir: $str_dir" }
        chmod 0775, $str_dir;
      }
      unless(-d $str_dir) { die "bad state dir: $str_dir" }
      my $ffn = "$str_dir/$bfn";
      if(open FOO, ">$ffn"){
        push @results, [$ct_sop, $roi_num, $ffn];
#          push(@{$analysis->{structs_by_ct}->{$ct_sop}->{$roi_num}}, $ffn);
        print FOO join("\\", @$contour);
        close FOO;
        chmod 0664, "$ffn";
      } else {
        push @results, [$ct_sop, $roi_num, "couldn't open $ffn - $!"];
#          push(@{$analysis->{structs_by_ct}->{$ct_sop}->{$roi_num}},
#            "couldn't open $ffn - $!");
      }
    }
  }
}
for my $i (@results){
  print "$i->[0]|$i->[1]|$i->[2]\n";
}

