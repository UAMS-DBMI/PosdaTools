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
        image => "FetchBitmapPng?obj_path=$self->{path}&file_id=$png_file_id"
      };
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
sub FetchBitmapPng{
  my ($self, $http, $dyn) = @_;
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
  $self->SendContentFromFh($http, $fh, "image/png",
  $self->CreateNotifierClosure("NullNotifier", $dyn));
} 
sub FetchTestPattern{
  my($self, $http, $dyn) = @_;
  my $tp_path = "$self->{params}->{tmp_dir}/TestPattern.png";
  my $tmp_path = "$self->{params}->{tmp_dir}/TestPattern.pbm";
  unless(-f $tp_path){
    my $cmd = "MakeTestPbm.pl 512 512  >$tmp_path; ". 
    "convert $tmp_path $tp_path; rm $tmp_path; echo done";
    my @render_list;
    Dispatch::LineReader->new_cmd($cmd,
      $self->HandleRenderersLines(\@render_list),
      $self->ContinueRenderingImage($http, $dyn, $tp_path,
        \@render_list)
    );
    return;
  }
  $self->SendCachedPng($http, $dyn, $tp_path);
} 
sub ContinueRenderingTp{
  my($self, $http, $dyn, $rendered_test_pat, $render_list) = @_;
  my $sub = sub {
    $self->SendCachedPng($http, $dyn, $rendered_test_pat);
  };
  return $sub;
}
sub SendCachedPng{
  my($self, $http, $dyn, $png_path) = @_;
  my $content_type = "image/jpeg";
  open my $sock, "cat $png_path|" or die "Can't open " .
    "$png_path for reading ($!)";

  $self->SendContentFromFh($http, $sock, $content_type,
  $self->CreateNotifierClosure("NullNotifier", $dyn));
}
sub FetchDicomJpeg{
  my($self, $http, $dyn) = @_;
  my $dicom_file_id = $dyn->{file_id};
  $self->{CurrentDicomFile} = $dicom_file_id;
  unless(defined $self->{WindowWidth}){
    $self->{WindowWidth} = "";
    $self->{WindowCenter} = ""; 
  }
  my $window_width = $self->{WindowWidth};
  my $window_ctr = $self->{WindowCenter};
  my $jpeg_file = "$self->{params}->{tmp_dir}/" .
    "$dicom_file_id" ."_$window_ctr" . "_$window_width.jpeg";
  unless(-f $jpeg_file){
    #todo make cmd to Render Dicom to $rendered_dicom_jpeg
    my $rendered_dicom_gray = "$self->{params}->{tmp_dir}/$dicom_file_id.gray";
    my $cmd = "CacheDicomAsJpeg.pl $dicom_file_id \"$window_width\" " .
     "\"$window_ctr\" " .
     "$rendered_dicom_gray $jpeg_file;echo 'done'";
    my @render_list;
    Dispatch::LineReader->new_cmd($cmd,
      $self->HandleRenderersLines(\@render_list),
      $self->ContinueRenderingImage($http, $dyn, $jpeg_file,
        $rendered_dicom_gray, $dicom_file_id, \@render_list)
    );
    return;
  }
  unless($self->{CachedJpegs}->{$dicom_file_id} eq $jpeg_file){
    $self->{CachedJpegs}->{$dicom_file_id} = $jpeg_file;
  }
  $self->SendCachedJpeg($http, $dyn, $self->{CachedJpegs}->{$dicom_file_id})
} 
sub HandleRenderersLines{
  my($self, $render_list) = @_;
  my $sub = sub {
    my($line) = @_;
    push @$render_list, $line;
  };
  return $sub;
}
sub ContinueRenderingImage{
  my($self, $http, $dyn, $rendered_dicom_jpeg, $rendered_dicom_gray, 
    $dicom_file_id, $render_list) = @_;
  my $sub = sub {
    $self->{CachedJpegs}->{$dicom_file_id} = $rendered_dicom_jpeg;
    $self->SendCachedJpeg($http, $dyn, $rendered_dicom_jpeg);
    unlink $rendered_dicom_gray;
  };
  return $sub;
}
sub SendCachedJpeg{
  my($self, $http, $dyn, $jpeg_path) = @_;
  my $contour_file_id = $self->{ContourFileId};
  my $content_type = "image/jpeg";
  open my $sock, "cat $jpeg_path|" or die "Can't open " .
    "$jpeg_path for reading ($!)";

  $self->SendContentFromFh($http, $sock, $content_type,
  $self->CreateNotifierClosure("NullNotifier", $dyn));
}

