#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/FileCollectionAnalysis.pm,v $
#$Date: 2015/06/03 14:17:32 $
#$Revision: 1.16 $
#
#Copyright 2014, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
#
use strict;
use Posda::ValidationRules;
package Posda::FileCollectionAnalysis;
sub new {
  my($class, $coll) = @_;
  my $this = {
    stuid_to_index => {},
    stuid_from_index => {},
    stindex => 1,
    seuid_to_index => {},
    seuid_from_index => {},
    seindex => 1,
    hierarchy => {},
    study_consistency => {},
    series_consistency => {},
    patient_consistency => {},
    errors => [],
  };
  bless $this, $class;
  if(defined $coll){
    for my $file (keys %$coll){
      $this->Analyze($file, $coll->{$file});
    }
    $this->ConsistencyErrors;
  }
  return $this;
}
sub Analyze{
  my($this, $file, $desc) = @_;
  $this->{FilesByDigest}->{$desc->{digest}} = $desc;
  $this->{FilesToDigest}->{$file} = $desc->{digest};
  $this->BuildHierarchy($file, $desc);
  $this->BuildPatientConsistencyStruct($file, $desc);
  $this->BuildStudyConsistencyStruct($file, $desc);
  $this->BuildSeriesConsistencyStruct($file, $desc);
#  $this->BuildSeriesConsistencyStruct($file, $desc);
}
sub BuildHierarchy{
  my($this, $file, $desc) = @_;
  my $study_uid = $desc->{study_uid};
  unless(defined $study_uid) {
    push(@{$this->{errors}}, {
      message => "file has no study uid",
      file => $file,
    });
    return;
  }
  my $st_index = $this->StudyIndex($study_uid);
  my $series_uid = $desc->{series_uid};
  unless(defined $series_uid) {
    push(@{$this->{errors}}, {
      message => "file has no series uid",
      file => $file,
    });
    return;
  }
  my $se_index = $this->SeriesIndex($series_uid);
  my $patient_id = $desc->{patient_id};
  unless(defined $patient_id) {
    push(@{$this->{errors}}, {
      message => "file has no patient id",
      file => $file,
    });
    return;
  }
  $this->{hierarchy}->{$patient_id}->{$st_index}->{$se_index}->{$file} = 1;
}
sub BuildPatientConsistencyStruct{
  my($this, $file, $desc) = @_;
  unless(defined $desc->{patient_id}){ return }
  for my $r (@Posda::ValidationRules::consistent_patient){
    if(exists $desc->{$r->{ele}}){
      my $v = $desc->{$r->{ele}};
      $this->{patient_consistency}->{$desc->{patient_id}}
        ->{$r->{ele}}->{$v} = 1;
    }
  }
}
sub BuildStudyConsistencyStruct{
  my($this, $file, $desc) = @_;
  unless(defined $desc->{study_uid}){ return }
  for my $r (@Posda::ValidationRules::consistent_study){
    if(exists $desc->{$r->{ele}}){
      my $st_index = $this->StudyIndex($desc->{study_uid});
      $this->{study_consistency}->{$st_index}
        ->{$r->{ele}}->{$desc->{$r->{ele}}} = 1;
    }
  }
}
sub BuildSeriesConsistencyStruct{
  my($this, $file, $desc) = @_;
  unless(defined $desc->{series_uid}){ return }
  for my $r (@Posda::ValidationRules::consistent_series){
    my $se_index = $this->SeriesIndex($desc->{series_uid});
    if(exists $desc->{$r->{ele}}){
      $this->{series_consistency}->{$se_index}
        ->{$r->{ele}}->{$desc->{$r->{ele}}} = 1;
    }
  }
}
sub BuildNewHierarchy{
  my($this) = @_;
  for my $p (keys %{$this->{hierarchy}}){
    $this->{NewHierarchy}->{$p} = $this->BuildPatHierarchy($p);
  }
}
sub BuildPatHierarchy{
  my($this, $p) = @_;
  my $old_hierarchy = $this->{hierarchy}->{$p};
  my %new_hierarchy;
  for my $st_i (keys %{$old_hierarchy}){
    my $st_uid = $this->{stuid_from_index}->{$st_i};
    my @pids = keys %{$this->{study_consistency}->{$st_i}->{"(0010,0020)"}};
    my @pnames = keys %{$this->{study_consistency}->{$st_i}->{"(0010,0010)"}};
    my @descs = keys %{$this->{study_consistency}->{$st_i}->{"(0008,1030)"}};
    my @stids = keys %{$this->{study_consistency}->{$st_i}->{"(0020,0010)"}};
    my @stdates = keys %{$this->{study_consistency}->{$st_i}->{"(0008,0020)"}};
    my $st_struct = {
      uid => $st_uid,
      pid => ($#pids > 0) ? \@pids : $pids[0],
      pname => ($#pnames > 0) ? \@pnames : $pnames[0],
      desc => ($#descs > 0) ? \@descs : $descs[0],
      id => ($#stids > 0) ? \@stids : $stids[0],
      date => ($#stdates > 0) ? \@stdates : $stdates[0],
    };
    for my $se_i (keys %{$old_hierarchy->{$st_i}}){
      my $se_uid = $this->{seuid_from_index}->{$se_i};
      my @bps = keys %{$this->{series_consistency}->{$se_i}->{"(0018,0015)"}};
      my @sdescs =
        keys %{$this->{series_consistency}->{$se_i}->{"(0008,103e)"}};
      my @sdates = 
        keys %{$this->{series_consistency}->{$se_i}->{"(0008,0021)"}};
      my @modalities = 
        keys %{$this->{series_consistency}->{$se_i}->{"(0008,0060)"}};
      my $se_struct = {
        uid => $se_uid,
        modality => ($#modalities > 0) ? \@modalities : $modalities[0],
        desc => ($#sdescs > 0) ? \@sdescs : $sdescs[0],
        body_part => ($#bps > 0) ? \@bps : $bps[0],
        sdates => ($#sdates > 0) ? \@sdates : $sdates[0],
      };
      my %fh;
      for my $file (keys %{$old_hierarchy->{$st_i}->{$se_i}}){
        my $f_dig = $this->{FilesToDigest}->{$file};
        my $f_info = $this->{FilesByDigest}->{$f_dig};
        $fh{$file} = {
          digest => $f_dig,
          sop_instance_uid => $f_info->{sop_inst_uid},
          dataset_digest => $f_info->{dataset_digest},
        } 
      }
      $se_struct->{files} = \%fh;
      $st_struct->{series}->{$se_i} = $se_struct;
    }
    $new_hierarchy{studies}->{$st_i} = $st_struct;
  }
  return \%new_hierarchy;
}
sub ConsistencyErrors{
  my($this) = @_;
  
  for my $type (
      "patient_consistency", "study_consistency", "series_consistency"
  ){
    for my $index (keys %{$this->{$type}}){
      for my $ele (keys %{$this->{$type}->{$index}}){
        my @values = keys %{$this->{$type}->{$index}->{$ele}};
        if(@values > 1){
          my $num_values = @values;
          my $err = {
            message => "Error in $type: $ele has $num_values values",
            type => $type,
            sub_type => "multiple element values",
            index => $index,
            ele => $ele,
            values => \@values,
          };
          if($type eq "patient_consistency"){
            $err->{patient} = $index;
          } elsif($type eq "series_consistency"){
            $err->{series_uid} = $this->{seuid_from_index}->{$index};
          } elsif($type eq "study_consistency"){
            $err->{study_uid} = $this->{stuid_from_index}->{$index};
          }
          push(@{$this->{errors}}, $err);
        }
      }
    }
  }
}
sub ImageNumberErrors{
  my($this) = @_;
  my %series_info_by_uid;
  for my $subj (keys %{$this->{hierarchy}}){
    my $suh = $this->{hierarchy}->{$subj};
    for my $st_i (keys %$suh){
      my $sth = $suh->{$st_i};
      series_1:
      for my $se_i (keys %{$sth}){
        my $seh = $sth->{$se_i};
        my $series_instance_uid = $this->{seuid_from_index}->{$se_i};
        unless(exists $series_info_by_uid{$series_instance_uid}){
          $series_info_by_uid{$series_instance_uid} = {
            num_files => 0,
            se_i => $se_i,
          };
        }
        my $si_hash = $series_info_by_uid{$series_instance_uid};
        for my $f (keys %$seh){
          $si_hash->{num_files} += 1;
          my $f_dig = $this->{FilesToDigest}->{$f};
          my $f_info = $this->{FilesByDigest}->{$f_dig};
          if(
            exists $si_hash->{modality} && exists $f_info->{modality} &&
            $si_hash->{modality} ne $f_info->{modality}
          ){
            ## inconsistent series - skip and don't report here
            delete $series_info_by_uid{$series_instance_uid};
            next series_1;
          }
          $si_hash->{modality} = $f_info->{modality};
          if(defined $f_info->{"(0020,0013)"}){
            my $image_number = $f_info->{"(0020,0013)"};
            $si_hash->{has_some_image_numbers} = 1;
            $si_hash->{image_numbers}->{$image_number} = 1;
          } else {
            $si_hash->{missing_some_image_numbers} = 1;
          }
          my $z;
          if(defined $f_info->{normalized_loc}){
            $si_hash->{has_some_normalized_loc} = 1;
            my $z = $f_info->{normalized_loc};
            $si_hash->{z_values}->{$z} = 1;
          }
          $si_hash->{files}->{$f} = $f_info;
        }
      }
    }
  }
  series_2:
  for my $series_uid (keys %series_info_by_uid){
    my $series = $series_info_by_uid{$series_uid};
    if($series->{num_files} <= 1){ next series_2 } # not enough files
    unless($series->{has_some_normalized_loc}) { next series_2 } #no z-values
    my $num_z_values = keys %{$series->{z_values}};
    my $num_image_numbers = keys %{$series->{image_numbers}};
    if($num_z_values == 1) { next series_2 } # probably not 3-D
    unless($num_z_values == $series->{num_files}){
      # number of z_values doesn't match number of images in series
      push(@{$this->{errors}}, {
        message => "Error in image_number_check:" . 
          "series has some (but not all) z-values",
        type => "image_number_check",
        sub_type => "not all values",
        series_uid => $series_uid,
        num_images => $series->{num_images},
        num_z_values => $num_z_values,
      });
      next series_2;
    }
    if($series->{missing_some_image_numbers}){
      push(@{$this->{errors}}, {
        message => "Error in image_number_check: " . 
          "series has z-values but missing some image numbers",
        type => "image_number_check",
        sub_type => "missing image numbers",
        series_uid => $series_uid,
        num_images => $series->{num_images},
        num_z_values => $num_z_values,
        num_image_numbers => $num_image_numbers,
      });
      next series_2;
    }
    my @image_num_order;
    my @image_num_rev_order;
    for my $f (
     sort {
       $series->{files}->{$a}->{normalized_loc} <=> 
       $series->{files}->{$b}->{normalized_loc}
     }
     keys %{$series->{files}}
    ){
      my $image_num = $series->{files}->{$f}->{"(0020,0013)"};
      push(@image_num_order, $image_num);
      unshift(@image_num_rev_order, $image_num);
    }
    my $is_ascending = 1;
    my $last_in;
    my $i;
    for $i (0 .. $#image_num_order){
      if($is_ascending){
        unless(defined $last_in){
          $last_in = $image_num_order[$i];
          next;
        }
        if($image_num_order[$i] > $last_in){
          $last_in = $image_num_order[$i];
        } else {
          $is_ascending = 0;
        }
      }
    }
    my $is_descending = 1;
    $last_in = undef;
    for $i (0 .. $#image_num_rev_order){
      if($is_descending){
        unless(defined $last_in){
          $last_in = $image_num_rev_order[$i];
          next;
        }
        if($image_num_rev_order[$i] > $last_in){
          $last_in = $image_num_rev_order[$i];
        } else {
          $is_descending = 0;
        }
      }
    }
    unless($is_ascending || $is_descending){
      push(@{$this->{errors}}, {
        message => "Error in image_number_check: " . 
          "series image numbers are not ascending or descending when " .
          "sorted by z-values",
        type => "image_number_check",
        sub_type => "image numbers don't track z-values",
        series_uid => $series_uid,
#        up => \@image_num_order,
#        down => \@image_num_rev_order,
       });
    }
  }
}
sub StructureSetLinkages{
  my($this) = @_;
  my @structs;
  my %SopToDig;
  my %SopToFile;
  for my $file (keys %{$this->{FilesToDigest}}){
    my $dig = $this->{FilesToDigest}->{$file};
    my $f_info = $this->{FilesByDigest}->{$dig};
    my $sop_inst = $f_info->{sop_inst_uid};
    if(exists $SopToDig{$sop_inst}){
      if($SopToDig{$sop_inst} eq $dig){
        # two files are the same
        push(@{$this->{errors}}, {
          message => "Error duplicate files: ",
          type => "duplicate files",
          sop_inst => $sop_inst,
          file_1 => $file,
          file_2 => $SopToFile{$sop_inst},
       });
      } else {
        # two different files have same sop_inst_uid
        push(@{$this->{errors}}, {
          message => "Error SOP instances (different files): " , 
          type => "duplicate sop_instance",
          sop_inst => $sop_inst,
          file_1 => $file,
          file_2 => $SopToFile{$sop_inst},
       });
      }
    }
    $SopToDig{$sop_inst} = $dig;
    $SopToFile{$sop_inst} = $file;
    if($f_info->{modality} eq "RTSTRUCT"){
      push(@structs, $f_info);
    }
  }
  struct:
  for my $struct (@structs){
    my $error_flagged = 0;
    for my $ref_struct (@{$struct->{series_refs}}){
      my $num_img_refs = $ref_struct->{num_images};
      my $ref_for = $ref_struct->{ref_for};
      my $ref_study = $ref_struct->{ref_study};
      my $ref_series = $ref_struct->{ref_series};
      my $refs = 0;
      my $ref_unknown = 0;
      my $ref_wrong_series = 0;
      my $ref_wrong_study = 0;
      my $ref_wrong_for = 0;
      img_ref:
      for my $img_ref (@{$ref_struct->{img_list}}){
        $refs += 1;
        unless(exists $SopToDig{$img_ref}){
          $ref_unknown += 1; next img_ref;
        }
        my $ref_dig = $SopToDig{$img_ref};
        my $ref_info = $this->{FilesByDigest}->{$ref_dig};
        unless($ref_study eq $ref_info->{study_uid}){
          $ref_wrong_study += 1;
        }
        unless($ref_series eq $ref_info->{series_uid}){
          $ref_wrong_series += 1;
        }
        unless($ref_for eq $ref_info->{for_uid}){
          $ref_wrong_for += 1;
        }
      }
      if(
        $ref_unknown || $ref_wrong_series || $ref_wrong_study || $ref_wrong_for
      ){
        push(@{$this->{errors}}, {
          message => "Error in Structure Set Linkages: " . 
            "Total images linked: $refs, unknown: $ref_unknown " .
            "bad series: $ref_wrong_series, bad study: $ref_wrong_study " . 
            "bad for: $ref_wrong_for",
          type => "structure_set_linkage",
          series_uid => $struct->{series_uid},
          sop_inst => $struct->{sop_inst_uid},
        });
        next struct;
      }
    }
    for my $roi_num (keys %{$struct->{rois}}){
      for my $roi_c_num (keys %{$struct->{rois}->{$roi_num}->{sop_refs}}){
        my $ref_sop_inst =
          $struct->{rois}->{$roi_num}->{sop_refs}->{$roi_c_num};
        unless(exists $SopToDig{$ref_sop_inst}){
          push(@{$this->{errors}}, {
            message => "Error in Structure Set Linkages: " . 
              "At least one roi_contour is linked to unknown image",
            type => "structure_set_linkage",
            series_uid => $struct->{series_uid},
            sop_inst => $struct->{sop_inst_uid},
          });
          next struct;
        }
      }
    }
    for my $roi_num (keys %{$struct->{rois}}){
      contour:
      for my $contour (@{$struct->{rois}->{$roi_num}->{contours}}){
        unless($contour->{type} eq "CLOSED_PLANAR") { next contour }
        unless($contour->{ref_type}){
          push(@{$this->{errors}}, {
            message => "Error in Structure Set Linkages: " . 
              "At least one roi_contour has no sop_class in linkage",
            type => "structure_set_linkage",
            series_uid => $struct->{series_uid},
            sop_inst => $struct->{sop_inst_uid},
          });
          next struct;
        }
      }
    }
  }
}
sub StudyIndex{
  my($this, $study_uid) = @_;
  unless(exists $this->{stuid_to_index}->{$study_uid}){
    my $index = $this->{stindex}++;
    $this->{stuid_to_index}->{$study_uid} = $index;
    $this->{stuid_from_index}->{$index} = $study_uid;
  }
  return $this->{stuid_to_index}->{$study_uid}
}
sub SeriesIndex{
  my($this, $series_uid) = @_;
  unless(exists $this->{seuid_to_index}->{$series_uid}){
    my $index = $this->{seindex}++;
    $this->{seuid_to_index}->{$series_uid} = $index;
    $this->{seuid_from_index}->{$index} = $series_uid;
  }
  return $this->{seuid_to_index}->{$series_uid}
}
1;
