#!/usr/bin/perl -w
#
use strict;
package Posda::UidCollector;
sub CollectUids{
  my($this, $dicom_info) = @_;
  my %Uids;
  for my $i (keys %{$dicom_info->{FilesByDigest}}){
    my $info = $dicom_info->{FilesByDigest}->{$i};
    my $modality = $info->{modality};
    if($modality eq "REG"){ $this->CollectRegUids($info, \%Uids) }
    elsif($modality eq "CT") { $this->CollectImgUids($info, \%Uids) }
    elsif($modality eq "PT") { $this->CollectImgUids($info, \%Uids) }
    elsif($modality eq "MR") { $this->CollectImgUids($info, \%Uids) }
    elsif($modality eq "RTSTRUCT") { $this->CollectRtsUids($info, \%Uids) }
    elsif($modality eq "RTPLAN") { $this->CollectRtpUids($info, \%Uids) }
    elsif($modality eq "RTDOSE") { $this->CollectRtdUids($info, \%Uids) }
    else{
      print STDERR "Dont know how to collect UIDs from modality: $modality\n";
    }
  }
  $this->{CollectedUids} = \%Uids;
}
sub CollectRegUids{
  my($this, $info, $uids) = @_;
  $uids->{$info->{for_uid}} = 1;
  $uids->{$info->{series_uid}} = 1;
  $uids->{$info->{study_uid}} = 1;
  $uids->{$info->{sop_inst_uid}} = 1;
  for my $st (keys %{$info->{study_refs}}){
    $uids->{$st} = 1;
    for my $sr (keys %{$info->{study_refs}->{$st}}){
      $uids->{$sr} = 1;
      for my $sc (keys %{$info->{study_refs}->{$st}->{$sr}}){
        for my $si (keys %{$info->{study_refs}->{$st}->{$sr}->{$sc}}){
          $uids->{$si} = 1;
        }
      }
    }
  }
}
sub CollectImgUids{
  my($this, $info, $uids) = @_;
  $uids->{$info->{for_uid}} = 1;
  $uids->{$info->{series_uid}} = 1;
  $uids->{$info->{study_uid}} = 1;
  $uids->{$info->{sop_inst_uid}} = 1;
}
sub CollectRtsUids{
  my($this, $info, $uids) = @_;
  $uids->{$info->{for_uid}} = 1;
  $uids->{$info->{series_uid}} = 1;
  $uids->{$info->{study_uid}} = 1;
  $uids->{$info->{sop_inst_uid}} = 1;
  for my $i (keys %{$info->{RefFors}}){
    $uids->{$i} = 1;
  }
  for my $roi (keys %{$info->{rois}}){
    $uids->{$info->{rois}->{$roi}->{ref_for}} = 1;
    for my $i (keys %{$info->{rois}->{$roi}->{sop_refs}}){
      my $u = $info->{rois}->{$roi}->{sop_refs}->{$i};
      $uids->{$u} = 1;
    }
    for my $c (@{$info->{rois}->{$roi}->{contours}}){
      $uids->{$c->{ref}} = 1;
    }
  }
}
sub CollectRtpUids{
  my($this, $info, $uids) = @_;
  $uids->{$info->{for_uid}} = 1;
  $uids->{$info->{series_uid}} = 1;
  $uids->{$info->{study_uid}} = 1;
  $uids->{$info->{sop_inst_uid}} = 1;
  $uids->{$info->{ref_struct_set}} = 1;
}
sub CollectRtdUids{
  my($this, $info, $uids) = @_;
  $uids->{$info->{for_uid}} = 1;
  $uids->{$info->{series_uid}} = 1;
  $uids->{$info->{study_uid}} = 1;
  $uids->{$info->{sop_inst_uid}} = 1;
  if($uids->{$info->{ref_plan}}){
    $uids->{$info->{ref_plan}} = 1;
  }
  if($uids->{$info->{ref_ss}}){
    $uids->{$info->{ref_ss}} = 1;
  }
  for my $i (keys %{$info->{plan_refs}}){
    $uids->{$i} = 1;
  }
}
1;
