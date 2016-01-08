#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/Dvh.pm,v $
#$Date: 2012/02/07 13:41:44 $
#$Revision: 1.7 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
{
  package Posda::Dvh;
  sub new_from_dose_ss {
    my($class, $dose_ds, $ss_ds) = @_;
    my $this = {};
    my $SOPClass = $dose_ds->Get("(0008,0016)");
    my $SOPInst = $dose_ds->Get("(0008,0018)");
    unless($SOPClass eq "1.2.840.10008.5.1.4.1.1.481.2"){
      die "Not an RT Dose Storage SOP";
    }
    $this->{NormPoint} = $dose_ds->Get("(3004,0040)");
    $this->{NormValue} = $dose_ds->Get("(3004,0042)");
    my $match = $dose_ds->Search("(300c,0060)[<0>](0008,1150)");
    unless(defined($match) && ref($match) eq "ARRAY"){
      die "No structure set reference in dose";
    }
    unless($#{$match} == 0){
      my $count = scalar @{$match};
      die "dose references more than one structure set ($count)";
    }
    my $RefSsSopClass = $dose_ds->Get(
      "(300c,0060)[$match->[0]->[0]](0008,1150)"
    );
    my $RefSsSopInst = $dose_ds->Get(
      "(300c,0060)[$match->[0]->[0]](0008,1155)"
    );
    unless($RefSsSopClass eq "1.2.840.10008.5.1.4.1.1.481.3"){
      die "dose doesn't references structure set ($RefSsSopInst)";
    }
    unless($ss_ds->{SopInst} eq $RefSsSopInst){
      die "dose references different structure set ($RefSsSopInst vs " .
        "$ss_ds->{SopInst})";
    }

    $match = $dose_ds->Search("(3004,0050)[<0>](3004,0058)");
    my @List;
    for my $m (@$match){
      my $i = $m->[0];
      my $hash;
      $hash->{Type} = $dose_ds->Get("(3004,0050)[$i](3004,0001)");
      $hash->{Units} = $dose_ds->Get("(3004,0050)[$i](3004,0002)");
      $hash->{DoseType} = $dose_ds->Get("(3004,0050)[$i](3004,0004)");
      $hash->{DoseScaling} = $dose_ds->Get("(3004,0050)[$i](3004,0052)");
      $hash->{VolumeUnits} = $dose_ds->Get("(3004,0050)[$i](3004,0054)");
      $hash->{NumBins} = $dose_ds->Get("(3004,0050)[$i](3004,0056)");
      $hash->{Data} = $dose_ds->Get("(3004,0050)[$i](3004,0058)");
      $hash->{RealLength} = scalar @{$hash->{Data}};
      my $match1 = $dose_ds->Search(
        "(3004,0050)[$i](3004,0060)[<0>](3004,0062)"
      );
      for my $m1 (@$match1){
        my $j = $m1->[0];
        $hash->{struct}->[$j]->{ContributionType} =
          $dose_ds->Get("(3004,0050)[$i](3004,0060)[$j](3004,0062)");
        my $RoiNum = 
          $dose_ds->Get("(3004,0050)[$i](3004,0060)[$j](3006,0084)");
        unless(exists $ss_ds->{ROI}->{$RoiNum}){
          die "dvh $i references undefined ROI $RoiNum";
        }
        $hash->{struct}->[$j]->{Roi} = $ss_ds->{ROI}->{$RoiNum};
      }
      $hash->{MinimumDose} = $dose_ds->Get("(3004,0050)[$i](3004,0070)");
      $hash->{MaximumDose} = $dose_ds->Get("(3004,0050)[$i](3004,0072)");
      $hash->{MeanDose} = $dose_ds->Get("(3004,0050)[$i](3004,0074)");
      $List[$i] = $hash;
    }
    $this->{List} = \@List;
    bless $this, $class;
    return $this;
  }
}
{
  package Posda::IpDose;
  sub new_from_dose{
    my($class, $dose_ds) = @_;
    my $matches = $dose_ds->Search("(3004,0010)[<0>](3004,0002)");
    unless(defined($matches) && ref($matches) eq "ARRAY"){
      die "no interest points";
    }
    my $this = {};
    for my $m (@$matches){
      my $i = $m->[0];
      my $Units = $dose_ds->Get("(3004,0010)[$i](3004,0002)");
      my $Value = $dose_ds->Get("(3004,0010)[$i](3004,0012)");
      my $ref_roi = $dose_ds->Get("(3004,0010)[$i](3006,0084)");
      my $roi_matches = $dose_ds->Search("(3006,0020)[<0>](3006,0022)",
        $ref_roi);
      unless(
        defined($roi_matches) && 
        ref($roi_matches) eq "ARRAY" &&
        $#{$roi_matches} == 0
      ) { die "bad reference to ROI (in SS ROI Seq)" }
      my $rc_matches = $dose_ds->Search("(3006,0039)[<0>](3006,0084)",
        $ref_roi);
      unless(
        defined($rc_matches) && 
        ref($rc_matches) eq "ARRAY" &&
        $#{$rc_matches} == 0
      ) { die "bad reference to ROI (in ROI Contour Seq)" }
      my $ss_roi_i = $roi_matches->[0]->[0];
      my $roi_c_i = $roi_matches->[0]->[0];
      my $Name = $dose_ds->Get("(3006,0020)[$ss_roi_i](3006,0026)");
      my $Alg = $dose_ds->Get("(3006,0020)[$ss_roi_i](3006,0036)");
      my $contour_seq = $dose_ds->Get("(3006,0039)[$roi_c_i](3006,0040)");
      unless($#{$contour_seq} == 0){
        die "only contour allowed in interest point"
      }
      my $Type = $dose_ds->Get(
        "(3006,0039)[$roi_c_i](3006,0040)[0](3006,0042)");
      unless($Type eq "POINT") { die "IP must have type POINT" }
      my $NumPoints = $dose_ds->Get(
        "(3006,0039)[$roi_c_i](3006,0040)[0](3006,0046)");
      my $Data = $dose_ds->Get(
        "(3006,0039)[$roi_c_i](3006,0040)[0](3006,0050)");
      unless($NumPoints == 1) { die "only one point allowed in contour of IP" }
      unless($#{$Data} == 2) { die "point must have 3 floats" }
      if(exists $this->{$Name}){ die "dup definition of IP $Name"; }
      $this->{$Name} = {
        Alg => $Alg,
        Point => $Data,
        Units => $Units,
        Value => $Value,
      };
    }
    return bless $this, $class;
  }
}
{
  package Posda::Dvh::RoiStructMap;
  sub new {
    my($class, $ds) = @_;
    my $this = {};
    my $SOPClass = $ds->Get("(0008,0016)");
    my $SOPInst = $ds->Get("(0008,0018)");
    unless($SOPClass eq "1.2.840.10008.5.1.4.1.1.481.3"){
      die "Not an RT Structure Set Storage SOP";
    }
    $this->{SopInst} = $SOPInst;
    my $match = $ds->Search("(3006,0020)[<0>](3006,0022)");
    my %ROI_Table;
    for my $m (@$match){
      my $i = $m->[0];
      my $RoiNum = $ds->Get("(3006,0020)[$i](3006,0022)");
      my $RoiFor = $ds->Get("(3006,0020)[$i](3006,0024)");
      my $RoiDesc = $ds->Get("(3006,0020)[$i](3006,0026)");
      my $RoiVol = $ds->Get("(3006,0020)[$i](3006,002c)");
      my $RoiGen = $ds->Get("(3006,0020)[$i](3006,0036)");
      if(exists $ROI_Table{$RoiNum}) {
        die "Duplicate ROI Number ($RoiNum) in items " .
          "$ROI_Table{$RoiNum}->{index} and $i";
      }
      $ROI_Table{$RoiNum} = {
        index => $i,
        for => $RoiFor,
        desc => $RoiDesc,
        gen => $RoiGen,
      };
      if(defined $RoiVol) { $ROI_Table{$RoiNum}->{vol} = $RoiVol }
    }
    $match = $ds->Search("(3006,0080)[<0>](3006,0084)");
    for my $m (@$match){
      my $i = $m->[0];
      my $ObsNum = $ds->Get("(3006,0080)[$i](3006,0082)");
      my $RoiNum = $ds->Get("(3006,0080)[$i](3006,0084)");
      my $ObsLabel = $ds->Get("(3006,0080)[$i](3006,0085)");
      my $ObsDesc = $ds->Get("(3006,0080)[$i](3006,0088)");
      my $ObsType = $ds->Get("(3006,0080)[$i](3006,00a4)");
      my $ObsInterp = $ds->Get("(3006,0080)[$i](3006,00a6)");
      unless(defined $ROI_Table{$RoiNum}){
        die "Undefined ROI Num $RoiNum encountered in ROI " .
          "observation $ObsNum (index $i)";
      }
  
      if(defined $ROI_Table{$RoiNum}->{label}){
        die "Observation $ObsNum ($i) redefines label from " .
          "$ROI_Table{$RoiNum}->{label} to $ObsLabel";
      }
      $ROI_Table{$RoiNum}->{label} = $ObsLabel;
  
      if(defined $ROI_Table{$RoiNum}->{obs_desc}){
        die "Observation $ObsNum ($i) redefines obs_desc from " .
          "$ROI_Table{$RoiNum}->{obs_desc} to $ObsDesc";
      }
      $ROI_Table{$RoiNum}->{obs_desc} = $ObsDesc;
  
      if(defined $ROI_Table{$RoiNum}->{type}){
        die "Observation $ObsNum ($i) redefines type from " .
          "$ROI_Table{$RoiNum}->{type} to $ObsType";
      }
      $ROI_Table{$RoiNum}->{type} = $ObsType;
  
      if(defined $ROI_Table{$RoiNum}->{interpreter}){
        die "Observation $ObsNum ($i) redefines interpreter from " .
          "$ROI_Table{$RoiNum}->{interpreter} to $ObsInterp";
      }
      $ROI_Table{$RoiNum}->{interpreter} = $ObsInterp;
    }
    $match = $ds->Search("(3006,0080)[<0>](3006,00b0)[<1>](3006,00b2)");
    for my $m (@$match){
      my $i = $m->[0];
      my $j = $m->[1];
      my $RoiNum = $ds->Get("(3006,0080)[$i](3006,0084)");
      my $Property = $ds->Get("(3006,0080)[$i](3006,00b0)[$j](3006,00b2)");
      my $Value = $ds->Get("(3006,0080)[$i](3006,00b0)[$j](3006,00b4)");
      unless(exists $ROI_Table{$RoiNum}){
        die "Undefined ROI Num $RoiNum encountered in ROI " .
          "observation (index $i)";
      }
    }
    $this->{ROI} = \%ROI_Table;
    return bless $this, $class;
  }
}
{
  package Posda::Dvh::Graph;
  sub new{
    my($class) = @_;
    my $this = {
      rows => 672,
      cols => 1024,
      tl_sub => [192,192],
      br_sub => [962,608],
      draw => [],
    };
    return bless $this, $class;
  }
  sub SetXScale{
    my($this, $min, $max) = @_;
    $this->{min_x} = $min;
    $this->{max_x} = $max;
  }
  sub SetYScale{
    my($this, $min, $max) = @_;
    $this->{min_y} = $min;
    $this->{max_y} = $max;
  }
  sub DrawHorizScale{
    my($this, $num_lines) = @_;
    $this->{num_horiz_lines} = $num_lines;
    my $inc = ($this->{br_sub}->[1] - $this->{tl_sub}->[1]) / $num_lines;
    push(@{$this->{draw}}, "stroke black");
    my $r_line = $this->{tl_sub}->[1] - 8;
    my $l_line = $this->{br_sub}->[0] + 8;
    for my $step (0 .. $num_lines){
      my $y = $this->{tl_sub}->[1] + ($inc * $step);
      push(@{$this->{draw}}, "line $r_line,$y $l_line,$y");
    }
  }
  sub DrawVertScale{
    my($this, $num_lines) = @_;
    $this->{num_vert_lines} = $num_lines;
    my $inc = ($this->{br_sub}->[0] - $this->{tl_sub}->[0]) / $num_lines;
    push(@{$this->{draw}}, "stroke black");
    my $r_line = $this->{tl_sub}->[0] - 8;
    my $l_line = $this->{br_sub}->[1] + 8;
    for my $step (0 .. $num_lines){
      my $y = $this->{tl_sub}->[1] + ($inc * $step);
      push(@{$this->{draw}}, "line $y, $r_line $y, $l_line");
    }
  }
  sub MarkHorizScale{
    my($this, $max, $min) = @_;
    unless(defined $this->{num_horiz_lines}) {
      die "MarkHorizScale requires DrawHorizScale";
    }
    my $val_inc = ($max - $min) / $this->{num_horiz_lines};
    my $inc = ($this->{br_sub}->[1] - $this->{tl_sub}->[1]) / 
      $this->{num_horiz_lines};
    push @{$this->{draw}}, "stroke black gravity NorthEast";
    for my $step (0 .. $this->{num_horiz_lines}){
      my $val = $min + ($val_inc * $step);
      my $y = $this->{tl_sub}->[1] + ($inc * $step);
      my $pos = ($this->{cols} - $this->{tl_sub}->[0]) + 16;
      push @{$this->{draw}}, "text $pos,$y \"$val\"";
    }
  }
  sub MarkVertScale{
    my($this, $max, $min) = @_;
    unless(defined $this->{num_vert_lines}) {
      die "MarkVertScale requires DrawVertScale";
    }
    my $val_inc = ($max - $min) / $this->{num_vert_lines};
    my $inc = ($this->{br_sub}->[0] - $this->{tl_sub}->[0]) / 
      $this->{num_vert_lines};
    push @{$this->{draw}}, "stroke black gravity SouthWest";
    for my $step (0 .. $this->{num_horiz_lines}){
      my $val = $min + ($val_inc * $step);
      my $y = $this->{br_sub}->[0] - ($inc * $step);
      my $pos = ($this->{cols} - $this->{br_sub}->[0]) - 16;
      push @{$this->{draw}}, "text $y,$pos \"$val\"";
    }
  }
  sub DrawDvh{
    my($this, $dvh, $color) = @_;
    push @{$this->{draw}}, "stroke $color";
    my $num_values = scalar @$dvh;
    unless(($num_values & 1) == 0){ die "Odd number of values" }
    my $num_points = $num_values / 2;
    my $num_segs = $num_points - 1;
    my $origin = [$this->{tl_sub}->[0], $this->{br_sub}->[1]];
    my $x_inc = 1 / (($this->{max_x} - $this->{min_x}) / 
                ($this->{br_sub}->[0] - $this->{tl_sub}->[1]));
    my $y_inc = 1 / (($this->{max_y} - $this->{min_y}) / 
                ($this->{br_sub}->[1] - $this->{tl_sub}->[1]));
    my $cur_center = 0;
    for my $i (0 .. $num_segs - 1){
      my $left_bin_size = $dvh->[$i * 2] * 100;
      my $right_bin_size = $dvh->[($i + 1) * 2] * 100;
      $cur_center += $left_bin_size;
      my $left_i = ($i * 2) + 1;
      my $right_i = (($i + 1) * 2) + 1;
      my $left_y = $dvh->[$left_i];
      my $right_y = $dvh->[$right_i];
      my $left_x = $cur_center - ($left_bin_size / 2);
      my $right_x = $cur_center + ($right_bin_size / 2);
      my $from_x = $origin->[0] + ($left_x * $x_inc);
      my $from_y = $origin->[1] - ($left_y * $y_inc);
      my $to_x = $origin->[0] + ($right_x * $x_inc);
      my $to_y = $origin->[1] - ($right_y * $y_inc);
      push @{$this->{draw}}, "line $from_x,$from_y $to_x,$to_y";
    }
  }
  sub SetPenColor{
    my($this, $color) = @_;
    push @{$this->{draw}}, "stroke $color";
  }
  sub DrawLine{
    my($this, $from, $to) = @_;
    my($from_x, $from_y) = ($from->[0], $from->[1]);
    my($to_x, $to_y) = ($to->[0], $to->[1]);
    my $origin = [$this->{tl_sub}->[0], $this->{br_sub}->[1]];
    my $x_scale = 1 / (($this->{max_x} - $this->{min_x}) / 
                ($this->{br_sub}->[0] - $this->{tl_sub}->[1]));
    my $y_scale = 1 / (($this->{max_y} - $this->{min_y}) / 
                ($this->{br_sub}->[1] - $this->{tl_sub}->[1]));
    my $scaled_from_x = $from_x * $x_scale;
    my $scaled_to_x = $to_x * $x_scale;
    my $scaled_from_y = $from_y * $y_scale;
    my $scaled_to_y = $to_y * $y_scale;
    my $act_from_x = $origin->[0] + $scaled_from_x;
    my $act_from_y = $origin->[1] - $scaled_from_y;
    my $act_to_x = $origin->[0] + $scaled_to_x;
    my $act_to_y = $origin->[1] - $scaled_to_y;
    push @{$this->{draw}}, "line " .
      "$act_from_x,$act_from_y " .
      "$act_to_x,$act_to_y";
  }
  sub AddCaption{
    my($this, $index, $size, $text, $color) = @_;
    my $origin_x = 50;
    my $origin_y = 30;
    my $x = $origin_x;
    my $y = $origin_y + ($index * $size);
    push @{$this->{draw}}, "stroke '$color'";
    push @{$this->{draw}}, "gravity NorthWest";
    push @{$this->{draw}}, "text $x,$y '$text'";
  }
  sub Render{
    my($this, $file_name) = @_;
    if(-f $file_name){ `rm $file_name` }
    if(-f "temp.mvg"){`rm temp.mvg`}
    my $cmd = "convert -size $this->{cols}x$this->{rows} " .
      "xc:white -fill grey " .
      "-draw \"rectangle $this->{tl_sub}->[0],$this->{tl_sub}->[1] " .
      "$this->{br_sub}->[0],$this->{br_sub}->[1]\" ";
    if($#{$this->{draw}} >= 0){
      open FILE, ">", "temp.mvg";
      for my $d (@{$this->{draw}}){
        print FILE "$d\n";
      }
      close FILE;
      $cmd .= "-draw \@temp.mvg ";
    }
    $cmd .= "$file_name";
    `$cmd`;
  }
}
1;
