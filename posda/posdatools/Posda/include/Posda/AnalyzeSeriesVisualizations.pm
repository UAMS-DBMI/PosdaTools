package Posda::AnalyzeSeriesVisualizations;
use strict;

use Posda::PopupWindow;
use Posda::ImageDisplayer;
use Nifti::Parser;
use Posda::FileVisualizer;
use Posda::SeriesVisualizer;
use Posda::DB qw( Query );
use Digest::MD5;
use Debug;

use vars qw( @ISA );
@ISA = ("Posda::ImageDisplayer");
sub MakeQueuer{ 
  my($http) = @_;
  my $sub = sub {
    my($txt) = @_;
    $http->queue($txt);
  };
  return $sub;
}

sub Init {
  my ($self, $params) = @_;
  $self->{title} = "BuildDicomDefaced";
  $self->{params} = $params;
  $self->{mode} = "NewView";
  $self->{width} = 2000;
  $self->{height} = 1024;
  my %patients;
  my %collections;
  Query('VerboseActivityReport')->RunQuery(sub{
    my($row) = @_;
    my($collection, $site, $patient_id,
      $patient_age,
      $study_instance_uid, $study_date, $study_description,
      $series_instance_uid, $series_date, $series_description,
      $dicom_file_type, $modality, $num_files) = @$row;
   $patients{$patient_id}->{studies}->{$study_instance_uid}->{series}
     ->{$series_instance_uid}->{dicom_file_type}->{$dicom_file_type} = 1;
   $patients{$patient_id}->{studies}->{$study_instance_uid}->{series}
     ->{$series_instance_uid}->{modality}->{$modality} = 1;
   $patients{$patient_id}->{studies}->{$study_instance_uid}->{series}
     ->{$series_instance_uid}->{num_files}->{$num_files} = 1;
   $patients{$patient_id}->{studies}->{$study_instance_uid}->{series}
     ->{$series_instance_uid}->{series_date}->{$series_date} = 1;
   $patients{$patient_id}->{studies}->{$study_instance_uid}->{series}
     ->{$series_instance_uid}->{series_description}->{$series_description} = 1;
   $patients{$patient_id}->{studies}->{$study_instance_uid}->{series}
     ->{$series_instance_uid}->{study_date}->{$study_date} = 1;
   $patients{$patient_id}->{studies}->{$study_instance_uid}->{series}
     ->{$series_instance_uid}->{study_description}->{$study_description} = 1;
   $patients{$patient_id}->{studies}->{$study_instance_uid}->{study_description}
     ->{$study_description} = 1;
   $patients{$patient_id}->{studies}->{$study_instance_uid}->{study_date}
     ->{$study_date} = 1;
   $patients{$patient_id}->{collection}->{$collection}->{sites}->{$site} = 1;
   $collections{$collection}->{$site} = 1;
   $self->{patients} = \%patients;
   $self->{collections} = \%collections;
  },sub{}, $params->{activity_id});
  $self->{SeriesStatus} = {};
  Query('FailedNiftiConversionByActivity')->RunQuery(sub{
    my($row) = @_;
    $self->{FailedNiftiConversions}->{$row->[1]} = $row->[0];
    $self->{SeriesStatus}->{$row->[1]} = "failed nifti conversion";
  }, sub{}, $params->{activity_id});
  my $q = Query('GetDefacedDicom');
  Query('ImageDefacingResultsByActivity')->RunQuery(sub{
    my($row) = @_;
    my $h = {
      subprocess_invocation_id => $row->[0],
      file_id => $row->[1],
      defaced_file_id => $row->[2],
      three_d => $row->[3],
      face_box => $row->[4],
      defaced => $row->[5],
      success => $row->[6],
      error_code => $row->[7],
      series_instance_uid => $row->[8],
      mapped_to_dicom_files => $row->[9],
      nifti_base_file_name => $row->[10],
      nifti_json_file_id => $row->[11],
      iop => $row->[12],
      first_ipp => $row->[13],
      last_ipp => $row->[14],
      specified_gantry_tilt => $row->[15],
      computed_gantry_tilt => $row->[16],
      num_files_in_series => $row->[17],
      num_files_selected_from_series => $row->[18],
    };
    unless(defined $h->{file_id}){
      unless($self->{SeriesStatus}->{$h->{series_instance_uid}} eq "failed nifti conversion"){
        print STDERR "#######\n" .
          "series instance uid: $h->{series_instance_uid}\n" .
          "Not returned in FailedNiftiConversionByActivity\n" .
          "#######\n";
        $self->{SeriesStatus}->{$h->{series_instance_uid}} = "failed nifti_conversion";
      }
      return;
    }
    if($h->{three_d} eq ""){
      $self->{FailedDefacing}->{$h->{series_instance_uid}} = $h;
      $self->{SeriesStatus}->{$h->{series_instance_uid}} = "failed 3D reconstruction";
      return;
    }
    if($h->{face_box} eq ""){
      $self->{FailedDefacing}->{$h->{series_instance_uid}} = $h;
      $self->{SeriesStatus}->{$h->{series_instance_uid}} = "failed to find face";
      return;
    }
    if($h->{defaced_file_id} eq ""){
      $self->{FailedDefacing}->{$h->{series_instance_uid}} = $h;
      $self->{SeriesStatus}->{$h->{series_instance_uid}} = "failed to deface";
      return;
    }
    unless($h->{mapped_to_dicom_files}){
      $self->{FailedDicomMapping}->{$h->{series_instance_uid}} = $h;
      $self->{SeriesStatus}->{$h->{series_instance_uid}} = "Defaced, but not mapped back to DICOM";
      return;
    }
    $self->{SeriesStatus}->{$h->{series_instance_uid}} = "Defaced, mapped back to DICOM";
    $self->{DefacedNifti}->{$h->{series_instance_uid}} = $h;
    $q->RunQuery(sub{
      my($row) = @_;
      my $h1 = {
        undefaced_nifti_file => $row->[0],
        defaced_nifti_file => $row->[1],
        original_dicom_series_instance_uid => $row->[2],
        defaced_dicom_series_instance_uid => $row->[3],
        number_of_files_text => $row->[4],
        import_event_comment => $row->[5],
        difference_nifti_file => $row->[6],
      };
      $self->{DefacedDicom}->{$h->{series_instance_uid}} = $h1;
      $self->{DefacedSeries}->{$h1->{defaced_dicom_series_instance_uid}} = 1;
      $self->{SeriesStatus}->{$h1->{defaced_dicom_series_instance_uid}} = "defaced dicom series";
    }, sub{}, $h->{defaced_file_id});
    for my $i (keys %{$self->{DefacedNifti}}){
      unless(exists $self->{DefacedDicom}->{$i}){
        $self->{AwaitingConversionToDicom}->{$i} = 1;
      }
    }
    for my $ser (keys %{$self->{SeriesStatus}}){
      $self->{EnabledSeries}->{$self->{SeriesStatus}->{$ser}}->{value} = 1;
    }
  }, sub {}, $params->{activity_id});
  for my $ser (keys %{$self->{SeriesStatus}}){
    $self->{EnabledSeries}->{$self->{SeriesStatus}->{$ser}}->{value} = 1;
  }
  $self->{SeriesNiftiConversionNotes} = {};
  for my $ser (keys %{$self->{SeriesStatus}}){
    Query('GetNiftiConversionNotesBySeries')->RunQuery(sub{
      my($row) = @_;
      my $text = $row->[0];
      if($text =~ /^\{(.*)\}$/) {$text = $1}
      my @lines = split(/,/, $text);
      for my $i (0 .. $#lines){
        if($lines[$i] =~ /^\"(.*)\"$/) { $lines[$i] = $1 }
      }
      $self->{SeriesNiftiConversionNotes}->{$ser} = \@lines;;
    }, sub {}, $ser);
  }
  $self->{SeriesNiftiConversionWarnings} = {};
  for my $ser (keys %{$self->{SeriesStatus}}){
    my @list;
    Query('GetDcm2NiiWarningsBySeries')->RunQuery(sub{
      my($row) = @_;
      my $warning = $row->[0];
      push @list, $warning;
    }, sub {}, $ser);
    if($#list >= 0){
      $self->{SeriesNiftiConversionWarnings}->{$ser} = \@list;
    }
  }
  $self->{EquivalenceClasses} = {};
  Query('GetEquivalenceClassesByActivity')->RunQuery(sub{
    my($row) = @_;
    my($visual_review_instance_id,
      $series_instance_uid,
      $equivalence_class_number,
      $projection_type,
      $file_id,
      $num_files) = @$row;
    $self->{EquivalenceClasses}->{$series_instance_uid}
      ->{$equivalence_class_number} = {
       projection_type => $projection_type,
       file_id => $file_id,
       num_files => $num_files
     };
  }, sub{}, $params->{activity_id});
  $self->{patient_list} = [sort keys %{$self->{patients}}];
  $self->{selected_patient} = $self->{patient_list}->[0];
  $self->{SurpressNiftiConversionWarnings}->{value} = 1;
  $self->{SurpressNiftiConversionNotes}->{value} = 1;
}

sub Setmode{
  my ($self, $http, $dyn) = @_;
  $self->{mode} = $dyn->{mode};
}

my $content = <<EOF;
<div id="menu"></div>
<hr>
<div id="content"></div>
EOF

sub Content{
  my ($self, $http, $dyn) = @_;
  $self->RefreshEngine($http, $dyn, $content);
  $self->QueueJsCmd("UpdateDivs([['menu', 'MenuResponse'], ['content', 'ContentResponse']])");
}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  my $mode = $self->{mode};
  if($self->can($mode)){
    return $self->$mode($http, $dyn);
  } else {
    $http->queue("<pre>Unimplemented mode: $self->{mode}</pre>");
  }
}

