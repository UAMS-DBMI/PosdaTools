#!/usr/bin/perl -w
#
use strict;
package Posda::ImageDisplayer::StructAnalysisImageDisplayer;
use Posda::ImageDisplayer;
use Posda::DB qw( Query );
use Dispatch::LineReader;
use Storable qw ( store_fd fd_retrieve );
use JSON;
use Debug;
use File::Temp qw/ tempfile /;
my $dbg = sub {print STDERR @_ };
##################################################
#Data Fetched via Ajax (AjaxPosdaGet):
#  ImageLabels
#  ImageUrl
##################################################
#Methods Invoked via Ajax:
#  GetContoursToRender
##################################################
use vars qw( @ISA );
@ISA = ( "Posda::ImageDisplayer" );
sub Init{
  my($self, $parms) = @_;
  $self->{ImageTypes} = [["Rendered Bitmap", "Rendered Bitmap"],
    ["Dicom Image", "Dicom Image"], ["Test Pattern", "Test Pattern"]];
  $self->{ImageUrl} = { url_type => "absolute", image => "/LoadingScreen.png" };
  $self->{ImageLabels} = {
    top_text => "<small>U</small>",
    bottom_text => "<small>U</small>",
    right_text => "<small>U</small>",
    left_text => "<small>U</small>",
  };
  $self->{params} = $parms;
  $self->{x_shift} = "0.5";
  $self->{y_shift} = "0.5";

  $self->{title} = "ss_file_id: $self->{params}->{ss_file_id}" .
    "; roi_num: $self->{params}->{roi_num}, " .
    "($self->{x_shift}, $self->{y_shift})";
  $self->{height} = 600;
  $self->{width} = 600;
  $self->{canvas_height} = 512;
  $self->{canvas_width} = 512;
  $self->{ImageList} = {};
  Query('GetStructContoursToSegByStructIdAndRoi')->RunQuery(sub{
    my($row) = @_;
    my(
      $structure_set_file_id, $image_file_id, $roi_num,
      $rows, $cols, $num_contours, $num_points,
      $total_one_bits, $contour_slice_file_id,
      $segmentation_slice_file_id, $png_slice_file_id
    ) = @$row;
    $self->{ImageList}->{$image_file_id} = {
       rows => $rows,
       cols => $cols,
       num_contours => $num_contours,
       num_points => $num_points,
       total_one_bits => $total_one_bits,
       contour_slice_file_id => $contour_slice_file_id,
       segmentation_slice_file_id => $segmentation_slice_file_id,
       png_slice_file_id => $png_slice_file_id,
    };
    
  }, sub {}, $self->{params}->{ss_file_id}, $self->{params}->{roi_num});
  $self->{SortedFileInfo} = [];
  for my $f_info (@{$self->{params}->{file_sort}}){
    if(exists $self->{ImageList}->{$f_info->{file_id}}){
      push @{$self->{SortedFileInfo}}, $f_info;
    }
  }
  $self->{DispMode} = "SegmentsAndContours";
  $self->{CurrentUrlIndex} = 0;
  $self->{RoiVisible} = 1;
  $self->InitializeUrls;
}
sub InitializeUrls{
  my($self)= @_;
  if($self->{DispMode} eq "SegmentsAndContours"){
    my $num_slices = @{$self->{SortedFileInfo}};
    $self->{ImageLabels}->{low_offset} = 
      $self->{SortedFileInfo}->[0]->{offset};
    $self->{ImageLabels}->{high_offset} = 
      $self->{SortedFileInfo}->[$num_slices - 1]->{offset};

    unless(
      defined($self->{CurrentUrlIndex}) &&
      $self->{CurrentUrlIndex} >= 0 &&
      $self->{CurrentUrlIndex} < $num_slices
    ){
      $self->{CurrentUrlIndex} = 0;
    }
    $self->{BitmapImageUrls} = [];
    $self->{JpegImageUrls} = [];
    $self->{ContourFileIds} = [];
    for my $index (0 .. $num_slices - 1){
      my $i_fid = $self->{SortedFileInfo}->[$index]->{file_id};
      my $png_file_id = $self->{ImageList}->{$i_fid}->{png_slice_file_id};
      my $contour_file_id =
        $self->{ImageList}->{$i_fid}->{contour_slice_file_id};
      $self->{ContourFileIds}->[$index] = $contour_file_id;
      $self->{BitmapImageUrls}->[$index] = {
        url_type => "relative",
        image => "FetchPng?obj_path=$self->{path}&file_id=$png_file_id"
      };
      unless(defined $self->{WindowCenter}) { $self->{WindowCenter} = "" }
      unless(defined $self->{WindowWidth}) { $self->{WindowWidth} = "" }
      $self->{JpegImageUrls}->[$index] = {
        url_type => "relative",
        image => "FetchDicomJpeg?obj_path=$self->{path}&file_id=$i_fid" .
          "&win=$self->{WindowCenter}&lev=$self->{WindowWidth}"
      };
    }
    $self->SetImageUrl;
  }
};
sub SetImageUrl{
  my($self)= @_;
  $self->{ImageLabels}->{VisibleContours} = {
       "this_roi" => $self->{RoiVisible},
  };
  unless(defined $self->{CurrentUrlIndex}){ $self->{CurrentUrlIndex} = 0 }
  unless(defined $self->{ImageType}){
    $self->{ImageType} = "Rendered Bitmap";
  }
  my $current_index = $self->{CurrentUrlIndex};
  if($self->{ImageType} eq "Rendered Bitmap"){
    $self->{ImageUrl} = $self->{BitmapImageUrls}->[$current_index];
  }elsif($self->{ImageType} eq "Dicom Image"){
    $self->{ImageUrl} = $self->{JpegImageUrls}->[$current_index];
  } elsif($self->{ImageType} eq "Test Pattern"){
    $self->{ImageUrl} = {
        url_type => "relative",
        image => "FetchTestPattern?obj_path=$self->{path}"
    };
  }else{
    die "WTF?  Image Type = $self->{ImageType} !!!";
  }
  $self->{ContourFileId} = $self->{ContourFileIds}->[$current_index];
  my $contour_file_path;
  Query('GetFilePath')->RunQuery(sub {
    my($row) = @_;
    $contour_file_path = $row->[0];
  }, sub {}, $self->{ContourFileIds}->[$self->{CurrentUrlIndex}]);
  $self->{ContourFilePath} = $contour_file_path;
  my $current_file_id = $self->{SortedFileInfo}->[$current_index]->{file_id};
  $self->{ImageLabels}->{current_instance} = 
    $self->{params}->{file_to_instance}->{$current_file_id};
  $self->{ImageLabels}->{current_offset} = 
    $self->{SortedFileInfo}->[$current_index]->{offset};
  $self->{ImageLabels}->{current_index} = $current_index;
}

