#!/usr/bin/perl -w
use strict;
use Posda::Try;
use Posda::DB qw( Query );

package Posda::SegToStruct;
my $help = <<EOF;
This package manages DICOM Segmentations which might be converted 
into RTSTRUCT files.  To use it, create an object:

my \$obj = Posda::SeqSemanticConversion->new(\$file);

where <file> is the full path to a DICOM Segmenation Object.

This new will not succeed unless the DICOM Segmentation has
Segmenation Type = 'BINARY' (i.e. it only deals with bitmaps)
It will also fail unless bits_allocated = 1 and bits_stored = 1;
It will also fail if rows * columns is not a mutliple of 8 
(i.e it is not going to shift bits within bytes).
It also assumes that the frame has two dimensions, frame_position
and segmentation.

Internal structure (after new)

\$this = {
  file = <path to file>,
  study_instance_uid => <study_instance_uid>,
  series_instance_uid => <series_instance_uid>,
  sop_instance_uid => <sop_instance_uid>,
  frame_of_reference_uid => <frame_of_reference_uid>,
  patient_id => <patient_id>,
  samples_per_pixel => 1,                       #required value
  photometric_interpretation => 'MONOCHROME2',  #required value
  number_of_frames  => <num_frames>,            #(num_rows * num_cols *
                                                #num_frames) / 8
                                                #  must equal bytes in
                                                #  pixel data
  rows => <num_rows>,                           #num_rows * num_cols 
                                                #must be multiple
  cols => <num_cols>,                           #  of eight
  bits_allocated => 1,                          #required value
  bits_stored => 1,                             #required value
  high_bit => 0,                                #required value
  pixel_representation => 0,                    #required value
  segmentation_type => 'BINARY',                #required value
  pixel_size => <num_bytes in pixel>,
  pixel_offset => <position of pixels in file>
  ref_series => {
    <series_instance_uid> => {
      <sop_inst> => {
        sop_class => <sop_class>,
        in_posda => "1" or "0",
        in_nbia => "1" or "0",
        posda_path => <path_to_file_in_posda>,
        nbia_path => <path_to_file_in_nbia>,
      },
      ...
    },
    ...
  },
  dimension_organization => {
    dimension_organization_uid = <dimension_organization_uid>,
    dimension_indices => [
      {
        dimension_sig => "(gggg,eeee)[<0>](gggg,eeee)",
        dimension_desc => <dimension_description>
      },
      ...
    ],
  },
  segmentations => {
    <seg_no> => {
      label => <label>,
      description => <description>,
      color => <color>,
      algorithm => {
        type => <type>,
        name => <name>,
      },
      segmented_property => {
        type => {
          meaning => <meaning>,
          code => <code>,
          scheme => <coding_scheme>,
        },
        category => {
          meaning => <meaning>,
          code => <code>,
          scheme => <coding_scheme>,
        },
      },
    },
    ...
  },
  frame_descriptor => {
    <index_0> => {
      <index_1> => {
        offset_within_pixels => <offset>,
        plane_orientation => <iop>,
        pixel_spacing => <pixel_spacing>,
        slice_spacing => <slice_spacing>,
        slice_thickness => <slice_thickness>,
        plane_position => <ipp>,
        referenced_segment_number => <segment_number>,
        referenced_images => {
          <sop_instance_uid> => 1,
        },
        ...
      },
    },
  }
};

