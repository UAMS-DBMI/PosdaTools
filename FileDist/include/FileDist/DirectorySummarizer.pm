#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/FileDist/include/FileDist/DirectorySummarizer.pm,v $
#$Date: 2014/09/03 20:51:41 $
#$Revision: 1.3 $
#
use strict;
package FileDist::DirectorySummarizer;
###  Virtual Class for objects to Summarize Directory Contents
sub InitSummary{
  my($this) = @_;
  my $child_name = $this->child_path("Nicknames");
  my $child = $this->get_obj($child_name);
  unless($child) {
    Posda::HttpApp::DicomNicknames->new($this->{session}, $child_name);
  }
  $this->{RoutesBelow}->{GetDicomNicknamesByFile} = 1;
  $this->{RoutesBelow}->{GetFilesByFileNickname} = 1;
  $this->{RoutesBelow}->{GetFilesByUidNickname} = 1;
  $this->{RoutesBelow}->{GetEntityNicknameByEntityId} = 1;
  $this->{RoutesBelow}->{GetEntityIdByNickname} = 1;
  $this->{RoutesBelow}->{GetFileList} = 1;
  $this->{ImportsFromAbove}->{GetDicomNicknamesByFile} = 1;
  $this->{ImportsFromAbove}->{GetFilesByFileNickname} = 1;
  $this->{ImportsFromAbove}->{GetFilesByUidNickname} = 1;
  $this->{ImportsFromAbove}->{GetEntityNicknameByEntityId} = 1;
  $this->{ImportsFromAbove}->{GetEntityIdByNickname} = 1;
  $this->{Exports}->{GetFileList} = 1;
  $this->{Nicknames} = {};
  $this->{Modalities} = {};
  for my $f (keys %{$this->{Analyzer}->{DirectoryManager}->{Processed}}){
    my $dicom_info = $this->{Analyzer}->{FM}->DicomInfo($f);
    if($dicom_info) { $this->{DicomInfo}->{$f} = $dicom_info }
    else { print STDERR "No Dicom Info for $f\n" }
  }
  $this->{SortedFiles} = [
    sort {
      return $this->{DicomInfo}->{$a}->{patient_id}
        cmp $this->{DicomInfo}->{$b}->{patient_id}||
      $this->{DicomInfo}->{$a}->{study_uid}
        cmp $this->{DicomInfo}->{$b}->{study_uid}||
      $this->{DicomInfo}->{$a}->{series_uid}
        cmp $this->{DicomInfo}->{$b}->{series_uid}||
      $this->{DicomInfo}->{$a}->{norm_x}
        <=> $this->{DicomInfo}->{$b}->{norm_x} ||
      $this->{DicomInfo}->{$a}->{norm_y}
        <=> $this->{DicomInfo}->{$b}->{norm_y} ||
      $this->{DicomInfo}->{$a}->{norm_z}
        <=> $this->{DicomInfo}->{$b}->{norm_z};
    }
    keys %{$this->{DicomInfo}}
  ];
  for my $f (@{$this->{SortedFiles}}){
    my $d_nn =
      $this->FetchFromAbove("GetDicomNicknamesByFile", $f);
    my $f_nn = $d_nn->[0];
    $this->{Nicknames}->{f_nn}->{$d_nn->[0]} = 1;
    my $uid_nn = $d_nn->[1];
    $this->{Nicknames}->{uid_nn}->{$d_nn->[1]} = 1;
    my $st_nn =
      $this->FetchFromAbove("GetEntityNicknameByEntityId",
        "Study", $this->{DicomInfo}->{$f}->{study_uid});
    $this->{Nicknames}->{study_nn}->{$st_nn} = 1;
    my $series_nn =
      $this->FetchFromAbove("GetEntityNicknameByEntityId",
        "Series", $this->{DicomInfo}->{$f}->{series_uid});
    my $modality = $this->{DicomInfo}->{$f}->{modality};
    $this->{Nicknames}->{series_nn}->{$series_nn}->{$modality} += 1;
    $this->{Modalities}->{$modality} = 1;
    $this->{Summary}->{$st_nn}->{$series_nn}->{modality}->{$modality} = 1;
    $this->{Summary}->{$st_nn}->{$series_nn}->{uids}->{$uid_nn}->{$f_nn} = 1;
  }
}
sub StudySeriesImageSelections{
  my($this, $http, $dyn) = @_;
  $http->queue("\n\n\n<small>Summary of Directory Contents:<ul>\n");
  for my $study (sort keys %{$this->{Summary}}){
    $http->queue("<li>$study ( " . 
      "<a href=\"#\" onClick=\"ns('ExamineStudy?" .
      "obj_path=$this->{path}&study=$study')\">view</a>):" .
      "<ul>\n");
      for my $series (sort keys %{$this->{Summary}->{$study}}){
        my($num_uids, $num_files) = $this->CountFilesAndUids($study, $series);
        $http->queue("<li>$series, $num_files files, " .
          " $num_uids uids " .
          "<a href=\"#\", onClick=\"ns('ExamineSeries?obj_path=$this->{path}" .
          "&series=$series')\">(view)</a>\n");
        if(
          (scalar keys %{$this->{Summary}->{$study}->{$series}->{modality}})
          > 1
        ){
          $http->queue("<ul>\n");
          $http->queue("<li>modalities:<ul>\n");
          $http->queue("</ul></li>\n");
          $http->queue("</ul>\n");
        } else {
          my @modalities = keys 
            %{$this->{Summary}->{$study}->{$series}->{modality}};
          my $modality = $modalities[0];
          $http->queue(" modality: $modality");
        }
        $http->queue("</li>\n");
      }
    $http->queue("</ul></li>\n");
  }
  $http->queue("</ul></small>\n");
}
sub CountFilesAndUids{
  my($this, $study, $series) = @_;
  my $num_files = 0;
  my $num_uids = 0;
  my $foo = $this->{Summary}->{$study}->{$series}->{uids};
  for my $uid (keys %$foo){
    $num_uids += 1;
    for my $f (keys %{$foo->{$uid}}){
      $num_files += 1;
    }
  }
  return $num_uids, $num_files;
}
sub ExamineStudy{
  my($this, $http, $dyn) = @_;
  my $child_name = $this->child_path("Examine_$dyn->{study}");
  my $cmp_obj = $this->child($child_name);
  if($cmp_obj) {
    print STDERR "???  already exists ???";
  } else {
    $cmp_obj = FileDist::ShowStudy->new($this->{session},
      $child_name, $dyn->{study}, $this->{DicomInfo}, $this->{Summary});
  }
  $cmp_obj->ReOpenFile;
}
sub ExamineSeries{
  my($this, $http, $dyn) = @_;
  my $child_name = $this->child_path("Examine_$dyn->{series}");
  my $cmp_obj = $this->child($child_name);
  if($cmp_obj) {
    print STDERR "???  already exists ???";
  } else {
    $cmp_obj = FileDist::ShowSeries->new($this->{session},
      $child_name, $dyn->{series}, $this->{DicomInfo}, $this->{Summary});
  }
  $cmp_obj->ReOpenFile;
}
sub ClearSummary{
  my($this) = @_;
  delete $this->{Analyzer};
  delete $this->{DicomInfo};
  delete $this->{directory};
  delete $this->{Nicknames};
  delete $this->{SortedFiles};
  delete $this->{Summary};
  delete $this->{Modalities};
  $this->delete_descendants;
}
############################
sub GetFileList {
  my($this) = @_;
  return $this->{SortedFiles};
}
1;
