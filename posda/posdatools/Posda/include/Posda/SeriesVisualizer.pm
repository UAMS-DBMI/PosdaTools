package Posda::SeriesVisualizer;
use strict;

use Posda::PopupWindow;
use Posda::DB qw( Query );
use Digest::MD5;
use ActivityBasedCuration::Quince;


use vars qw( @ISA );
@ISA = ("Posda::PopupWindow");
sub MakeQueuer{ 
  my($http) = @_;
  my $sub = sub {
    my($txt) = @_;
    $http->queue($txt);
  };
  return $sub;
}

sub SpecificInitialize {
  my ($self, $params) = @_;
  $self->{title} = "Generic SeriesVisualizer";
  # Determine temp dir
  $self->{temp_path} = "$self->{LoginTemp}/$self->{session}";
  $self->{params} = $params;
  $self->{series_instance_uid} = $params->{series_instance_uid};
  $self->{activity_id} = $params->{activity_id};
  my %sop_instances;
  my %instance_numbers;
  my %series_instances;
  my %series_dates;
  my %study_instances;
  my %study_dates;
  my %patient_ids;
  my %modalities;
  my %dicom_file_types;
  my %for_uids;
  my %iops;
  my %ipps;
  my %pix_digs;
  
  my $get_f_info = Query('GetFileInfoForSeriesReport');
  Query('GetFilesInSeriesAndActivity')->RunQuery(sub{
    my($row) = @_;
    my $file_id = $row->[0];
    Query('GetFileInfoForSeriesReport')->RunQuery(sub{
      my($row) = @_;
      my($file_id,
        $sop_instance_uid,
        $series_instance_uid,
        $series_date,
        $study_instance_uid,
        $study_date,
        $instance_number,
        $patient_id,
        $modality,
        $dicom_file_type,
        $for_uid,
        $iop,
        $ipp,
        $pixel_data_digest) = @$row;
      $sop_instances{$sop_instance_uid} = 1;
      $instance_numbers{$instance_number} = 1;
      $series_instances{$series_instance_uid} = 1;
      $series_dates{$series_date} = 1;
      $study_instances{$study_instance_uid} = 1;
      $study_dates{$study_date} = 1;
      $patient_ids{$patient_id} = 1;
      $modalities{$modality} = 1;
      $dicom_file_types{$dicom_file_type} = 1;
      $for_uids{$for_uid} = 1;
      $iops{$iop} = 1;
      $ipps{$ipp} = 1;
      $pix_digs{$pixel_data_digest} = 1;
      $self->{FilesInSeries}->{$file_id} = {
        sop_instance_uid => $sop_instance_uid,
        instance_number => $instance_number,
        series_instance_uid => $series_instance_uid,
        series_date => $series_date,
        study_instance_uid => $study_instance_uid,
        study_date => $study_date,
        patient_id => $patient_id,
        modality => $modality,
        dicom_file_type => $dicom_file_type,
        for_uid => $for_uid,
        iop => $iop,
        ipp => $ipp,
        pixel_data_digest => $pixel_data_digest
      };
      $self->{SeriesCounts} = {
        sops => \%sop_instances,
        inst_nums  => \%instance_numbers,
        series_inst  => \%series_instances,
        series_dates  => \%series_dates,
        study_instances  => \%study_instances,
        study_dates  => \%study_dates,
        patient_ids  => \%patient_ids,
        modalities  => \%modalities,
        dicom_file_types  => \%dicom_file_types,
        frame_of_ref  => \%for_uids,
        iops  => \%iops,
        ipps  => \%ipps,
        pixels  => \%pix_digs 
      };
    }, sub  {}, $file_id);
    $self->{mode} = "series_report";
    $self->{sort_field} = "instance_number";
  }, sub {}, $self->{series_instance_uid}, $self->{activity_id});
}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  if($self->{mode} eq "series_report"){
    $self->SeriesReport($http, $dyn);
    $self->SeriesSummary($http, $dyn);
    return;
  }
  my $queuer = MakeQueuer($http);
  $http->queue("<pre>Params: ");
  Debug::GenPrint($queuer, $self->{params}, 1);
  $http->queue(";\n");
  $http->queue("</pre>");
}

