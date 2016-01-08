#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/CompressContours.pl,v $
#$Date: 2011/06/23 15:31:26 $
#$Revision: 1.2 $

#use Cwd;
use strict;
use Posda::Dataset;
use VectorMath;

Posda::Dataset::InitDD();

#unless($#ARGV == 0) { die "usage: $0 <file>\n" }
my $file = $ARGV[0];
#unless($file=~/^\//){$file=getcwd."/$file"}
my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($file);
unless($ds) { die "$file is not a DICOM file" }
my $modality = $ds->Get("(0008,0060)");
unless($modality eq "RTSTRUCT"){ die "$file is not an RTSTRUCT" }
my($list) = $ds->Search("(3006,0039)[<0>](3006,0040)[<1>](3006,0046)");
my $modified = 0;
for my $match (@$list){
  my $rn = $match->[0];
  my $cn = $match->[1];
  my $nc = $ds->Get("(3006,0039)[$rn](3006,0040)[$cn](3006,0046)");
  my $cnts = $ds->Get("(3006,0039)[$rn](3006,0040)[$cn](3006,0050)");
  unless((scalar @$cnts) % 3 == 0) {
    die "(3006,0039)[$rn](3006,0040)[$cn](3006,0050) has $cnts floats " .
      "(not divisible by 3)";
  }
  my $calc_nc = int ((scalar @$cnts) / 3) ;
  unless ($nc == $calc_nc) {
    die "(3006,0039)[$rn](3006,0040)[$cn](3006,0050) " .
      "number of points doesn't match contour data"
  }
  my $new_c = CompressContours($cnts);
  if((scalar @$new_c) < (scalar @$cnts)){
    $modified = 1;
    my $before = scalar @$cnts;
    my $after = scalar @$new_c;
#    print "(3006,0039)[$rn](3006,0040)[$cn](3006,0050) goes from $before" .
#      " to $after floats\n";
    my $new_np = int($after / 3);
    $ds->Insert("(3006,0039)[$rn](3006,0040)[$cn](3006,0046)", $new_np);
    $ds->Insert("(3006,0039)[$rn](3006,0040)[$cn](3006,0050)", $new_c);
  }
}
if($modified){
  $ds->WritePart10("$file.new", $xfr_stx, "POSDA", undef, undef);
}
sub CompressContours{
  my($cnts) = @_;
  my @new_cnts;
  my $n_pts = int((scalar @$cnts) / 3);
  unless($n_pts > 3) { return $cnts }
  push @new_cnts, $cnts->[0];
  push @new_cnts, $cnts->[1];
  push @new_cnts, $cnts->[2];
  my $prior_point = 0;
  my $cur_point = 1;
  my $next_point = 2;
  outer:
  while($cur_point != 0){
    inner:
    while(CheckCollinear($cnts, $prior_point, $cur_point, $next_point)){
      $cur_point += 1;
      if($cur_point == $n_pts) { $cur_point = 0 }
      $next_point += 1;
      if($next_point == $n_pts) { $next_point = 0 }
      if($cur_point == 0) { last inner }
    }
    unless($cur_point == 0){
      push @new_cnts, $cnts->[($cur_point * 3)];
      push @new_cnts, $cnts->[($cur_point * 3) + 1];
      push @new_cnts, $cnts->[($cur_point * 3) + 2];
      $prior_point = $cur_point;
      $cur_point = $next_point;
      $next_point = $cur_point + 1;
      if($next_point == $n_pts) { $next_point = 0 }
    }
  }
  return \@new_cnts;
}
sub CheckCollinear{
  my($cnts, $p, $c, $n) = @_;
  my $pp = [$cnts->[($p * 3)], $cnts->[($p * 3) + 1],
    $cnts->[($p * 3) + 2]];
  my $cp = [$cnts->[($c * 3)], $cnts->[($c * 3) + 1],
    $cnts->[($c * 3) + 2]];
  my $np = [$cnts->[($n * 3)], $cnts->[($n * 3) + 1],
    $cnts->[($n * 3) + 2]];
  return VectorMath::Collinear($pp, $cp, $np);
}
