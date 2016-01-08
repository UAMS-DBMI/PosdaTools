#!/usr/bin/perl -w
use strict;
my $suspect_types = {
};
my $val_types = {
  radius => 1,
  diameter => 1,
  circle => 1,
  semicircle => 1,
  quartercircle => 1,
  hemisphere => 1,
  quartersphere => 1,
  quadrant => 1,
  point => 1,
  sphere => 1,
};
#$Source: /home/bbennett/pass/archive/Posda/bin/test/ComputeMargin.pl,v $
#$Date: 2011/12/06 17:50:20 $
#$Revision: 1.17 $
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
#  in=<number of input fd>
#  out=<number of output fd>
#  status=<number of status fd>
#  rows=<number of rows in bitmap output>
#  cols=<number of cols in bitmap output>
#  rowspc=<spacing between columns>
#  colspc=<spacing between rows>
#  slicespc=<spacing between rows>
#  margin=<margin value>
#
#

# Here's the analysis for actually calculating margins
#  For each input bit, if its a zero, do nothing, if its a 1, then
#  look at the 6 adjoining bits (top, bottom, anterior, posterior, left, right)
#  there are 64 possibilities, each of which corresponds to one of the
#  following types of bit:
#    bare point (1 way)
#    inside solid (1 way)
#    inside line (3 ways, orientation of line)
#    inside plane (3 ways, orientation of plane)
#    tip of line (6 ways, orientation of line, and which end)
#    edge of plane (12 ways, orientation of plane and which edge)
#    corner of plane (12 ways, orientation of plane and which corner)
#    face of solid (6 ways, orientation of face and direction of normal);
#    edge of solid (12, orientation of edge and direction of normal)
#    corner of solid (8, which corner)
# Heres the table:
#  indx tbaplr                            shape        dim  orientation
#     0 000000 - bare point            sphere            3     N/A
#     1 000001 - tip of line           hemisphere        3     l
#     2 000010 - tip of line           hemisphere        3     r
#     3 000011 - inside line           circle            2     nlr
#     4 000100 - tip of line           hemisphere        3     a
#     5 000101 - corner of plane       quartersphere     3     al
#     6 000110 - corner of plane       quartersphere     3     ar
#     7 000111 - edge of plane         semicircle        2     tab
#     8 001000 - tip of line           hemisphere        3     p
#     9 001001 - corner of plane       quartersphere     3     pl
#    10 001010 - corner of plane       quartersphere     3     pr
#    11 001011 - edge of plane         semicircle        2     tpb
#    12 001100 - inside line           circle            2     nap
#    13 001101 - edge of plane         semicircle        2     tlb
#    14 001110 - edge of plane         semicircle        2     trb
#    15 001111 - inside plane          diameter          1     tb
#    16 010000 - tip of line           hemisphere        3     t
#    17 010001 - corner of plane       quartersphere     3     tl
#    18 010010 - corner of plane       quartersphere     3     tr
#    19 010011 - edge of plane         semicircle        2     atp
#    20 010100 - corner of plane       quartersphere     3     ta
#    21 010101 - corner of solid       quadrant          3     tal
#    22 010110 - corner of solid       quadrant          3     tar
#    23 010111 - edge of solid         quartercircle     2     ta
#    24 011000 - corner of plane       quartersphere     3     tp
#    25 011001 - corner of solid       quadrant          3     tpl
#    26 011010 - corner of solid       quadrant          3     tpr
#    27 011011 - edge of solid         quartercircle     2     tp
#    28 011100 - edge of plane         semicircle        2     ltr
#    29 011101 - edge of solid         quartercircle     2     tr
#    30 011110 - edge of solid         quartercircle     2     tl
#    31 011111 - face of a solid       radius            1     t
#    32 100000 - tip of line           hemisphere        3     b
#    33 100001 - corner of plane       quartersphere     3     bl
#    34 100010 - corner of plane       quartersphere     3     br
#    35 100011 - edge of plane         semicircle        2     abp
#    36 100100 - corner of plane       quartersphere     3     ba
#    37 100101 - corner of solid       quadrant          3     bal
#    38 100110 - corner of solid       quadrant          3     bar
#    39 100111 - edge of solid         quartercircle     2     ba
#    40 101000 - corner of plane       quartersphere     3     bp
#    41 101001 - corner of solid       quadrant          3     bpl
#    42 101010 - corner of solid       quadrant          3     bpr
#    43 101011 - edge of solid         quartercircle     2     bp
#    44 101100 - edge of plane         semicircle        2     lbr
#    45 101101 - edge of solid         quartercircle     2     bl
#    46 101110 - edge of solid         quartercircle     2     br
#    47 101111 - face of a solid       radius            1     b
#    48 110000 - inside line           circle            2     ntb
#    49 110001 - edge of plane         semicircle        2     alp
#    50 110010 - edge of plane         semicircle        2     arp
#    51 110011 - inside plane          diameter          1     ap
#    52 110100 - edge of plane         semicircle        2     lar
#    53 110101 - edge of solid         quartercircle     2     al
#    54 110110 - edge of solid         quartercircle     2     ar
#    55 110111 - face of a solid       radius            1     a
#    56 111000 - edge of plane         semicircle        2     lpr
#    57 111001 - edge of solid         quartercircle     2     pl
#    58 111010 - edge of solid         quartercircle     2     pr
#    59 111011 - face of a solid       radius            1     p
#    60 111100 - inside plane          diameter          1     lr
#    61 111101 - face of a solid       radius            1     r
#    62 111110 - face of a solid       radius            1     l
#    63 111111 - inside of solid       point            N/A
#
#    type of shape         number of transforms
#    sphere                        1  : identity
#    hemisphere                    6  : identity
#                                     :  90 lr
#                                     : 180 lr
#                                     : 270 lr
#                                     :  90 ap
#                                     :  90 ap, 180 tb
#    circle                        3  : identity
#                                     :  90 lr
#                                     :  90 ap
#    semicircle                   12  : identity
#                                     :  90 lr
#                                     : 180 lr
#                                     : 270 lr
#                                     :  90 ap
#                                     :  90 ap,  90 tb
#                                     :  90 ap, 180 tb
#                                     :  90 ap, 270 tb
#                                     :  90 tb
#                                     :  90 tb,  90 lr
#                                     :  90 tb, 180 lr
#                                     :  90 tb, 270 lr
#    quartersphere                12  : identity
#                                     :  90 lr
#                                     : 180 lr
#                                     : 270 lr
#                                     :  90 ap
#                                     :  90 ap,  90 tb
#                                     :  90 ap, 180 tb
#                                     :  90 ap, 270 tb
#                                     :  90 tb
#                                     :  90 tb,  90 lr
#                                     :  90 tb, 180 lr
#                                     :  90 tb, 270 lr
#    quartercircle                12  : identity
#                                     :  90 lr
#                                     : 180 lr
#                                     : 270 lr
#                                     :  90 ap
#                                     :  90 ap,  90 tb
#                                     :  90 ap, 180 tb
#                                     :  90 ap, 270 tb
#                                     :  90 tb
#                                     :  90 tb,  90 lr
#                                     :  90 tb, 180 lr
#                                     :  90 tb, 270 lr
#    quadrant                      8  : identity
#                                     :  90 lr
#                                     : 180 lr
#                                     : 270 lr
#                                     :  90 tb
#                                     :  90 tb,  90 lr
#                                     :  90 tb, 180 lr
#                                     :  90 tb, 270 lr
#    radius                        6  : identity
#                                     :  90 lr
#                                     : 180 lr
#                                     : 270 lr
#                                     :  90 ap
#                                     :  90 ap, 180 tb
#    diameter                      3  : identity
#                                     :  90 lr
#                                     :  90 ap
#
use VectorMath;
my $types = [
 ["t000000", "bare point", "sphere", "r001010"],
 ["t000001", "tip of line", "hemisphere", "r010001"],
 ["t000010", "tip of line", "hemisphere", "r0m0001"],
 ["t000011", "inside line", "circle", "r010001"],
 ["t000100", "tip of line", "hemisphere", "r001100"],
 ["t000101", "corner of plane", "quartersphere", "r010001"],
 ["t000110", "corner of plane", "quartersphere", "r0m000m"],
 ["t000111", "edge of plane", "semicircle", "r001m00"],
 ["t001000", "tip of line", "hemisphere", "r001m00"],
 ["t001001", "corner of plane", "quartersphere", "r01000m"],
 ["t001010", "corner of plane", "quartersphere", "r0m0001"],
 ["t001011", "edge of plane", "semicircle", "r001100"],
 ["t001100", "inside line", "circle", "r001100"],
 ["t001101", "edge of plane", "semicircle", "r0m0100"],
 ["t001110", "edge of plane", "semicircle", "r010100"],
 ["t001111", "inside plane", "diameter", "r001010"],
 ["t010000", "tip of line", "hemisphere", "r001010"],
 ["t010001", "corner of plane", "quartersphere", "r010100"],
 ["t010010", "corner of plane", "quartersphere", "r0m0100"],
 ["t010011", "edge of plane", "semicircle", "r0010m0"],
 ["t010100", "corner of plane", "quartersphere", "r001100"],
 ["t010101", "corner of solid", "quadrant", "r00m0m0"],
 ["t010110", "corner of solid", "quadrant", "r001m00"],
 ["t010111", "edge of solid", "quartercircle", "r100010"],
 ["t011000", "corner of plane", "quartersphere", "r001010"],
 ["t011001", "corner of solid", "quadrant", "r00mm00"],
 ["t011010", "corner of solid", "quadrant", "r0010m0"],
 ["t011011", "edge of solid", "quartercircle", "r100001"],
 ["t011100", "edge of plane", "semicircle", "r1000m0"],
 ["t011101", "edge of solid", "quartercircle", "r001010"],
 ["t011110", "edge of solid", "quartercircle", "r00m010"],
 ["t011111", "face of solid", "radius", "r0010m0"],
 ["t100000", "tip of line", "hemisphere", "r0010m0"],
 ["t100001", "corner of plane", "quartersphere", "r010m00"],
 ["t100010", "corner of plane", "quartersphere", "r0m0m00"],
 ["t100011", "edge of plane", "semicircle", "r001010"],
 ["t100100", "corner of plane", "quartersphere", "r0010m0"],
 ["t100101", "corner of solid", "quadrant", "r00m100"],
 ["t100110", "corner of solid", "quadrant", "r001010"],
 ["t100111", "edge of solid", "quartercircle", "r10000m"],
 ["t101000", "corner of plane", "quartersphere", "r001m00"],
 ["t101001", "corner of solid", "quadrant", "r00m010"],
 ["t101010", "corner of solid", "quadrant", "r001100"],
 ["t101011", "edge of solid", "quartercircle", "r1000m0"],
 ["t101100", "edge of plane", "semicircle", "r100010"],
 ["t101101", "edge of solid", "quartercircle", "r0010m0"],
 ["t101110", "edge of solid", "quartercircle", "r00m0m0"],
 ["t101111", "face of solid", "radius", "r001010"],
 ["t110000", "inside line", "circle", "r001010"],
 ["t110001", "edge of plane", "semicircle", "r0m0001"],
 ["t110010", "edge of plane", "semicircle", "r010001"],
 ["t110011", "inside plane", "diameter", "r001100"],
 ["t110100", "edge of plane", "semicircle", "r100001"],
 ["t110101", "edge of solid", "quartercircle", "r001100"],
 ["t110110", "edge of solid", "quartercircle", "r00mm00"],
 ["t110111", "face of solid", "radius", "r001m00"],
 ["t111000", "edge of plane", "semicircle", "r10000m"],
 ["t111001", "edge of solid", "quartercircle", "r001m00"],
 ["t111010", "edge of solid", "quartercircle", "r00m100"],
 ["t111011", "face of solid", "radius", "r001100"],
 ["t111100", "inside plane", "diameter", "r010001"],
 ["t111101", "face of solid", "radius", "r0m0001"],
 ["t111110", "face of solid", "radius", "r010001"],
 ["t111111", "inside solid", "point", "r001010"],
];
my $rotations = {
  r100010 => [[1,0,0], [0,1,0], [0,0,1]],
  r100001 => [[1,0,0], [0,0,1], [0,-1,0]],
  r1000m0 => [[1,0,0], [0,-1,0], [0,0,-1]],
  r10000m => [[1,0,0], [0,0,-1], [0,1,0]],
  rm00010 => [[-1,0,0], [0,1,0], [0,0,-1]],
  rm00001 => [[-1,0,0], [0,0,1], [0,1,0]],
  rm000m0 => [[-1,0,0], [0,-1,0], [0,0,1]],
  rm0000m => [[-1,0,0], [0,0,-1], [0,-1,0]],
  r010100 => [[0,1,0], [1,0,0], [0,0,-1]],
  r010001 => [[0,1,0], [0,0,1], [1,0,0]],
  r010m00 => [[0,1,0], [-1,0,0], [0,0,1]],
  r01000m => [[0,1,0], [0,0,-1], [-1,0,0]],
  r0m0100 => [[0,-1,0], [1,0,0], [0,0,1]],
  r0m0001 => [[0,-1,0], [0,0,1], [-1,0,0]],
  r0m0m00 => [[0,-1,0], [-1,0,0], [0,0,-1]],
  r0m000m => [[0,-1,0], [0,0,-1], [1,0,0]],
  r001100 => [[0,0,1], [1,0,0], [0,1,0]],
  r001010 => [[0,0,1], [0,1,0], [-1,0,0]],
  r001m00 => [[0,0,1], [-1,0,0], [0,-1,0]],
  r0010m0 => [[0,0,1], [0,-1,0], [1,0,0]],
  r00m100 => [[0,0,-1], [1,0,0], [0,-1,0]],
  r00m010 => [[0,0,-1], [0,1,0], [1,0,0]],
  r00mm00 => [[0,0,-1], [-1,0,0], [0,1,0]],
  r00m0m0 => [[0,0,-1], [0,-1,0], [-1,0,0]],
};
my $table = [
  "sphere",
  "hemisphere",
  "hemisphere",
  "circle",
  "hemisphere",
  "quartersphere",
  "quartersphere",
  "semicircle",
  "hemisphere",
  "quartersphere",
  "quartersphere",
  "semicircle",
  "circle",
  "semicircle",
  "semicircle",
  "diameter",
  "hemisphere",
  "quartersphere",
  "quartersphere",
  "semicircle",
  "quartersphere",
  "quadrant",
  "quadrant",
  "quartercircle",
  "quartersphere",
  "quadrant",
  "quadrant",
  "quartercircle",
  "semicircle",
  "quartercircle",
  "quartercircle",
  "radius",
  "hemisphere",
  "quartersphere",
  "quartersphere",
  "semicircle",
  "quartersphere",
  "quadrant",
  "quadrant",
  "quartercircle",
  "quartersphere",
  "quadrant",
  "quadrant",
  "quartercircle",
  "semicircle",
  "quartercircle",
  "quartercircle",
  "radius",
  "circle",
  "semicircle",
  "semicircle",
  "diameter",
  "semicircle",
  "quartercircle",
  "quartercircle",
  "radius",
  "semicircle",
  "quartercircle",
  "quartercircle",
  "radius",
  "diameter",
  "radius",
  "radius",
  "point",
];
my %counts;
my $num_zeros = 0;

