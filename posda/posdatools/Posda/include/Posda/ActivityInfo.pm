#!/usr/bin/perl -w
use strict;
package Posda::ActivityInfo;
use Posda::DB 'Query';
sub new {
  my($class, $act_id) = @_;
  my $this = {};
  Query('GetActivityInfo')->RunQuery(sub{
    my($row) = @_;
    my($activity_id, $brief_description, $when_created,
      $who_created, $when_closed) = @$row;
    $this->{activity_id} = $activity_id;
    $this->{description} = $brief_description;
    $this->{when_created} = $when_created;
    $this->{who_created} = $who_created;
    $this->{when_closed} = $when_closed;
  }, sub {}, $act_id);
  if(exists $this->{activity_id}) { return bless $this, $class }
  die "No activity $act_id";
};
sub LatestTimepoint{
  my($this) = @_;
  my $act_time_id;
  Query('LatestActivityTimepointsForActivity')->RunQuery(sub{
    my($row) = @_;
    $act_time_id = $row->[3];
  }, sub {}, $this->{activity_id});
  return $act_time_id;
}
sub GetTimePointList{
  my($this) = @_;
  my @activity_timepoints;
  my %activity_tp_info;
  Query('ActivityTimepointsForActivity')->RunQuery(sub{
    my($row) = @_;
    my($activity_id, $activity_created, $activity_description,
      $activity_timepoint_id, $timepoint_created, $comment,
      $creating_user) = @$row;
    unless($activity_id == $this->{activity_id}){
      die "non_matching $activity_id for timepoint $activity_timepoint_id";
    }
    unless($activity_created == $this->{when_created}){
      die "non_matching creation_time for timepoint $activity_timepoint_id";
    }
    unless($activity_description == $this->{description}){
      die "non_matching description for timepoint $activity_timepoint_id";
    }
    push(@activity_timepoints, $activity_timepoint_id);
    $activity_tp_info{$activity_timepoint_id} = {
      
    };
  }, sub{}, $this->{activity_id});
  return \@activity_timepoints, \%activity_tp_info;
}
sub GetFileIdsInTimepoint{
  my($this, $tp_id) = @_;
  my @file_ids;
  Query('FileIdsByActivityTimepointId')->RunQuery(sub {
    my($row) = @_;
    push(@file_ids, $row->[0]);
  }, sub{}, $tp_id);
  return \@file_ids;
}
sub GetFileInfoForTp{
  my($this, $tp_id) = @_;
  my $file_ids = $this->GetFileIdsInTimepoint($tp_id);
  my %FileInfo;
  my $q = Query('WhereFileSitsExt');
  for my $f (@$file_ids){
    $q->RunQuery(sub {
      my($row) = @_;
      my($collection, $site, $patient_id, $study_instance_uid,
        $series_instance_uid, $sop_instance_uid,
        $modality, $dicom_file_type) = @$row;
      if(exists $FileInfo{$f}){
        die "Duplicate files in timepoint $tp_id";
      }
      $FileInfo{$f}->{collection} = $collection;
      $FileInfo{$f}->{site} = $site;
      $FileInfo{$f}->{patient_id} = $patient_id;
      $FileInfo{$f}->{study_instance_uid} = $study_instance_uid;
      $FileInfo{$f}->{series_instance_uid} = $series_instance_uid;
      $FileInfo{$f}->{sop_instance_uid} = $sop_instance_uid;
      $FileInfo{$f}->{modality} = $modality;
      $FileInfo{$f}->{dicom_file_type} = $dicom_file_type;
      $FileInfo{$f}->{file_id} = $f;
    }, sub {}, $f);
  }
  return \%FileInfo;
}
sub MakeFileHierarchyFromInfo{
  my($this, $info) = @_;
  my %H;
  for my $f (keys %$info){
    my $i = $info->{$f};
    $H{$i->{collection}}->{$i->{site}}->{$i->{patient_id}}
      ->{$i->{study_instance_uid}}->{$i->{series_instance_uid}}
      ->{$i->{sop_instance_uid}}->{$f} = 1;
  }
  return \%H;
}
sub MakeCondensedHierarchyFromInfo{
  my($this, $info) = @_;
  my %Report;
  for my $f (keys %$info){
    my $i = $info->{$f};
     $Report{$i->{collection}}->{$i->{site}}->{$i->{patient_id}}
        ->{files}->{$i->{file_id}} = 1;
      $Report{$i->{collection}}->{$i->{site}}->{$i->{patient_id}}
        ->{sops}->{$i->{sop_instance_uid}} = 1;
      $Report{$i->{collection}}->{$i->{site}}->{$i->{patient_id}}
        ->{sop_classes}->{$i->{dicom_file_type}} = 1;
      $Report{$i->{collection}}->{$i->{site}}->{$i->{patient_id}}
        ->{modalities}->{$i->{modality}} = 1;
      $Report{$i->{collection}}->{$i->{site}}->{$i->{patient_id}}
       ->{studies}->{$i->{study_instance_uid}} = 1;
      $Report{$i->{collection}}->{$i->{site}}->{$i->{patient_id}}
       ->{series}->{$i->{series_instance_uid}} = 1;
  }
  return \%Report;
}
sub PrintCondensedHierarchyReport{
  my($this, $rpt, $hier) = @_;
  $rpt->print("collection,site,patient_id,num_studies,num_series," .
    "num_modalities,num_sop_classes,num_sops,num_files\r\n");
  for my $coll(sort keys %{$hier}){
    my $site_h = $hier->{$coll};
    for my $site (sort keys %$site_h){
      my $pat_h = $site_h->{$site};
      for my $pat_id (sort keys %$pat_h){
        my $h = $pat_h->{$pat_id};
        my $num_files = keys %{$h->{files}};
        my $num_modalities = keys %{$h->{modalities}};
        my $num_sop_class = keys %{$h->{sop_classes}};
        my $num_studies = keys %{$h->{studies}};
        my $num_series = keys %{$h->{series}};
        my $num_sops = keys %{$h->{sops}};
        $rpt->print("$coll,$site,$pat_id,$num_studies,$num_series,$num_modalities," .
          "$num_sop_class,$num_sops,$num_files\r\n");
      }
    }
  }
}
sub MakeFileHierarchyForLatestTimepoint{
  my($this) = @_;
  my $tp = $this->LatestTimepoint;
  unless(defined $tp) { die "No timepoint defined for $this->{activity_id}" }
  return $this->MakeFileHierarchyFromInfo($this->GetFileInfoForTp($tp));
}
sub PrintHierarchyReport{
  my($this, $rpt, $hier) = @_;
  my @cols = ("collection", "site", "patient_id", "study_instance_uid", 
    "series_instance_uid", "num_sops", "num_files");
  my $print_row = sub {
    my($p, $cols) = @_;
    for my $i (0 .. $#{$cols}){
      my $v = $cols->[$i];
      $v =~ s/"/""/g;
      $p->print("\"$v\"");
      if($i == $#cols){
       $p->print("\r\n");
      } else {
       $p->print(",");
      }
    }
  };
  &$print_row($rpt, \@cols);
  for my $col (keys %$hier){
    for my $site (keys %{$hier->{$col}}){
      for my $pat (keys %{$hier->{$col}->{$site}}){
        for my $stdy (keys %{$hier->{$col}->{$site}->{$pat}}){
          for my $series (keys %{$hier->{$col}->{$site}->{$pat}->{$stdy}}){
            my $sh = $hier->{$col}->{$site}->{$pat}->{$stdy}->{$series};
            my $num_sops = 0;
            my $num_files = 0;
            for my $sop (keys %$sh){
              $num_sops += 1;
              for my $f (keys %{$sh->{$sop}}){
                $num_files += 1;
              }
            }
            my $row = [$col, $site, $pat, $stdy, $series, $num_sops, $num_files];
            &$print_row($rpt, $row);
          }
        }
      }
    }
  }
}
sub CreateTpFromSeriesList{
  my($this, $series_list, $comment, $notify) = @_;
  my @attr_names = (
    'collection', 'site', 'patient_id', 'study_instance_uid',
    'series_instance_uid', 'sop_instance_uid', 'dicom_file_type', 'modality',
    'file_id');
  my @Rows;
  for my $series_instance_uid (keys %$series_list){
    Query("DistinctVisibleFileReportBySeries")->RunQuery(sub{
      my($row) = @_;
      my %values;
      for my $i (@attr_names) {
        my $v = shift (@$row);
        unless(defined $v) { $v = '<undef>' }
        $values{$i} = $v;
      }
      push @Rows, \%values;
    }, sub {}, $series_instance_uid);
  }
  my %FileIds;
  for my $row (@Rows){
    $FileIds{$row->{file_id}} = $row;
  }
  my $cre = Query("CreateActivityTimepoint");
  $cre->RunQuery(sub {}, sub {},
    $this->{activity_id}, $0, $comment, $notify);
  my $act_time_id;
  my $gid = Query("GetActivityTimepointId");
  $gid->RunQuery(sub {
    my($row) = @_;
    $act_time_id = $row->[0];
  }, sub{});
  unless(defined $act_time_id){
    die "Unable to new activity_timepoint_id";
  }
  my $ins_file = Query("InsertActivityTimepointFile");
  for my $file_id (keys %FileIds){
    $ins_file->RunQuery(sub{}, sub{}, $act_time_id, $file_id);
  }
  return $act_time_id, \%FileIds;
}

1;
