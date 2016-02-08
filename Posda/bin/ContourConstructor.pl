#!/usr/bin/perl -w
#
# Input Structure:
#<STDIN> = [
#  {
#    type => "IsoDose",
#    norm_iop => "1\0\0\0\1\0", (e.g.)
#    norm_x => <x>,
#    norm_y => <y>,
#    norm_z => <z>,
#    pix_sp => "1\1", (e.g.)
#    rows => <rows>,
#    cols => <cols>,
#    list => [
#      {
#        color => <color>,
#        file => <3d point file>,
#      },
#      ...
#    ],
#  },
#  {
#    type => "3dContour",
#    norm_iop => "1\0\0\0\1\0", (e.g.)
#    norm_x => <x>,
#    norm_y => <y>,
#    norm_z => <z>,
#    pix_sp => "1\1", (e.g.)
#    rows => <rows>,
#    cols => <cols>,
#    color => <color>, 
#    file => <3d point file>,
#  },
#  {
#    type => "2dContour",
#    x_shift => <x_shift>, (optional)
#    y_shift => <y_shift>, (optional)
#    color => <color>,
#    file => <2d point file>,
#  },
#  {
#    type => "2dContourBatch",
#    pix_sp_x => <pix_sp_x>,
#    pix_sp_y => <pix_sp_y>,
#    x_shift => <x_shift>, (optional)
#    y_shift => <y_shift>, (optional)
#    color => <color>,
#    file => <2d Contours File>,
#  },
#  {
#    type => "RoisFromStruct",
#    norm_iop => "1\0\0\0\1\0", (e.g.)
#    norm_x => <x>,
#    norm_y => <y>,
#    norm_z => <z>,
#    pix_sp => "1\1", (e.g.)
#    rows => <rows>,
#    cols => <cols>,
#    struct_set => <struct_set_file>,
#    roi_list => [
#      {
#        color => <color>,
#        offset => <offset in struct_set_file>,
#        length => <length in struct_set_file>,
#        num_pts => <number points in struct_set_file>,
#      },
#      ...
#    ],
#  },
#];
#<3d point file> is file containing floats separated by
#                backslashes (suitable for inclusion in SS)
#<2d point file> is same, except points are pairs rather than triples
#<2d Contour File> is format produced by BitmapToContours:
#  BEGIN
#  <x>, <y>,
#  ...
#  END
#  ...
#  <eof>
#Encodes a batch of closed 2d contours (see SplitIsoDoseContours.pl)
use strict;
use JSON::PP;
use Storable qw( store_fd fd_retrieve );
use Posda::FlipRotate;
use Debug;
$| = 1;
my $dbg = sub {print STDERR @_ };
my $to_do = fd_retrieve(\*STDIN);
my @Contours;
unless(ref($to_do) eq "ARRAY"){
  die "Instructions are not a list";
}
inst:
for my $i (@$to_do){
  if($i->{type} eq "RoisFromStruct"){ ProcessRoisFromStruct($i, \@Contours) }
  elsif($i->{type} eq "IsoDose"){ ProcessIsoDose($i, \@Contours) }
  elsif($i->{type} eq "2dContour"){ Process2dContour($i, \@Contours) }
  elsif($i->{type} eq "2dContourBatch"){ Process2dContourBatch($i, \@Contours) }
  elsif($i->{type} eq "3dContour"){ Process3dContour($i, \@Contours) }
  elsif($i->{type} eq "NoOp"){ next inst }
  else {
    print STDERR "ContourConstructor.pl: Unknown type $i->{type}\n";
  }
}
my $json = JSON::PP->new();
#$json->pretty(0);
#my $json_text = $json->encode(\@Contours);
#print STDERR "Json text: $json_text\n";
#$json->pretty(0);
print $json->encode(\@Contours);
exit(0);
sub ProcessRoisFromStruct{
  my($desc, $Contours) = @_;
#print STDERR "In ContourConstructor.pl, desc: ";
#Debug::GenPrint($dbg, $desc, 1);
#print STDERR "\n";
  my @iop;
  ($iop[0],$iop[1],$iop[2],$iop[3],$iop[4],$iop[5]) = 
    split(/\\/, $desc->{norm_iop});
  my @pix_sp = split(/\\/, $desc->{pix_sp});
  my $ipp = [$desc->{norm_x}, $desc->{norm_y}, $desc->{norm_z}];
  my $max_dist = 0;
  open my $fh, "<$desc->{struct_set}" 
    or die "ContourConstructor.pl: Can't open $desc->{struct_set} ($!)\n";
  for my $i (0 .. $#{$desc->{roi_list}}){
    my $c_desc = $desc->{roi_list}->[$i];
    my $buff;
    seek($fh, $c_desc->{offset}, 0);
    my $count = read($fh, $buff, $c_desc->{length});
    unless($count == $c_desc->{length}){
      die "ContourConstructor.pl: Read wrong length ($count vs " .
        "$c_desc->{length} at $c_desc->{offset} in $desc->{struct_set}";
    }
    my $nf = $c_desc->{num_pts} * 3;
    my @floats = split(/\\/, $buff);
    my $nrf = @floats;
    unless($nf == $nrf) {
      die "ContourConstructor.pl: Read wrong number of floats ($nrf vs " .
        "$nf at $c_desc->{offset} in $desc->{struct_set}";
    }
    unless(($nf % 3) == 0){
      die "ContourConstructor.pl: Number of floats ($nf) % 3 non-zero " .
        "at $c_desc->{offset} in $desc->{struct_set}";
    }
    my @points;
    my $num_pts = int $nf / 3;
    for my $i (0 .. $num_pts - 1){
      my $pt = [$floats[$i*3], $floats[($i*3)+1], $floats[($i*3)+2]];
      my $pix_pt = Posda::FlipRotate::ToPixCoords(
        \@iop, $ipp, $desc->{rows}, $desc->{cols}, \@pix_sp, $pt);
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
    push(@$Contours, {
      color => "#$c_desc->{color}",
      points => \@points,
      max_dist => $max_dist,
    });
  }
}
sub Process3dContour{
  my($desc, $Contours) = @_;
  my @iop;
  ($iop[0],$iop[1],$iop[2],$iop[3],$iop[4],$iop[5]) = 
    split(/\\/, $desc->{norm_iop});
  my @pix_sp = split(/\\/, $desc->{pix_sp});
  my $ipp = [$desc->{norm_x}, $desc->{norm_y}, $desc->{norm_z}];
  my $max_dist = 0;
  open my $fh, "<$desc->{file}" 
    or die "ContourConstructor.pl: Can't open $desc->{struct_set} ($!)\n";
  my $buff;
  seek($fh, 0, 2);
  my $length = tell($fh);
  seek($fh, 0, 0);
  my $count = read($fh, $buff, $length);
  unless($count == $length){
    die "ContourConstructor.pl: Read wrong length ($count vs " .
      "$length in $desc->{file}";
  }
  my @floats = split(/\\/, $buff);
  my $nrf = @floats;
  my $nf = $nrf;
  unless(($nf % 3) == 0){
    die "ContourConstructor.pl: Number of floats ($nf) % 3 non-zero " .
      "in $desc->{file}";
  }
  my @points;
  my $num_pts = int $nf / 3;
  for my $i (0 .. $num_pts - 1){
    my $pt = [$floats[$i*3], $floats[($i*3)+1], $floats[($i*3)+2]];
    my $pix_pt = Posda::FlipRotate::ToPixCoords(
      \@iop, $ipp, $desc->{rows}, $desc->{cols}, \@pix_sp, $pt);
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
  push(@$Contours, {
    color => "#$desc->{color}",
    points => \@points,
    max_dist => $max_dist,
  });
}
sub ProcessIsoDose{
  my($desc, $Contours) = @_;
  my @iop;
  ($iop[0],$iop[1],$iop[2],$iop[3],$iop[4],$iop[5]) = 
    split(/\\/, $desc->{norm_iop});
  my @pix_sp = split(/\\/, $desc->{pix_sp});
  my $ipp = [$desc->{norm_x}, $desc->{norm_y}, $desc->{norm_z}];
  my $max_dist = 0;
  ent:
  for my $d (0 .. $#{$desc->{list}}){
    open my $fh, "<$desc->{list}->[$d]->{file}" or next ent;
    my $line = <$fh>;
     close $fh;
    unless(defined $line) { next ent }
    if($line eq "") { next ent }
    my @floats = split(/\\/, $line);
    my $nf = @floats;
    my @points;
    my $num_pts = int $nf / 3;
    for my $i (0 .. $num_pts - 1){
      my $pt = [$floats[$i*3], $floats[($i*3)+1], $floats[($i*3)+2]];
      my $pix_pt = Posda::FlipRotate::ToPixCoords(
        \@iop, $ipp, $desc->{rows}, $desc->{cols}, \@pix_sp, $pt);
      my $dist = abs($pix_pt->[2] - $ipp->[2]);
      if($dist > $max_dist) { $max_dist = $dist }
      push(@points, $pix_pt);
    }
    unless(
      $#points >= 1 &&
      $points[$#points]->[0] == $points[0]->[0] &&
      $points[$#points]->[1] == $points[0]->[1]
    ){
      push(@points, $points[0]);
    }
    push(@$Contours,{
      color => "#$desc->{list}->[$d]->{color}",
      points => \@points,
    });
  }
}
sub Process2dContour{
  my($desc, $Contours) = @_;
  my $file = $desc->{file};
  my $color = $desc->{color};
  my $x_shift = 0;
  my $y_shift = 0;
  if(exists $desc->{x_shift}) { $x_shift = $desc->{x_shift} }
  if(exists $desc->{y_shift}) { $y_shift = $desc->{y_shift} }
  open my $fh, "<$file" or return;
  my $line = <$fh>;
  close $fh;
  unless(defined $line) { return }
  if($line eq "") { return }
  my @floats = split(/\\/, $line);
  my $nf = @floats;
  if($nf & 1) { return }
  my $num_pts = int $nf / 2;
  my @points;
  for my $i (0 .. $num_pts - 1){
    my $pt = [$floats[$i * 2], $floats[($i * 2) + 1]];
    $pt->[0] += $x_shift;
    $pt->[1] += $y_shift;
    push(@points, $pt);
  }
  unless(
    $#points >= 1 &&
    $points[$#points]->[0] == $points[0]->[0] &&
    $points[$#points]->[1] == $points[0]->[1]
  ){
    push(@points, $points[0]);
  }
  push(@$Contours,{
    color => "#$color",
    points => \@points,
  });
}
sub Process2dContourBatch{
  my($desc, $Contours) = @_;
  my $file = $desc->{file};
  my $color = $desc->{color};
  my $pix_sp_x = $desc->{pix_sp_x};
  my $pix_sp_y = $desc->{pix_sp_y};
  my $x_shift = 0;
  my $y_shift = 0;
  if(exists $desc->{x_shift}) { $x_shift = $desc->{x_shift} }
  if(exists $desc->{y_shift}) { $y_shift = $desc->{y_shift} }
  my @contours;
  open my $fh, "<$file" or return;
  my $state = "BEGIN_Search";
  my $contour = [];
  while (my $line = <$fh>){
    chomp $line;
    if($state eq "BEGIN_Search"){
      if($line eq "BEGIN"){
        $state = "END_Search";
      } else {
        die "Should have seen a BEGIN or EOF here";
      }
    } elsif($state eq "END_Search"){
      if($line eq "END"){
        push(@contours, $contour);
        $contour = [];
        $state = "BEGIN_Search";
      } elsif ($line =~ /^(.*), (.*)$/){
        my $x = $1;
        my $y = $2;
        push @{$contour}, [($x + $x_shift)/$pix_sp_x,
          ($y + $y_shift)/$pix_sp_y];
      } else {
        die "Couldn't make sense of line: $line";
      }
    }
  }
  for my $c (@contours){
    push(@$Contours,{
      color => "#$color",
      points => $c,
    });
  }
}
1;
