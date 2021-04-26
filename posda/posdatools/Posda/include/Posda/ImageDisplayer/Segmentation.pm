#!/usr/bin/perl -w
#
use strict;
package Posda::ImageDisplayer::Segmentation;
use VectorMath;
use Posda::ImageDisplayer;
use Posda::DB qw( Query );
use Dispatch::LineReader;
use Storable qw ( store_fd fd_retrieve );
use JSON;
use File::Temp qw/ tempfile /;
use Debug;
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
my $expander = <<EOF;
<?dyn="BaseHeader"?>
<script type="text/javascript">
<?dyn="AjaxObj"?>
<?dyn="DicomImageDispJs"?>
<?dyn="JsContent"?>
<?dyn="JsControllerLocal"?>
</script>
</head>
<body>
<?dyn="Content"?>
<?dyn="Footer"?>
EOF
sub Init{
  my($self, $parms) = @_;
  $self->{expander} = $expander;
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

  $self->{title} = "seg_file_id: $self->{params}->{seg_file_id}" .
    "; segmentation: $self->{params}->{selected_segmentation}, " .
    "($self->{x_shift}, $self->{y_shift})";
  $self->{height} = 600;
  $self->{width} = 600;
  $self->{canvas_height} = 512;
  $self->{canvas_width} = 512;
  $self->{ImageList} = {};
  $self->{CurrentUrlIndex} = 0;
  $self->{RoiVisible} = 1;
  $self->{WindowWidth} = "";
  $self->{WindowCtr} = "";
  $self->InitializeUrls;
  $self->SetImageUrl;
}
sub InitializeUrls{
  my($self)= @_;
  $self->SortSliceInfo;
    ######  Here is the "definition" of FileList #########
#    push @{$self->{FileList}}, {
#      dicom_file_id => $dicom_file_id,
#      contour_files => [
#        {
#          file_id => $contour_file_id,
#          num_contours => $num_contours,
#          contour_points => $contour_points,
#          color => $color,
#          roi_id => $roi_id,
#        },
#        ...
#      ],
#      seg_bitmaps => [
#        {
#          seg_slice_bitmap_file_id => $seg_slice_bitmap_file_id,
#          png_file_id => $png_file_id,
#          frame_no => $frame_no,
#          total_one_bits => $total_one_bits,
#          num_bare_points => $num_bare_points,
#        },
#        ...
#      ],
#      offset => $offset,
#      off_normal => $off_normal,
#      iop => $iop,
#      ipp => $ipp,
#    };
    #^^^^^  Here is the "definition" of FileList ^^^^^^^^^
  $self->{BitmapImageUrls} = [];
  $self->{ContourFileIds} = [];
  $self->{JpegImageUrls} = [];
  for my $i (0 .. $#{$self->{FileList}}){
    my $ent = $self->{FileList}->[$i];
    my $jpeg_url = "FetchDicomJpeg?obj_path=$self->{path}&file_id=" .
      $ent->{dicom_file_id} . "&width=$self->{WindowWidth}" .
      "&ctr=$self->{WindowCtr}";
    push(@{$self->{JpegImageUrls}}, {
      image => $jpeg_url,
      url_type => "relative",
    });
    push(@{$self->{ContourFiles}}, $ent->{contour_files});
    my $png_file_id = $ent->{seg_bitmaps}->[0]->{png_file_id};
    my $bitmap_url = "FetchPng?obj_path=$self->{path}&file_id=" .
      $png_file_id;
    push(@{$self->{BitmapImageUrls}}, {
      image => $bitmap_url,
      url_type => "relative",
    });
  }
};
sub SetImageUrl{
  my($self)= @_;
  unless(defined $self->{CurrentUrlIndex}){ $self->{CurrentUrlIndex} = 0 }
  unless(defined $self->{ImageType}){
    $self->{ImageType} = "Rendered Bitmap";
  }
  my $current_index = $self->{CurrentUrlIndex};
  if($self->{ImageType} eq "Rendered Bitmap"){
    $self->{ImageUrl} = $self->{BitmapImageUrls}->[$current_index];
  }elsif($self->{ImageType} eq "Dicom Image"){
    $self->{ImageUrl} = $self->{JpegImageUrls}->[$current_index];
  } elsif($self->{ImageType} eq "TestPattern"){
    $self->{ImageUrl} = {
        url_type => "relative",
        image => "FetchTestPattern?obj_path=$self->{path}"
    };
  }else{
    die "WTF?  Image Type = $self->{ImageType} !!!";
  }
  my $contour_file_path;
  my $cfi = $self->{ContourFiles}->[$self->{CurrentUrlIndex}];
  my $contour_file_id = $cfi->[0]->{file_id};
  $self->{ContourFileId} = $contour_file_id;
  Query('GetFilePath')->RunQuery(sub {
    my($row) = @_;
    $contour_file_path = $row->[0];
  }, sub {}, $contour_file_id);
  $self->{ContourFilePath} = $contour_file_path;
  $self->{ImageLabels}->{current_instance} = 
    $self->{FileList}->[$current_index]->{instance_number};
  $self->{ImageLabels}->{current_offset} = 
    $self->{FileList}->[$current_index]->{offset};
  $self->{ImageLabels}->{current_index} = $current_index;
  $self->{ImageLabels}->{VisibleContours} = {
     "this_roi" => $self->{RoiVisible}
  };
}
sub SortSliceInfo{
  my($self) = @_;
  my $get_file_id = Query('SopInActivity');
  my %offset_info;
  my $iop;
  frame:
  for my $frame_no (keys %{$self->{params}->{segmentation_slice_info}}){
    my $slice_info = $self->{params}->{segmentation_slice_info}->{$frame_no};
    my $rel_sop = [ keys %{$slice_info->{sops}} ]->[0];
    my $file_id;
    my $instance_number;
    $get_file_id->RunQuery(sub{
      my($row) = @_;
      $file_id = $row->[0];
      $instance_number = $row->[1];
    }, sub{}, $rel_sop, $self->{params}->{activity_id});
    unless(defined $file_id){
      my $msg = "Error: frame $frame_no has no related file";
      print STDERR "####################\n$msg\n####################\n";
      push(@{$self->{errors}}, $msg);
      next frame;
    }
    $slice_info->{dicom_file_id} = $file_id;
    my $ipp = $slice_info->{ipp};
    my $iop = $slice_info->{iop};
    my @iop = split(/\\/, $iop);
    my $dx = [$iop[0], $iop[1], $iop[2]];
    my $dy = [$iop[3], $iop[4], $iop[5]];
    my $dz = VectorMath::cross($dx, $dy);
    my $rot = [$dx, $dy, $dz];
    my @ipp = split(/\\/, $ipp);
    my $rot_dx = VectorMath::Rot3D($rot, $dx);
    my $rot_dy = VectorMath::Rot3D($rot, $dy);
    my $rot_iop = [$rot_dx, $rot_dy];
    my $rot_ipp = VectorMath::Rot3D($rot, \@ipp);
    my $h = {
      rot_iop => $rot_iop,
      rot_ipp => $rot_ipp,
      frame_no => $frame_no
    };
    $offset_info{$file_id} = $h;
    $offset_info{$file_id}->{instance_number} = $instance_number;
  }
  my $min_z; my $max_z;
  my $tot_x = 0;  my $tot_y = 0; my $num_slice = 0;
  for my $i (keys %offset_info){
    my $off_info = $offset_info{$i};
    $num_slice += 1;
    $tot_x += $off_info->{rot_ipp}->[0];
    $tot_y += $off_info->{rot_ipp}->[1];
    my $z = $off_info->{rot_ipp}->[2];
    unless(defined $min_z) {
      $min_z = $z;
    }
    unless(defined $max_z) {
      $max_z = $z;
    }
    if($z < $min_z){
      $min_z = $z;
    }
    if($z > $max_z){
      $max_z = $z;
    }
  }
  my $avg_x = $tot_x / $num_slice;
  my $avg_y = $tot_y / $num_slice;

  for my $i (keys %offset_info){
    my $off_info = $offset_info{$i};
    $off_info->{z_coord} = $off_info->{rot_ipp}->[2];
    $off_info->{z_diff} = $off_info->{rot_ipp}->[2] - $min_z;
    $off_info->{x_diff} = $off_info->{rot_ipp}->[0] - $avg_x;
    $off_info->{y_diff} = $off_info->{rot_ipp}->[1] - $avg_y;
  }
  $self->{FileList} = [];
  for my $si (
    sort {
      $offset_info{$a}->{z_diff} <=> $offset_info{$b}->{z_diff}
    }
    keys %offset_info
  ){
    my $off_info = $offset_info{$si};
    my $frame_no = $off_info->{frame_no};
    my $param_info = $self->{params}->{segmentation_slice_info}->{$frame_no};
    my $offset = $off_info->{z_coord};
    my $x_diff = $off_info->{x_diff};
    my $y_diff = $off_info->{y_diff};
    my $off_normal =
      sqrt(($off_info->{x_diff} ** 2) + ($off_info->{y_diff} ** 2));
    my $dicom_file_id = $param_info->{dicom_file_id};
    my $instance_number = $off_info->{instance_number};
    my $contour_file_id = $param_info->{contour_file_id};
    my $png_file_id = $param_info->{png_file_id};
    my $seg_slice_bitmap_file_id = $param_info->{seg_slice_bitmap_file_id};
    my $total_one_bits = $param_info->{total_one_bits};
    my $num_bare_points = $param_info->{num_bare_points};
    my $num_contours = $param_info->{num_contours};
    my $contour_points = $param_info->{contour_points};
    my $iop = $param_info->{iop};
    my $ipp = $param_info->{ipp};
    my $color = "ff0000";
    my $roi_id = "this_roi";

    ######  Here is the "definition" of FileList #########
    push @{$self->{FileList}}, {
      dicom_file_id => $dicom_file_id,
      instance_number => $instance_number,
      contour_files => [
        {
          file_id => $contour_file_id,
          num_contours => $num_contours,
          contour_points => $contour_points,
          color => $color,
          roi_id => $roi_id,
          instance_number => $instance_number,
        },
      ],
      seg_bitmaps => [
        {
          seg_slice_bitmap_file_id => $seg_slice_bitmap_file_id,
          png_file_id => $png_file_id,
          frame_no => $frame_no,
          total_one_bits => $total_one_bits,
          num_bare_points => $num_bare_points,
          seg_id => "this_seg",
          color => $color,
        },
      ],
      offset => $offset,
      off_normal => $off_normal,
      iop => $iop,
      ipp => $ipp,
    };
    #^^^^^  Here is the "definition" of FileList ^^^^^^^^^
  }
#print STDERR "-------------------------------\n";
#print STDERR "File List: ";
#Debug::GenPrint($dbg, $self->{FileList}, 1);
#print STDERR "\n";
#print STDERR "-------------------------------\n";
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
  <select class="form-control"
    onchange="javascript:SetToolType(this.options[this.selectedIndex].value);">
    <option value="None" selected="">No tool</option>
    <option value="Pan/Zoom">P/Z tool</option>
    <option value="Select">Sel tool</option>
  </select>
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
  for my $i (0 .. $#{$self->{FileList}}){
    $http->queue("<option value=\"$i\">" .
      "$self->{FileList}->[$i]->{offset}</option>");
  }
}