sub NewView{
  my ($self, $http, $dyn) = @_;
  $http->queue('<table class="table table-condensed" id="table_new_view" style="width:100%">');
#  for my $pat_id (keys %{$self->{patients}}){
  {
    my $pat_id = $self->{selected_patient};
    $http->queue('<tr>');
    for my $i (0 .. 14){
      $http->queue('<th></th>');
    }
    $http->queue('</tr>');
    for my $std (sort keys %{$self->{patients}->{$pat_id}->{studies}}){
      $http->queue('<tr>');
      $http->queue("<th>study</th><th colspan=4>$std</th>");
      $http->queue('</tr>');
      series:
      for my $ser (sort keys %{$self->{patients}->{$pat_id}->{studies}->{$std}->{series}}){
        my $s_h = $self->{patients}->{$pat_id}->{studies}->{$std}->{series}->{$ser};
        #if(exists $self->{DefacedSeries}->{$ser}) { next series }
        if($self->{EnabledSeries}->{$self->{SeriesStatus}->{$ser}}->{value} == 0) { next series }
        $http->queue('<tr>');
        $http->queue('<th colspan=1></th>');
        $http->queue("<th colspan=4>series: $ser</th>");
        $http->queue("<th colspan=5>");
        my $dicom_file_type;
        my @dicom_file_types = keys %{$s_h->{dicom_file_type}};
        if($#dicom_file_types > 0){
          $dicom_file_type = "(";
          for my $i (0 .. $#dicom_file_types){
            $dicom_file_type .= $dicom_file_types[$i];
            if($i == $#dicom_file_types){
              $dicom_file_type .= ", ";
            } else {
              $dicom_file_type .= ")";
            }
          }
        } else {
          $dicom_file_type = $dicom_file_types[0];
        }
        my $modality;
        my @modalities = keys %{$s_h->{modality}};
        if($#modalities > 0){
          $modality = "(";
          for my $i (0 .. $#modalities){
            $modality .= $modalities[$i];
            if($i == $#modalities){
              $modality .= ", ";
            } else {
              $modality .= ")";
            }
          }
        }else{
            $modality = $modalities[0];
        }
        my $num_files = [keys %{$s_h->{num_files}}]->[0];
        $http->queue("dicom_file_type: $dicom_file_type, modality: $modality, " .
          "num_files: $num_files");
        $http->queue("</th>");
        $http->queue("<th colspan=5>");
        $http->queue("$self->{SeriesStatus}->{$ser}");
        if(exists $self->{EquivalenceClasses}->{$ser}){
          my $num_e = keys %{$self->{EquivalenceClasses}->{$ser}};
          $http->queue(", $num_e equivalence classes");
        }
        $http->queue("</th>");
        $http->queue('</tr>');
        if($self->{ExpandRows}->{value} == 1){
          $self->NewerConvertedRow($http, {
#          $self->NewConvertedRow($http, {
            series_instance_uid => $ser,
            series_status => $self->{SeriesStatus}->{$ser},
          });
        }
        if($self->{ShowEquivalenceClasses}->{value} == 1){
          $self->ShowEquivalenceClasses($http, {
            series_instance_uid => $ser
          });
        }
      }
    }
  }
  $http->queue('</table>');
}