EOF
sub new{
  my($class, $file) = @_;
  my $try = Posda::Try->new($file);
  unless(defined $try) { die "$file failed to parse" };
  unless(exists $try->{dataset}) {
    die "$file is not a DICOM file";
  }
  my $ds = $try->{dataset};
  my $this = { file => $file };
  bless $this, $class;
  $this->{study_instance_uid} = $ds->Get("(0020,000d)");
  $this->{series_instance_uid} = $ds->Get("(0020,000e)");
  $this->{frame_of_reference_uid} = $ds->Get("(0008,0018)");
  $this->{patient_id} = $ds->Get("(0010,0020)");
  $this->{samples_per_pixel} = $ds->Get("(0028,0002)");
  $this->{photometric_interpretation} = $ds->Get("(0028,0004)");
  $this->{number_of_frames} = $ds->Get("(0028,0008)");
  $this->{rows} = $ds->Get("(0028,0010)");
  $this->{cols} = $ds->Get("(0028,0011)");
  $this->{bits_allocated} = $ds->Get("(0028,0100)");
  $this->{bits_stored} = $ds->Get("(0028,0101)");
  $this->{high_bit} = $ds->Get("(0028,0102)");
  $this->{pixel_representation} = $ds->Get("(0028,0103)");
  $this->{segmentation_type} = $ds->Get("(0062,0001)");
  unless($this->{samples_per_pixel} == 1){
    die "Samples per pixel = $this->{samples_per_pixel} vs 1";
  }
  unless($this->{bits_allocated} == 1){
    die "Bits Allocated = $this->{bits_allocated} vs 1";
  }
  unless($this->{bits_stored} == 1){
    die "Bits Stored = $this->{bits_stored} vs 1";
  }
  unless($this->{high_bit} == 0){
    die "Bits Stored = $this->{bits_stored} vs 0";
  }
  unless($this->{photometric_interpretation} eq 'MONOCHROME2'){
    die "Photometric Interpretation = " .
      "$this->{photometric_interpretation} vs MONOCHROME2";
  }
  my $pix = $ds->{0x7fe0}->{0x10};
  $this->{pixel_size} = $pix->{ele_len_in_file};
  unless(
    $this->{pixel_size} == 
    (($this->{rows} * $this->{cols} * $this->{number_of_frames}) / 8)
  ){
    my $correct_pix = ($this->{rows} * $this->{cols}) / 8;
    die "pixel_size ($this->{pixel_size}) should be $correct_pix";
  }
  $this->{pixel_offset} = $pix->{file_pos};

  ###############################################################
  #Referenced Series Sequence
  my $series_of_related_images = $ds->Get("(0008,1115)[0](0020,000e)");
  my $list = $ds->Search("(0008,1115)[0](0008,114a)[<0>](0008,1155)");
  unless(ref($list) eq "ARRAY"){
    die "Didn't find any referenced sops";
  }
  for my $match (@$list){
    my $sop_instance = 
     $ds->Get("(0008,1115)[0](0008,114a)[$match->[0]](0008,1155)");
    $this->{ref_series}->{$series_of_related_images}->{$sop_instance} = 1;
    my $sop_class = 
     $ds->Get("(0008,1115)[0](0008,114a)[$match->[0]](0008,1150)");
    ### to do
    ### go look in DB for files, and put file paths here
  }

  ###############################################################
  #Dimension organization/index sequences
  $this->{dimension_organization} = 
  my $ml = $ds->Search("(0020,9221)[<0>](0020,9164)");
  unless(defined($ml) && ref($ml) eq "ARRAY"){
    die "Didn't find an Dimension Organizaton";
  }
  unless($#{$ml} == 0){
    die "More than one Dimension Organization";
  }
  $this->{dimension_organization} = {
    dimension_organization_uid => 
      $ds->Get("(0020,9221)[$ml->[0]->[0]](0020,9164)"),
    dimension_indices => [],
  };
  $ml = $ds->Search("(0020,9222)[<0>](0020,9164)");
  unless(defined($ml) && ref($ml) eq "ARRAY"){
    die "Can't find any dimension indices";
  }
  my $num_i = @$ml;
  unless ($num_i == 2){
    die "Num dimension indices ($num_i) should be 2";
  }
  for my $m (@$ml){
    my $dim_i_uid = $ds->Get("(0020,9222)[$m->[0]](0020,9164)");
    unless(
      $this->{dimension_organization}->{dimension_organization_uid} eq
      $dim_i_uid
    ){
      die "Dimension index $m has uid $dim_i_uid vs " .
        $this->{dimension_organization}->{dimension_organization_uid};
    }
    my $dim_i_ptr = $ds->Get("(0020,9222)[$m->[0]](0020,9165)");
    my $fun_g_ptr = $ds->Get("(0020,9222)[$m->[0]](0020,9167)");
    my $dim_i_desc = $ds->Get("(0020,9222)[$m->[0]](0020,9421)");
    push @{$this->{dimension_organization}->{dimension_indices}}, {
      dimension_sig => $fun_g_ptr . "[<0>]" . $dim_i_ptr,
      dimension_desc => $dim_i_desc
    };
  }

  ###############################################################
  # Segment Sequence
  $ml = $ds->Search("(0062,0002)[<0>](0062,0004)");
  unless(defined($ml) && ref($ml) eq "ARRAY") { die "Didn't find any segments" }
  for my $m (@$ml){
    my $i = $m->[0];
    my $seg_no = $ds->Get("(0062,0002)[$i](0062,0004)");
    my $label = $ds->Get("(0062,0002)[$i](0062,0005)");
    my $desc = $ds->Get("(0062,0002)[$i](0062,0006)"); my $alg_t = $ds->Get("(0062,0002)[$i](0062,0008)");
    my $alg_n = $ds->Get("(0062,0002)[$i](0062,0009)");
    my $color = $ds->Get("(0062,0002)[$i](0062,000d)");
    my $seg_p_t = $ds->Get("(0062,0002)[$i](0062,0003)[0](0008,0104)") .
      " (" .
      $ds->Get("(0062,0002)[$i](0062,0003)[0](0008,0100)") .
      " of " .
      $ds->Get("(0062,0002)[$i](0062,0003)[0](0008,0102)") .
      ")";
    my $seg_p_c = $ds->Get("(0062,0002)[$i](0062,000f)[0](0008,0104)") .
      " (" .
      $ds->Get("(0062,0002)[$i](0062,000f)[0](0008,0100)") .
      " of " .
      $ds->Get("(0062,0002)[$i](0062,000f)[0](0008,0102)") .
      ")";
    $this->{segmentations}->{$seg_no} = {
      label => $label,
      description => $desc,
      color => $color,
      algorithm => {
        name => $alg_n,
        type => $alg_t,
      },
      segmented_property => {
        type => $seg_p_t,
        category => $seg_p_c,
      },
    };
  }

  ###############################################################
  # Functional Groups Sequences...
  my $iop = $ds->Get("(5200,9229)[0](0020,9116)[0](0020,0037)");
  my $slice_thickness =
    $ds->Get("(5200,9229)[0](0028,9110)[0](0018,0050)");
  my $slice_spacing =
    $ds->Get("(5200,9229)[0](0028,9110)[0](0018,0088)");
  my $pixel_spacing =
    $ds->Get("(5200,9229)[0](0028,9110)[0](0028,0030)");
  $ml = $ds->Search("(5200,9230)[<0>](0020,9111)[0](0020,9157)");
  my $frame_size = ($this->{rows} * $this->{cols}) / 8;
  my $offset_within_pixels = 0;
  unless(defined($ml) && ref($ml) eq "ARRAY"){
    die "No frame descriptors found";
  }
  my $n_f_found = @$ml;
  unless($n_f_found == $this->{number_of_frames}){
    die "$n_f_found descriptors found for $this->{number_of_frames} frames";
  }
  for my $m (@$ml){
    my $i = $m->[0];
    my $d_i_v = $ds->Get("(5200,9230)[$i](0020,9111)[0](0020,9157)");
    my($index_0,$index_1) = @$d_i_v;
    if(exists $this->{frame_descriptor}->{$index_0}->{$index_1}){
      die "duplicate dimension indices \"$index_1\\$index_0\" at $i";
    }
    $this->{frame_descriptor}->{$index_0}->{$index_1} = {
      offset_within_pixels => $offset_within_pixels,
      plane_orientation => $iop,
      pixel_spacing => $pixel_spacing,
      slice_spacing => $slice_spacing,
    };
    $offset_within_pixels += $frame_size;
    my $p = $this->{frame_descriptor}->{$index_0}->{$index_1};
    $p->{plane_position} =
      $ds->Get("(5200,9230)[$i](0020,9113)[0](0020,0032)");
    $p->{referenced_segment_number} =
      $ds->Get("(5200,9230)[$i](0062,000a)[0](0062,000b)");
    if(
      ref($p->{referenced_segment_number}) eq "ARRAY" &&
      $#{$p->{referenced_segment_number}} == 0
    ){
      $p->{referenced_segment_number} =
        $p->{referenced_segment_number}->[0];
    }
    my $ml_n =
      $ds->Search("(5200,9230)[$i](0008,9124)[0](0008,2112)[<0>](0008,1155)");
    if(defined($ml_n) && ref($ml_n) eq "ARRAY"){
      for my $m (@$ml_n){
        my $j = $m->[0];
        my $sop =
          $ds->Get("(5200,9230)[$i](0008,9124)[0](0008,2112)[$j](0008,1155)");
        $p->{referenced_images}->{$sop} = 1;
      }
    }
  }



  return $this;
}
1;