sub ToggleRoiVisible{
  my($self, $http, $dyn) = @_;
  if($self->{RoiVisible}){
    $self->{RoiVisible} = 0;
  } else {
    $self->{RoiVisible} = 1;
  }
  $self->SetImageUrl;
}

sub ToggleRoiVisibilty{
  my($self, $http, $dyn) = @_;
  $self->NotSoSimpleButton($http, {
     op => "ToggleRoiVisible",
     caption => "Toggle Roi",
     sync => "UpdateImage();"
  });
}

sub Content{
  my($self, $http, $dyn) = @_;
  $self->RefreshEngine($http, $dyn, $content);
}
##### Pixel Rendering Stuff
#######  End of Image Stuff
#######  Begin Contour Stuff
sub GetContoursToRender{
  my($self, $http, $dyn) = @_;
  my $contour_file_id = $self->{ContourFileId};
  my $json_contours_path = "$self->{params}->{tmp_dir}/$contour_file_id.json";
  unless(-f $json_contours_path){
    my $contour_render_struct = [
      {
        id => "this_roi",
        color => "ff0000",
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
sub ContinueProcessingContours{
  my($self, $http, $dyn, $tmp1, $json_contours_path, $contour_file_id) = @_;
  my $sub = sub {
    unlink $tmp1;
    $self->SendCachedContours($http, $dyn, $json_contours_path);
  };
  return $sub;
}
sub SendCachedContours{
  my($self, $http, $dyn, $json_contours_path) = @_;
  my $contour_file_id = $self->{ContourFileId};
  my $content_type = "text/json";
  open my $sock, "cat $json_contours_path|" or die "Can't open " .
    "$json_contours_path for reading ($!)";

#  open FILE, "<$json_contours_path" or die "Can't open $json_contours_path" .
#    " for reading ($!)";
  $self->SendContentFromFh($http, $sock, "application/json",
  $self->CreateNotifierClosure("NullNotifier", $dyn));
}

sub ImageTypeSelector{
  my($self, $http, $dyn) = @_;
  unless(defined $self->{ImageType}){
    $self->{ImageType} = "Rendered Bitmap";
  }
  $self->SelectDelegateByValue($http, {
    op => "SelectImageType",
    id => "SelectImageTypeDropdown",
    class => "form-control",
    style => "",
    sync => "UpdateImage();"
  });
  for my $i ("Rendered Bitmap", "Dicom Image", "TestPattern"){
   $http->queue("<option value=\"$i\"");
   if($i eq $self->{ImageType}){
     $http->queue(" selected");
   }
   $http->queue(">$i</option>");
  }
  $http->queue("</select>");
}
sub SelectImageType{
  my($self, $http, $dyn) = @_;
  $self->{ImageType} = $dyn->{value};
  $self->SetImageUrl;
}
1;