sub NewerConvertedRow{
  my ($self, $http, $dyn) = @_;
  my $ser = $dyn->{series_instance_uid};
  my $ser_stat = $dyn->{series_status};
  $http->queue("<tr><td colspan=5>");
  $self->Vcol1($http,$dyn);
  $http->queue("</td><td colspan=5>");
  $self->Vcol2($http,$dyn);
  $http->queue("</td><td colspan=5>");
  $self->Vcol3($http,$dyn);
  $http->queue("</td></tr>");
#  if($self->{ShowEquivalenceClasses}->{value} == 1){
#    $self->ShowEquivalenceClasses($http, {
#      series_instance_uid => $ser
#    });
#  }
}

sub ShowEquivalenceClasses{
  my ($self, $http, $dyn) = @_;
  my $ser = $dyn->{series_instance_uid};
  for my $equiv (keys %{$self->{EquivalenceClasses}->{$ser}}){
    my $file_id = $self->{EquivalenceClasses}->{$ser}->{$equiv}->{file_id};
    my $num_files = $self->{EquivalenceClasses}->{$ser}->{$equiv}->{num_files};
    $http->queue("<tr>");
    $http->queue("<td colspan=2><pre>Equiv class: $equiv\nNum files: $num_files</pre></td>");
    $http->queue("<td colspan=10>");
    $http->queue("<img src=\"FetchPng?obj_path=$self->{path}&file_id=$file_id\">");
    $http->queue("</td>");
    $http->queue("<td colspan=3>");
    $http->queue("</td>");
    $http->queue("</tr>");
  }
}

