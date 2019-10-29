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
sub _GetCollectionAndSite {
  my ($this) = @_;
  my $r = Query('CollectionSiteFromTp')->FetchOneHash($this->LatestTimepoint());
  $this->{collection} = $r->{collection_name};
  $this->{site} = $r->{site_name};
}
sub GetCollection {
  my ($this) = @_;
  if (not defined $this->{collection}) {
    $this->_GetCollectionAndSite()
  }

  return $this->{collection};
}
sub GetSite {
  my ($this) = @_;
  if (not defined $this->{site}) {
    $this->_GetCollectionAndSite()
  }

  return $this->{site};
}
sub GetSiteCode {
  my ($this) = @_;

  if (not defined $this->{site}) {
    $this->_GetCollectionAndSite()
  }

  my $r = Query('GetSiteCodeBySite')->FetchOneHash($this->{site});
  return $r->{site_code}
}
sub GetCollectionCode {
  my ($this) = @_;

  if (not defined $this->{collection}) {
    $this->_GetCollectionAndSite()
  }

  my $r = Query('GetCollectionCodeByCollection')->FetchOneHash($this->{collection});
  return $r->{collection_code}
}

sub LatestTimepoint {
  my($this) = @_;

  my $res = Query('LatestActivityTimepointsForActivity')
            ->FetchOneHash($this->{activity_id});

  return $res->{activity_timepoint_id};
}

# TODO this appears unused, not refactoring
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

sub GetFileInfoForTp{
  my($this, $tp_id) = @_;
  
  my %FileInfo;
  my $results = Query('FileDetailsForTimepoint')->FetchResults($tp_id);
  map {
    my($file_id,
       $collection,
       $site,
       $visibility,
       $patient_id,
       $study_instance_uid,
       $series_instance_uid,
       $sop_instance_uid,
       $sop_class_uid,
       $modality,
       $dicom_file_type,
       $path,
       $earliest_import_day,
       $latest_import_day) = @$_;

    $FileInfo{$file_id}->{collection} = $collection;
    $FileInfo{$file_id}->{site} = $site;
    $FileInfo{$file_id}->{visibility} = $visibility;
    $FileInfo{$file_id}->{patient_id} = $patient_id;
    $FileInfo{$file_id}->{study_instance_uid} = $study_instance_uid;
    $FileInfo{$file_id}->{series_instance_uid} = $series_instance_uid;
    $FileInfo{$file_id}->{sop_instance_uid} = $sop_instance_uid;
    $FileInfo{$file_id}->{sop_class_uid} = $sop_class_uid;
    $FileInfo{$file_id}->{modality} = $modality;
    $FileInfo{$file_id}->{dicom_file_type} = $dicom_file_type;
    $FileInfo{$file_id}->{file_path} = $path;
    $FileInfo{$file_id}->{earliest_import} = $earliest_import_day;
    $FileInfo{$file_id}->{latest_import} = $latest_import_day;
    $FileInfo{$file_id}->{file_id} = $file_id;
  } @$results;

  return \%FileInfo;
}