sub SeriesReport{
  my ($self, $http, $dyn) = @_;
  $http->queue(
    "<h4>Series report for series $self->{series_instance_uid}:</h4>");
  my $num_files = keys %{$self->{FilesInSeries}};
  $http->queue("<pre>Contains $num_files files\n");
  for my $i ("dicom_file_types", "modalities", "patient_ids", 
    "frame_of_ref", "iops", "series_dates", "study_instances",
    "study_dates"
  ){
    my $num = keys %{$self->{SeriesCounts}->{$i}};
    if($num > 1){
      $http->queue("Has $num $i\n");
    } else {
      my $v = [keys %{$self->{SeriesCounts}->{$i}}]->[0];
      $http->queue("Has one $i ($v)\n");
    }
  }
#  "inst_nums", "ipps", "sops", "pixels"
  my $num_insts = keys %{$self->{SeriesCounts}->{ipps}};
  if($num_insts == $num_files){
    $http->queue("Has $num_insts instance_numbers (one per file)");
  } else {
    $http->queue("Has $num_insts instance_numbers (NOT one per file)\n");
  }
  $http->queue("\n");
  my $num_sops = keys %{$self->{SeriesCounts}->{sops}};
  if($num_sops == $num_files){
    $http->queue("Has $num_sops sops (one per file)");
  } else {
    $http->queue("Has $num_sops sops (NOT one per file)");
  }
  $http->queue("\n");
  my $num_ipps = keys %{$self->{SeriesCounts}->{ipps}};
  if($num_ipps == $num_files){
    $http->queue("Has $num_ipps ipps (one per file)");
  } else {
    $http->queue("Has $num_ipps ipps (NOT one per file)");
  }
  $http->queue("\n");
  my $num_pixels = keys %{$self->{SeriesCounts}->{pixels}};
  if($num_pixels == $num_files){
    $http->queue("Has $num_pixels pixels (one per file)");
  } else {
    $http->queue("Has $num_pixels pixels (NOT one per file)");
  }
  $http->queue("\n");

  $http->queue("</pre>");
}

sub SeriesSummary{
  my ($self, $http, $dyn) = @_;
  $http->queue(
    "<h4>Series summary for series $self->{series_instance_uid}:</h4>");
  my @files = sort
    {
       $self->{FilesInSeries}->{$a}->{$self->{sort_field}} <=>
       $self->{FilesInSeries}->{$b}->{$self->{sort_field}}
    }
    keys %{$self->{FilesInSeries}};
  my @keys = ("instance_number", "sop_instance_uid", "dicom_file_type",
    "modality", "iop", "ipp");
  $http->queue("<table class=\"table table-striped\"><tr>");
  $http->queue("<th>file_id</th>");
  for my $k (@keys){
    $http->queue("<th>$k</th>");
  }
  for my $i (@files){
    $http->queue("<tr>");
    $http->queue("<td>$i</td>");
    for my $k (@keys){
      $http->queue("<td>$self->{FilesInSeries}->{$i}->{$k}</td>");
    }
    $http->queue("</tr>");
  }
  $http->queue("</table>");
}

  

sub SetSeriesReport{
  my ($self, $http, $dyn) = @_;
  $self->{mode} = "series_report";
}

sub OpenInQuince{
  my ($self, $http, $dyn) = @_;
  bless $self, "ActivityBasedCuration::Quince";
  $self->Initialize({
    type => "series",
    series_instance_uid => $self->{params}->{series_instance_uid}
  });
}


sub MenuResponse {
  my ($self, $http, $dyn) = @_;
  $self->NotSoSimpleButton($http, {
     op => "SetSeriesReport",
     caption => "Series Report",
     sync => "Update();"
  });
  $self->NotSoSimpleButton($http, {
     op => "OpenInQuince",
     caption => "Open in Quince",
     sync => "Reload();"
  });
}

1;