sub Vcol1{
  my ($self, $http, $dyn) = @_;
  my $ser = $dyn->{series_instance_uid};
  my $ser_stat = $dyn->{series_status};
  if($ser_stat eq "Defaced, mapped back to DICOM"){
    $self->FaceBoxAndDefaced($http, $dyn);
  } elsif($ser_stat eq "failed to find face"){
    $self->ThreeD($http, $dyn);
  } elsif(
    $ser_stat eq "failed 3D reconstruction" ||
    $ser_stat eq "failed nifti conversion"
  ){
    $self->SeriesNiftiConversionNotes($http, {ser => $ser});
  } else {
    $http->queue("more to come");
  }
}
sub NiftiConversionNotes{
  my ($self, $http, $dyn) = @_;
  my $ser = $dyn->{series_instance_uid};
  my $ser_stat = $dyn->{series_status};
  $http->queue("<pre>");
  $http->queue("Nifti Conversion Notes:\n");
  for my $line(@{$self->{SeriesNiftiConversionNotes}->{$ser}}){
    $http->queue("$line\n");
  }
  $http->queue("</pre>");
}
sub FaceBoxAndDefaced{
  my ($self, $http, $dyn) = @_;
  my $ser = $dyn->{series_instance_uid};
  my $df_h = $self->{DefacedNifti}->{$ser};
  $http->queue("<img src=\"FetchPng?obj_path=$self->{path}&file_id=$df_h->{three_d}\" width=\"256\">");
  $http->queue("<img src=\"FetchPng?obj_path=$self->{path}&file_id=$df_h->{defaced}\" width=\"256\">");
}

sub ThreeD{
  my ($self, $http, $dyn) = @_;
  my $ser = $dyn->{series_instance_uid};
  my $row = $self->{FailedDefacing}->{$ser};
  my $undefaced_nifti_file = $row->{file_id};
  my $three_d = $row->{three_d};
  $http->queue("<img src=\"FetchPng?obj_path=$self->{path}&file_id=$three_d\" width=\"256\">");
}
sub Vcol2{
  my ($self, $http, $dyn) = @_;
  my $ser = $dyn->{series_instance_uid};
  my $ser_stat = $dyn->{series_status};
  $self->ConversionInfo($http, $dyn);
#  $http->queue("more to come");
}
sub ConversionInfo{
  my ($self, $http, $dyn) = @_;
  my $ser = $dyn->{series_instance_uid};
  my $ser_stat = $dyn->{series_status};
  my $df_h = $self->{DefacedNifti}->{$ser};
  my $di_h = $self->{DefacedDicom}->{$ser};
  my $row = $self->{FailedDefacing}->{$ser};
  my $undefaced_nifti_file = $row->{file_id};
  my $three_d = $row->{three_d};
  if($ser_stat eq "Defaced, mapped back to DICOM"){
    $http->queue("<pre>Nifti Files\n");
    $http->queue("Converted: $df_h->{file_id}");
    $http->queue("<input type=\"Button\" class=\"btn btn-default\" onClick=\"" .
        "javascript:PosdaGetRemoteMethod('LaunchNiftiViewer', 'file_id=$df_h->{file_id}', " .
        "'function(){}')\" value=\"view\">\n");
    $http->queue("Defaced: $df_h->{defaced_file_id}");
    $http->queue("<input type=\"Button\" class=\"btn btn-default\" onClick=\"" .
        "javascript:PosdaGetRemoteMethod('LaunchNiftiViewer', 'file_id=$df_h->{defaced_file_id}', " .
        "'function(){}')\" value=\"view\">\n");
    $http->queue("Difference $di_h->{difference_nifti_file}");
    $http->queue("<input type=\"Button\" class=\"btn btn-default\" onClick=\"" .
        "javascript:PosdaGetRemoteMethod('LaunchNiftiViewer', 'file_id=$di_h->{difference_nifti_file}', " .
        "'function(){}')\" value=\"view\">\n");
    $http->queue("</pre>");
  } elsif ($ser_stat eq "failed to find face"){
    $http->queue("<pre>");
    $http->queue("Converted $undefaced_nifti_file");
    $http->queue("<input type=\"Button\" class=\"btn btn-default\" onClick=\"" .
        "javascript:PosdaGetRemoteMethod('LaunchNiftiViewer', 'file_id=$undefaced_nifti_file', " .
        "'function(){}')\" value=\"view\">\n");
    $http->queue("</pre>");
    $self->SeriesNiftiConversionWarnings($http, { ser => $ser });
    $self->SeriesNiftiConversionNotes($http, { ser => $ser });
  } elsif ($ser_stat eq "failed 3D reconstruction"){
    $self->SeriesNiftiConversionWarnings($http, { ser => $ser });
  }
}
sub SeriesNiftiConversionWarnings{
  my ($self, $http, $dyn) = @_;
  my $ser = $dyn->{ser};
  if(exists $self->{SeriesNiftiConversionWarnings}->{$ser}){
    $http->queue("<pre>");
    if($self->{SurpressNiftiConversionWarnings}->{value} == 0){
      for my $line (@{$self->{SeriesNiftiConversionWarnings}->{$ser}}){
        $http->queue("$line\n");
      } 
    } else {
      $http->queue("Nifti conversion warnings surpressed");
    }
    $http->queue("</pre>");
  }
}
sub Vcol3{
  my ($self, $http, $dyn) = @_;
  my $ser = $dyn->{series_instance_uid};
  my $ser_stat = $dyn->{series_status};
  $http->queue("<input type=\"Button\" class=\"btn btn-default\" onClick=\"" .
    "javascript:PosdaGetRemoteMethod('LaunchSeriesVisualizer', 'series_instance_uid=$ser', " .
    "'function(){}')\" value=\"original series report\">\n");
  #$http->queue("more to come");
}

