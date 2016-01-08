#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/GradientAt.pl,v $
#$Date: 2013/01/30 21:25:55 $
#$Revision: 1.1 $

use Cwd;
use strict;
use Posda::Dataset;
use Posda::FlipRotate;

Posda::Dataset::InitDD();

unless($#ARGV == 3) { die "usage: $0 <file> <x> <y> <z>\n" }
my $file = $ARGV[0]; unless($file=~/^\//){$file=getcwd."/$file"}
my $x = $ARGV[1];
my $y = $ARGV[2];
my $z = $ARGV[3];

my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($file);
unless($ds) { die "$file is not a DICOM file" }

# Get the information we'll use:
my $bits_a = $ds->Get("(0028,0100)");
my $bits_s = $ds->Get("(0028,0101)");
my $pix_rep = $ds->Get("(0028,0103)");
my $num_frames = $ds->Get("(0028,0008)");
my $iop = $ds->Get("(0020,0037)");
my $ipp = $ds->Get("(0020,0032)");
my $rows = $ds->Get("(0028,0010)");
my $cols = $ds->Get("(0028,0011)");
my $pix_sp = $ds->Get("(0028,0030)");
my $gfov = $ds->Get("(3004,000c)");
my $scaling = $ds->Get("(3004,000e)");
my $units = $ds->Get("(3004,0002)");
my $type = $ds->Get("(3004,000a)");
my $pix_data = $ds->Get("(7fe0,0010)");

unless($pix_rep == 0) { die "only unsigned need apply" }
my $words = 1;
unless($bits_a == 16 && $bits_s == 16) { 
  unless($bits_a == 32 && $bits_s == 32){
    die "only unsigned short or long need apply" 
  }
  if($bits_a == 32){ $words = 2 }
}
my $normal = VectorMath::cross(
  [$iop->[0], $iop->[1], $iop->[2]],
  [$iop->[3], $iop->[4], $iop->[5]]
);
unless(
  $xfr_stx eq "1.2.840.10008.1.2" || $xfr_stx eq "1.2.840.10008.1.2.1"
){ die "only little endian non-compressed xfer_syntaxes" }
unless(Posda::Dataset::NativeMoto == 0) { die "we only run on LE machines" }
my $point = [$x, $y, $z];
my $pix_coords = 
  Posda::FlipRotate::ToPixCoords($iop, $ipp, $rows, $cols, $pix_sp, $point);
my $pix_x = $pix_coords->[0];  # Actually Pix coords
my $pix_y = $pix_coords->[1];  # Actually Pix coords
my $off_z = $pix_coords->[2];  # Still in offset mm from ipp
#print "pix_y: $pix_y pix_x: $pix_x off_z: $off_z\n";
unless($pix_x >= 0 && $pix_x <= $cols - 1) {
  die "point is not in an interpolable column"
}
my $start_col = int($pix_x);
my $col_frac = $pix_x - $start_col;
#print "col_frac: $col_frac\n";
unless($pix_y >= 0 && $pix_y <= $rows - 1) {
  die "point is not in an interpolable row"
}
my $start_row = int($pix_y);
my $row_frac = $pix_y - $start_row;
#print "row_frac: $row_frac\n";
my $end_col = $start_col + 1;
my $end_row = $start_row + 1;
my @slice_dist;
for my $dist (@$gfov){
  push @slice_dist, $dist;
}
my $act_num_frames = scalar @slice_dist;
unless($num_frames == $act_num_frames) {
  die "gfov doesn't match num_frames $num_frames vs $act_num_frames"
}
unless($slice_dist[0] == 0){
  die "gfov doesn't look very clueful"
}
my $frame_frac;
my $start_frame;
my $end_frame;
for my $i (0 .. $#slice_dist - 1){
  if(
     $slice_dist[$i] <= $off_z && $off_z <= $slice_dist[$i+1] ||
     $slice_dist[$i + 1] < $off_z && $off_z <= $slice_dist[$i]
  ){
    if($slice_dist[$#slice_dist] < 0){
      $end_frame = $i;
      $start_frame = $i + 1;
    } else{
      $start_frame = $i;
      $end_frame = $i + 1;
    }
    $frame_frac = ($off_z - $slice_dist[$start_frame]) / 
      ($slice_dist[$end_frame] - $slice_dist[$start_frame]);
#print "off_z: $off_z\n";
#print "start_frame: $start_frame\n";
#print "end_frame: $end_frame\n";
#print "slice_dist[$start_frame] = $slice_dist[$start_frame]\n";
#print "slice_dist[$end_frame] = $slice_dist[$end_frame]\n";
#print "Frame_frac: $frame_frac\n";
    last;
  }
  #print "$off_z not between $slice_dist[$i] and $slice_dist[$i + 1]\n";
}
unless(defined $frame_frac) { die "not in a frame" }
#print "interpolate $frame_frac from frame $start_frame to $end_frame\n";
#print "interpolate $row_frac from row $start_row to $end_row\n";
#print "interpolate $col_frac from col $start_col to $end_col\n";
#print "Rows: $rows\n";
#print "Cols: $cols\n";
my $b_p_row = $cols * 2 * $words;
my $b_p_frame = $rows * $cols * 2 * $words;
#print "Bytes/row: $b_p_row\n";
#print "Bytes/frame: $b_p_frame\n";
my $tot_bytes = $b_p_frame * $num_frames;
my $length_of_pix = length $pix_data;
unless($tot_bytes == $length_of_pix){
  die "total bytes ($tot_bytes) != length_of_pix ($length_of_pix)"
}
#my $start_z = $ipp->[2];
#my $end_z = $start_z + ($slice_dist[$#slice_dist]);
my $p1_ind = ($start_frame * $b_p_frame) +
  ($start_row * $b_p_row) + ($start_col * 2 * $words);
my $p2_ind = ($end_frame * $b_p_frame) +
  ($start_row * $b_p_row) + ($start_col * 2 * $words);
my $p3_ind = ($start_frame * $b_p_frame) +
  ($end_row * $b_p_row) + ($start_col * 2 * $words);
my $p4_ind = ($end_frame * $b_p_frame) +
  ($end_row * $b_p_row) + ($start_col * 2 * $words);
my $p5_ind = ($start_frame * $b_p_frame) +
  ($start_row * $b_p_row) + ($end_col * 2 * $words);
my $p6_ind = ($end_frame * $b_p_frame) +
  ($start_row * $b_p_row) + ($end_col * 2 * $words);
my $p7_ind = ($start_frame * $b_p_frame) +
  ($end_row * $b_p_row) + ($end_col * 2 * $words);
my $p8_ind = ($end_frame * $b_p_frame) +
  ($end_row * $b_p_row) + ($end_col * 2 * $words);

#printf 'p1 index: %d (0x%04x) ' .
#  "($start_row, $start_col, $start_frame)" . ' %d' .
#  "\n", $p1_ind, $p1_ind, ($start_row * $cols) + $start_col;
#printf 'p2 index: %d (0x%04x) ' .
#  "($start_row, $start_col, $end_frame)\n", $p2_ind, $p2_ind;
#printf 'p3 index: %d (0x%04x) ' .
#  "($start_row, $end_col, $start_frame)" . ' %d' . "\n", 
#  $p3_ind, $p3_ind, ($end_row * $cols) + $start_col;
#printf 'p4 index: %d (0x%04x) ' .
#  "($start_row, $end_col, $end_frame)\n", $p4_ind, $p4_ind;
#printf 'p5 index: %d (0x%04x) ' .
#  "($end_row, $start_col, $start_frame)" . ' %d' . "\n", 
#  $p5_ind, $p5_ind, ($start_row * $cols) + $end_col;
#printf 'p6 index: %d (0x%04x) ' .
#  "($end_row, $start_col, $end_frame)\n", $p6_ind, $p6_ind;
#printf 'p7 index: %d (0x%04x) ' .
#  "($end_row, $end_col, $start_frame)" . ' %d' . "\n", 
#  $p7_ind, $p7_ind, ($end_row * $cols) + $end_col;
#printf 'p8 index: %d (0x%04x) ' .
#  "($end_row, $end_col, $end_frame)\n", $p8_ind, $p8_ind;

my $p1 = ($words == 1) ? 
  unpack("v", pack("n", vec($pix_data, $p1_ind/2, 16))) :
  unpack("V", pack("N", vec($pix_data, $p1_ind/4, 32)));
my $p2 = ($words == 1) ?
  unpack("v", pack("n", vec($pix_data, $p2_ind/2, 16))) :
  unpack("V", pack("N", vec($pix_data, $p2_ind/4, 32)));
my $p3 = ($words == 1) ?
  unpack("v", pack("n", vec($pix_data, $p3_ind/2, 16))) :
  unpack("V", pack("N", vec($pix_data, $p3_ind/4, 32)));
my $p4 = ($words == 1) ?
  unpack("v", pack("n", vec($pix_data, $p4_ind/2, 16))) :
  unpack("V", pack("N", vec($pix_data, $p4_ind/4, 32)));
my $p5 = ($words == 1) ?
  unpack("v", pack("n", vec($pix_data, $p5_ind/2, 16))) :
  unpack("V", pack("N", vec($pix_data, $p5_ind/4, 32)));
my $p6 = ($words == 1) ?
  unpack("v", pack("n", vec($pix_data, $p6_ind/2, 16))) :
  unpack("V", pack("N", vec($pix_data, $p6_ind/4, 32)));
my $p7 = ($words == 1) ?
  unpack("v", pack("n", vec($pix_data, $p7_ind/2, 16))) :
  unpack("V", pack("N", vec($pix_data, $p7_ind/4, 32)));
my $p8 = ($words == 1) ?
  unpack("v", pack("n", vec($pix_data, $p8_ind/2, 16))) :
  unpack("V", pack("N", vec($pix_data, $p8_ind/4, 32)));

printf "p1 : $p1 (0x%04x)\n", $p1;
printf "p2 : $p2 (0x%04x)\n", $p2;
printf "p3 : $p3 (0x%04x)\n", $p3;
printf "p4 : $p4 (0x%04x)\n", $p4;
printf "p5 : $p5 (0x%04x)\n", $p5;
printf "p6 : $p6 (0x%04x)\n", $p6;
printf "p7 : $p7 (0x%04x)\n", $p7;
printf "p8 : $p8 (0x%04x)\n", $p8;
# assume: 
#  x0 < x < x1
#  y0 < y < y1
#  z0 < z < z1
# p1 is value at (x0, y0, z0)
# p2 is value at (x0, y0, z1)
# p3 is value at (x0, y1, z0)
# p4 is value at (x0, y1, z1)
# p5 is value at (x1, y0, z0)
# p6 is value at (x1, y0, z1)
# p7 is value at (x1, y1, z0)
# p8 is value at (x1, y1, z1)
#########################################
# Here we interpolate gradients
#########################################
my $dxdd_y0z0 = ($p5-$p1) * $scaling;
my $dxdd_y0z1 = ($p6-$p2) * $scaling;
my $dxdd_y1z0 = ($p7-$p3) * $scaling;
my $dxdd_y1z1 = ($p8-$p4) * $scaling;
my $dxdd_y0 = $dxdd_y0z0 + $frame_frac * ($dxdd_y0z1 - $dxdd_y0z0);
my $dxdd_y1 = $dxdd_y1z0 + $frame_frac * ($dxdd_y1z1 - $dxdd_y1z0);
my $dxdd = $dxdd_y0 + $col_frac * ($dxdd_y1 - $dxdd_y0);
my $dydd_x0z0 = ($p3-$p1) * $scaling;
my $dydd_x0z1 = ($p4-$p2) * $scaling;
my $dydd_x1z0 = ($p7-$p5) * $scaling;
my $dydd_x1z1 = ($p8-$p6) * $scaling;
my $dydd_x0 = $dydd_x0z0 + $frame_frac * ($dydd_x0z1 - $dydd_x0z0);
my $dydd_x1 = $dydd_x1z0 + $frame_frac * ($dydd_x1z1 - $dydd_x1z0);
my $dydd =  $dydd_x0 + $row_frac * ($dydd_x1 - $dydd_x0);
my $dzdd_x0y0 = ($p2-$p1) * $scaling;
my $dzdd_x0y1 = ($p4-$p3) * $scaling;
my $dzdd_x1y0 = ($p6-$p5) * $scaling;
my $dzdd_x1y1 = ($p8-$p7) * $scaling;
my $dzdd_x0 = $dzdd_x0y0 + $col_frac * ($dzdd_x0y1 - $dzdd_x0y0);
my $dzdd_x1 = $dzdd_x1y0 + $col_frac * ($dzdd_x1y1 - $dzdd_x1y0);
my $dzdd =  $dzdd_x0 + $row_frac * ($dzdd_x1 - $dzdd_x0);

my $g_abs = sqrt(($dxdd * $dxdd) + ($dydd * $dydd) + ($dzdd * $dzdd));
my $dir = [($dxdd/$g_abs), ($dydd/$g_abs), ($dzdd/$g_abs)];

my @p_list = sort($p1, $p2, $p3, $p4, $p5, $p6, $p7, $p8);
my $alt = abs($p_list[0] - $p_list[$#p_list]) * $scaling;
print "$g_abs [$dir->[0], $dir->[1], $dir->[2]] $alt\n";