my $content = <<EOF;
<div style="display: flex; flex-direction: column; align-items: flex-beginning; margin-bottom: 5px" id="div_content">
<div id="div_canvas">
<table border="1" width="100%">
<tr>
<td align="center" colspan="3" id="TopPositionText"`>
</td>
</tr>
<tr>
<td id="LeftPositionText">
</td>
<td align="center" valign="center">
<canvas id="MyCanvas" width="<?dyn="CanvasWidth"?>" height="<?dyn="CanvasWidth"?>"></canvas>
</td>
<td id="RightPositionText">
</td>
</tr>
<tr>
<td align="center" colspan="3" id="BottomPositionText">
</td>
</tr>
</table>
</div>
<div id="div_control_buttons_1" style="display: flex; flex-direction: row; align-items: flex-end; margin-left: 10px">
<div id="ControlButton1" width="10%">
<input type="Button" class="btn btn-default"  onclick="javascript:ResetZoom();" value="reset">
</div>
<div width=10% id="ToolTypeSelector">
<?dyn="ToolTypeSelector"?>
</div>
<div width=10% id="CineSelector">
  <select class="form-control"
    onchange="javascript:SetCineMode(this.options[this.selectedIndex].value);">
    <option value="Cine off" selected="">Cine off</option>
    <option value="Cine +">Cine +</option>
    <option value="Cine -">Cine -</option>
  </select>
</div>
<div id="divPrev" width="10%">&nbsp;<?dyn="PrevButton"?></div>
<div id="divNext" width="10%">&nbsp;<?dyn="NextButton"?></div>
<div id="divOffsetSelector" width="10%">
  <select id="OffsetSelector" class="form-control"
    onchange="javascript:PosdaGetRemoteMethod('SetImageIndex', 'value=' +
      this.options[this.selectedIndex].value, 
      function () { UpdateImage(); });">
   <?dyn="OffsetOptions"?>
   </select>
</div>
</div>
<div id="div_control_buttons_1" style="display: flex; flex-direction: row; align-items: flex-end; margin-left: 10px">
<div id="CtPresets">
<?dyn="PresetWidgetCt"?>
</div>
<div id="ToggleRoiVisibility">
<?dyn="ToggleRoiVisibilty"?>
</div>
<div>
<?dyn="ImageTypeSelector"?>
</div>
<div id="div_annotation_ctrl">
</div>
</div>
</div>
<div>
<p>
<pre>
<div id="CurrentOffset"></div>
<div id="CurrentInstance"></div>
Transform: <div id="divTransform"></div>
<div id="MousePosition"></div>
<div id="div_contours_pending">&nbsp;</div>
<div id="div_image_pending">&nbsp;</div>
</pre>
</p>
</div>
<div style="display: flex; flex-direction: row; align-items: flex-end; margin-left: 10px">
</div>
EOF

sub OffsetOptions{
my($self, $http, $dyn) = @_;
  for my $i (0 .. $#{$self->{SortedFileInfo}}){
    $http->queue("<option value=\"$i\">" .
      "$self->{SortedFileInfo}->[$i]->{offset}</option>");
  }
}

sub Content{
  my($self, $http, $dyn) = @_;
  $self->RefreshEngine($http, $dyn, $content);
}

sub GetContoursToRender{
  my($self, $http, $dyn) = @_;
  my $contour_file_id = $self->{ContourFileId};
  my $json_contours_path = "$self->{params}->{tmp_dir}/$contour_file_id.json";
  unless(-f $json_contours_path){
    my $contour_render_struct = [
      {
        color => "ff0000",
        id => "this_roi",
        type => "2dContourBatch",
        file => $self->{ContourFilePath},
        pix_sp_x => 1,
        pix_sp_y => 1,
        x_shift => $self->{x_shift},
        y_shift => $self->{y_shift},
      },
    ];
    my $tmp1 = "$self->{params}->{tmp_dir}/$contour_file_id.contours";
    Storable::store $contour_render_struct, $tmp1;
    my $cmd = "cat $tmp1|Construct2DContoursFromExtractedFile.pl > " .
      "$json_contours_path;" .
      "echo 'done'";
    Dispatch::LineReader->new_cmd($cmd,
      $self->NullLineHandler(),
      $self->ContinueProcessingContours($http, $dyn, $tmp1, 
        $json_contours_path, $contour_file_id)
    );
    return;
  }
  $self->SendCachedContours($http, $dyn, $json_contours_path);
}

1;