sub DataDump{
  my ($self, $http, $dyn) = @_;
  my $queuer = MakeQueuer($http);
  $http->queue("<pre>Data: ");
  Debug::GenPrint($queuer, $self, 1, 4);
  $http->queue(";\n");
  $http->queue("</pre>");
}

sub WaitingToConvertToDicom{
  my ($self, $http, $dyn) = @_;
  $http->queue("<pre>WaitingToConvertToDicom coming soon</pre>");
}

my $fully_converted_content = <<EOF;
<div
   style="display: flex; flex-direction: row; align-items: flex_beginning; margin-top: 5px; margin-right: 5px; margin-bottom: 5px; margin-left: 5px;">
<table class="table table-condensed" id="table_fully_converted" summary="Fully Defaced DICOM" style="width:100%" border="1">
<tr>
<th>3d render</th><th>nifti_file</th><th>series</th>
</tr>
<?dyn="FullyConvertedTableRows"?>
</table>
</div>
EOF

sub FullyConverted{
  my ($self, $http, $dyn) = @_;
  $self->RefreshEngine($http, $dyn, $fully_converted_content);
}

sub FullyConvertedTableRows{
  my ($self, $http, $dyn) = @_;
  unless(exists $self->{DefacedDicom} && ref($self->{DefacedDicom}) eq "HASH"){
    return;
  }
  my @defaced_list = sort keys %{$self->{DefacedDicom}};
  for my $i (0 .. $#defaced_list){
    $self->FullyConvertedTableRow($http, { defaced_nifti => $defaced_list[$i] });
  }
}
sub NewConvertedRow{
  my ($self, $http, $dyn) = @_;
  my $ser = $dyn->{series_instance_uid};
  my $status = $self->{SeriesStatus}->{$ser};
  if($status eq "failed to find face"){
    return $self->FailedDefacing($http, $dyn);
  }
  if($status eq "Defaced, mapped back to DICOM"){
    return $self->FullyDefaced($http, $dyn);
  }
  if($status eq "failed 3D reconstruction"){
    return $self->Failed3D($http, $dyn);
  }
  if($status eq "failed nifti conversion"){
    return $self->FailedNiftiConversion($http, $dyn);
  }
  $http->queue("<tr><td colspan=8>Status:\"$status\" not yet supported</td></tr>");
}
sub FullyDefaced{
  my ($self, $http, $dyn) = @_;
  my $ser = $dyn->{series_instance_uid};
  my $row_d = $self->{DefacedDicom}->{$ser};
  my $row_n = $self->{DefacedNifti}->{$ser};
  my $undefaced_nifti_file = $row_d->{undefaced_nifti_file};
  my $defaced_nifti_file = $row_d->{defaced_nifti_file};
  my $difference_nifti_file = $row_d->{difference_nifti_file};
  my $defaced_series = $row_d->{defaced_dicom_series_instance_uid};
  my $three_d = $row_n->{three_d};
  my $facebox = $row_n->{face_box};
  my $defaced = $row_n->{defaced};
  
  $http->queue("<tr><td colspan=3>");
  $http->queue("<img src=\"FetchPng?obj_path=$self->{path}&file_id=$facebox\" width=\"256\">");
  $http->queue("<img src=\"FetchPng?obj_path=$self->{path}&file_id=$defaced\" width=\"256\">");
  $http->queue("</td>");
  $http->queue("<td><pre>");
  $http->queue("Original: $undefaced_nifti_file");
  $http->queue("<input type=\"Button\" class=\"btn btn-default\" onClick=\"" .
      "javascript:PosdaGetRemoteMethod('LaunchNiftiViewer', 'file_id=$undefaced_nifti_file', " .
      "'function(){}')\" value=\"view\">\n");
  $http->queue("Defaced: $defaced_nifti_file");
  $http->queue("<input type=\"Button\" class=\"btn btn-default\" onClick=\"" .
      "javascript:PosdaGetRemoteMethod('LaunchNiftiViewer', 'file_id=$defaced_nifti_file', " .
      "'function(){}')\" value=\"view\">\n");
  $http->queue("Difference $difference_nifti_file");
  $http->queue("<input type=\"Button\" class=\"btn btn-default\" onClick=\"" .
      "javascript:PosdaGetRemoteMethod('LaunchNiftiViewer', 'file_id=$difference_nifti_file', " .
      "'function(){}')\" value=\"view\">\n");
  $http->queue("</pre></td>");
  $http->queue("<td><pre>");
  $http->queue("Original Series $ser");
  $http->queue("<input type=\"Button\" class=\"btn btn-default\" onClick=\"" .
    "javascript:PosdaGetRemoteMethod('LaunchSeriesVisualizer', 'series_instance_uid=$ser', " .
    "'function(){}')\" value=\"report\">\n");
  $http->queue("Defaced $defaced_series");
  $http->queue("<input type=\"Button\" class=\"btn btn-default\" onClick=\"" .
    "javascript:PosdaGetRemoteMethod('LaunchSeriesVisualizer', 'series_instance_uid=$defaced_series', " .
    "'function(){}')\" value=\"report\">\n");

  $http->queue("</pre></td>");
  $http->queue("</tr>");
}
sub FailedDefacing{
  my ($self, $http, $dyn) = @_;
  my $ser = $dyn->{series_instance_uid};
  my $row = $self->{FailedDefacing}->{$ser};
  my $undefaced_nifti_file = $row->{file_id};
  my $three_d = $row->{three_d};
  
  $http->queue("<tr><td colspan=3>");
  $http->queue("<img src=\"FetchPng?obj_path=$self->{path}&file_id=$three_d\" width=\"256\">");
  $http->queue("</td>");
  $http->queue("<td><pre>");
  $http->queue("Original: $undefaced_nifti_file");
  $http->queue("<input type=\"Button\" class=\"btn btn-default\" onClick=\"" .
      "javascript:PosdaGetRemoteMethod('LaunchNiftiViewer', 'file_id=$undefaced_nifti_file', " .
      "'function(){}')\" value=\"view\">\n");
  $http->queue("</pre>");
  if(exists $self->{SeriesNiftiConversionWarnings}->{$ser}){
    $http->queue("<pre>");
    for my $line (@{$self->{SeriesNiftiConversionWarnings}->{$ser}}){
      $http->queue("$line\n");
    } 
    $http->queue("</pre>");
  }
  $http->queue("</td>");
  $http->queue("<td><pre>");
  $http->queue("Original Series $ser");
  $http->queue("<input type=\"Button\" class=\"btn btn-default\" onClick=\"" .
    "javascript:PosdaGetRemoteMethod('LaunchSeriesVisualizer', 'series_instance_uid=$ser', " .
    "'function(){}')\" value=\"report\">\n");
  $http->queue("</pre></td>");
  $http->queue("</tr>");
}
sub SeriesNiftiConversionNotes{
  my ($self, $http, $dyn) = @_;
  my $ser = $dyn->{ser};
  if(exists $self->{SeriesNiftiConversionNotes}){
    $http->queue("<pre>");
    if($self->{SurpressNiftiConversionNotes}->{value} == 0){
      $http->queue("Series Nifti Conversion Notes:\n");
      for my $line(@{$self->{SeriesNiftiConversionNotes}->{$ser}}){
        $http->queue("$line\n");
      }
    } else {
      $http->queue("Series Nifti Conversion Notes Surpressed");
    }
  }
}
sub Failed3D{
  my ($self, $http, $dyn) = @_;
  my $ser = $dyn->{series_instance_uid};
  my $row = $self->{FailedDefacing}->{$ser};
  my $undefaced_nifti_file = $row->{file_id};
  
  $http->queue("<tr><td colspan=3>");
  $self->SeriesNiftiConversionNotes($http, {ser => $ser});
  $http->queue("</td>");
  $http->queue("<td><pre>");
  $http->queue("Original: $undefaced_nifti_file");
  $http->queue("<input type=\"Button\" class=\"btn btn-default\" onClick=\"" .
      "javascript:PosdaGetRemoteMethod('LaunchNiftiViewer', 'file_id=$undefaced_nifti_file', " .
      "'function(){}')\" value=\"view\">\n");
  $http->queue("</pre>");
  $self->SeriesNiftiConversionWarnings($http, { ser => $ser });
  $http->queue("</td>");
  $http->queue("<td><pre>");
  $http->queue("Original Series $ser");
  $http->queue("<input type=\"Button\" class=\"btn btn-default\" onClick=\"" .
    "javascript:PosdaGetRemoteMethod('LaunchSeriesVisualizer', 'series_instance_uid=$ser', " .
    "'function(){}')\" value=\"report\">\n");
  $http->queue("</pre></td>");
  $http->queue("</tr>");
}
sub FailedNiftiConversion{
  my ($self, $http, $dyn) = @_;
  my $ser = $dyn->{series_instance_uid};

  my $row = $self->{FailedDefacing}->{$ser};
  
  $http->queue("<tr><td colspan=3>");
  if(exists $self->{SeriesNiftiConversionNotes}->{$ser}){
    $self->SeriesNiftiConversionNotes($http, {ser => $ser});
  }
  $http->queue("</td>");
  $http->queue("<td><pre>");
#  $http->queue("Failed nifti file conversion:\n");
  $http->queue("</pre></td>");
  $http->queue("<td><pre>");
  $http->queue("Original Series $ser");
  $http->queue("<input type=\"Button\" class=\"btn btn-default\" onClick=\"" .
    "javascript:PosdaGetRemoteMethod('LaunchSeriesVisualizer', 'series_instance_uid=$ser', " .
    "'function(){}')\" value=\"report\">\n");
  $http->queue("</pre></td>");
  $http->queue("</tr>");
}
sub FullyConvertedTableRow{
  my ($self, $http, $dyn) = @_;
  my $defaced_file_id = $dyn->{defaced_nifti};
  my $df_h = $self->{DefacedNifti}->{$defaced_file_id};
  my $di_h = $self->{DefacedDicom}->{$defaced_file_id};
  $http->queue("<tr><td>");
  $http->queue("<img src=\"FetchPng?obj_path=$self->{path}&file_id=$df_h->{three_d}\" width=\"256\">");
  $http->queue("<img src=\"FetchPng?obj_path=$self->{path}&file_id=$df_h->{defaced}\" width=\"256\">");
  $http->queue("</td>");
  $http->queue("<td><pre>");
  $http->queue("Original: $df_h->{file_id}");
  $http->queue("<input type=\"Button\" class=\"btn btn-default\" onClick=\"" .
      "javascript:PosdaGetRemoteMethod('LaunchNiftiViewer', 'file_id=$df_h->{file_id}', " .
      "'function(){}')\" value=\"view\">\n");
  $http->queue("Defaced: $df_h->{defaced_file_id}");
  $http->queue("<input type=\"Button\" class=\"btn btn-default\" onClick=\"" .
      "javascript:PosdaGetRemoteMethod('LaunchNiftiViewer', 'file_id=$df_h->{defaced_file_id}', " .
      "'function(){}')\" value=\"view\">\n");
  $http->queue("Difference $di_h->{difference_nifti_file}");
  $http->queue("<input type=\"Button\" class=\"btn btn-default\" onClick=\"" .
      "javascript:PosdaGetRemoteMethod('LaunchNiftiViewer', 'file_id=$di_h->{difference_nifti_file}', " .
      "'function(){}')\" value=\"view\">\n");
  $http->queue("</pre></td>");
  $http->queue("<td><pre>");
  $http->queue("Original: $di_h->{original_dicom_series_instance_uid}");
  $http->queue("<input type=\"Button\" class=\"btn btn-default\" onClick=\"" .
    "javascript:PosdaGetRemoteMethod('LaunchSeriesVisualizer', 'series_instance_uid=$di_h->{original_dicom_series_instance_uid}', " .
    "'function(){}')\" value=\"report\">\n");
  $http->queue("Defaced $di_h->{defaced_dicom_series_instance_uid}");
  $http->queue("<input type=\"Button\" class=\"btn btn-default\" onClick=\"" .
    "javascript:PosdaGetRemoteMethod('LaunchSeriesVisualizer', 'series_instance_uid=$di_h->{defaced_dicom_series_instance_uid}', " .
    "'function(){}')\" value=\"report\">\n");
  $http->queue("</pre></td>");
  $http->queue("</tr>");
}