sub MakeFileHierarchyFromInfo{
  my($this, $info) = @_;
  my %H;
  for my $f (keys %$info){
    my $i = $info->{$f};
    $H{$i->{collection}}->{$i->{site}}->{$i->{patient_id}}
      ->{$i->{study_instance_uid}}->{$i->{series_instance_uid}}
      ->{$i->{sop_instance_uid}}->{$f} = $i->{visibility};
  }
  return \%H;
}
sub MakeCondensedHierarchyFromInfo{
  my($this, $info) = @_;
  my %Report;
  for my $f (keys %$info){
    my $i = $info->{$f};
     $Report{$i->{collection}}->{$i->{site}}->{$i->{patient_id}}
        ->{files}->{$f} = 1;
     if( defined($i->{visibility})){
       $Report{$i->{collection}}->{$i->{site}}->{$i->{patient_id}}
        ->{hidden_files}->{$f} = 1;
     } else {
       $Report{$i->{collection}}->{$i->{site}}->{$i->{patient_id}}
        ->{visible_files}->{$f} = 1;
     }
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
    "num_modalities,num_sop_classes,num_sops,num_files,visible,hidden\r\n");
  for my $coll(sort keys %{$hier}){
    my $site_h = $hier->{$coll};
    for my $site (sort keys %$site_h){
      my $pat_h = $site_h->{$site};
      for my $pat_id (sort keys %$pat_h){
        my $h = $pat_h->{$pat_id};
        my $num_files = keys %{$h->{files}};
        my $num_visible = keys %{$h->{visible_files}};
        my $num_hidden = keys %{$h->{hidden_files}};
        my $num_modalities = keys %{$h->{modalities}};
        my $num_sop_class = keys %{$h->{sop_classes}};
        my $num_studies = keys %{$h->{studies}};
        my $num_series = keys %{$h->{series}};
        my $num_sops = keys %{$h->{sops}};
        $rpt->print("$coll,$site,$pat_id,$num_studies,$num_series,$num_modalities," .
          "$num_sop_class,$num_sops,$num_files,$num_visible,$num_hidden\r\n");
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
    "series_instance_uid", "num_sops", "num_files", "visible", "hidden");
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
            my $num_visible = 0;
            my $num_hidden = 0;
            for my $sop (keys %$sh){
              $num_sops += 1;
              for my $f (keys %{$sh->{$sop}}){
                $num_files += 1;
                if(defined $sh->{$sop}->{$f}){
                  $num_hidden += 1;
                } else {
                  $num_visible += 1;
                }
              }
            }
            my $row = [$col, $site, $pat, $stdy, $series, $num_sops, $num_files,
              $num_visible, $num_hidden];
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
    die "Unable to retrieve new activity_timepoint_id";
  }
  my $ins_file = Query("InsertActivityTimepointFile");
  for my $file_id (keys %FileIds){
    $ins_file->RunQuery(sub{}, sub{}, $act_time_id, $file_id);
  }
  return $act_time_id, \%FileIds;
}
sub SeriesDupReport{
  my($this, $FileInfo) = @_;
  my %Series;
  my %SeriesWithDups;
  # $SeriesWithDups{<series_instance_uid>} = {
  #   num_sops => <num_sops>,
  #   num_files => <num_files>,
  # };
  #
  #
  my %SeriesDupReport;
  #$SeriesDupReport = {<series_instance_uid>} = {
  #  <import_day> => {
  #    sops => {
  #      <sop_instance_uid> {
  #        <file_id> => 1,
  #      ...
  #      },
  #      ...
  #    },
  #    files => {
  #      <file_id> => <sop_instance_uid>,
  #      ...
  #    },
  #    num_sops => <num_sops>,
  #    num_files => <num_files>,
  #    min_file_id => <min_file_id>,
  #    max_file_id => <max_file_id>,
  #  },
  #  ...
  #};
  for my $f (keys %$FileInfo){
    my $series = $FileInfo->{$f}->{series_instance_uid};
    unless(defined $series) { die "Series undefined for $f" }
    my $sop = $FileInfo->{$f}->{sop_instance_uid};
    $Series{$series}->{$sop}->{$f} = 1;
  }
  for my $series (keys %Series){
    my $num_sops = keys %{$Series{$series}};
    my $num_files = 0;
    for my $sop (keys %{$Series{$series}}){
      $num_files += keys %{$Series{$series}->{$sop}};
    }
    if($num_sops != $num_files){
       $SeriesWithDups{$series}->{num_sops} = $num_sops;
       $SeriesWithDups{$series}->{num_files} = $num_files;
    }
  }
  for my $series(keys %SeriesWithDups){
    for my $sop(keys %{$Series{$series}}){
      for my $f (keys %{$Series{$series}->{$sop}}){
        my $tt = $FileInfo->{$f}->{latest_import};
        my $day = substr $tt, 0, 10;
        $SeriesDupReport{$series}->{$day}->{sops}->{$sop}->{$f} = 1;
        $SeriesDupReport{$series}->{$day}->{files}->{$f} = $sop;
      }
    }
  }
  for my $series(keys %SeriesDupReport){
    for my $day(keys %{$SeriesDupReport{$series}}){
      my $p = $SeriesDupReport{$series}->{$day};
      my @sops = keys %{$p->{sops}};
      $p->{num_sops} =  @sops;
      my @files = sort keys %{$p->{files}};
      $p->{num_files} = @files;
      $p->{max_file_id} = $files[$#files];
      $p->{min_file_id} = $files[0];
    }
  }
  return \%SeriesWithDups, \%SeriesDupReport;
}

1;
