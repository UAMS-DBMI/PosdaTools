#$Source: /home/bbennett/pass/archive/Posda/include/Posda/DicomFileAnalysis.pm,v $
#$Date: 2010/09/13 14:15:12 $
#$Revision: 1.4 $
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package Posda::DicomFileAnalysis;
use Digest::MD5;
use Posda::Try;
use Debug;
my $dgb = sub {print STDERR @_ };

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
  my($data, $try)  = @_;

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
    $data->{for_uid} = $fors[0];
  } else {
    $data->{for_uid} = \@fors;
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
  $data->{series_refs} = \@ser_ref;
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
  $data->{rois} = \%Roi;
}
sub ProcessReg{
  my($this, $ds) = @_
}
my $ModalityProcessing = {
  RTSTRUCT => \&ProcessStruct,
  REG => \&ProcessReg,
};
sub AnalyzeTry{
  my($this, $try) = @_;
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
  my $data = {
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
    $data->{norm_iop} = $norm_iop;
  }
  if(defined($ipp)){
    my $norm_x = sprintf("%0.4f", $ipp->[0]);
    $data->{norm_x} = $norm_x;
    my $norm_y = sprintf("%0.4f", $ipp->[1]);
    $data->{norm_y} = $norm_y;
    my $norm_z = sprintf("%0.4f", $ipp->[2]);
    $data->{norm_z} = $norm_z;
  }
  if(exists $try->{dataset_start_offset}){
    $data->{dataset_start_offset} = 
      $try->{dataset_start_offset};
  } else {
    $data->{dataset_start_offset} = 0;
  }
  if(exists $try->{dataset_digest}) {
    $data->{dataset_digest} = $try->{dataset_digest};
  }
  unless(defined $sop_inst_uid) { 
    return $data;
  }
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
      &{$ModalityProcessing->{$modality}}($data, $try);
    }
  }
  return $data;
}
sub ProcessNewFile{
  my($this, $file, $anon, $digest, $len) = @_;
  my $try = Posda::Try->new_with_digest_and_length($file, $digest, $len);
  my $q = $this->{db}->prepare(
    "insert into file (digest, size_in_bytes, is_dicom_file, file_type) " .
    "values (?, ?, ?, ?)"
  );
  unless(exists $try->{dataset}){
    my $file_type = `file $file`;
    chomp $file_type;
    my $q = $this->{db}->prepare(
      "insert into file (digest, size_in_bytes, is_dicom_file, file_type) " .
      "values (?, ?, ?, ?)"
    );
    $q->execute($digest, $len, 'false', $file_type);
    return $this->NotADicomFile($try);
  }
  $q->execute($digest, $len, 'true', "parsed_dicom_file");

  ########### check for an existing dataset (from another file)
  my $dataset_digest = $try->{digest};
  my $dataset_start_offset = 0;
  if($try->{has_meta_header}){
    $dataset_digest = $try->{dataset_digest};
    $dataset_start_offset = $try->{dataset_start_offset};
  }
  my $q1 = $this->{db}->prepare("select * from dicom_sop_instance " .
    "where dataset_digest = ?");
  $q1->execute($dataset_digest);
  my @list;
  while(my $h = $q1->fetchrow_hashref()){
    $h->{digest} = $try->{digest};
    push @list, $h;
  }
  my $q2 = $this->{db}->prepare(
    "insert into dicom_file(" .
    "  digest, dataset_digest, dataset_start_offset, is_sop" .
    ")values(" .
    "  ?, ?, ?, ?" .
    ")"
  );
  if($#list == 0){
    $q2->execute($digest, $dataset_digest, $dataset_start_offset, 'true');
    return $this->GetDataFromDb($list[0], $try, $anon);
  }
  if($#list > 0){ die "multiple rows for dataset with digest $dataset_digest" }

  my $data = $this->AnalyzeTry($try);
  $data->{xfr_stx} = $try->{xfr_stx};
  $data->{dataset_digest} = $dataset_digest;
  unless(
    defined($data->{sop_class_uid}) && 
    $data->{sop_class_uid} ne "<undef>"
  ){
    $q2->execute($digest, $dataset_digest, $dataset_start_offset, 'false');
    return $this->NotASop($data);
  }
  $q2->execute($digest, $dataset_digest, $dataset_start_offset, 'true');
  $this->CreateAnonData($try->{dataset}, $anon, $dataset_digest);
  return $this->CreateSopInstance($data);
}
sub GetDataFromDb{
  my($this, $h, $anon) = @_;
  unless($h->{sop_type}){ return $this->NotADicomFile($h) }
  $this->LoadAnonData($h, $anon);
  return $this->LoadSop($h);
}
sub TryFile{
  my($this, $file, $anon) = @_;
  my($digest, $len) = Posda::Try->GetDigestAndLength($file);
  my $q = $this->{db}->prepare(
    "select * from file natural left join dicom_file " .
    "natural left join dicom_sop_instance " .
    "where digest = ?"
  );
  $q->execute($digest);
  my @list;
  while (my $h = $q->fetchrow_hashref()){
    push(@list, $h);
  }
my $file_count = scalar @list;
  if($#list < 0){
    return $this->ProcessNewFile($file, $anon, $digest, $len);
  }
  if($#list > 0) {
    die "> 1 entries for file with digest $digest";
  }
  return $this->GetDataFromDb($list[0], $anon);
}
sub new{
  my($class, $db_cs) = @_;
  my $this = {};
  $this->{db} = DBI->connect($db_cs, "", "");
  unless($this->{db}) { die "can't connect using $db_cs" }
  bless $this, $class;
  return $this;
}
#############################################################
sub NotADicomFile{
  my($this, $h) = @_;
  my $ret;
  if(ref($h) eq "Posda::Try"){
    $ret = {
    };
  } else {
    $ret = $h;
  }
  return $ret;
}
sub NotASop{
  my($this, $h) = @_;
  return $h;
}
#############################################################
#  Load Data from DB
sub LoadCt{
  my($this, $ret) = @_;
  my $q = $this->{db}->prepare(
    "select * from dicom_ct_dataset where dataset_digest = ?"
  );
  $q->execute($ret->{dataset_digest});
  my @rows;
  while (my $h = $q->fetchrow_hashref()){
    push(@rows, $h);
  }
  if($#rows < 0){
    print STDERR "no CT rows for alleged CT $ret->{dataset_digest}\n";
    return;
  }
  if($#rows > 0){
    my $count = scalar @rows;
    print STDERR "$count CT rows for CT $ret->{dataset_digest}\n";
    return;
  }
  for my $i ("for_uid", "norm_iop", "norm_x", "norm_y", "norm_z"){
    $ret->{$i} = $rows[0]->{$i};
  }
}
sub LoadStruct{
  my($this, $ret) = @_;
  my $q = $this->{db}->prepare(
    "select * from dicom_rtstruct_dataset where dataset_digest = ?"
  );
  $q->execute($ret->{dataset_digest});
  my @rows;
  while (my $h = $q->fetchrow_hashref()){
    push(@rows, $h);
  }
  if($#rows < 0){
    print STDERR "no RTSTRUCT rows for alleged RTSTRUCT" .
      " $ret->{dataset_digest}\n";
    return;
  }
  if($#rows > 0){
    my $count = scalar @rows;
    print STDERR "$count RTSTRUCT rows for RTSTRUCT $ret->{dataset_digest}\n";
    return;
  }
  $ret->{for_uid} = $rows[0]->{for_uid};
  my $q1 = $this->{db}->prepare(
    "select * from dicom_rtstruct_series_ref where dataset_digest = ?"
  );
  $q1->execute($ret->{dataset_digest});
  my @series_refs;
  while(my $h = $q1->fetchrow_hashref()){
    push(@series_refs, {
      num_images => $h->{num_image_refs},
      ref_for => $h->{ref_for},
      ref_series => $h->{ref_series},
      ref_study => $h->{ref_study},
    });
  }
  $ret->{series_refs} = \@series_refs;
  my $q2 = $this->{db}->prepare(
    "select * from dicom_roi_dataset where dataset_digest = ?"
  );
  $q2->execute($ret->{dataset_digest});
  my %rois;
  while(my $h = $q2->fetchrow_hashref()){
    my $hash = {
      roi_num => $h->{roi_num},
      gen_alg => $h->{gen_alg},
      max_x => $h->{max_x},
      max_y => $h->{max_y},
      max_z => $h->{max_z},
      min_x => $h->{min_x},
      min_y => $h->{min_y},
      min_z => $h->{min_z},
      ref_for => $h->{ref_for},
      roi_name => $h->{roi_name},
      tot_contours => $h->{tot_contours},
      tot_points => $h->{tot_points},
    };
    my %cont_types;
    my $q3 = $this->{db}->prepare(
      "select * from roi_contour_types where " .
      "dataset_digest = ? and roi_num = ?"
    );
    $q3->execute($ret->{dataset_digest}, $h->{roi_num});
    while(my $h1 = $q3->fetchrow_hashref()){
      $cont_types{$h1->{contour_type}} = $h1->{num_contours};
    }
    $hash->{contour_types} = \%cont_types;
    my @sop_refs;
    my $q4 = $this->{db}->prepare(
      "select * from roi_sop_refs where " .
      "dataset_digest = ? and roi_num = ?"
    );
    $q4->execute($ret->{dataset_digest}, $h->{roi_num});
    while(my $h2 = $q4->fetchrow_hashref()){
      push(@sop_refs, $h2->{sop_instance_uid});
    }
    $hash->{sop_refs} = \@sop_refs;
    $rois{$hash->{roi_num}} = $hash;
  }
  $ret->{rois} = \%rois;
}
sub LoadPlan{
  my($this, $ret) = @_;
  my $q = $this->{db}->prepare(
    "select * from dicom_rt_plan_dataset where dataset_digest = ?"
  );
  $q->execute($ret->{dataset_digest});
  my @rows;
  while (my $h = $q->fetchrow_hashref()){
    push(@rows, $h);
  }
  if($#rows < 0){
    print STDERR "no RTPLAN rows for alleged RTPLAN $ret->{dataset_digest}\n";
    return;
  }
  if($#rows > 0){
    my $count = scalar @rows;
    print STDERR "$count RTPLAN rows for RTPLAN $ret->{dataset_digest}\n";
    return;
  }
  for my $i ("for_uid"){
    $ret->{$i} = $rows[0]->{$i};
  }
}
sub LoadDose{
  my($this, $ret) = @_;
  my $q = $this->{db}->prepare(
    "select * from dicom_rt_dose_dataset where dataset_digest = ?"
  );
  $q->execute($ret->{dataset_digest});
  my @rows;
  while (my $h = $q->fetchrow_hashref()){
    push(@rows, $h);
  }
  if($#rows < 0){
    print STDERR "no RTDOSE rows for alleged RTDOSE $ret->{dataset_digest}\n";
    return;
  }
  if($#rows > 0){
    my $count = scalar @rows;
    print STDERR "$count RTDOSE rows for RTDOSE $ret->{dataset_digest}\n";
    return;
  }
  for my $i (
    "for_uid", "norm_iop", "norm_x", "norm_y", "norm_z", "num_frames",
    "max_offset", "old_style_offset_corrected"
  ){
    $ret->{$i} = $rows[0]->{$i};
  }
}
sub LoadSop{
  my($this, $h) = @_;
  my $ret = {
    digest => $h->{digest},
    dataset_digest => $h->{dataset_digest},
    dataset_start_offset => $h->{dataset_start_offset},
    sop_class_uid => $h->{sop_class_uid},
    sop_inst_uid => $h->{sop_instance_uid},
    modality => $h->{modality},
    sop_type => $h->{sop_type},
    xfr_stx => $h->{xfr_stx},
    img_type => $h->{img_type},
    patient_id => $h->{patient_id},
    patient_name => $h->{patient_name},
    series_uid => $h->{series_uid},
    study_uid => $h->{study_uid},
    for_uid => $h->{for_uid},
  };
  $this->LoadElements($ret);
  if($h->{sop_type} eq "CT") { $this->LoadCt($ret) }
  if($h->{sop_type} eq "RTS") { $this->LoadStruct($ret) }
  if($h->{sop_type} eq "RTP") { $this->LoadPlan($ret) }
  if($h->{sop_type} eq "RTD") { $this->LoadDose($ret) }
  return $ret;
}
sub LoadElements{
  my($this, $ret) = @_;
  my $q = $this->{db}->prepare(
    "select * from dicom_dataset_element where dataset_digest = ?"
  );
  $q->execute($ret->{dataset_digest});
  while (my $h = $q->fetchrow_hashref()){
    $ret->{$h->{ele_sig}} = $h->{ele_value};
  }
}
sub LoadAnonData{
  my($this, $h, $anon) = @_;
  my $q = $this->{db}->prepare(
    "select * from dicom_anonymizer_sub where dataset_digest = ?"
  );
  $q->execute($h->{dataset_digest});
  while(my $h1 = $q->fetchrow_hashref()){
     $anon->{sub}->{$h1->{element_sig}}->{name} = $h1->{element_name};
     $anon->{sub}->{$h1->{element_sig}}->{values}->{$h1->{element_value}} = "";
     $anon->{sub}->{$h1->{element_sig}}->{occurances}->{$h1->{element_value}}
       += $h1->{occurance_count};
  }
  my $q1 = $this->{db}->prepare(
    "select * from dicom_anonymizer_date where dataset_digest = ?"
  );
  $q1->execute($h->{dataset_digest});
  while(my $h1 = $q1->fetchrow_hashref()){
    $anon->{date}->{dates}->{$h1->{date_value}} = "";
    $anon->{date}->{occurances}->{$h1->{date_value}} += $h1->{occurance_count};
  }
}
#############################################################
#  Insert Data into DB
sub InsertElementValues{
  my($this, $data) = @_;
  my $q = $this->{db}->prepare(
    "insert into dicom_dataset_element(dataset_digest, ele_sig, ele_value) " .
    "values (?, ?, ?)"
  );
  for my $i (keys %$data){
    my $value = $data->{$i};
    if($i =~ /^\(.*\)$/){
      $q->execute($data->{dataset_digest}, $i, $value);
    }
  }
}
sub CreateSopInstance{
  my($this, $data) = @_;
  my $q = $this->{db}->prepare(
    "insert into dicom_sop_instance(" .
    "  dataset_digest, sop_class_uid, " .
    "  sop_instance_uid, modality, sop_type, xfr_stx, img_type, " .
    "  patient_id, patient_name, series_uid, study_uid, for_uid" .
    ")values(" .
    "  ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
  );
  my $sop_type = Posda::DataDict::GetSopClassPrefix($data->{sop_class_uid});
  $q->execute(
    $data->{dataset_digest}, $data->{sop_class_uid}, $data->{sop_inst_uid},
    $data->{modality}, $sop_type, $data->{xfr_stx}, $data->{img_type},
    $data->{patient_id}, $data->{patient_name}, $data->{series_uid},
    $data->{study_uid}, $data->{for_uid}
  );
  $this->InsertElementValues($data);
  if($sop_type eq "CT"){
    $this->CreateACt($data);
  }
  if($sop_type eq "RTD"){
    $this->CreateADose($data);
  }
  if($sop_type eq "RTP"){
    $this->CreateAPlan($data);
  }
  if($sop_type eq "RTS"){
    $this->CreateAStruct($data);
  }
  return $data;
}
sub CreateACt{
  my($this, $data) = @_;
  my $q = $this->{db}->prepare(
    "insert into dicom_ct_dataset(" .
    "  dataset_digest, for_uid, norm_iop, norm_x, norm_y, norm_z" .
    ")values(" .
    "  ?, ?, ?, ?, ?, ?" .
    ")"
  );
  $q->execute($data->{dataset_digest}, $data->{for_uid},
    $data->{norm_iop}, $data->{norm_x}, $data->{norm_y}, $data->{norm_z});
}
sub CreateADose{
  my($this, $data) = @_;
  my @gfov = split(/\\/, $data->{"(3004,000c)"});
  my $num_frames = $data->{"(0028,0008)"};
  unless(scalar @gfov == $num_frames){
    print STDERR "Nonmatching num_frames and gfov in dataset " .
      "$data->{dataset_digest}\n";
  }
  my $old_style = "false";
  unless($gfov[0] == 0){
    $old_style = "true";
    my $first = $gfov[0];
    for my $i (0 .. $#gfov){ $gfov[$i] -= $first }
  }
  my $max_offset = $gfov[$#gfov];
  my $q = $this->{db}->prepare(
    "insert into dicom_rt_dose_dataset(" .
    "  dataset_digest, for_uid, norm_iop, norm_x, " .
    "  norm_y, norm_z, num_frames, max_offset, " .
    "  old_style_offset_corrected" .
    ")values(" .
    "  ?, ?, ?, ?," .
    "  ?, ?, ?, ?," . 
    "  ?" . 
    ")"
  );
  $q->execute(
    $data->{dataset_digest}, $data->{for_uid}, $data->{norm_iop}, 
    $data->{norm_x},
    $data->{norm_y}, $data->{norm_z}, $data->{num_frames}, $max_offset,
    $old_style
  );
}
sub CreateAPlan{
  my($this, $data) = @_;
  my $q = $this->{db}->prepare(
    "insert into dicom_rt_plan_dataset(" .
    "  dataset_digest, for_uid" .
    ")values(" .
    "  ?, ?" .
    ")"
  );
  $q->execute($data->{dataset_digest}, $data->{for_uid});
}
sub CreateAStruct{
  my($this, $data) = @_;
  my $q = $this->{db}->prepare(
    "insert into dicom_rtstruct_dataset(" .
    "  dataset_digest, for_uid" .
    ")values(" .
    "  ?, ?" .
    ")"
  );
  $q->execute($data->{dataset_digest}, $data->{for_uid});
  my $q1 = $this->{db}->prepare(
    "insert into dicom_roi_dataset(" .
    "  dataset_digest,  roi_num, gen_alg, max_x, " .
    "  max_y, max_z, min_x, min_y, " .
    "  min_z, ref_for, roi_name, tot_contours, " .
    "  tot_points" .
    ") values(" .
    "  ?, ?, ?, ?, " .
    "  ?, ?, ?, ?, " .
    "  ?, ?, ?, ?, " .
    "  ?" .
    ")"
  );
  for my $key (keys %{$data->{rois}}){
    my $i = $data->{rois}->{$key};
    $q1->execute(
      $data->{dataset_digest}, $i->{roi_num}, $i->{gen_alg}, $i->{max_x},
      $i->{max_y}, $i->{max_z}, $i->{min_x}, $i->{min_y}, 
      $i->{min_z}, $i->{ref_for}, $i->{roi_name}, $i->{tot_contours},
      $i->{tot_points}
    );
    my $q2 = $this->{db}->prepare(
      "insert into roi_contour_types(" .
      "  dataset_digest, roi_num, contour_type, num_contours" .
      ")values(" .
      "  ?, ?, ?, ?" .
      ")"
    );
    for my $j (keys %{$i->{contour_types}}){
      $q2->execute(
        $data->{dataset_digest}, $i->{roi_num}, $j, $i->{contour_types}->{$j}
      );
    }
    my $q3 = $this->{db}->prepare(
      "insert into roi_sop_refs(" .
      "  dataset_digest, roi_num, sop_instance_uid" .
      ")values(" .
      "  ?, ?, ?" .
      ")"
    );
    for my $j (@{$i->{sop_refs}}){
      $q3->execute($data->{dataset_digest}, $i->{roi_num}, $j);
    }
  }
  my $q4 = $this->{db}->prepare(
    "insert into dicom_rtstruct_series_ref(" .
    "  dataset_digest, ref_for, num_image_refs, " .
    "  ref_study, ref_series" .
    ")values(" .
    "  ?, ?, ?, " .
    "  ?, ?" .
    ")"
  );
  for my $i(@{$data->{series_refs}}){
    $q4->execute(
      $data->{dataset_digest}, $i->{ref_for}, $i->{num_images},
      $i->{ref_study}, $i->{ref_series}
    );
  }
}
sub CreateAnonData{
  my($this, $dataset, $anon, $dataset_digest) = @_;
  my $hash = {};
  Posda::Anonymizer::history_builder($hash, $dataset, undef);
  my $q = $this->{db}->prepare(
    "insert into dicom_anonymizer_sub(" .
    "  dataset_digest, element_sig, element_value, " .
    "  element_name, occurance_count" .
    ")values(" .
    "  ?, ?, ?," .
    "  ?, ? " .
    ")"
  );
  my $q1 = $this->{db}->prepare(
    "insert into dicom_anonymizer_date(" .
    "  dataset_digest, date_value, occurance_count" .
    ")values(" .
    "  ?, ?, ? " .
    ")"
  );
  for my $sig (keys %{$hash->{sub}}){
    $anon->{sub}->{$sig}->{name} = $hash->{sub}->{$sig}->{name};
    for my $v (keys %{$hash->{sub}->{$sig}->{values}}){
      $anon->{sub}->{$sig}->{values}->{$v} = "";
      $q->execute($dataset_digest, $sig, $v, $hash->{sub}->{$sig}->{name},
        $hash->{sub}->{$sig}->{occurances}->{$v})
    }
    for my $v (keys %{$hash->{sub}->{$sig}->{occurances}}){
      $anon->{sub}->{$sig}->{occurances}->{$v} +=
        $hash->{sub}->{$sig}->{occurances}->{$v};
    }
  }
  for my $date (keys %{$hash->{date}->{dates}}){
    $anon->{date}->{dates}->{$date} = "";
    $anon->{date}->{occurances}->{$date} += 
      $hash->{date}->{occurances}->{$date};
    $q1->execute($dataset_digest, $date, $hash->{date}->{occurances}->{$date});
  }
}
1;
