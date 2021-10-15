#!/usr/bin/perl -w
#
use strict;
package Posda::NiftiNoFacesReport;
use Nifti::Parser;
use Posda::FileVisualizer;
use Posda::SeriesVisualizer;
#use Posda::ImageDisplayer;
use Posda::DB qw( Query );
use Dispatch::LineReader;
use VectorMath;
use Storable qw ( store_fd fd_retrieve );
use JSON;
use Debug;
use File::Temp qw/ tempfile /;
my $dbg = sub {print STDERR @_ };

use vars qw( @ISA );
@ISA = ( "Posda::PopupWindow" );
sub SpecificInitialize{
  my($self, $parms) = @_;
  $self->{params} = $parms;
  $self->{title} =
    "Nifti No Face Report Viewer: " .
    "Subprocess Invocation id: $self->{params}->{subprocess_invocation_id}";
  $self->{width} = 1024;
  $self->{height} = 1024;
  $self->InitializeFileList();
}

sub InitializeFileList{
  my($self) = @_;
  Query("NoFaceInFileNiftiDefacingBySubprocess")->RunQuery(sub{
    my($row) = @_;
    my($surface_file_id, $nifti_file_id) = @$row;
    unless(exists $self->{row_list}) { $self->{row_list} = []}
    push(@{$self->{row_list}}, {
      surface_file_id => $surface_file_id,
      nifti_file_id => $nifti_file_id,
    });
  },sub {}, $self->{params}->{subprocess_invocation_id});
  $self->{first_row_index} = 0;
}

my $content = <<EOF;
<div
   style="display: flex; flex-direction: row; align-items: flex_beginning; margin-top: 5px; margin-right: 5px; margin-bottom: 5px; margin-left: 5px;">
<table class="table table-condensed" id="table_no_faces" summary="No Faces Found" style="width:100%" border="1">
<tr>
<th>3d render</th><th>nifti_file_id</th><th>series/frame of ref</th><th>num_sops</th>
</tr>
<?dyn="TableRows"?>
</table>
</div>
EOF

sub DumpParms{
  my($self, $http, $dyn) = @_;
  my $queuer = Posda::FileVisualizer::MakeQueuer($http);
  Debug::GenPrint($queuer, $self->{params}, 1);
}

sub FailedDefacingTableRows{
  my($self, $http, $dyn) = @_;
  unless($#{$self->{row_list}} >= 0) {return}
  unless($self->{first_row_index} > 0) { $self->{first_row_index} = 0 }
  unless($self->{first_row_index} <= $#{$self->{row_list}}){ $self->{first_row_index} = $#{$self->{row_list}} }
  for my $i ($self->{first_row_index} .. $#{$self->{row_list}}){
    my $row = $self->{row_list}->[$i];
    my($nifti_file_from_series_id,
      $series,
      $for,
      $modality,
      $dicom_file_type,
      $iop,
      $first_ipp,
      $last_ipp,
      $nifti_json_file_id,
      $nifti_base_file_name,
      $specified_gantry_tilt,
      $computed_gantry_tilt,
      $conversion_time,
      $num_sops);
    Query('GetConversionInfoForConvertedNifti')->RunQuery(sub{
      my($r) = @_;
      ($nifti_file_from_series_id,
        $series,
        $for,
        $modality,
        $dicom_file_type,
        $iop,
        $first_ipp,
        $last_ipp,
        $nifti_json_file_id,
        $nifti_base_file_name,
        $specified_gantry_tilt,
        $computed_gantry_tilt,
        $conversion_time,
        $num_sops) = @$r;
    }, sub {}, $row->{nifti_file_id});
    $http->queue("<tr><td>" .
      "<img src=\"FetchPng?obj_path=$self->{path}&file_id=$row->{surface_file_id}\" width=\"256\">");
    $http->queue("<pre>");
    $http->queue($self->FetchPngDescription($row->{surface_file_id}));
    $http->queue("</pre></td>" .
      "<td>$row->{nifti_file_id}" .
      "<input type=\"Button\" class=\"btn btn-default\" onClick=\"" .
      "javascript:PosdaGetRemoteMethod('LaunchNiftiViewer', 'file_id=$row->{nifti_file_id}', " .
      "'function(){}')\" value=\"view\">" .
      "</td>" .
      "<td><pre>Series: $series");
    $http->queue("<input type=\"Button\" class=\"btn btn-default\" onClick=\"" .
      "javascript:PosdaGetRemoteMethod('LaunchSeriesVisualizer', 'series_instance_uid=$series', " .
      "'function(){}')\" value=\"report\">\n");
    $http->queue("For: $for" .
      "<input type=\"Button\" class=\"btn btn-default\" onClick=\"" .
      "javascript:PosdaGetRemoteMethod('LaunchForDefacingVisualizer', 'for_uid=$for', " .
      "'function(){}')\" value=\"report\">\n" .
      "<td>$num_sops</td>");
    $http->queue("</tr>");
  }
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

sub ContentResponse{
  my($self, $http, $dyn) = @_;
  $self->RefreshEngine($http, $dyn, $content);
}

sub MenuResponse{
}

sub FetchPngDescription{
  my ($self, $file_id) = @_;
  my $file_path;
  Query('GetFilePath')->RunQuery(sub{
    my($row) = @_;
    $file_path = $row->[0];
  }, sub{}, $file_id);
  my $desc = `file $file_path`;
  chomp $desc;
  if($desc =~ /(PNG.*)$/) { $desc = $1 }
  return $desc;
}

sub FetchPng{
  my ($self, $http, $dyn) = @_;
  $self->FetchImgFile($http, $dyn, "image/png");
}

sub FetchImgFile{
  my ($self, $http, $dyn, $mime_type) = @_;
  my $file;
  unless(defined($dyn->{file_id}) && $dyn->{file_id} ne ""){
    print STDERR "file_id not defined:\n";
    for my $i (keys %$dyn){
      print STDERR "dyn{$i} = $dyn->{$i}\n";
    }
    return;
  }

  Query('GetFilePath')->RunQuery(sub{
    my($row) = @_;
    $file = $row->[0];
  }, sub {}, $dyn->{file_id});
  open my $fh, "cat $file|" or die "Can't open $file for reading ($!)";
  $self->SendContentFromFh($http, $fh, $mime_type,
  $self->CreateNotifierClosure("NullNotifier", $dyn));
}

sub NullNotifier{};

1;
