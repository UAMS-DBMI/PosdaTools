package Posda::StructFixer;
use strict;
use Posda::Try;
Posda::Dataset::InitDD();
####################################################
#   Build Data Stuctures:
#
#$ImgsByZ->{<z>} = <file_name>;
#
#$ImgSopClass = <sop_class_id>
#
#$ImgsByFile->{<file_name>} = <sop_instance_uid>;
#
#$ImgFor = <frame_of_reference_of_images>
#
#   From Passed in structure:
#
#$ImgsByUid->{<sop_instance_uid>} = {
#  file => <file_name>,
#  iop => <iop>, # actual iop
#  ipp => <ipp>, # actual ipp
#  series_uid => <series_instance_uid>, 
#  study_uid => <study_instance_uid>, 
#  sop_class_uid => <sop_class_uid>,
#  for_uid => <frame_of_reference_uid>
#};
sub new {
  my($class, $ImgsByUid, $StructSetFile) = @_;
  my $this = {
    ImgsByUid => $ImgsByUid,
  };
  bless $this, $class;
  $this->CheckImagFor;
  $this->GetImagSop;
  $this->CheckImagGeo;
  return $this;
}
sub CheckImagFor{
  my($this) = @_;
  my $For;
  for my $i (keys %{$this->{ImgsByUid}}){
    unless(defined $For) { $For = $this->{ImgsByUid}->{$i}->{for_uid} }
    unless($For eq $this->{ImgsByUid}->{$i}->{for_uid}){
      unless(exists $this->{errors}){ $this->{errors} = {} }
      my $msg = "Images have different frames of reference: " .
        "$For vs $this->{ImgsByUid}->{$i}->{for_uid}";
      $this->{errors}->{$msg} = 1;
    }
  }
  $this->{ImgFor} = $For;
} 
sub GetImagSop{
  my($this) = @_;
  my $Sop;
  for my $i (keys %{$this->{ImgsByUid}}){
    unless(defined $Sop) { $Sop = $this->{ImgsByUid}->{$i}->{sop_class_uid} }
    unless($Sop eq $this->{ImgsByUid}->{$i}->{sop_class_uid}){
      unless(exists $this->{errors}){ $this->{errors} = {} }
      my $msg = "Images have different sop_classes: " .
        "$Sop vs $this->{ImgsByUid}->{$i}->{sop_class_uid}";
      $this->{errors}->{$msg} = 1;
    }
  }
  $this->{ImgSopClass} = $Sop;
} 
sub CheckImagGeo{
  my($this) = @_;
  for my $i (keys %{$this->{ImgsByUid}}){
    my @iop = map { sprintf("%.8f", $_) } split /\\/, $this->{ImgsByUid}->{$i}->{iop};
    if (
      $iop[0] == 1 and
      $iop[1] == 0 and
      $iop[2] == 0 and
      $iop[3] == 0 and
      $iop[4] == 1 and
      $iop[5] == 0
    ){
      my($x, $y, $z) = split /\\/, $this->{ImgsByUid}->{$i}->{ipp};
      my $file = $this->{ImgsByUid}->{$i}->{file};
      $this->{ImgsByZ}->{$z} = $file;
      $this->{ImgsByFile}->{$file} = $i;
      $this->{ImgsByUid}->{$i}->{z} = $z;
    } else {
      my $msg = "Image ($i) is not axial ($iop[0], $iop[1], " .
        "$iop[2], $iop[3], $iop[4], $iop[5])";
      $this->{errors}->{$msg} = 1;
    }
  }
};
sub LinkStructSet{
  my($this, $ds) = @_;

  #
  # Add all the Contour References
  #
  my $max_mapping_dist = 0;
  my $min_mapping_dist;
  my $ct_cont_ref = $ds->Substitutions(
    "(3006,0039)[<0>](3006,0040)[<1>](3006,0042)", "CLOSED_PLANAR"
  );
  my $num_links = @{$ct_cont_ref->{list}};
  z_value:
  for my $inst (@{$ct_cont_ref->{list}}){
    my $r_i = $inst->[$ct_cont_ref->{index_list}->{"<0>"}];
    my $rc_i = $inst->[$ct_cont_ref->{index_list}->{"<1>"}];
    my $z = $ds->ExtractElementBySig(
      "(3006,0039)[$r_i](3006,0040)[$rc_i](3006,0050)[2]"
    );
    unless($z ne "") { next z_value }
    my $closest_z = $z;
    unless(defined $this->{ImgsByZ}->{$z}){
      $this->BuildCtMap($z);
      $closest_z = $this->{CtMap}->{$z};
    }
    my $dist = abs($closest_z - $z);
    unless(defined $min_mapping_dist) { $min_mapping_dist = $dist }
    if($dist > $max_mapping_dist) { $max_mapping_dist = $dist }
    if($dist < $min_mapping_dist) { $min_mapping_dist = $dist }
    my $Uid = $this->{ImgsByFile}->{$this->{ImgsByZ}->{$closest_z}};
    $ds->Insert("(3006,0039)[$r_i](3006,0040)[$rc_i](3006,0016)[0](0008,1150)",
      $this->{ImgSopClass});
    $ds->Insert("(3006,0039)[$r_i](3006,0040)[$rc_i](3006,0016)[0](0008,1155)",
      $Uid);
  }
  push @{$this->{link_record}}, "linked $num_links contours" .
    " (min_dist = $min_mapping_dist, " .
     "max_dist = $max_mapping_dist)";
  #
  # Fix Referenced Frame of Reference Sequence
  #
  my $ref_for = $ds->Get("(3006,0010)[0](0020,0052)");
  if($ref_for eq $this->{ImgFor}){
    push @{$this->{link_record}}, "didn't have to change referenced FOR";
  } else {
    $ds->InsertElementBySig("(3006,0010)[0](0020,0052)", $this->{ImgFor});
    push @{$this->{link_record}}, "Changed referenced FOR: $ref_for " .
      " => $this->{ImgFor}";
  }
  #
  # Rebuild the RT Study Reference Sequence
  #
  my %Studies;
  for my $uid (keys %{$this->{ImgsByUid}}){
    my $item = $this->{ImgsByUid}->{$uid};
    $Studies{$item->{study_uid}}->{$item->{series_uid}}->{$uid} = $item->{z};
  }
  my $tot_series = 0;
  my $tot_images = 0;
  my $study_index = 0;
  for my $st (keys %Studies){
    $ds->InsertElementBySig("(3006,0010)[0](3006,0012)[$study_index](0008,1150)", 
      "1.2.840.10008.3.1.2.3.1");
    $ds->InsertElementBySig("(3006,0010)[0](3006,0012)[$study_index](0008,1155)", 
      $st);
    my $series_index = 0;
    for my $ser (keys %{$Studies{$st}}){
      $ds->InsertElementBySig(
        "(3006,0010)[0](3006,0012)[$study_index]" . 
        "(3006,0014)[$series_index](0020,000e)", 
        $ser);
      my $image_index = 0;
      for my $i (
        sort
        { $Studies{$st}->{$ser}->{$b} <=> $Studies{$st}->{$ser}->{$a} }
        keys %{$Studies{$st}->{$ser}}
      ){
        $ds->InsertElementBySig(
          "(3006,0010)[0](3006,0012)[$study_index]" .
          "(3006,0014)[$series_index](3006,0016)[$image_index](0008,1150)", 
          "1.2.840.10008.5.1.4.1.1.2");
        $ds->InsertElementBySig(
          "(3006,0010)[0](3006,0012)[$study_index]" .
          "(3006,0014)[$series_index](3006,0016)[$image_index](0008,1155)", 
          $i);
        $image_index += 1;
      }
      $tot_images += $image_index;
      $series_index += 1;
    }
    $tot_series += $series_index;
    $study_index += 1;
  }
  push @{$this->{link_record}}, "inserted $study_index studies, $tot_series series," .
    " $tot_images images into ref_study seq";
  #
  # Fix frames of reference in Stucture Set ROI sequence
  #
  my $for_ref = $ds->Substitutions("(3006,0020)[<0>](3006,0024)");
  my $num_fors = @{$for_ref->{list}};
  my $num_changed = 0;
  for my $inst (@{$ct_cont_ref->{list}}){
    my $r_i = $inst->[$for_ref->{index_list}->{"<0>"}];
    my $sig = "(3006,0020)[$r_i](3006,0024)";
    my $ref_for = $ds->ExtractElementBySig($sig);
    if($ref_for ne $this->{ImgFor}){
      $ds->InsertElementBySig($sig, $this->{ImgFor});
      $num_changed += 1;
    }
  }
  push @{$this->{link_record}},
    "Replaced $num_changed of $num_fors roi frames of reference";
  return 1;
}

sub BuildCtMap{
  my($this, $z) = @_;
  if(exists $this->{CtMap}->{$z}){ return };
  my $closest_z;
  my $dist;
  for my $i (keys %{$this->{ImgsByZ}}){
    unless(defined($closest_z)){ $closest_z = $i }
    unless(defined($dist)){ $dist = abs($z - $i) }
    if(abs($z - $i) < $dist){
      $closest_z = $i;
      $dist = abs ($z - $i);
    }
  }
  $this->{CtMap}->{$z} = $closest_z;
}
