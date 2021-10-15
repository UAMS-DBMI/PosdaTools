package Posda::BuildDicomDefaced;
use strict;

use Posda::PopupWindow;
use Posda::NiftiNoFacesReport;
use Posda::DB qw( Query );
use Digest::MD5;
use Debug;

use vars qw( @ISA );
@ISA = ("Posda::NiftiNoFacesReport");
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
  $self->{title} = "BuildDicomDefaced";
  $self->{params} = $params;
  $self->{mode} = "FullyConverted";
  $self->{width} = 2000;
  Query('FailedNiftiConversionByActivity')->RunQuery(sub{
    my($row) = @_;
    $self->{FailedNiftiConversions}->{$row->[0]} = 1;
  }, sub{}, $params->{activity_id});
  my $q = Query('GetDefacedDicom');
  $self->{row_list} = [];
  row:
  for my $row (@{$params->{rows}}){
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
    };
    if($h->{three_d} ne "" and $h->{face_box} eq ""){
      push(@{$self->{row_list}}, {surface_file_id =>$h->{three_d}, nifti_file_id => $h->{file_id}});
    }
    unless(defined $h->{file_id}){
      print STDERR "#######\n" .
        "no row for series $h->{series_instance_uid}\n#######\n";
      next row;
    }
    if($h->{defaced_file_id} eq ""){
      $self->{FailedDefacing}->{$h->{file_id}} = $h;
      next row;
    }
    unless($h->{mapped_to_dicom_files}){
      $self->{FailedDicomMapping}->{$h->{file_id}} = $h;
      next row;
    }
    $self->{DefacedNifti}->{$h->{defaced_file_id}} = $h;
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
      $self->{DefacedDicom}->{$h->{defaced_file_id}} = $h1;
    }, sub{}, $h->{defaced_file_id});
    for my $i (keys %{$self->{DefacedNifti}}){
      unless(exists $self->{DefacedDicom}->{$i}){
        $self->{AwaitingConversionToDicom}->{$i} = 1;
      }
    }
  }
}

sub Setmode{
  my ($self, $http, $dyn) = @_;
  $self->{mode} = $dyn->{mode};
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

sub DataDump{
  my ($self, $http, $dyn) = @_;
  my $queuer = MakeQueuer($http);
  $http->queue("<pre>Params: ");
  Debug::GenPrint($queuer, $self->{params}, 1);
  $http->queue(";\n");
  $http->queue("</pre>");
}

sub FailedConversion{
  my ($self, $http, $dyn) = @_;
  $http->queue("<pre>FailedConversion coming soon</pre>");
}

my $failed_defacing_content = <<EOF;
<div
   style="display: flex; flex-direction: row; align-items: flex_beginning; margin-top: 5px; margin-right: 5px; margin-bottom: 5px; margin-left: 5px;">
<table class="table table-condensed" id="table_no_faces" summary="No Faces Found" style="width:100%" border="1">
<tr>
<th>3d render</th><th>nifti_file_id</th><th>series/frame of ref</th><th>num_sops</th>
</tr>
<?dyn="FailedDefacingTableRows"?>
</table>
</div>
EOF

sub FailedDefacing{
  my ($self, $http, $dyn) = @_;
  $self->RefreshEngine($http, $dyn, $failed_defacing_content);
}

sub FailedMappingBackToDicom{
  my ($self, $http, $dyn) = @_;
  $http->queue("<pre>FailedMappingBackToDicom coming soon</pre>");
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

sub MenuResponse {
  my ($self, $http, $dyn) = @_;
  $self->NotSoSimpleButton($http, {
     op => "Setmode",
     mode => "DataDump",
     caption => "Show Data Dump",
     sync => "UpdateContent();"
  });
  $self->NotSoSimpleButton($http, {
     op => "Setmode",
     mode => "FailedConversion",
     caption => "Show Failed Conversions",
     sync => "UpdateContent();"
  });
  $self->NotSoSimpleButton($http, {
     op => "Setmode",
     mode => "FailedDefacing",
     caption => "Show Failed Defacing",
     sync => "UpdateContent();"
  });
  $self->NotSoSimpleButton($http, {
     op => "Setmode",
     mode => "FailedMappingBackToDicom",
     caption => "Show Failed Mapping Back To Dicom",
     sync => "UpdateContent();"
  });
  $self->NotSoSimpleButton($http, {
     op => "Setmode",
     mode => "WaitingToConvertToDicom",
     caption => "Show Waiting on Conversion Back to Dicom",
     sync => "UpdateContent();"
  });
  $self->NotSoSimpleButton($http, {
     op => "Setmode",
     mode => "FullyConverted",
     caption => "Show Fully Defaced Dicom",
     sync => "UpdateContent();"
  });
}

1;
