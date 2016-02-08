#!/usr/bin/perl -w
#
use strict;
use JSON::PP;
use Storable qw( store_fd fd_retrieve );
use Posda::FlipRotate;
use Debug;
$| = 1;
my $dbg = sub {print STDERR @_ };
my $to_do = fd_retrieve(\*STDIN);
my @Contours;
unless(ref($to_do) eq "HASH"){
  die "Instructions are not a hash";
}
my $struct_set = $to_do->{struct_set};
my $norm_iop = $to_do->{norm_iop};
my $norm_x = $to_do->{norm_x};
my $norm_y = $to_do->{norm_y};
my $norm_z = $to_do->{norm_z};
my $rows = $to_do->{rows};
my $cols = $to_do->{cols};
my $pix_sp = $to_do->{pix_sp};
my $offset = $to_do->{offset};
my $length = $to_do->{length};
my $num_points = $to_do->{num_pts};
my $file = $to_do->{file_name};
my @iop;
($iop[0],$iop[1],$iop[2],$iop[3],$iop[4],$iop[5]) = split(/\\/, $norm_iop);
my @pix_sp = split(/\\/, $pix_sp);
my $ipp = [$norm_x, $norm_y, $norm_z];
open my $fh, "<$struct_set" 
  or die "ConstructRoiContour.pl: Can't open <$struct_set ($!)";
seek($fh, $offset, 0);
my $buff;
unless(defined($length)) { $length = 0 }
if($length) {
  my $count = read($fh, $buff, $length);
  unless($count == $length){
    die "ContourConstructor.pl: Read wrong length ($count vs " .
      "$length} at $offset in $struct_set";
  }
} else { $buff = "" }
close $fh;
my @floats = split(/\\/, $buff);
my $nrf = @floats;
if($nrf == 0){
  print "Wrote (empty) contour to $file\n";
  open $fh, ">$file" or die "can't open >$file";
  close $fh;
  exit(0);
}
unless(($nrf % 3) == 0){
  die "ContourConstructor.pl: Number of floats ($nrf) % 3 non-zero " .
    "at $offset in $struct_set";
}
my @points;
my $max_dist = 0;
my $num_pts = int $nrf / 3;
unless($num_pts == $num_points){
  die "Wrong number of points";
}
for my $i (0 .. $num_pts - 1){
  my $pt = [$floats[$i*3], $floats[($i*3)+1], $floats[($i*3)+2]];
  my $pix_pt = Posda::FlipRotate::ToPixCoords(
    \@iop, $ipp, $rows, $cols, \@pix_sp, $pt);
  my $dist = abs($pix_pt->[2] - $ipp->[2]);
  if($dist > $max_dist) { $max_dist = $dist }
  push(@points, $pix_pt);
}
unless(
  $points[$#points]->[0] == $points[0]->[0] &&
  $points[$#points]->[1] == $points[0]->[1]
){
  push(@points, $points[0]);
}
open $fh, ">$file" or die "Can't open >$file ($1)";
for my $i (0 .. $#points){
  print $fh "$points[$i]->[0]\\$points[$i]->[1]";
  unless($i == $#points) { print $fh "\\" }
}
close $fh;
print "Wrote contour to $file\n";
exit(0);
