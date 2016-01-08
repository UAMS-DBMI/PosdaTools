#$Source: /home/bbennett/pass/archive/Posda/include/Posda/DicomAnalysis.pm,v $
#$Date: 2010/09/15 16:00:38 $
#$Revision: 1.14 $
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package Posda::DicomAnalysis;
use Posda::Try;

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
  RTSTRUCT => [
   "(3006,0002)", #Structure Set Label 
   "(3006,0004)", #Structure Set Name 
   "(3006,0008)", #Structure Set Date 
   "(3006,0008)", #Structure Set Time 
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
    "(300c,0002)[0](0008,1150)", #Referenced Plan SOP Class
    "(300c,0002)[0](0008,1155)", #Referenced Plan SOP Instance
  ],
};
sub ProcessStruct{
  my($this, $try)  = @_;

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
    $this->{by_file}->{$try->{filename}}->{for_uid} = $fors[0];
  } else {
    $this->{by_file}->{$try->{filename}}->{for_uid} = \@fors;
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
    my $ref_study = $ds->Get(
      "(3006,0010)[$for_i](3006,0012)[$st_i](0008,1155)");
    my $ref_series = $ds->Get(
      "(3006,0010)[$for_i](3006,0012)[$st_i](3006,0014)[$se_i](0020,000e)");
    my $img_seq = $ds->Get(
      "(3006,0010)[$for_i](3006,0012)[$st_i](3006,0014)[$se_i](3006,0016)"
    );
    my $num_images = scalar @$img_seq;
    push(@ser_ref, {
      ref_for => $ref_for,
      ref_study => $ref_study,
      ref_series => $ref_series,
      num_images => $num_images,
    });
  }
  $this->{by_file}->{$try->{filename}}->{series_refs} = \@ser_ref;
  # Build ROI table
  my %Roi;
  $m = $ds->Search("(3006,0020)[<0>](3006,0022)");
  for my $i (@$m){
    my $roi_num = $ds->Get("(3006,0020)[$i->[0]](3006,0022)");
    my $ref_for = $ds->Get("(3006,0020)[$i->[0]](3006,0024)");
    my $roi_name = $ds->Get("(3006,0020)[$i->[0]](3006,0026)");
    my $roi_alg = $ds->Get("(3006,0020)[$i->[0]](3006,0036)");
    $Roi{$roi_num} = {
      roi_num => $roi_num,
      ref_for => $ref_for,
      roi_name => $roi_name,
      gen_alg => $roi_alg,
    };
  }
  for my $i (keys %Roi){
    my $tot_points = 0;
    my $tot_contours = 0;
    my %contour_types;
    my @sop_refs;
    my ($max_x, $min_x, $max_y, $min_y, $max_z, $min_z);
    $m = $ds->Search("(3006,0039)[<0>](3006,0084)", $i);
    for my $j (@$m){
      my $color = $ds->Get("(3006,0039)[$j->[0]](3006,002a)");
      my $m1 = $ds->Search("(3006,0039)[$j->[0]](3006,0040)[<0>](3006,0050)");
      for my $k (@$m1){
        my $type = $ds->Get(
          "(3006,0039)[$j->[0]](3006,0040)[$k->[0]](3006,0042)");
        my $num_pts = $ds->Get(
          "(3006,0039)[$j->[0]](3006,0040)[$k->[0]](3006,0046)");
        my $data = $ds->Get(
          "(3006,0039)[$j->[0]](3006,0040)[$k->[0]](3006,0050)");
        my $ref = $ds->Get(
          "(3006,0039)[$j->[0]](3006,0040)[$k->[0]](3006,0016)[0](0008,1155)");
        $tot_contours += 1; 
        $tot_points += $num_pts; 
        $contour_types{$type} += 1;
        if(defined $ref){ push @sop_refs, $ref }
        for my $n (0 .. $num_pts - 1){
          my $xi = ($n * 3);
          my $yi = ($n * 3) + 1;
          my $zi = ($n * 3) + 2;
          my $x = $data->[$xi];
          my $y = $data->[$yi];
          my $z = $data->[$zi];
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
    $Roi{$i}->{tot_points} = $tot_points;
    $Roi{$i}->{tot_contours} = $tot_contours;
    $Roi{$i}->{contour_types} = \%contour_types;
    $Roi{$i}->{sop_refs} = \@sop_refs;
    $Roi{$i}->{max_x} = $max_x;
    $Roi{$i}->{min_x} = $min_x;
    $Roi{$i}->{max_y} = $max_y;
    $Roi{$i}->{min_y} = $min_y;
    $Roi{$i}->{max_z} = $max_z;
    $Roi{$i}->{min_z} = $min_z;
  }
  $this->{by_file}->{$try->{filename}}->{rois} = \%Roi;
}
sub ProcessReg{
  my($this, $ds) = @_
}
sub ProcessFiles{
  my($this) = @_;
}
sub ProcessStudies{
  my($this) = @_;
}
my $ModalityProcessing = {
  RTSTRUCT => \&ProcessStruct,
  REG => \&ProcessReg,
};
my $PostProcessing = [
  \&ProcessStudies,
  \&ProcessFiles,
];
sub set_elements{
  my($analysis) = @_;
  my $foo = sub {
    my($element, $sig) = @_;
    my $index = 0;
    my $processed = "";
    my $remaining = $sig;
    while($remaining ne "") {
      if($remaining =~ /^([^\[]+)\[([^\]]+)\](.*)$/){
        $processed .= $1;
        my $existing_index = $2;
        $remaining = $3;
        $processed .= "[<$index>]";
        $index += 1;
      } else {
        $processed .= $remaining;
        $remaining = "";
      }
    }
    $analysis->{elements}->{$processed} = 1;
  }
}
sub make_wanted {
  my($analysis) = @_;
  my $foo = sub {
    my($try) = @_;
    my $ds = $try->{dataset};
    $ds->MapPvt(set_elements $analysis);
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
    $analysis->{by_file}->{$try->{filename}} = {
      xfr_stx => $try->{xfr_stx},
      study_uid => $study_uid,
      series_uid => $series_uid,
      img_type => $img_type,
      sop_inst_uid => $sop_inst_uid,
      sop_class_uid => $sop_class_uid,
      modality => $modality,
      digest => $try->{digest},
      for_uid => $for_uid,
      patient_name => $patient_name,
      patient_id => $patient_id,
    };
    if(defined($iop)){
      my @norm;
      for my $i (@$iop) { push(@norm, sprintf("%0.4f", $i)) }
      for my $i (0 .. $#norm){
        if($norm[$i] == 0){ $norm[$i] = "0"}
        if($norm[$i] == 1){ $norm[$i] = "1"}
        if($norm[$i] == -1){ $norm[$i] = "-1"}
      }
      my $norm_iop = join("\\", @norm);
      $analysis->{by_file}->{$try->{filename}}->{norm_iop} = $norm_iop;
    }
    if(defined($ipp)){
      my $norm_x = sprintf("%0.4f", $ipp->[0]);
      $analysis->{by_file}->{$try->{filename}}->{norm_x} = $norm_x;
      my $norm_y = sprintf("%0.4f", $ipp->[1]);
      $analysis->{by_file}->{$try->{filename}}->{norm_y} = $norm_y;
      my $norm_z = sprintf("%0.4f", $ipp->[2]);
      $analysis->{by_file}->{$try->{filename}}->{norm_z} = $norm_z;
    }
    if(exists $try->{dataset_start_offset}){
      $analysis->{by_file}->{$try->{filename}}->{dataset_start_offset} = 
        $try->{dataset_start_offset};
    } else {
      $analysis->{by_file}->{$try->{filename}}->{dataset_start_offset} = 0;
    }
    $analysis->{digest_to_file}->{$try->{digest}}->{$try->{filename}} = 1;
    my $data = $analysis->{by_file}->{$try->{filename}};
    if(exists $try->{dataset_digest}) {
      $data->{dataset_digest} = $try->{dataset_digest};
      $analysis->{dataset_digest_to_file}->{$try->{digest}}->{$try->{filename}}
        = 1;
    }
    unless(defined $sop_inst_uid) { 
      return;
    }
    $analysis->{sop_to_file}->{$sop_inst_uid}->{$try->{filename}} += 1;
    if(defined $study_uid){
      for my $i (@$StudyAttrs){
        my $value = $ds->Get($i);
        if(ref($value) eq "ARRAY"){
          $value = join('\\', @$value);
        }
        unless(defined($value)){$value = "<undef>"}
        $data->{$i} = $value;
      }
    }
    if(defined $series_uid){
      for my $i (@$SeriesAttrs){
        my $value = $ds->Get($i);
        if(ref($value) eq "ARRAY"){
          $value = join('\\', @$value);
        }
        unless(defined($value)){$value = "<undef>"}
        $data->{$i} = $value;
      }
    }
    for my $i (@$ForAttrs){
      my $value = $ds->Get($i);
      if(ref($value) eq "ARRAY"){
        $value = join('\\', @$value);
      }
      unless(defined($value)){$value = "<undef>"}
      $data->{$i} = $value;
    }
    if(defined $modality){
      if(exists $ModalityAttrs->{$modality}){
        for my $i (@{$ModalityAttrs->{$modality}}){
          my $value = $ds->Get($i);
          if(ref($value) eq "ARRAY"){
            $value = join('\\', @$value);
          }
          unless(defined($value)){$value = "<undef>"}
          $data->{$i} = $value;
        }
      }
      if(exists $ModalityProcessing->{$modality}){
        &{$ModalityProcessing->{$modality}}($analysis, $try);
      }
    }
  };
  return $foo;
};
sub new_from_flist{
  my($class, $flist) = @_;
  my $this = {};
  $this->{by_file} = $flist;
  for my $file(keys %$flist){
    $this->{digest_to_file}->{$flist->{$file}->{digest}}->{$file} = 1;
    $this->{dataset_digest_to_file}->
      {$flist->{$file}->{dataset_digest}}->{$file} = 1;
    $this->{sop_to_file}->
      {$flist->{$file}->{sop_inst_uid}}->{$file} = 1;
  }
  bless $this, $class;
  $this->post_process();
  return $this;
}
sub new_from_dir{
  my($class, $dir) = @_;
  my $this = {};
  bless $this, $class;
  Posda::Find::DicomOnly($dir, $this->make_wanted);
  for my $i (@$PostProcessing){
    &$i($this);
  }
  return $this;
}
sub post_process{
  my($this) = @_;
  for my $i (@$PostProcessing){
    &$i($this);
  }
  return $this;
}
sub new_blank{
  my($class) = @_;
  my $this = {};
  return bless $this, $class;
}
sub add_dicom_try{
  my($this, $try) = @_;
  my $foo = $this->make_wanted();
  &$foo($try);
}
sub Secondary{
  my($this, $nicknames) = @_;
  my $secondary = {};
  for my $file (keys %{$this->{by_file}}){
     my $info = $this->{by_file}->{$file};
     my $series_uid = $info->{series_uid};
     my $study_uid = $info->{study_uid};
     my $modality = $info->{modality};
     my $for_uid = $info->{for_uid};
     my $patient_name = $info->{patient_name};
     my $patient_id = $info->{patient_id};
     my $series = $nicknames->series_nickname($series_uid);
     my $study = $nicknames->study_nickname($study_uid);
     my $for = $nicknames->for_nickname($for_uid);
     my $series_description = $info->{"(0008,103e)"};
     $secondary->{series_nicknames}->{$series_uid} = $series;
     $secondary->{study_nicknames}->{$study_uid} = $study;
     $secondary->{for_nicknames}->{$for_uid} = $for;
     if(exists $secondary->{series}->{$series}){
       $secondary->{series}->{$series}->{count} += 1;
       my $si = $secondary->{series}->{$series};
       unless($si->{modality} eq $modality){
         push @{$secondary->{series}->{$series}->{errors}},
           "Error: Series $series has non matching modalities: " .
          "$modality and $si->{modality}\n";
       }
       unless($si->{study} eq $study){
         push @{$secondary->{series}->{$series}->{errors}},
          "Error: Series $series has non matching studies: " .
          "$study and $si->{study}\n";
       }
       unless($si->{series_description} eq $series_description){
         push @{$secondary->{series}->{$series}->{errors}},
          "Error: Series $series has non matching descriptions: " .
          "$series_description and $si->{series_description}\n";
       }
       push(@{$secondary->{series}->{$series}->{files}}, $file);
     } else {
       $secondary->{series}->{$series} = {
         count => 1,
         modality => $modality,
         uid => $series_uid,
         series => $series,
         study => $study,
         series_description => $series_description,
         for => $for,
         files => [$file],
         patient_name => $patient_name,
         patient_id => $patient_id,
       };
     }
  }
  return $secondary;
}
1;
