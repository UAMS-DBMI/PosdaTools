#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package Posda::SimpleDicomAnalysis;
use Posda::FlipRotate;
use Time::HiRes qw( gettimeofday tv_interval );

my $StudyAttrs = [
  "(0010,0010)", #Patient's Name
  "(0010,0020)", #Patient's ID
  "(0010,0030)", #Patient's Birth Date
  "(0010,0040)", #Patient's Sex
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
  "(0018,1030)", #Protocol Name
  "(0008,103e)", #Series Description
  "(0018,5100)", #Patient Position
  "(0008,0070)", #Manufacturer
  "(0008,0080)", #Institution Name
  "(0008,1090)", #Manufacturer's Model Name
];
my $ForAttrs = [
  "(0020,0052)", #Frame of Reference UID
  "(0020,1040)", #Position Reference Indicator
];
my $ModalityAttrs = {
  RTIMAGE => [
    "(0020,0037)", #Image Orientation Patient
    "(0020,1041)", #Slice Location
    "(0028,0004)", #Photometric Interpretation
    "(0028,0010)", #Rows
    "(0028,0011)", #Columns
    "(0028,0030)", #Pixel Spacing
    "(0028,0100)", #Bits Allocated
    "(0028,0101)", #Bits Stored
    "(0028,0102)", #High Bit
    "(0028,0103)", #Pixel Representation
    "(0028,1050)", #Window Center
    "(0028,1051)", #Window Width
    "(0028,1052)", #Rescale Intercept
    "(0028,1053)", #Rescale Slope
    "(0028,1055)", #Window Center & Width Explanation
  ],
  RG => [
    "(0020,0013)", #Image Type
    "(0028,0002)", #Samples Per Pixel
    "(0028,0004)", #Photometric Interpretation
    "(0028,0010)", #Rows
    "(0028,0011)", #Columns
    "(0028,0030)", #Pixel Spacing
    "(0028,0100)", #Bits Allocated
    "(0028,0101)", #Bits Stored
    "(0028,0102)", #High Bit
    "(0028,0103)", #Pixel Representation
    "(0028,1050)", #Window Center
    "(0028,1051)", #Window Width
    "(0028,1052)", #Rescale Intercept
    "(0028,1053)", #Rescale Slope
    "(0028,1055)", #Window Center & Width Explanation
  ],
  CT => [
    "(0018,0050)", #Slice Thickness
    "(0020,0032)", #Image Position Patient
    "(0020,0037)", #Image Orientation Patient
    "(0020,1041)", #Slice Location
    "(0020,0013)", #Image Type
    "(0028,0002)", #Samples Per Pixel
    "(0028,0004)", #Photometric Interpretation
    "(0028,0010)", #Rows
    "(0028,0011)", #Columns
    "(0028,0030)", #Pixel Spacing
    "(0028,0100)", #Bits Allocated
    "(0028,0101)", #Bits Stored
    "(0028,0102)", #High Bit
    "(0028,0103)", #Pixel Representation
    "(0028,1050)", #Window Center
    "(0028,1051)", #Window Width
    "(0028,1052)", #Rescale Intercept
    "(0028,1053)", #Rescale Slope
    "(0028,1055)", #Window Center & Width Explanation
  ],
  OT => [
    "(0018,0050)", #Slice Thickness
    "(0020,0032)", #Image Position Patient
    "(0020,0037)", #Image Orientation Patient
    "(0020,1041)", #Slice Location
    "(0020,0013)", #Image Type
    "(0028,0002)", #Samples Per Pixel
    "(0028,0004)", #Photometric Interpretation
    "(0028,0010)", #Rows
    "(0028,0011)", #Columns
    "(0028,0030)", #Pixel Spacing
    "(0028,0100)", #Bits Allocated
    "(0028,0101)", #Bits Stored
    "(0028,0102)", #High Bit
    "(0028,0103)", #Pixel Representation
    "(0028,1050)", #Window Center
    "(0028,1051)", #Window Width
    "(0028,1052)", #Rescale Intercept
    "(0028,1053)", #Rescale Slope
    "(0028,1055)", #Window Center & Width Explanation
  ],
  SC => [
    "(0018,0050)", #Slice Thickness
    "(0020,0032)", #Image Position Patient
    "(0020,0037)", #Image Orientation Patient
    "(0020,1041)", #Slice Location
    "(0020,0013)", #Image Type
    "(0028,0002)", #Samples Per Pixel
    "(0028,0004)", #Photometric Interpretation
    "(0028,0010)", #Rows
    "(0028,0011)", #Columns
    "(0028,0030)", #Pixel Spacing
    "(0028,0100)", #Bits Allocated
    "(0028,0101)", #Bits Stored
    "(0028,0102)", #High Bit
    "(0028,0103)", #Pixel Representation
    "(0028,1050)", #Window Center
    "(0028,1051)", #Window Width
    "(0028,1052)", #Rescale Intercept
    "(0028,1053)", #Rescale Slope
    "(0028,1055)", #Window Center & Width Explanation
  ],
  MR => [
    "(0018,0050)", #Slice Thickness
    "(0020,0032)", #Image Position Patient
    "(0020,0037)", #Image Orientation Patient
    "(0020,1041)", #Slice Location
    "(0028,0002)", #Samples Per Pixel
    "(0028,0004)", #Photometric Interpretation
    "(0028,0010)", #Rows
    "(0028,0011)", #Columns
    "(0028,0030)", #Pixel Spacing
    "(0028,0100)", #Bits Allocated
    "(0028,0101)", #Bits Stored
    "(0028,0102)", #High Bit
    "(0028,0103)", #Pixel Representation
    "(0028,1050)", #Window Center
    "(0028,1051)", #Window Width
    "(0028,1052)", #Rescale Intercept
    "(0028,1053)", #Rescale Slope
    "(0028,1055)", #Window Center & Width Explanation
  ],
  PT => [
    "(0018,0050)", #Slice Thickness
    "(0020,0032)", #Image Position Patient
    "(0020,0037)", #Image Orientation Patient
    "(0020,1041)", #Slice Location
    "(0028,0002)", #Samples Per Pixel
    "(0028,0004)", #Photometric Interpretation
    "(0028,0010)", #Rows
    "(0028,0011)", #Columns
    "(0028,0030)", #Pixel Spacing
    "(0028,0100)", #Bits Allocated
    "(0028,0101)", #Bits Stored
    "(0028,0102)", #High Bit
    "(0028,0103)", #Pixel Representation
    "(0028,1050)", #Window Center
    "(0028,1051)", #Window Width
    "(0028,1052)", #Rescale Intercept
    "(0028,1053)", #Rescale Slope
    "(0028,1055)", #Window Center & Width Explanation
  ],
  RTSTRUCT => [
   "(3006,0002)", #Structure Set Label 
   "(3006,0004)", #Structure Set Name 
   "(3006,0008)", #Structure Set Date 
   "(3006,0009)", #Structure Set Time 
  ],
  RTPLAN => [
  ],
  RTDOSE => [
    "(0018,0050)", #Slice Thickness
    "(0020,0032)", #Image Position Patient
    "(0020,0037)", #Image Orientation Patient
    "(0020,1041)", #Slice Location
    "(0028,0002)", #Samples Per Pixel
    "(0028,0004)", #Photometric Interpretation
    "(0028,0010)", #Rows
    "(0028,0011)", #Columns
    "(0028,0030)", #Pixel Spacing
    "(0028,0100)", #Bits Allocated
    "(0028,0101)", #Bits Stored
    "(0028,0102)", #High Bit
    "(0028,0103)", #Pixel Representation
    "(0028,0008)", #Number of Frames
    "(0028,0009)", #Frame Increment Pointer
    "(3004,0002)", #Dose Units
    "(3004,0004)", #Dose Type
    "(3004,000a)", #Dose Summation Type
    "(3004,000c)", #Grid Frame Offset Vector
    "(3004,000e)", #Dose Grid Scaling
    "(3004,0014)", #Tissue Heterogeneity Correction
    "(3005,\"ITC_DVH_Computation \",50)", #DVH source
    "(300c,0002)[0](0008,1150)", #Referenced Plan SOP Class
    "(300c,0002)[0](0008,1155)", #Referenced Plan SOP Instance
  ],
  REG => [
    "(0020,0052)", #Frame of Reference UID
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
#    my $img_seq = $ds->Get(
#      "(3006,0010)[$for_i](3006,0012)[$st_i](3006,0014)[$se_i](3006,0016)"
#    );
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
  # Build ROI table
  my %Roi;
  my $command = "ExtractRoiInfo.pl \"$file\"";
  open my $fh, "$command|";
  line:
  while(my $line = <$fh>){
    chomp $line;
    my @fields = split(/\|/, $line);
    if($#fields == 2){
      $Roi{$fields[0]}->{$fields[1]} = $fields[2];
    } elsif($#fields == 3 && $fields[1] eq "contour_types"){
      $Roi{$fields[0]}->{contour_types}->{$fields[2]} = $fields[3];
    } elsif($#fields == 3 && $fields[1] eq "sop_refs"){
      $Roi{$fields[0]}->{sop_refs}->[$fields[2]] = $fields[3];
    } elsif($#fields == 3 && $fields[1] eq "color"){
      $Roi{$fields[0]}->{color}->[$fields[2]] = $fields[3];
    } elsif($#fields == 1){
      $Roi{$fields[0]}->{$fields[1]} = "";
    } else {
      print STDERR "Bad line from ExtractRoiInfo:\n\t\"$line\"\n";
    }
  }
  $this->{rois} = \%Roi;
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
  if(defined($iop)){
    my @norm;
    for my $i (@$iop) { push(@norm, sprintf("%0.4f", $i)) }
    for my $i (0 .. $#norm){
      if($norm[$i] == 0){ $norm[$i] = "0"}
      if($norm[$i] == 1){ $norm[$i] = "1"}
      if($norm[$i] == -1){ $norm[$i] = "-1"}
    }
    my $norm_iop = join("\\", @norm);
    $analysis->{norm_iop} = $norm_iop;
  }
  if(defined($ipp)){
    my $norm_x = sprintf("%0.4f", $ipp->[0]);
    $analysis->{norm_x} = $norm_x;
    my $norm_y = sprintf("%0.4f", $ipp->[1]);
    $analysis->{norm_y} = $norm_y;
    my $norm_z = sprintf("%0.4f", $ipp->[2]);
    $analysis->{norm_z} = $norm_z;
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
  if(defined $modality){
    if(exists $ModalityAttrs->{$modality}){
      for my $i (@{$ModalityAttrs->{$modality}}){
        my $value = $ds->Get($i);
        if(ref($value) eq "ARRAY"){
          $value = join('\\', @$value);
        }
        unless(defined($value)){$value = "<undef>"}
        $analysis->{$i} = $value;
      }
    }
    if(exists $ModalityProcessing->{$modality}){
      &{$ModalityProcessing->{$modality}}($analysis, $try, $file_name);
    }
  }
  return $analysis;
}
my $extra = {
  RTSTRUCT => sub {
    my($analysis, $try) = @_;
    my $rl = $try->{dataset}->Search("(3006,0039)[<0>](3006,0084)");
    for my $r (@$rl){
      my $roi_i = $r->[0];
      my $roi_num = $try->{dataset}->Get("(3006,0039)[$roi_i](3006,0084)");
      my $m = $try->{dataset}->Search("(3006,0039)[$roi_i](3006,0040)[<0>](3006,0016)[0](0008,1155)");
      for my $i (@$m){
        my $ct_sop = 
          $try->{dataset}->Get("(3006,0039)[$roi_i](3006,0040)[$i->[0]](3006,0016)[0](0008,1155)");
        my $contour = $try->{dataset}->Get("(3006,0039)[$roi_i](3006,0040)[$i->[0]](3006,0050)");
        my $num_pts = $try->{dataset}->Get("(3006,0039)[$roi_i](3006,0040)[$i->[0]](3006,0046)");
        unless(exists $analysis->{structs_by_ct}->{$ct_sop}->{$roi_num}){
          $analysis->{structs_by_ct}->{$ct_sop}->{$roi_num} = [];
        }
        push(@{$analysis->{structs_by_ct}->{$ct_sop}->{$roi_num}}, $contour);
      }
    }
  },
};
sub ExtraAnalysis{
  my($analysis, $try) = @_;
  my $modality = $analysis->{modality};
  if(defined($modality) && exists $extra->{$modality}){
    &{$extra->{$modality}}($analysis, $try);
  }
}
1;