my $menu = <<EOF;
Select Patient: <select id="patient_selector"
onchange="javascript:PosdaGetRemoteMethod('SetSelectedPatient', 'value=' +
  this.options[this.selectedIndex].value,
  function() { UpdateDiv('content', 'ContentResponse'); });">
  <?dyn="PatientOptions"?>
</select>
&nbsp;&nbsp;&nbsp;
<input type="checkbox" name="ExpandRows"
   onChange="<?dyn="CheckBoxChange" name="ExpandRows"?>"> Expand Rows
&nbsp;&nbsp;&nbsp;
<input type="checkbox" name="ShowEquivalenceClasses""
   onChange="<?dyn="CheckBoxChange" name="ShowEquivalenceClasses"?>"> Show Equivalence Classes
&nbsp;&nbsp;&nbsp;-- Surpress: 
<input type="checkbox" name="SurpressNiftiConversionWarnings""
   onChange="<?dyn="CheckBoxChange" name="SurpressNiftiConversionWarnings"?>"> Nifti Conversion Warnings 
&nbsp;&nbsp;&nbsp;
<input type="checkbox" name="SurpressNiftiConversionNotes""
   onChange="<?dyn="CheckBoxChange" name="SurpressNiftiConversionNotes"?>"> Nifti Conversion Notes 