sub CanvasHeight{
  my($self, $http, $dyn) = @_;
  $http->queue($self->{canvas_height});
}
sub CanvasWidth{
  my($self, $http, $dyn) = @_;
  $http->queue($self->{canvas_width});
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
##### Pixel Rendering Stuff
#######  End of Image Stuff
#######  Begin Contour Stuff
sub GetContoursToRender{
  my($self, $http, $dyn) = @_;
  my $contour_file_id = $self->{ContourFileId};
  my $json_contours_path;
  my $border_contour_file = 
    "$self->{params}->{tmp_dir}/border_contours.contours";
  unless(-f $border_contour_file){
    open FILE, ">$border_contour_file" or
      die "can't open $border_contour_file";
    print FILE "BEGIN\n";
    print FILE "-0.5,-0.5\n";
    print FILE "-0.5,512.5\n";
    print FILE "512.5,512.5\n";
    print FILE "512.5,-0.5\n";
    print FILE "-0.5,-0.5\n";
    print FILE "END\n";
    close FILE;
  }
  my $border_contour_file1 = 
    "$self->{params}->{tmp_dir}/border_contours1.contours";
  unless(-f $border_contour_file1){
    open FILE, ">$border_contour_file1" or 
      die "can't open $border_contour_file1";
    print FILE "BEGIN\n";
    print FILE "0.5,0.5\n";
    print FILE "0.5,511.5\n";
    print FILE "511.5,511.5\n";
    print FILE "511.5,0.5\n";
    print FILE "0.5,0.5\n";
    print FILE "END\n";
    close FILE;
  }
  my $border_contour_file2 = 
    "$self->{params}->{tmp_dir}/border_contours2.contours";
  unless(-f $border_contour_file2){
    open FILE, ">$border_contour_file2" or 
      die "can't open $border_contour_file2";
    print FILE "BEGIN\n";
    print FILE "-0.5,-0.5\n";
    print FILE "0,511.5\n";
    print FILE "511.5,511.5\n";
    print FILE "511.5,-0.5\n";
    print FILE "-0.5,-0.5\n";
    print FILE "END\n";
    close FILE;
  }
  if(exists $self->{CachedContours}->{$contour_file_id}){
    $json_contours_path = $self->{CachedContours}->{$contour_file_id};
  } else {
    my $contour_render_struct = [
      {
        color => "ff0000",
        type => "2dContourBatch",
        file => $self->{ContourFilePath},
        pix_sp_x => 1,
        pix_sp_y => 1,
        x_shift => $self->{x_shift},
        y_shift => $self->{y_shift},
      },
#      {
#        color => "00ff00",
#        type => "2dContourBatch",
#        file => $border_contour_file,
#        pix_sp_x => 1,
#        pix_sp_y => 1,
#        x_shift => 0,
#        y_shift => 0,
#      },
#      {
#        color => "0000ff",
#        type => "2dContourBatch",
#        file => $border_contour_file1,
#        pix_sp_x => 1,
#        pix_sp_y => 1,
#        x_shift => 0,
#        y_shift => 0,
#      },
#      {
#        color => "ff0000",
#        type => "2dContourBatch",
#        file => $border_contour_file2,
#        pix_sp_x => 1,
#        pix_sp_y => 1,
#        x_shift => 0.5,
#        y_shift => 0.5,
#      },
    ];
    my $tmp1 = "$self->{params}->{tmp_dir}/$contour_file_id.contours";
    my $tmp2 = "$self->{params}->{tmp_dir}/$contour_file_id.json";
    Storable::store $contour_render_struct, $tmp1;
    my $cmd = "cat $tmp1|ContourConstructor.pl > $tmp2;echo 'done'";
    Dispatch::LineReader->new_cmd($cmd,
      $self->NullLineHandler(),
      $self->ContinueProcessingContours($http, $dyn, $tmp1, 
        $tmp2, $contour_file_id)
    );
    return;
  }
  $self->SendCachedContours($http, $dyn, $json_contours_path);
}
sub ContinueProcessingContours{
  my($self, $http, $dyn, $tmp1, $tmp2, $contour_file_id) = @_;
  my $sub = sub {
    unlink $tmp1;
    $self->{CachedContours}->{$contour_file_id} = $tmp2;
    $self->SendCachedContours($http, $dyn, $tmp2);
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
