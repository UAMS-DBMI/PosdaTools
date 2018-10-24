#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use VectorMath;
my $c_source = 0;
for my $i (@ARGV){
  if ($i eq "-c") { $c_source = 1; }
}
my $types = [
 ["t000000", "bare point", "sphere"],
 ["t000001", "tip of line", "hemisphere"],
 ["t000010", "tip of line", "hemisphere"],
 ["t000011", "inside line", "circle"],
 ["t000100", "tip of line", "hemisphere"],
 ["t000101", "corner of plane", "quartersphere"],
 ["t000110", "corner of plane", "quartersphere"],
 ["t000111", "edge of plane", "semicircle"],
 ["t001000", "tip of line", "hemisphere"],
 ["t001001", "corner of plane", "quartersphere"],
 ["t001010", "corner of plane", "quartersphere"],
 ["t001011", "edge of plane", "semicircle"],
 ["t001100", "inside line", "circle"],
 ["t001101", "edge of plane", "semicircle"],
 ["t001110", "edge of plane", "semicircle"],
 ["t001111", "inside plane", "diameter"],
 ["t010000", "tip of line", "hemisphere"],
 ["t010001", "corner of plane", "quartersphere"],
 ["t010010", "corner of plane", "quartersphere"],
 ["t010011", "edge of plane", "semicircle"],
 ["t010100", "corner of plane", "quartersphere"],
 ["t010101", "corner of solid", "quadrant"],
 ["t010110", "corner of solid", "quadrant"],
 ["t010111", "edge of solid", "quartercircle"],
 ["t011000", "corner of plane", "quartersphere"],
 ["t011001", "corner of solid", "quadrant"],
 ["t011010", "corner of solid", "quadrant"],
 ["t011011", "edge of solid", "quartercircle"],
 ["t011100", "edge of plane", "semicircle"],
 ["t011101", "edge of solid", "quartercircle"],
 ["t011110", "edge of solid", "quartercircle"],
 ["t011111", "face of solid", "radius"],
 ["t100000", "tip of line", "hemisphere"],
 ["t100001", "corner of plane", "quartersphere"],
 ["t100010", "corner of plane", "quartersphere"],
 ["t100011", "edge of plane", "semicircle"],
 ["t100100", "corner of plane", "quartersphere"],
 ["t100101", "corner of solid", "quadrant"],
 ["t100110", "corner of solid", "quadrant"],
 ["t100111", "edge of solid", "quartercircle"],
 ["t101000", "corner of plane", "quartersphere"],
 ["t101001", "corner of solid", "quadrant"],
 ["t101010", "corner of solid", "quadrant"],
 ["t101011", "edge of solid", "quartercircle"],
 ["t101100", "edge of plane", "semicircle"],
 ["t101101", "edge of solid", "quartercircle"],
 ["t101110", "edge of solid", "quartercircle"],
 ["t101111", "face of solid", "radius"],
 ["t110000", "inside line", "circle"],
 ["t110001", "edge of plane", "semicircle"],
 ["t110010", "edge of plane", "semicircle"],
 ["t110011", "inside plane", "diameter"],
 ["t110100", "edge of plane", "semicircle"],
 ["t110101", "edge of solid", "quartercircle"],
 ["t110110", "edge of solid", "quartercircle"],
 ["t110111", "face of solid", "radius"],
 ["t111000", "edge of plane", "semicircle"],
 ["t111001", "edge of solid", "quartercircle"],
 ["t111010", "edge of solid", "quartercircle"],
 ["t111011", "face of solid", "radius"],
 ["t111100", "inside plane", "diameter"],
 ["t111101", "face of solid", "radius"],
 ["t111110", "face of solid", "radius"],
 ["t111111", "inside solid", "point"]
];
my $canon_types = {
  hemisphere => "t010000",
  circle => "t110000",
  quartersphere => "t010001",
  semicircle => "t101100",
  quartercircle => "t010111",
  diameter => "t001111",
  quadrant => "t101010",
  radius => "t101111",
  point => "t111111",
  sphere => "t000000",
};
my $rotations;
my $rots;
my $twenty_four = [
  [[1, 0, 0], [0, 1, 0]],
  [[1, 0, 0], [0, 0, 1]],
  [[1, 0, 0], [0, -1, 0]],
  [[1, 0, 0], [0, 0, -1]],
  [[-1, 0, 0], [0, 1, 0]],
  [[-1, 0, 0], [0, 0, 1]],
  [[-1, 0, 0], [0, -1, 0]],
  [[-1, 0, 0], [0, 0, -1]],
  [[0, 1, 0], [1, 0, 0]],
  [[0, 1, 0], [0, 0, 1]],
  [[0, 1, 0], [-1, 0, 0]],
  [[0, 1, 0], [0, 0, -1]],
  [[0, -1, 0], [1, 0, 0]],
  [[0, -1, 0], [0, 0, 1]],
  [[0, -1, 0], [-1, 0, 0]],
  [[0, -1, 0], [0, 0, -1]],
  [[0, 0, 1], [1, 0, 0]],
  [[0, 0, 1], [0, 1, 0]],
  [[0, 0, 1], [-1, 0, 0]],
  [[0, 0, 1], [0, -1, 0]],
  [[0, 0, -1], [1, 0, 0]],
  [[0, 0, -1], [0, 1, 0]],
  [[0, 0, -1], [-1, 0, 0]],
  [[0, 0, -1], [0, -1, 0]],
];
my @FullRotations;
for my $i (@$twenty_four){
  my $norm = VectorMath::cross($i->[0], $i->[1]);
  my $rot = [
    $i->[0],
    $i->[1],
    $norm
  ];
  my($i1, $i2, $i3);
  if($i->[0]->[0] == 1) { $i1 = "x";
  } elsif ($i->[0]->[0] == -1) { $i1 = "-x"
  } elsif ($i->[0]->[1] == 1) { $i1 =  "y"
  } elsif ($i->[0]->[1] == -1) { $i1 =  "-y"
  } elsif ($i->[0]->[2] == 1) { $i1 =  "z"
  } else { $i1 =  "-z" }
  if($i->[1]->[0] == 1) { $i2 = "x"
  } elsif ($i->[1]->[0] == -1) { $i2 = "-x"
  } elsif ($i->[1]->[1] == 1) { $i2 = "y"
  } elsif ($i->[1]->[1] == -1) { $i2 = "-y"
  } elsif ($i->[1]->[2] == 1) { $i2 = "z"
  } else { $i2 = "-z" }
  if($norm->[0] == 1) { $i3 = "x"
  } elsif ($norm->[0] == -1) { $i3 = "-x"
  } elsif ($norm->[1] == 1) { $i3 = "y"
  } elsif ($norm->[1] == -1) { $i3 = "-y"
  } elsif ($norm->[2] == 1) { $i3 = "z"
  } else { $i3 = "-z" }
  my $name = "r";
  if($i->[0]->[0] == 0){ $name .= "0"
  }elsif($i->[0]->[0] == 1){ $name .= "1"
  }elsif($i->[0]->[0] == -1) { $name .= "m" }
  if($i->[0]->[1] == 0){ $name .= "0"
  }elsif($i->[0]->[1] == 1){ $name .= "1"
  }elsif($i->[0]->[1] == -1) { $name .= "m" }
  if($i->[0]->[2] == 0){ $name .= "0"
  }elsif($i->[0]->[2] == 1){ $name .= "1"
  }elsif($i->[0]->[2] == -1) { $name .= "m" }
  if($i->[1]->[0] == 0){ $name .= "0"
  }elsif($i->[1]->[0] == 1){ $name .= "1"
  }elsif($i->[1]->[0] == -1) { $name .= "m" }
  if($i->[1]->[1] == 0){ $name .= "0"
  }elsif($i->[1]->[1] == 1){ $name .= "1"
  }elsif($i->[1]->[1] == -1) { $name .= "m" }
  if($i->[1]->[2] == 0){ $name .= "0"
  }elsif($i->[1]->[2] == 1){ $name .= "1"
  }elsif($i->[1]->[2] == -1) { $name .= "m" }
  $rotations->{$i1}->{$i2}->{$i3} = $name;
  $rots->{$name} = $rot;
  push(@FullRotations, [$name, $rot]);
}
for my $i (keys %$rotations){
  for my $j (keys %{$rotations->{$i}}){
    for my $k (keys %{$rotations->{$i}->{$j}}){
      print "$rotations->{$i}->{$j}->{$k}:\tx->$i;\ty->$j;\tz->$k\n";
    }
  }
}
my @Results;
for my $i (@$types){
  my $t = $i->[0];
  my $ct = $canon_types->{$i->[2]};
  print "need transform to $t from $ct ($i->[2])\n";
  my @rots;
  for my $rot (sort keys %$rots){
    my($cd, $cmt) = ComputePositionAndType($i->[0]);
    if($i->[1] ne $cd){
      print "###############\n";
      print "$i->[0]: $i->[1] vs $cd\n";
      print "###############\n";
    }
    if($i->[2] ne $cmt){
      print "###############\n";
      print "$i->[0]: $i->[2] vs $cmt\n";
      print "###############\n";
    }
    my $vl = TypeToVectorList($ct);
    my $nvl = [];
    for my $v (@$vl){ push @$nvl, VectorMath::Rot3D($rots->{$rot}, $v) }
    my $n_name = VectorListToType($nvl);
    if($n_name eq $t){
      print "\t$rot: $n_name\n";
      push @rots, $rot;
    }
  }
  push(@Results, [$t, $i->[1], $i->[2], $rots[0]]);
}
sub ComputePositionAndType{
  my($type) = @_;
  unless($type =~ /^t(.)(.)(.)(.)(.)(.)$/){ die "bad type" }
  my $t = $1;
  my $b = $2;
  my $a = $3;
  my $p = $4;
  my $l = $5;
  my $r = $6;
  my $count = $t + $b + $a + $p + $l + $r;
  if($count == 0){
    return "bare point", "sphere";
  }
  if($count == 1){
    return "tip of line", "hemisphere";
  }
  if($count == 2) {
    if($t == $b && $a == $p && $l == $r){
      return "inside line", "circle";
    } else {
      return "corner of plane", "quartersphere";
    }
  }
  if($count == 3){
    if($t == $b || $a == $p || $l == $r){
      return "edge of plane", "semicircle";
    } else {
      return "corner of solid", "quadrant";
    }
  }
  if($count == 4){
    if($t == $b && $a == $p && $l == $r){
      return "inside plane", "diameter";
    } else {
      return "edge of solid", "quartercircle";
    }
  }
  if($count == 5){
    return "face of solid", "radius";
  }
  if($count == 6){
    return "inside solid", "point"
  }
}
sub TypeToVectorList{
  my($type) = @_;
  unless($type =~ /^t(.)(.)(.)(.)(.)(.)$/){ die "bad type" }
  my @list;
  my $t = $1;
  my $b = $2;
  my $a = $3;
  my $p = $4;
  my $l = $5;
  my $r = $6;
  if($t) { push @list, [0, -1, 0]}
  if($b) { push @list, [0, 1, 0]}
  if($a) { push @list, [0, 0, -1]}
  if($p) { push @list, [0, 0, 1]}
  if($l) { push @list, [-1, 0, 0]}
  if($r) { push @list, [1, 0, 0]}
  return \@list;
}
sub VectorListToType{
  my($vl) = @_;
  my $t = 0;
  my $b = 0;
  my $a = 0;
  my $p = 0;
  my $l = 0;
  my $r = 0;
  for my $v (@$vl){
    if($v->[0] == 0 && $v->[1] == -1 && $v->[2] == 0){ $t = 1
    } elsif ($v->[0] == 0 && $v->[1] == 1 && $v->[2] == 0) { $b = 1
    } elsif ($v->[0] == 0 && $v->[1] == 0 && $v->[2] == -1) { $a = 1
    } elsif ($v->[0] == 0 && $v->[1] == 0 && $v->[2] == 1) { $p = 1
    } elsif ($v->[0] == -1 && $v->[1] == 0 && $v->[2] == 0) { $l = 1
    } elsif ($v->[0] == 1 && $v->[1] == 0 && $v->[2] == 0) { $r = 1
    } else {
      die "bad vector\n";
    }
  }
  return "t$t$b$a$p$l$r";
}
if ($c_source) {
  print "\n\n" .
        "/* \n" .
        " *  Start of generated code from program: $0\n" .
        " *    (dir Posda/bin/test/  )\n" .
        " */\n";
  print "\nenum rotations_types { \n";
  for my $r (@FullRotations){ print "  $r->[0],\n"; }
  print "  rotations_types_max\n};\n\n";

  print "\nstatic const int rotations[rotations_types_max][3][3] = { \n";
  for my $r (@FullRotations){
    print "  [$r->[0]] = " .
      "{{$r->[1]->[0]->[0],$r->[1]->[0]->[1],$r->[1]->[0]->[2]}," .
      " {$r->[1]->[1]->[0],$r->[1]->[1]->[1],$r->[1]->[1]->[2]}," .
      " {$r->[1]->[2]->[0],$r->[1]->[2]->[1],$r->[1]->[2]->[2]}},\n";
  }
  print "};\n\n";
  print "\nenum geometric_types {\n";
  for my $canon_type (sort keys %$canon_types) {
    print "  geometric_type_$canon_type,\n";
  }
  print "  geometric_types_max\n};\n\n";

  print "static const char *geometric_types_description[geometric_types_max] = {\n";
  for my $canon_type (sort keys %$canon_types) {
    print "  [geometric_type_$canon_type] = \"$canon_type\",\n";
  }
  print "};\n\n";

  print "static const char *types_description[64] = {\n";
  for my $t (@Results){
    print " \"$t->[1]\",\n";
  }
  print "};\n\n";

  print "static const int types_geometric_value[64] = {\n";
  for my $t (@Results){
    print " geometric_type_$t->[2],\n";
  }
  print "};\n\n";
  print "static const char *types_geometric_string_value[64] = {\n";
  for my $t (@Results){
    print " \"$t->[2]\",\n";
  }
  print "};\n\n";
  print "static const int types_rotation[64] = {\n";
  for my $t (@Results){
    print " $t->[3],\n";
  }
  print "};\n";
  print "\n\n" .
        "/* \n" .
        " *  End of generated code from program: $0\n" .
        " *    (dir Posda/bin/test/  )\n" .
        " */\n";
} else {
  for my $t (@Results){
    print " [\"$t->[0]\", \"$t->[1]\", \"$t->[2]\", \"$t->[3]\"],\n";
  }
  for my $r (@FullRotations){
    print "  $r->[0] => " .
      "[[$r->[1]->[0]->[0],$r->[1]->[0]->[1],$r->[1]->[0]->[2]]," .
      " [$r->[1]->[1]->[0],$r->[1]->[1]->[1],$r->[1]->[1]->[2]]," .
      " [$r->[1]->[2]->[0],$r->[1]->[2]->[1],$r->[1]->[2]->[2]]],\n";
  }
} 
print "Finished\n";