--  
EOF
sub CheckBoxChange{
  my ($self, $http, $dyn) = @_;
  $http->queue("javascript:PosdaGetRemoteMethod('CheckBoxClick', 'name=$dyn->{name}' + " .
    "'&value=' + (this.checked ? '1' : '0')" .
    ", function(){UpdateDiv('content', 'ContentResponse');});");
}
sub CheckBoxState{
  my ($self, $http, $dyn) = @_;
  my $name = $dyn->{name};
  print STDERR "############\nIn CheckBoxChange:\n";
  for my $i (keys %$dyn){
    print STDERR "dyn{$i} = $dyn->{$i}\n";
  }
  print STDERR "############\n";
  return $self->{$name}->{value};
}
sub CheckBoxClick{
  my ($self, $http, $dyn) = @_;
  my $state = $dyn->{value};
  my $name = $dyn->{name};
  $self->{$name}->{value} = $state;
}
sub PatientOptions{
  my ($self, $http, $dyn) = @_;
  for my $p (@{$self->{patient_list}}){
    $http->queue("<option value=\"$p\"");
    if($p eq $self->{selected_patient}){ $http->queue(" selected") }
    $http->queue(">$p</option>");
  }
}
sub SetSelectedPatient{
  my ($self, $http, $dyn) = @_;
  $self->{selected_patient} = $dyn->{value};
}
sub MenuResponse {
  my ($self, $http, $dyn) = @_;
  $self->RefreshEngine($http, $dyn, $menu);
  return;
  $self->NotSoSimpleButton($http, {
     op => "Setmode",
     mode => "DataDump",
     caption => "Show Data Dump",
     sync => "UpdateContent();"
  });
  $self->NotSoSimpleButton($http, {
     op => "Setmode",
     mode => "FullyConverted",
     caption => "Show Fully Defaced Dicom",
     sync => "UpdateContent();"
  });
  $self->NotSoSimpleButton($http, {
     op => "Setmode",
     mode => "NewView",
     caption => "New Default View",
     sync => "UpdateContent();"
  });
}
sub LaunchNiftiViewer{
  my($self, $http, $dyn) = @_;
  my $nifti_file_id = $dyn->{file_id};
  my $file_path;
  my $file_type;
  Query("GetFileTypeAndPath")->RunQuery(sub{
    my($row) = @_;
    $file_type = $row->[0];
    $file_path = $row->[1];
  }, sub{}, $nifti_file_id);
  my $nifti;
  if($file_type =~ /gzip/){
    $nifti = Nifti::Parser->new_from_zip($file_path, $nifti_file_id,$self->{params}->{tmp_dir});
  } else {
    $nifti = Nifti::Parser->new($file_path, $nifti_file_id);
  }
  unless(defined $nifti){
    print STDERR "Nifti file ($nifti_file_id) $file_path failed to parse\n";
    return;
  }
  my $params = {
    file_id=> $nifti_file_id,
    file_path=> $file_path,
    nifti => $nifti,
    temp_path => "$ENV{POSDA_CACHE_ROOT}/RenderedNiftiSlices",
  };
  my $class = "Posda::FileVisualizer::Nifti";
  eval "require $class";
  if($@){
    print STDERR "Class failed to compile\n\t$@\n";
    return;
  }

  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  my $name = "nifti_viewer_$self->{sequence_no}";
  $self->{sequence_no} += 1;
  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);
}

sub LaunchSeriesVisualizer{
  my($self, $http, $dyn) = @_;
  my $series_instance_uid = $dyn->{series_instance_uid};
  my $file_path;
  my $params = {
    activity_id => $self->{params}->{activity_id},
    series_instance_uid => $series_instance_uid,
    temp_path => "$ENV{POSDA_CACHE_ROOT}/RenderedNiftiSlices",
  };
 my $class = "Posda::SeriesVisualizer";
  eval "require $class";
  if($@){
    print STDERR "Class failed to compile\n\t$@\n";
    return;
  }

  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  my $name = "series_visualizer_$self->{sequence_no}";
  $self->{sequence_no} += 1;
  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);
}

1;
