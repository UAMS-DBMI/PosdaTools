#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/FeedContourer.pl,v $
#$Date: 2011/12/01 16:42:56 $
#$Revision: 1.2 $
#
#Copyright 2011, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

# Streamed Pixel operations
# This program accepts contours on an fd and writes a bitmap
# on another fd of the points contained within the contours
# The fd's have been opened by the parent process...

# What to do is specified on the command line.
# All of the parameters on the command line are of the form:
#  <name>=<value> (no spaces)
# parameter order does not matter.
# Here are the possible parameters:
#  in=<number of first input fd>
#  out=<number of output fd>
#  status=<number of status fd>
#
# On the input socket, the format of the contours is the following:
# BEGIN CONTOUR             - marks the beginning of a contour
# row1,col1                     - first point in contour
# row2,col2                     - next point
# ...                           - and so on
#                               -   not necessarily integer
#                               -   may be negative
# rown,coln                     - last point
# END CONTOUR
# ...                       - repeat for as many contours as you have
#
use strict;
use Posda::FlipRotate;
use Math::Polygon;

my($in, $out, $status, $name, 
   $max_x, $max_y, $max_z, $min_x, $min_y, $min_z);
my $normalizing_transform = [ ];
my $debug;
for my $i (@ARGV){
  unless($i =~ /^([^=]+)=([^=]+)$/) {
    die "$0: can't parse parameter $i";
  }
  my $key = $1;
  my $value = $2;
  if($key eq "in") { $in = $value }
  elsif ($key eq "out") { $out = $value }
  elsif ($key eq "status") { $status = $value }
  elsif ($key eq "name") { $name = $value }
  elsif ($key =~ m/^v_(\d)(\d)$/) {
     $normalizing_transform->[$1]->[$2] = $value;
  }
  else { die "$0: unknown parameter: $key" }
}
unless(defined $in) { die "$0: in is not defined" }
unless(defined $out) { die "$0: out is not defined" }
unless(defined $status) { die "$0: status is not defined" }
unless(defined $name) { die "$0: name is not defined" }
for my $i (0 .. 3) {
  for my $j (0 .. 3) {
    unless(defined $normalizing_transform->[$i]->[$j]) 
       { die "$0: normalizing_transform->[$i]->[$j] is not defined" }
  }
}
# print "$0: Starting contoure: $name.\n";

if($debug){
  print "$0: DEBUG\n";
}

open(INPUT, "<&", $in) or die "$0: Can't open in = $in ($!)";
open(OUTPUT, ">&", $out) or die "$0: Can't open out = $out ($!)";

#print "$0:\n\trows: $rows, cols: $cols, ul: ($ulx, $uly, $ulz) " .
#  "spc: ($rowspc, $colspc)\n";
while(my $line = <INPUT>){
  chomp $line;
  unless ($line =~ m/^\s*(.*)\s*,\s*(.*)\s*$/) { next line; }
  my $file = $1;
  my $off = $2;
  if ($file eq "") {
    print OUTPUT "BEGIN CONTOUR at $off\n";
    print OUTPUT "END CONTOUR\n";
    next line;
  }
  print OUTPUT "BEGIN CONTOUR at $off\n";
  open my $cont, "<$file" or die "can't open $file";
  line:
  while (my $line = <$cont>){
    my @nums = split(/\\/, $line);
    my $num_nums = @nums;
    unless(($num_nums % 3) == 0){
      print STDERR "$off: line doesn't contain multiple of 3 nums\n";
      next line;
    }
    my @points_2d;
    my $point_count = $num_nums / 3;
    for my $i (0 .. ($num_nums / 3) - 1){
      my $point_3d = Posda::Transforms::ApplyTransform(
        $normalizing_transform,
        [$nums[$i * 3], $nums[($i * 3)+1], $nums[($i * 3)+2]]);
      push(@points_2d, [$point_3d->[0], $point_3d->[1]]);
    }
    for my $i (0 .. $#points_2d){
      print OUTPUT "$points_2d[$i]->[0]\\$points_2d[$i]->[1]";
      unless($i == $#points_2d) { print OUTPUT "\\" }
    }
    print OUTPUT "\n";
  }
  print OUTPUT "END CONTOUR\n";
}
close OUTPUT;
close INPUT;
if(defined $status){
  open(STATUS, ">&", $status) or die "$0: Can't open status = $status ($!)";
  print STATUS "OK\n";
  close STATUS;
}
# print "$0: done with contoure: $name.\n";
1

