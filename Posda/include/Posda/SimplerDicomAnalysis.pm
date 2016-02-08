#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package Posda::SimplerDicomAnalysis;
use Posda::FlipRotate;
use Posda::Transforms;
use Time::HiRes qw( gettimeofday tv_interval );
my $version = '$Revision: 1.12 $'; #Should get revision from RCS

my $StudyAttrs = [
  "(0010,0010)", #Patient's Name
  "(0010,0020)", #Patient's ID
  "(0010,0030)", #Patient's Birth Date
  "(0010,1010)", #Patient's Age
  "(0010,1030)", #Patient's Weight
  "(0010,0040)", #Patient's Sex
  "(0010,2160)", #Ethnic Group
  "(0008,0020)", #Study Date
  "(0008,0030)", #Study Time
  "(0008,0090)", #Referring Physician's Name
  "(0020,0010)", #Study ID
  "(0008,0050)", #Accession Number
  "(0008,1030)", #Study Description
  "(0012,0010)", #Protocol:  Clinical Trial Sponsor Name
  "(0012,0020)", #Protocol ID:  Clinical Trial Protocol ID
  "(0012,0021)", #Protocol Name:  Clinical Trial Protocol Name
  "(0012,0030)", #Site ID:  Clinical Trial Site ID
  "(0012,0031)", #Site Name:  Clinical Trial Site Name
  "(0012,0040)", #Case ID:  Clinical Trial Subject ID
  "(0012,0050)", #Time Point ID:  Clinical Trial Time Point ID
  "(0012,0060)", #Coordinating Center Name: Trial Coordinating Center Name
];
my $SeriesAttrs = [
  "(0008,0060)", #Modality
  "(0020,000d)", #Study Instance UID
  "(0020,000e)", #Series Instance UID
  "(0020,0011)", #Series Number
  "(0020,0060)", #Laterality
  "(0008,0021)", #Series Date
  "(0008,0031)", #Series Time
  "(0018,0015)", #Body Part Examined
  "(0018,1030)", #Protocol Name
  "(0008,103e)", #Series Description
  "(0018,5100)", #Patient Position
  "(0008,0070)", #Manufacturer
  "(0008,0080)", #Institution Name
  "(0008,0081)", #Institution Address
  "(0008,1090)", #Manufacturer's Model Name
  "(0018,1020)", #Software Version
  "(0008,1080)", #Admitting Diagnosis Description
  "(0008,1010)", #Station Name
  "(0018,1000)", #Device Serial Number
  "(0020,0200)", #Synchronization Frame of Reference UID
];
my $ForAttrs = [
  "(0020,0052)", #Frame of Reference UID
  "(0020,1040)", #Position Reference Indicator
];
my $ImageAttrs = [
  "(0018,0050)", #Slice Thickness
  "(0020,1041)", #Slice Location
  "(0020,0013)", #Instance Number
  "(0028,0002)", #Samples Per Pixel
  "(0028,0004)", #Photometric Interpretation
  "(0028,0010)", #Rows
  "(0028,0011)", #Columns
  "(0028,0030)", #Pixel Spacing
  "(0028,0100)", #Bits Allocated
  "(0028,0101)", #Bits Stored
  "(0028,0102)", #High Bit
  "(0028,0103)", #Pixel Representation
];
my $ImageGeometryAttrs = [
  "(0020,0032)", #Image Position Patient
  "(0020,0037)", #Image Orientation Patient
];
my $WindowLevelAttrs = [
  "(0028,1050)", #Window Center
  "(0028,1051)", #Window Width
  "(0028,1052)", #Rescale Intercept
  "(0028,1053)", #Rescale Slope
  "(0028,1055)", #Window Center & Width Explanation
];
my $MultiFrameAttrs = [
  "(0028,0008)", #Number of Frames
  "(0028,0009)", #Frame Increment Pointer
];
my $HasFrameOfReference = {
  '1.2.840.10008.5.1.4.1.1.481.1' => 1, #RT Image
  '1.2.840.10008.5.1.4.1.1.1.1' => 1,   #Digital X-Ray
  '1.2.840.10008.5.1.4.1.1.1' => 1,     #Computed Radiography
  '1.2.840.10008.5.1.4.1.1.2' => 1,     #CT Image
  '1.2.840.10008.5.1.4.1.1.7' => 1,     #SC Image
  '1.2.840.10008.5.1.4.1.1.4' => 1,     #MR Image
  '1.2.840.10008.5.1.4.1.1.128' => 1,   #PT Image
  '1.2.840.10008.5.1.4.1.1.481.2' => 1, #RT Dose
  '1.2.840.10008.5.1.4.1.1.481.5' => 1, #RT Plan
  '1.2.840.10008.5.1.4.1.1.481.8' => 1, #RT Ion Plan
  '1.2.840.10008.5.1.4.1.1.66.1' => 1,  #Spatial Registration
};
my $HasWindowLevel = {
  '1.2.840.10008.5.1.4.1.1.481.1' => 1, #RT Image
  '1.2.840.10008.5.1.4.1.1.1.1' => 1,   #Digital X-Ray
  '1.2.840.10008.5.1.4.1.1.1' => 1,     #Computed Radiography
  '1.2.840.10008.5.1.4.1.1.2' => 1,     #CT Image
  '1.2.840.10008.5.1.4.1.1.7' => 1,     #SC Image
  '1.2.840.10008.5.1.4.1.1.4' => 1,     #MR Image
  '1.2.840.10008.5.1.4.1.1.128' => 1,   #PT Image
};
my $HasImagePixel = {
  '1.2.840.10008.5.1.4.1.1.481.1' => 1, #RT Image
  '1.2.840.10008.5.1.4.1.1.1.1' => 1,   #Digital X-Ray
  '1.2.840.10008.5.1.4.1.1.1' => 1,     #Computed Radiography
  '1.2.840.10008.5.1.4.1.1.2' => 1,     #CT Image
  '1.2.840.10008.5.1.4.1.1.7' => 1,     #SC Image
  '1.2.840.10008.5.1.4.1.1.4' => 1,     #MR Image
  '1.2.840.10008.5.1.4.1.1.128' => 1,   #PT Image
  '1.2.840.10008.5.1.4.1.1.481.2' => 1, #RT Dose
};
my $HasImageGeometry = {
  '1.2.840.10008.5.1.4.1.1.2' => 1,     #CT Image
  '1.2.840.10008.5.1.4.1.1.7' => 1,     #SC Image
  '1.2.840.10008.5.1.4.1.1.4' => 1,     #MR Image
  '1.2.840.10008.5.1.4.1.1.128' => 1,   #PT Image
  '1.2.840.10008.5.1.4.1.1.481.2' => 1, #RT Dose
};
my $IsMultiFrame = {
  '1.2.840.10008.5.1.4.1.1.481.2' => 1, #RT Dose
};
my $SopClassAttrs = {
  # RTIMAGE
  '1.2.840.10008.5.1.4.1.1.481.1' => [
  ],
  # DX
  '1.2.840.10008.5.1.4.1.1.1.1' => [
  ],
  # CR
  '1.2.840.10008.5.1.4.1.1.1' => [
  ],
  # CT 
  "1.2.840.10008.5.1.4.1.1.2" => [
  ],
  # Secondary Capture (OT or SC)
  '1.2.840.10008.5.1.4.1.1.7' => [
  ],
  # MR 
  "1.2.840.10008.5.1.4.1.1.4" => [
    "(0018,0020)", #Scanning Sequence
    "(0018,0021)", #Sequence Variant
    "(0018,0022)", #Scan Options
    "(0018,0023)", #MR Acquisition Type
    "(0018,0080)", #Repetition Time
    "(0018,0081)", #Echo Time
    "(0018,0082)", #Inversion Time
    "(0018,0091)", #Echo Train Length
    "(0018,1060)", #Trigger Time
  ],
  # PT 
  "1.2.840.10008.5.1.4.1.1.128" => [
    "(0018,1060)", #Trigger Time
    "(0018,1063)", #Frame Time
    "(0018,1242)", #Actual Frame Duration
    "(0028,0051)", #Corrected Image
    "(0054,0081)", #Number of Slices
    "(0054,1000)", #Series Type
    "(0054,1001)", #Units
    "(0054,1002)", #Counts Source
    "(0054,1004)", #Reprojection Method
    "(0054,1102)", #Decay Correction
    "(0054,1300)", #Frame Reference Time
    "(0054,1330)", #Image Index
  ],
  # RTSTRUCT 
  "1.2.840.10008.5.1.4.1.1.481.3" => [
   "(3006,0002)", #Structure Set Label 
   "(3006,0004)", #Structure Set Name 
   "(3006,0008)", #Structure Set Date 
   "(3006,0009)", #Structure Set Time 
  ],
  # RTPLAN 
  "1.2.840.10008.5.1.4.1.1.481.5" => [
  ],
  # RT ION PLAN 
  "1.2.840.10008.5.1.4.1.1.481.8" => [
  ],
  # RTDOSE
  "1.2.840.10008.5.1.4.1.1.481.2" => [
    "(3004,0002)", #Dose Units
    "(3004,0004)", #Dose Type
    "(3004,000a)", #Dose Summation Type
    "(3004,000c)", #Grid Frame Offset Vector
    "(3004,000e)", #Dose Grid Scaling
    "(3004,0014)", #Tissue Heterogeneity Correction
    "(3005,\"ITC_DVH_Computation\",50)", #DVH source
    "(300c,0002)[0](0008,1150)", #Referenced Plan SOP Class
    "(300c,0002)[0](0008,1155)", #Referenced Plan SOP Instance
  ],
  # Spatial Registration
  '1.2.840.10008.5.1.4.1.1.66.1' => [
  ],
};
sub ProcessDose{
  my($this, $try, $file) = @_;
  my $start = [ gettimeofday ];
  $this->{ref_plan} = $try->{dataset}->Get("(300c,0002)[0](0008,1155)");
  $this->{ref_frac_group} = $try->{dataset}->Get(
    "(300c,0002)[0](300c,0020)[0](300c,0022)"
  );
  $this->{ref_ss} = $try->{dataset}->Get("(300c,0060)[0](0008,1155)");
  my $dose_type = $try->{dataset}->Get("(3004,000a)");
  $this->{summation_type} = $dose_type;
  if ($dose_type eq "BEAM") {
    $this->{beam_num} = $try->{dataset}->Get(
      "(300c,0002)[0](300c,0020)[0](300c,0004)[0](300c,0006)");
  }
  # New Plan, Frac Grp, Beam, CP, Brachy References here
  my $plan_refs = $try->{dataset}->Search("(300c,0002)[<0>](0008,1155)");
  if(ref($plan_refs) eq "ARRAY"){
    for my $r (@$plan_refs){
      my $sop_class = $try->{dataset}->Get("(300c,0002)[$r->[0]](0008,1150)");
      my $sop_inst = $try->{dataset}->Get("(300c,0002)[$r->[0]](0008,1155)");
      $this->{plan_refs}->{$sop_inst} = {
        sop_class => $sop_class,
      };
      my $frac_refs = $try->{dataset}->Search(
        "(300c,0002)[$r->[0]](300c,0020)[<0>](300c,0022)");
      if(ref($frac_refs) eq "ARRAY"){
        for my $f (@$frac_refs){
          my $frac_num = $try->{dataset}->Get(
            "(300c,0002)[$r->[0]](300c,0020)[$f->[0]](300c,0022)");
          unless(
            defined($this->{plan_refs}->{$sop_inst}->{fracs}->{$frac_num})
          ){
            $this->{plan_refs}->{$sop_inst}->{fracs}->{$frac_num} = {};
          }
          my $beam_refs = $try->{dataset}->Search(
            "(300c,0002)[$r->[0]](300c,0020)[$f->[0]](300c,0004)" .
            "[<0>](300c,0006)");
          if(ref($beam_refs) eq "ARRAY"){
            for my $b (@$beam_refs){
              my $beam_num = $try->{dataset}->Get(
                "(300c,0002)[$r->[0]](300c,0020)[$f->[0]](300c,0004)" .
                "[$b->[0]](300c,0006)");
              $this->{plan_refs}->{$sop_inst}->{fracs}->{$frac_num}
                ->{beams}->{$beam_num} = {};
              my $cp_refs = $try->{dataset}->Search(
                "(300c,0002)[$r->[0]](300c,0020)[$f->[0]](300c,0004)" .
                "[$b->[0]](300c,00f2)[<0>](300c,00f4)");
              if(ref($cp_refs) eq "ARRAY"){
                for my $cp (@$cp_refs){
                  my $start = $try->{dataset}->Get(
                    "(300c,0002)[$r->[0]](300c,0020)[$f->[0]](300c,0004)" .
                    "[$b->[0]](300c,00f2)[$cp->[0]](300c,00f4)");
                  my $end = $try->{dataset}->Get(
                    "(300c,0002)[$r->[0]](300c,0020)[$f->[0]](300c,0004)" .
                    "[$b->[0]](300c,00f2)[$cp->[0]](300c,00f6)");
                  unless(exists(
                    $this->{plan_refs}->{$sop_inst}->{fracs}->{$frac_num}
                      ->{beams}->{$beam_num}->{cps})
                  ){
                    $this->{plan_refs}->{$sop_inst}->{fracs}->{$frac_num}
                      ->{beams}->{$beam_num}->{cps} = [];
                  }
                  push(
                    @{$this->{plan_refs}->{$sop_inst}->{fracs}->{$frac_num}
                      ->{beams}->{$beam_num}->{cps}},
                    {
                      start => $start,
                      end => $end,
                    }
                  );
                } #control points
              }
            } #beams
          }
          my $brachy_refs = $try->{dataset}->Search(
            "(300c,0002)[$r->[0]](300c,0020)[$f->[0]](300c,000a)" .
            "[<0>](300c,000c)");
          if(ref($brachy_refs) eq "ARRAY"){
            for my $b (@$brachy_refs){
              my $brachy_num = $try->{dataset}->Get(
                "(300c,0002)[$r->[0]](300c,0020)[$f->[0]](300c,000a)" .
                "[$b->[0]](300c,000c)");
              $this->{plan_refs}->{$sop_inst}->{fracs}->{$frac_num}
                ->{brachy_setups}->{$brachy_num} = {};
            }
          }
        } #fraction groups
      }
    } #plans
  }
  
  # get DVH info...
  $this->{dvhs} = [];
  my $d = $try->{dataset}->Search("(3004,0050)[<0>](3004,0058)");
  for my $i (@$d){
    my $dvh = {
      type => $try->{dataset}->Get("(3004,0050)[$i->[0]](3004,0001)"),
      dose_units => $try->{dataset}->Get("(3004,0050)[$i->[0]](3004,0002)"),
      dose_type => $try->{dataset}->Get("(3004,0050)[$i->[0]](3004,0004)"),
      normalization => $try->{dataset}->Get(
                        "(3004,0050)[$i->[0]](3004,0042)"),
      dose_scaling => $try->{dataset}->Get(
                        "(3004,0050)[$i->[0]](3004,0052)"),
      vol_units => $try->{dataset}->Get("(3004,0050)[$i->[0]](3004,0054)"),
      num_bins => $try->{dataset}->Get("(3004,0050)[$i->[0]](3004,0056)"),
      min_dose => $try->{dataset}->Get("(3004,0050)[$i->[0]](3004,0070)"),
      max_dose => $try->{dataset}->Get("(3004,0050)[$i->[0]](3004,0072)"),
      file_pos => $try->{dataset}->FilePos(
                    "(3004,0050)[$i->[0]](3004,0058)"),
      file_len => $try->{dataset}->EleLenInFile(
                    "(3004,0050)[$i->[0]](3004,0058)"),
      };
    $dvh->{rois} = [];
    my $r = $try->{dataset}->Search(
              "(3004,0050)[$i->[0]](3004,0060)[<0>](3006,0084)");
    for my $j (@$r){
      my $roi = {
        type => $try->{dataset}->Get(
          "(3004,0050)[$i->[0]](3004,0060)[$j->[0]](3004,0062)"),
        num => $try->{dataset}->Get(
          "(3004,0050)[$i->[0]](3004,0060)[$j->[0]](3006,0084)"),
      };
      push(@{$dvh->{rois}}, $roi);
    }
    push(@{$this->{dvhs}}, $dvh);
  }
  # get 3D dose info...
  my $pixel_desc = $try->{dataset}->GetEle("(7fe0,0010)");
  unless(defined $pixel_desc) { return }
  my $gfov_desc = $try->{dataset}->GetEle("(3004,000c)");
  unless (defined $gfov_desc) {
    print STDERR "Can't analyze 2d dose file\n";
    return;
  }
  $this->{gfov_pos} = $try->{dataset}->FilePos("(3004,000c)");
  $this->{gfov_len} = $try->{dataset}->EleLenInFile("(3004,000c)");
  my $command = "GetGfov.pl \"$file\" $this->{gfov_pos} $this->{gfov_len}";
  open my $g_fh, "$command|";
  my $line = <$g_fh>;
  close $g_fh;
  chomp $line;
  my $gfov = [ split(/\\/, $line) ];
  my $num_frames = @$gfov;
  $this->{"(3004,000c)"} = $line;
  my $rows = $this->{"(0028,0010)"};
  my $cols = $this->{"(0028,0011)"};
  my $iop = $try->{dataset}->Get("(0020,0037)");
  my $ipp = $try->{dataset}->Get("(0020,0032)");
  my $pix_sp = $try->{dataset}->Get("(0028,0030)");
  my $dose_grid_scaling = $this->{"(3004,000e)"};
  my $dose_units = $this->{"(3004,0002)"};
  my $bytes;
  my $bits_alloc = $this->{"(0028,0100)"};
  if($bits_alloc == 16) { $bytes = 2 } elsif($bits_alloc == 32){
    $bytes = 4
  } else {
    print STDERR "Can't analyze dose with bits_alloc = $bits_alloc\n";
    return;
  }
  $command = "AnalyzeDoseArray.pl \"$file\" $pixel_desc->{file_pos} " .
    "$num_frames $rows $cols $bytes";
  open my $fh, "$command|";
  $line = <$fh>;
  chomp $line;
  my($max_dose_at, $max_dose, $min_dose) = split(/\|/, $line);
  my $norm = VectorMath::cross(
    [$iop->[0], $iop->[1], $iop->[2]], [$iop->[3], $iop->[4], $iop->[5]]);
  my $offset = $gfov->[$max_dose_at];
  my $corner = VectorMath::Add(VectorMath::Scale($offset, $norm), $ipp);
  my $z = $corner->[2];
  $offset = $gfov->[$#{$gfov}];
  my $opp_corner = VectorMath::Add(VectorMath::Scale($offset, $norm), $ipp);
  my($rtl, $rtr, $rbl, $rbr) = Posda::FlipRotate::ToCorners(
    $rows, $cols, $iop, $ipp, $pix_sp);
  my($ltl, $ltr, $lbl, $lbr) = Posda::FlipRotate::ToCorners(
    $rows, $cols, $iop, $opp_corner, $pix_sp);
  my($min_x, $min_y, $min_z, $max_x, $max_y, $max_z);
  for my $p ($rtl, $rtr, $rbl, $rbr, $ltl, $ltr, $lbl, $lbr){
    unless(defined $min_x) { $min_x = $p->[0] }
    unless(defined $min_y) { $min_y = $p->[1] }
    unless(defined $min_z) { $min_z = $p->[2] }
    unless(defined $max_x) { $max_x = $p->[0] }
    unless(defined $max_y) { $max_y = $p->[1] }
    unless(defined $max_z) { $max_z = $p->[2] }
    if($p->[0] < $min_x) { $min_x = $p->[0] }
    if($p->[1] < $min_y) { $min_y = $p->[1] }
    if($p->[2] < $min_z) { $min_z = $p->[2] }
    if($p->[0] > $max_x) { $max_x = $p->[0] }
    if($p->[1] > $max_y) { $max_y = $p->[1] }
    if($p->[2] > $max_z) { $max_z = $p->[2] }
  }
  $this->{DoseBoundingBox} = 
    [[$min_x, $min_y, $min_z], [$max_x, $max_y, $max_z]];
  my $int = tv_interval($start, [ gettimeofday ]);
  $this->{max_dose_in_Gy} = $max_dose * $dose_grid_scaling;
  $this->{min_dose_in_Gy} = $min_dose * $dose_grid_scaling;
  unless ($dose_units eq "GRAY" || $dose_units eq "GY") {
    $this->{max_dose_in_Gy} /= 100;
    $this->{min_dose_in_Gy} /= 100;
  }
  $this->{max_dose_at_z} = $z;
}
sub ProcessStruct{
  my($this, $try, $file)  = @_;
  # Get FOR(s)
  my %for;
  my $ds = $try->{dataset};
  my $m = $ds->Search("(3006,0010)[<0>](0020,0052)");
  for my $i (@$m){
    my $for = $ds->Get("(3006,0010)[$i->[0]](0020,0052)");
    $for{$for} = 1;
  }
  my @fors = keys %for;
  if($#fors == 0){
    $this->{for_uid} = $fors[0];
  } else {
    $this->{for_uid} = \@fors;
  }
  # Get Transforms
  $m = $ds->Search("(3006,0010)[<0>](3006,00c0)[<1>](3006,00c2)");
  for my $i (@$m){
    my $fi = $i->[0];
    my $ti = $i->[1];
    my $to_for = $ds->Get("(3006,0010)[$fi](0020,0052)");
    $this->{xFormFors}->{$to_for} = 1;
    my $from_for = $ds->Get("(3006,0010)[$fi](3006,00c0)[$ti](3006,00c2)");
    $this->{xFormFors}->{$from_for} = 1;
    my $xform_type = $ds->Get("(3006,0010)[$fi](3006,00c0)[$ti](3006,00c4)");
    my $xform_matrix = $ds->Get("(3006,0010)[$fi](3006,00c0)[$ti](3006,00c6)");
    my $xform_comment = $ds->Get("(3006,0010)[$fi](3006,00c0)[$ti](3006,00c8)");
    $this->{transforms}->{$from_for}->{$to_for} = {
       type => $xform_type,
       comment => $xform_comment,
       matrix => (ref($xform_matrix) == "ARRAY") ? join("\\", @$xform_matrix):
         "not an ARRAY",
    };
  }
  # Find Referenced Study, Series
  my @ser_ref;
  $m = $ds->Search(
    "(3006,0010)[<0>](3006,0012)[<1>](3006,0014)[<2>](0020,000e)");
  for my $i (@$m){
    my $for_i = $i->[0];
    my $st_i = $i->[1];
    my $se_i = $i->[2];
    my $ref_for = $ds->Get("(3006,0010)[$for_i](0020,0052)");
    $this->{RefFors}->{$ref_for} = 1;
    my $ref_study = $ds->Get(
      "(3006,0010)[$for_i](3006,0012)[$st_i](0008,1155)");
    my $ref_series = $ds->Get(
      "(3006,0010)[$for_i](3006,0012)[$st_i](3006,0014)[$se_i](0020,000e)"
    );
    my $i_r = $ds->Search(
      "(3006,0010)[$for_i](3006,0012)[$st_i](3006,0014)[$se_i](3006,0016)" .
      "[<0>](0008,1155)"
    );
    my @img_list;
    for my $i (@$i_r){
      my $sop_inst = $ds->Get(
        "(3006,0010)[$for_i](3006,0012)[$st_i](3006,0014)[$se_i](3006,0016)" .
        "[$i->[0]](0008,1155)");
      push(@img_list, $sop_inst);
    }
    my $num_images = scalar @img_list;
    push(@ser_ref, {
      img_list => \@img_list,
      ref_for => $ref_for,
      ref_study => $ref_study,
      ref_series => $ref_series,
      num_images => $num_images,
    });
  }
  $this->{series_refs} = \@ser_ref;
  ##########################################
  # New Build ROI table
  $m = $ds->Search("(3006,0020)[<0>](3006,0022)");
  my %Rois;
  for my $i (@$m){
    my $roi_num = $ds->Get("(3006,0020)[$i->[0]](3006,0022)");
    my $ref_for = $ds->Get("(3006,0020)[$i->[0]](3006,0024)");
    my $roi_name = $ds->Get("(3006,0020)[$i->[0]](3006,0026)");
    my $roi_alg = $ds->Get("(3006,0020)[$i->[0]](3006,0036)");
    $Rois{$roi_num} = {
      roi_num => $roi_num,
      ref_for => $ref_for,
      roi_name => $roi_name,
      gen_alg => $roi_alg,
    };
  }
  $m = $ds->Search("(3006,0080)[<0>](3006,0084)");
  observ:
  for my $i (@$m){
    my $roi_num = $ds->Get("(3006,0080)[$i->[0]](3006,0084)");
    unless(defined $roi_num) { next observ }
    my $roi_obser_label = $ds->Get("(3006,0080)[$i->[0]](3006,0085)");
    if(defined $roi_obser_label) {
      $Rois{$roi_num}->{roi_obser_label} = $roi_obser_label;
    }
    my $roi_obser_desc = $ds->Get("(3006,0080)[$i->[0]](3006,0085)");
    if(defined $roi_obser_desc) {
      $Rois{$roi_num}->{roi_obser_desc} = $roi_obser_desc;
    }
    my $roi_interpreted_type = $ds->Get("(3006,0080)[$i->[0]](3006,00A4)");
    unless(defined $roi_interpreted_type) { $roi_interpreted_type = "" }
    $Rois{$roi_num}->{roi_interpreted_type} = $roi_interpreted_type;
  }
  for my $i (keys %Rois){
    my $tot_points = 0;
    my $tot_contours = 0;
    my %contour_types;
    my @sop_refs;
    my $color;
    open my $fh, "<", $file;
    my ($max_x, $min_x, $max_y, $min_y, $max_z, $min_z);
    $m = $ds->Search("(3006,0039)[<0>](3006,0084)", $i);
    for my $j (@$m){
      $color = $ds->Get("(3006,0039)[$j->[0]](3006,002a)");
      if (defined $color) {
        for my $j (0 .. $#{$color}){
          $Rois{$i}->{color}->[$j] = $color->[$j]
        }
      }
      my $m1 = $ds->Search("(3006,0039)[$j->[0]](3006,0040)[<0>](3006,0050)");
      my @contours;
      for my $k (@$m1){
        my $type = $ds->Get(
          "(3006,0039)[$j->[0]](3006,0040)[$k->[0]](3006,0042)");
        my $num_pts = $ds->Get(
          "(3006,0039)[$j->[0]](3006,0040)[$k->[0]](3006,0046)");
        my $data = $ds->Get(
          "(3006,0039)[$j->[0]](3006,0040)[$k->[0]](3006,0050)");
        my $data_len = $ds->EleLenInFile(
          "(3006,0039)[$j->[0]](3006,0040)[$k->[0]](3006,0050)");
        my $data_pos = $ds->FilePos(
          "(3006,0039)[$j->[0]](3006,0040)[$k->[0]](3006,0050)");
        my $ref_type = $ds->Get(
          "(3006,0039)[$j->[0]](3006,0040)[$k->[0]](3006,0016)[0](0008,1150)");
        my $ref = $ds->Get(
          "(3006,0039)[$j->[0]](3006,0040)[$k->[0]](3006,0016)[0](0008,1155)");
        $tot_contours += 1;
        $tot_points += $num_pts;
        $contour_types{$type} += 1;
        if(defined $ref){ push @sop_refs, $ref }
        push(@contours, {
          type => $type,
          num_pts => $num_pts,
          ref => $ref,
          ref_type => $ref_type,
          length => $data_len,
          ds_offset => $data_pos - $this->{dataset_start_offset},
        });
        if($tot_points > 2){
          seek($fh, $data_pos, 0);
          my $data;
          my $count = read $fh, $data, $data_len;
          unless($count == $data_len) {
            die "premature EOF ($count vs $data_len)";
          }
          my @data = split(/\\/, $data);
          for my $n (0 .. $num_pts - 1){
            my $xi = ($n * 3);
            my $yi = ($n * 3) + 1;
            my $zi = ($n * 3) + 2;
            my $x = $data[$xi];
            my $y = $data[$yi];
            my $z = $data[$zi];
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
      $Rois{$i}->{contours} = \@contours;
    }
    close ($fh);
    $Rois{$i}->{tot_points} = $tot_points;
    $Rois{$i}->{tot_contours} = $tot_contours;
    for my $j (keys %contour_types){
      $Rois{$i}->{contour_types}->{$j} = $contour_types{$j};
    }
    for my $j (0 .. $#sop_refs){
      $Rois{$i}->{sop_refs}->{$j} = $sop_refs[$j];
    }
    if ($tot_points > 2) {
      $Rois{$i}->{max_x} = $max_x;
      $Rois{$i}->{min_x} = $min_x;
      $Rois{$i}->{max_y} = $max_y;
      $Rois{$i}->{min_y} = $min_y;
      $Rois{$i}->{max_z} = $max_z;
      $Rois{$i}->{min_z} = $min_z;
    }
  }
  ##########################################
  $this->{rois} = \%Rois;
  my %contour_by_ct;
  for my $roi (keys %Rois){
    contour:
    for my $contour (@{$Rois{$roi}->{contours}}){
      unless(exists($contour->{ref}) && $contour->{type} eq "CLOSED_PLANAR"){
        next contour;
      }
      unless(exists $contour_by_ct{$contour->{ref}}->{$roi}){
        $contour_by_ct{$contour->{ref}}->{$roi} = [];
      }
      push(@{$contour_by_ct{$contour->{ref}}->{$roi}}, {
        ds_offset => $contour->{ds_offset},
        length => $contour->{length},
        num_pts => $contour->{num_pts},
      });
    }
  }
  $this->{contours_by_ct} = \%contour_by_ct;
}
sub ProcessPlan{
  my($this, $try)  = @_;
  $this->{ref_struct_set} = $try->{dataset}->Get("(300c,0060)[0](0008,1155)");
  $this->{label} = $try->{dataset}->Get("(300a,0002)");
  $this->{name} = $try->{dataset}->Get("(300a,0003)");
  $this->{num_beams} = $try->{dataset}->Get("(300a,0070)[0](300a,0080)");
  my $fraction_sequences = $try->{dataset}->Get("(300a,0070)");
  if(defined($fraction_sequences) && ref($fraction_sequences) eq "ARRAY"){
    $this->{num_fraction_groups} = scalar @$fraction_sequences;
  }
}
sub ProcessImage{
  my($this, $try)  = @_;
  $this->{ref_plan} = $try->{dataset}->Get("(300c,0002)[0](0008,1155)");
  $this->{ref_beam} = $try->{dataset}->Get("(300c,0006)");
  $this->{label} =  $try->{dataset}->Get("(3002,0002)");
}
sub ProcessRegistration{
  my($this, $try)  = @_;
  my $regs = $try->{dataset}->Search("(0070,0308)[<0>](0070,0309)[<1>]".
    "(0070,030a)[<2>]");
  if($regs && ref($regs) eq "ARRAY"){
    for my $i (@$regs){
      my $i1 = $i->[0];
      my $i2 = $i->[1];
      my $i3 = $i->[2];
      my $for_index = "(0070,0308)[$i1](0020,0052)";
      my $for = $try->{dataset}->Get($for_index);
      my $mtx_type_index = "(0070,0308)[$i1]" .
       "(0070,0309)[$i2](0070,030a)[$i3](0070,030c)";
      my $mtx_type = $try->{dataset}->Get($mtx_type_index);
      my $mtx_index = "(0070,0308)[$i1]" .
       "(0070,0309)[$i2](0070,030a)[$i3](3006,00c6)";
      my $mtx = $try->{dataset}->Get($mtx_index);
      $this->{regs}->[$i1]->{FoR} = $for;
      $this->{regs}->[$i1]->{transforms}->[$i2] = {
        type => $mtx_type,
        mtx => $mtx,
      };
    }
  }
  my $reg_refs = $try->{dataset}->Search("(0070,0308)[<0>](0008,1140)");
  if(defined($reg_refs) && ref($reg_refs) eq "ARRAY"){
    for my $ii (@$reg_refs){
      my $i = $ii->[0];
      my $img_refs = RefImageSeq($this, $try, "(0070,0308)[$i]");
      $this->{regs}->[$i]->{refs} = $img_refs;
    }
  }
  ProcessCommonInstanceReferenceModule($this, $try);
}
sub ProcessCommonInstanceReferenceModule{
  my($this, $try)  = @_;
  my $this_study_ref = $try->{dataset}->Search("(0008,1115)[<0>](0020,000e)");
  if(
    defined($this_study_ref) &&
    ref($this_study_ref) eq "ARRAY"
  ){
    for my $ii (@$this_study_ref) {
      my $i = $ii->[0];
      my $series_uid = $try->{dataset}->Get("(0008,1115)[$i](0020,000e)");
      my $image_refs = RefInstanceSeq($this, $try, "(0008,1115)[$i]");
      $this->{series_refs}->{$series_uid} = $image_refs;
    }
  }
  my $ot_study_ref = $try->{dataset}->Search("(0008,1200)[<0>](0020,000d)");
  if(
    defined($ot_study_ref) && ref($ot_study_ref) eq "ARRAY"
  ){
    for my $ss (@$ot_study_ref){
      my $s = $ss->[0];
      my $study_uid = $try->{dataset}->Get("(0008,1200)[$s]" .
            "(0020,000d)");
      my $series_ref = $try->{dataset}->Search("(0008,1200)[$s]" .
        "(0008,1115)[<0>](0020,000e)");
      if(defined($series_ref) && ref($series_ref) eq "ARRAY"){
        for my $ii (@$this_study_ref) {
          my $i = $ii->[0];
          my $series_uid = $try->{dataset}->Get("(0008,1200)[$s]" .
            "(0008,1115)[$i](0020,000e)");
          my $image_refs = RefInstanceSeq($this, $try,
            "(0008,1200)[$s](0008,1115)[$i]");
          $this->{study_refs}->{$study_uid}->{$series_uid} = $image_refs;
        }
      }
    }
  }
}
sub RefIiSeq{
  my($this, $try, $item_sig, $ele) = @_;
  my $result;
  my $img_ref_list = $try->{dataset}->Search("$item_sig$ele" . "[<0>]" .
    "(0008,1155)");
  if(defined($img_ref_list) && ref($img_ref_list) eq "ARRAY"){
    for my $ii (@$img_ref_list){
      my $i = $ii->[0];
      my $sop_inst = $try->{dataset}->Get("$item_sig$ele" . "[$i]" .
        "(0008,1155)");
      my $sop_class = $try->{dataset}->Get("$item_sig$ele" . "[$i]" .
        "(0008,1150)");
      $result->{$sop_class}->{$sop_inst} = 1;
    }
  }
  return $result;
}
sub RefImageSeq{
  my($this, $try, $item_sig) = @_;
  return RefIiSeq($this, $try, $item_sig, "(0008,1140)");
}
sub RefInstanceSeq{
  my($this, $try, $item_sig) = @_;
  return RefIiSeq($this, $try, $item_sig, "(0008,114a)");
}
my $SopClassProcessing = {
  "1.2.840.10008.5.1.4.1.1.481.3" => \&ProcessStruct,
  "1.2.840.10008.5.1.4.1.1.481.2" => \&ProcessDose,
  "1.2.840.10008.5.1.4.1.1.481.5" => \&ProcessPlan,
  "1.2.840.10008.5.1.4.1.1.481.8" => \&ProcessPlan,
  '1.2.840.10008.5.1.4.1.1.481.1' => \&ProcessImage,
  '1.2.840.10008.5.1.4.1.1.66.1' =>  \&ProcessRegistration,
};
my $ModalityProcessing = {
  RTSTRUCT => \&ProcessStruct,
  RTDOSE => \&ProcessDose,
  RTPLAN => \&ProcessPlan,
  RTIMAGE => \&ProcessImage,
  REG => \&ProcessRegistration,
};
sub Analyze {
  my($try, $file_name) = @_;
unless(defined $file_name) {
  my $i = 0;
  my $msg = "";
  while(caller($i)){
    my @foo = caller($i);
    my $file = $foo[1];
    my $line = $foo[2];
    $msg .= "\nline $line of $file";
    $i += 1;
  }
  die "File undefined in Analyze:$msg";
}
  my $ds = $try->{dataset};
  my $study_uid = $ds->Get("(0020,000d)");
  my $series_uid = $ds->Get("(0020,000e)");
  my $img_type = $ds->Get("(0008,0008)");
  unless(defined $img_type) { $img_type = "<undef>" }
  if(ref($img_type) eq "ARRAY"){
    $img_type = join("\\", @$img_type);
  }
  my $sop_inst_uid = $ds->Get("(0008,0018)");
  my $sop_class_uid = $ds->Get("(0008,0016)");
  my $modality = $ds->Get("(0008,0060)");
  my $for_uid = $ds->Get("(0020,0052)");
  my $patient_name = $ds->Get("(0010,0010)");
  my $patient_id = $ds->Get("(0010,0020)");
  my $iop = $ds->Get("(0020,0037)");
  my $ipp = $ds->Get("(0020,0032)");
  unless(defined $for_uid){ $for_uid = "<undef>"};
  my $analysis = {
    analyzer_version => $version,
    xfr_stx => $try->{xfr_stx},
    study_uid => $study_uid,
    series_uid => $series_uid,
    img_type => $img_type,
    sop_inst_uid => $sop_inst_uid,
    sop_class_uid => $sop_class_uid,
    modality => $modality,
    for_uid => $for_uid,
    patient_name => $patient_name,
    patient_id => $patient_id,
    dataset_digest => $try->{dataset_digest},
  };
  my $pix_desc = $ds->GetEle("(7fe0,0010)");
  if(defined $pix_desc){
    my $pos = $pix_desc->{file_pos};
    my $len = $pix_desc->{ele_len_in_file};
    my $command = "PixelDigest.pl \"$file_name\" $pos $len";
    open my $fh, "$command|";
    my $line = <$fh>;
    my $pix_digest;
    if($line =~ /^Digest:\s*(.*)$/){
      $pix_digest = $1;
    }
    $analysis->{pix_pos} = $pos;
    $analysis->{pixel_length} = $len;
    $analysis->{pixel_digest} = $pix_digest;
    my $window_center = $ds->Get("(0028,1050)[0]");
    my $window_width = $ds->Get("(0028,1051)[0]");
    if ($modality eq "CT") {
      unless (defined $window_center) {$window_center = 1000}
      unless (defined $window_width) {$window_width = 1000}
    }
    if (defined $window_center){$analysis->{window_center} = $window_center}
    if (defined $window_width){$analysis->{window_width} = $window_width}
  }
  my $normalizing_xform;
  if(defined($iop) && ref($iop) eq "ARRAY"){
    my @norm;
    for my $i (@$iop) { push(@norm, sprintf("%0.4f", $i)) }
    for my $i (0 .. $#norm){
      if($norm[$i] == 0){ $norm[$i] = "0"}
      if($norm[$i] == 1){ $norm[$i] = "1"}
      if($norm[$i] == -1){ $norm[$i] = "-1"}
    }
    my $norm_iop = join("\\", @norm);
    $analysis->{norm_iop} = $norm_iop;
    $normalizing_xform = Posda::Transforms::NormalizingImageOrientation($iop);
  }
  if(defined($ipp) && ref($ipp) eq "ARRAY"){
    my $norm_x = sprintf("%0.4f", $ipp->[0]);
    $analysis->{norm_x} = $norm_x;
    my $norm_y = sprintf("%0.4f", $ipp->[1]);
    $analysis->{norm_y} = $norm_y;
    my $norm_z = sprintf("%0.4f", $ipp->[2]);
    $analysis->{norm_z} = $norm_z;
    if(defined $normalizing_xform){
      my $rot_ipp = Posda::Transforms::ApplyTransform($normalizing_xform, $ipp);
      my $norm_pos = sprintf("%0.4f", $rot_ipp->[2]);
      $analysis->{normalized_loc} = $norm_pos;
    }
  }
  if(exists $try->{dataset_start_offset}){
    $analysis->{dataset_start_offset} = 
      $try->{dataset_start_offset};
  } else {
    $analysis->{dataset_start_offset} = 0;
  }
  unless(defined $sop_inst_uid) { 
    return;
  }
  if(defined $study_uid){
    for my $i (@$StudyAttrs){
      my $value = $ds->Get($i);
      if(ref($value) eq "ARRAY"){
        $value = join('\\', @$value);
      }
      unless(defined($value)){$value = "<undef>"}
      $analysis->{$i} = $value;
    }
  }
  if(defined $series_uid){
    for my $i (@$SeriesAttrs){
      my $value = $ds->Get($i);
      if(ref($value) eq "ARRAY"){
        $value = join('\\', @$value);
      }
      unless(defined($value)){$value = "<undef>"}
      $analysis->{$i} = $value;
    }
  }
  for my $i (@$ForAttrs){
    my $value = $ds->Get($i);
    if(ref($value) eq "ARRAY"){
      $value = join('\\', @$value);
    }
    unless(defined($value)){$value = "<undef>"}
    $analysis->{$i} = $value;
  }
  if(defined $sop_class_uid){
    if(exists($HasFrameOfReference->{$sop_class_uid})){
      for my $i (@$ForAttrs){
        GetAttr($analysis, $ds, $i);
      }
    }
    if(exists($HasWindowLevel->{$sop_class_uid})){
      for my $i (@$WindowLevelAttrs){
        GetAttr($analysis, $ds, $i);
      }
    }
    if(exists($HasImagePixel->{$sop_class_uid})){
      for my $i (@$ImageAttrs){
        GetAttr($analysis, $ds, $i);
      }
    }
    if(exists($HasImageGeometry->{$sop_class_uid})){
      for my $i (@$ImageGeometryAttrs){
        GetAttr($analysis, $ds, $i);
      }
    }
    if(exists($IsMultiFrame->{$sop_class_uid})){
      for my $i (@$MultiFrameAttrs){
        GetAttr($analysis, $ds, $i);
      }
    }
    if(exists $SopClassAttrs->{$sop_class_uid}){
      for my $i (@{$SopClassAttrs->{$sop_class_uid}}){
        GetAttr($analysis, $ds, $i);
      }
    }
    if(exists $SopClassProcessing->{$sop_class_uid}){
      &{$SopClassProcessing->{$sop_class_uid}}($analysis, $try, $file_name);
    }
  }
  return $analysis;
}
sub GetAttr{
  my($analysis, $ds, $ele) = @_;
  my $value = $ds->Get($ele);
  if(ref($value) eq "ARRAY"){
    $value = join('\\', @$value);
  }
  unless(defined($value)){$value = "<undef>"}
  $analysis->{$ele} = $value;
}
1;