my($in, $out, $status, $rows, $cols, $slices, $sampspc, $margin);
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
  elsif ($key eq "rows") { $rows = $value }
  elsif ($key eq "cols") { $cols = $value }
  elsif ($key eq "slices") { $slices = $value }
  elsif ($key eq "sampspc") { $sampspc = $value }
  elsif ($key eq "margin") { $margin = $value }
  elsif ($key eq "debug") { $debug = $value }
  else { die "$0: unknown parameter: $key" }
}
unless(defined $in) { die "$0: in is not defined" }
unless(defined $out) { die "$0: out is not defined" }
unless(defined $rows) { die "$0: rows is not defined" }
unless(defined $cols) { die "$0: cols is not defined" }
unless(defined $slices) { die "$0: slices is not defined" }
unless(defined $sampspc) { die "$0: rowspc is not defined" }
unless(defined $margin) { die "$0: margin is not defined" }
if($debug){
  print "$0: DEBUG\n";
  print "\trows: $rows\n";
  print "\tcols: $cols\n";
  print "\tslices: $slices\n";
  print "\tspc: $sampspc)\n";
  print "\tmargin: $margin\n";
}
my $int_margin = int(($margin+($sampspc/2))/$sampspc);
my $num_planes = (2 * $int_margin) + 1;
my $center_plane = $int_margin + 1;
my $bits_per_plane = $rows * $cols;
open(INPUT, "<&", $in) or die "$0: Can't open in = $in ($!)";
open(OUTPUT, ">&", $out) or die "$0: Can't open out = $out ($!)";
my @in_planes;
my @out_planes;
my $plane_being_filled = [];
my $empty_frame;
for my $i (0 .. $bits_per_plane - 1){ $empty_frame->[$i] = 0 }
my $in_polarity = 0;
my $in_count = 0;
my $frames_written = -$int_margin;
my $frames_filled = 0;
my $out_polarity = 0;
my $out_count = 0;
push(@in_planes, $empty_frame);
for my $i (0 .. 2 * $int_margin){
  my $ef = [];
  for my $j (0 .. $bits_per_plane - 1){ $ef->[$j] = 0 }
  $out_planes[$i] = $ef;
}
sub BuildSphere{
  my @list;
  for my $i (-$int_margin .. $int_margin){
    for my $j (-$int_margin .. $int_margin){
      for my $k (-$int_margin .. $int_margin){
        if(sqrt(($i * $i) + ($j * $j) + ($k * $k)) <= ($margin/$sampspc)){
          push(@list, [$j, $i, $k]);
        }
      }
    }
  }
  return \@list;
}
sub BuildHemisphere{
  #  Hemisphere above
  #  t010000
  my($rot, $type) = @_;
  my @list;
  for my $i (-$int_margin .. 0){
    for my $j (-$int_margin .. $int_margin){
      for my $k (-$int_margin .. $int_margin){
        if(sqrt(($i * $i) + ($j * $j) + ($k * $k)) <= ($margin/$sampspc)){
          push(@list, VectorMath::Rot3D($rot, [$j, $i, $k]));
        }
      }
    }
  }
if(exists $suspect_types->{hemisphere}){
  print "Hemisphere Kernal for type $type:\n";
  for my $i (@ list){
    print "\t[$i->[0], $i->[1], $i->[2]]\n";
  }
}
  return \@list;
}
sub BuildQuartersphere{
  # Quartersphere top and left
  # t010001
  my($rot, $type) = @_;
  my @list;
  for my $i (-$int_margin .. 0){
    for my $j (-$int_margin .. 0){
      for my $k (-$int_margin .. $int_margin){
        if(sqrt(($i * $i) + ($j * $j) + ($k * $k)) <= ($margin/$sampspc)){
          push(@list, VectorMath::Rot3D($rot, [$j, $i, $k]));
        }
      }
    }
  }
if(exists $suspect_types->{quartersphere}){
  print "Quartersphere Kernal for type $type:\n";
  for my $i (@ list){
    print "\t[$i->[0], $i->[1], $i->[2]]\n";
  }
}
  return \@list;
}
sub BuildQuadrant{
  # Quadrant below, right, posterior
  # t101010
  my($rot, $type) = @_;
  my @list;
  for my $i (0 .. $int_margin){
    for my $j (0 .. $int_margin){
      for my $k (0 .. $int_margin) {
        if(sqrt(($i * $i) + ($j * $j) + ($k * $k)) <= ($margin/$sampspc)){
          push(@list, VectorMath::Rot3D($rot, [$j, $i, $k]));
        }
      }
    }
  }
if(exists $suspect_types->{quadrant}){
  print "Quadrant Kernal for type $type:\n";
  for my $i (@ list){
    print "\t[$i->[0], $i->[1], $i->[2]]\n";
  }
}
  return \@list;
}
sub BuildCircle{
  # Circle right left anterior posterior
  # t110000
  my($rot, $type) = @_;
  my @list;
  for my $j (-$int_margin .. $int_margin){
    for my $k (-$int_margin .. $int_margin){
      if(sqrt(($j * $j) + ($k * $k)) <= ($margin/$sampspc)){
        push(@list, VectorMath::Rot3D($rot, [$j, 0, $k]));
      }
    }
  }
if(exists $suspect_types->{circle}){
  print "Circle Kernal for type $type:\n";
  for my $i (@ list){
    print "\t[$i->[0], $i->[1], $i->[2]]\n";
  }
}
  return \@list;
}
sub BuildSemicircle{
  # Semicircle below left right
  # t101100
  my($rot, $type) = @_;
  my @list;
  for my $j (-$int_margin .. $int_margin){
    for my $i (0 .. $int_margin){
      if(sqrt(($i * $i) + ($j * $j)) <= ($margin/$sampspc)){
        push(@list, VectorMath::Rot3D($rot, [$j, $i, 0]));
      }
    }
  }
if(exists $suspect_types->{Semicircle}){
  print "Semicircle Kernal for type $type:\n";
  for my $i (@ list){
    print "\t[$i->[0], $i->[1], $i->[2]]\n";
  }
}
  return \@list;
}
sub BuildQuartercircle{
  # Quartercircle top anterior
  # t010111
  my($rot, $type) = @_;
  my @list;
  for my $i (-$int_margin .. 0){
    for my $k (-$int_margin .. 0){
      if(sqrt(($i * $i) + ($k * $k)) <= ($margin/$sampspc)){
        push(@list, VectorMath::Rot3D($rot, [0, $i, $k]));
      }
    }
  }
if(exists $suspect_types->{quartercircle}){
  print "Quartercircle Kernal for type $type:\n";
  for my $i (@ list){
    print "\t[$i->[0], $i->[1], $i->[2]]\n";
  }
}
  return \@list;
}
sub BuildDiameter{
  # Diameter above and below
  # t001111
  my($rot, $type) = @_;
  my @list;
  for my $i (-$int_margin .. $int_margin){
    if(sqrt(($i * $i)) <= ($margin/$sampspc)){
      push(@list, VectorMath::Rot3D($rot, [0, $i, 0]));
    }
  }
if(exists $suspect_types->{diameter}){
  print "Diameter Kernal for type $type:\n";
  for my $i (@ list){
    print "\t[$i->[0], $i->[1], $i->[2]]\n";
  }
}
  return \@list;
}
sub BuildRadius{
  # Radius below
  # t101111
  my($rot, $type) = @_;
  my @list;
  for my $i (0 .. $int_margin){
    if(sqrt(($i * $i)) <= ($margin/$sampspc)){
      push(@list, VectorMath::Rot3D($rot, [0, $i, 0]));
    }
  }
if(exists $suspect_types->{radius}){
  print "Radius Kernal for type $type:\n";
  for my $i (@ list){
    print "\t[$i->[0], $i->[1], $i->[2]]\n";
  }
}
  return \@list;
}
sub BuildIdentity{
  my @list;
  push(@list, [0,0,0]);
  return \@list;
}
my @KernalTable;
for my $i (0 .. 63){
  if($types->[$i]->[2] eq "sphere"){
    $KernalTable[$i] = BuildSphere;
  }elsif($types->[$i]->[2] eq "hemisphere"){
    my $rot_name = $types->[$i]->[3];
    my $rot = $rotations->{$rot_name};
    $KernalTable[$i] = BuildHemisphere($rot, $types->[$i]->[0]);
  }elsif($types->[$i]->[2] eq "quartersphere"){
    my $rot_name = $types->[$i]->[3];
    my $rot = $rotations->{$rot_name};
    $KernalTable[$i] = BuildQuartersphere($rotations->{$types->[$i]->[3]},
      $types->[$i]->[0]);
  }elsif($types->[$i]->[2] eq "quadrant"){
    my $rot_name = $types->[$i]->[3];
    my $rot = $rotations->{$rot_name};
    $KernalTable[$i] = BuildQuadrant($rotations->{$types->[$i]->[3]},
      $types->[$i]->[0]);
  }elsif($types->[$i]->[2] eq "circle"){
    my $rot_name = $types->[$i]->[3];
    my $rot = $rotations->{$rot_name};
    $KernalTable[$i] = BuildCircle($rotations->{$types->[$i]->[3]});
  }elsif($types->[$i]->[2] eq "semicircle"){
    my $rot_name = $types->[$i]->[3];
    my $rot = $rotations->{$rot_name};
    $KernalTable[$i] = BuildSemicircle($rotations->{$types->[$i]->[3]},
      $types->[$i]->[0]);
  }elsif($types->[$i]->[2] eq "quartercircle"){
    my $rot_name = $types->[$i]->[3];
    my $rot = $rotations->{$rot_name};
    $KernalTable[$i] = BuildQuartercircle($rotations->{$types->[$i]->[3]},
      $types->[$i]->[0]);
  }elsif($types->[$i]->[2] eq "diameter"){
    my $rot_name = $types->[$i]->[3];
    my $rot = $rotations->{$rot_name};
    $KernalTable[$i] = BuildDiameter($rotations->{$types->[$i]->[3]},
      $types->[$i]->[0]);
  }elsif($types->[$i]->[2] eq "radius"){
    my $rot_name = $types->[$i]->[3];
    my $rot = $rotations->{$rot_name};
    $KernalTable[$i] = BuildRadius($rotations->{$types->[$i]->[3]},
      $types->[$i]->[0]);
  }elsif($types->[$i]->[2] eq "point"){
    my $rot_name = $types->[$i]->[3];
    my $rot = $rotations->{$rot_name};
    $KernalTable[$i] = BuildIdentity($rotations->{$types->[$i]->[3]});
  }
}
loop:
while($frames_written < $slices){
  plane_group:
  while(
    scalar(@$plane_being_filled) < $bits_per_plane && 
    scalar(@in_planes) < 3
  ){
    if($in_count > 0){
      if($in_count >= ($bits_per_plane - scalar(@$plane_being_filled))){
        for my $i (scalar(@$plane_being_filled) .. $bits_per_plane - 1){
          $plane_being_filled->[$i] = $in_polarity;
          $in_count -= 1;
        }
        unless(scalar(@$plane_being_filled) == $bits_per_plane){
          my $count = scalar(@$plane_being_filled);
          print STDERR "$0: Error - only $count bytes in frame " .
              "$bits_per_plane\n";
        }
      } else {
        for my $i (0 .. $in_count - 1){
          push(@$plane_being_filled, $in_polarity);
        }
        $in_count = 0;
      }
      unless(scalar(@$plane_being_filled) == $bits_per_plane){
        next plane_group;
      }
    } else {
      my $byte;
      my $unpacked;
      my $c = read(INPUT, $byte, 1);
      if($c){
        no warnings;
        $unpacked = unpack("c", $byte);
        $in_polarity = ($unpacked &0x80) >> 7;
        $in_count = $unpacked & 0x7f;
        next plane_group;
      }
    }
    # just filled a plane or gotten to end of input
    if(scalar(@$plane_being_filled) == $bits_per_plane){
      push(@in_planes, $plane_being_filled);
      $plane_being_filled = [];
    } else {
      push(@in_planes, $empty_frame);
    }
    $frames_filled += 1;
  }
  #have a full plane group
  
  if($frames_written < $slices){
    if($frames_filled <= $slices + 1){
#print("Frame: $frames_filled\n");
      #calculate the margin into output
      my $op_frame = $out_planes[$center_plane];
      my $prior_plane = $in_planes[0];
      my $current_frame = $in_planes[1];
      my $next_plane = $in_planes[2];
      for my $j (0 .. $rows - 1){
        for my $k (0 .. $cols - 1){
          my $index = ($j * $cols) + $k;
          if($current_frame->[$index]){
            # Here is where you expand the margin based on the
            # table (see analysis above)
            my($t, $b, $a, $p, $l, $r);
            if($j == 0){
              $t = 0;
              $b = $current_frame->[(($j + 1) * $cols)+ $k];
            } elsif ($j == $rows - 1){
              $b = 0;
              $t = $current_frame->[(($j - 1) * $cols) + $k];
            } else {
              $b = $current_frame->[(($j + 1) * $cols) + $k];
              $t = $current_frame->[(($j - 1) * $cols) + $k];
            }
            if($k == 0) {
              $l = 0;
              $r = $current_frame->[($j * $cols) + $k + 1];
            } elsif($k == $cols - 1) {
              $r = 0;
              $l = $current_frame->[($j * $cols) + $k - 1];
            } else {
              $r = $current_frame->[($j * $cols) + $k + 1];
              $l = $current_frame->[($j * $cols) + $k - 1];
            }
            $a = $prior_plane->[$index];
            $p = $next_plane->[$index];
            #  indx tbaplr
            my $type = 
              ($t ? 0x20 : 0) +
              ($b ? 0x10 : 0) +
              ($a ? 0x08 : 0) +
              ($p ? 0x04 : 0) +
              ($l ? 0x02 : 0) +
              ($r ? 0x01 : 0);
            if($type > 63) { die "type > 63" }
            my $kernal = $KernalTable[$type];
unless($val_types->{$types->[$type]->[2]}){
print "Applying kernal for type: $types->[$type]->[0] " .
  "($types->[$type]->[2]) at $j, $k\n";
}
            for my $offset(@$kernal){
              my $nj = $offset->[1] + $j;
              my $nk = $offset->[0] + $k;
              my $ni = $offset->[2];
if($suspect_types->{$types->[$type]->[2]}){
  print "\t[$nk, $nj, $ni]\n";
}
              if(
                $nj >= 0 && $nj < $rows &&
                $nk >= 0 && $nk < $cols &&
                abs($ni) <= $int_margin
              ){
                my $this_frame = $out_planes[$center_plane + $ni];
                my $this_index = ($nj * $cols) + $nk;
                $this_frame->[$this_index] |= 1;
              }
            } 
            my $tt = $table->[$type];
            $counts{$tt} += 1;
            # end expand margin
          } else {
            $num_zeros += 1;
          }
        }
      }
      #end of margin calculation
    }
    # write a plane and cause another to be slid in
     my $output_frame = $out_planes[0];
    if($frames_written >= 0){
      for my $i (0 .. $bits_per_plane - 1){
        my $byte = $output_frame->[$i];
        if($byte == $out_polarity) { $out_count += 1 } else {
          my $out = ($out_polarity ? 0x80 : 0) + $out_count;
          {
            no warnings;
            print OUTPUT pack("c", $out);
          }
          $out_polarity = $byte;
          $out_count = 1;
        }
        if($out_count > 127){
          my $out = ($out_polarity ? 0x80 : 0) | 127;
          {
            no warnings;
            print OUTPUT pack("c", $out);
          }
          $out_count -= 127;
        }
      }
    }
    $frames_written += 1;
    my $discard = shift(@in_planes);
    $discard = shift(@out_planes);
    my $ef = [];
    for my $i(0 .. $bits_per_plane - 1) { $ef->[$i] = 0 }
    push(@out_planes, $ef);
  }
}
print "out_count $out_count, out_polarity: $out_polarity\n";
if($out_count > 0){
  my $out = ($out_polarity ? 0x80 : 0) + $out_count;
  {
    no warnings;
    print OUTPUT pack("c", $out);
  }
}
print "Num zeros: $num_zeros\n";
for my $i (keys %counts){
  print "$i: $counts{$i}\n";
}

if(defined $status){
  open(STATUS, ">&", $status) or die "$0: Can't open status = $status ($!)";
  print STATUS "OK\n";
  close STATUS;
}
