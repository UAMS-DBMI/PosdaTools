#!/usr/bin/perl -w
#
use strict;
package Posda::HttpApp::SimplifiedImageDisp;
use Posda::HttpApp::JsController;
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
@ISA = ( "Posda::HttpApp::JsController" );
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
sub new {
  my($class, $sess, $path, $parms) = @_;
  my $self = Posda::HttpApp::JsController->new($sess, $path);
  bless($self, $class);
  $self->{expander} = $expander;
  $self->{ImageUrl} = { url_type => "absolute", image => "/LoadingScreen.png" };
  $self->{ImageLabels} = {
    top_text => "<small>U</small>",
    bottom_text => "<small>U</small>",
    right_text => "<small>U</small>",
    left_text => "<small>U</small>",
  };
  $self->{params} = $parms;
  $self->Init;
  return $self;
}
sub Init{
  my($self) = @_;
  $self->{x_shift} = "0.5";
  $self->{y_shift} = "0.5";
  $self->{title} = "ss_file_id: $self->{params}->{ss_file_id}" .
    "; roi_num: $self->{params}->{roi_num}, " .
    "($self->{x_shift}, $self->{y_shift})";
  $self->{height} = 600;
  $self->{width} = 600;
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
        image => "FetchDicomJpeg?obj_path=$self->{path}&file_id=$i_fid"
      };
    }
    $self->SetImageUrlAndContour;
  }
};
sub SetImageUrlAndContour{
  my($self)= @_;
  unless(defined $self->{CurrentUrlIndex}){ $self->{CurrentUrlIndex} = 0 }
  unless(defined $self->{ImageType}){
    $self->{ImageType} = "Rendered Bitmap";
  }
  my $current_index = $self->{CurrentUrlIndex};
  if($self->{ImageType} eq "Rendered Bitmap"){
    $self->{ImageUrl} = $self->{BitmapImageUrls}->[$current_index];
  }elsif($self->{ImageType} eq "Dicom Image"){
#    $self->{DicomImageJpegId} = $self->{DicomImageUrls}->[$current_index];
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
#print STDERR "#------------------- $self->{CurrentUrlIndex}\n" .
#  "Old contour path: $self->{ContourFilePath}\n" .
#  "New contour path: $contour_file_path\n" .
#  "#-------------------\n";

  $self->{ContourFilePath} = $contour_file_path;
  my $current_file_id = $self->{SortedFileInfo}->[$current_index]->{file_id};
  $self->{ImageLabels}->{current_instance} = 
    $self->{params}->{file_to_instance}->{$current_file_id};
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
#print STDERR "Executing Query: GetFilePath($dyn->{file_id})\n";
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
  $self->{WindowWidth} = -600;
  $self->{WindowCenter} = 1600;
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
print STDERR "Line from renderer: $line\n";
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
<canvas id="MyCanvas" width="512" height="512"></canvas>
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
<div id="div_control_buttons" style="display: flex; flex-direction: row; align-items: flex-end; margin-left: 10px">
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
<div id="ControlButton7" width="10%">&nbsp;<?dyn="PrevButton"?></div>
<div id="ControlButton8" width="10%">&nbsp;<?dyn="NextButton"?></div>
<div>
<?dyn="ImageTypeSelector"?>
</div>
</div>
<div>
<p>
<pre>
<div id="DebugInfo">
Debug Info goes here
</div>
<div id="div_contours_pending">&nbsp;</div>
<div id="div_image_pending"">&nbsp;</div>
</pre>
</p>
</div>
<div>
<p>
<pre>
<div id="CurrentInstance">
Current Instance Goes here
</div>
</pre>
</p>
</div>
<div style="display: flex; flex-direction: row; align-items: flex-end; margin-left: 10px">
<p>
Tool Type:
<div id="ToolType">
 Info goes here
</div>
</p>
</div>
<div>
<p>
<pre>
Mouse Position:
<div id="MousePosition">
</div>
</pre>
</p>
</div>
EOF

sub NextButton{
my($self, $http, $dyn) = @_;
$self->NotSoSimpleButton($http, {
    op => "NextSlice",
    caption => "nxt",
    id => "NextButton",
    sync => "UpdateImage();"
  });
}

sub PrevButton{
  my($self, $http, $dyn) = @_;
  $self->NotSoSimpleButton($http, {
    op => "PrevSlice",
    caption => "prv",
    id => "PrevButton",
    sync => "UpdateImage();"
  });
}

sub NextSlice{
  my($self, $http, $dyn) = @_;
  $self->{CurrentUrlIndex} += 1;
  if($self->{CurrentUrlIndex} > $#{$self->{BitmapImageUrls}}){
    $self->{CurrentUrlIndex} = 0;
  }
  $self->SetImageUrlAndContour;
}

sub PrevSlice{
  my($self, $http, $dyn) = @_;
  $self->{CurrentUrlIndex} -= 1;
  if($self->{CurrentUrlIndex} < 0){
    $self->{CurrentUrlIndex} = $#{$self->{BitmapImageUrls}};
  }
  $self->SetImageUrlAndContour;
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
      {
        color => "00ff00",
        type => "2dContourBatch",
        file => $border_contour_file,
        pix_sp_x => 1,
        pix_sp_y => 1,
        x_shift => 0,
        y_shift => 0,
      },
      {
        color => "0000ff",
        type => "2dContourBatch",
        file => $border_contour_file1,
        pix_sp_x => 1,
        pix_sp_y => 1,
        x_shift => 0,
        y_shift => 0,
      },
      {
        color => "ff0000",
        type => "2dContourBatch",
        file => $border_contour_file2,
        pix_sp_x => 1,
        pix_sp_y => 1,
        x_shift => 0.5,
        y_shift => 0.5,
      },
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
sub NullLineHandler{
  my($self) = @_;
  my $sub = sub{};
  return $sub;
}
sub NullNotifier{
  my($self, $dyn) = @_;
}
###############################################################
################### Javascript Expanders ######################
## This is the "JsContent" expander
my $js_content = <<EOF;

<!-- line __LINE__ of __FILE__ -->

function HeaderResponseReturned(text, status, xml){
  document.getElementById('header').innerHTML = text;
}

function MenuResponseReturned(text, status, xml){
  var obj = document.getElementById('menu');
  if(obj != null) { obj.innerHTML = text }
  // document.getElementById('menu').innerHTML = text;
}

function ContentResponseReturned(text, status, xml){
  document.getElementById('content').innerHTML = text;

  Dropzone.discover();

  // Apply highlight.js style to any code blocks
  \$('pre code').each(function(i, block) {
    hljs.highlightBlock(block);
  });

  \$('div.spinner').spin(spinner_opts);
}

function LoginResponseReturned(text, status, xml){
  document.getElementById('login').innerHTML = text;
}

function ActivityTaskStatusReturned(text, status, xml){
  document.getElementById('activitytaskstatus').innerHTML = text;
}

function UpdateHeader(){
  PosdaGetRemoteMethod("HeaderResponse", "" , HeaderResponseReturned);
}

function UpdateMenu(){
  PosdaGetRemoteMethod("MenuResponse", "" , MenuResponseReturned);
}

function UpdateContent(){
  PosdaGetRemoteMethod("ContentResponse", "" , ContentResponseReturned);
}

function UpdateLogin(){
  PosdaGetRemoteMethod("LoginResponse", "" , LoginResponseReturned);
}

function UpdateActivityTaskStatus(){
  PosdaGetRemoteMethod("DrawActivityTaskStatus", "" , ActivityTaskStatusReturned);
}

function UpdateDiv(div_text, method_text){
  PosdaGetRemoteMethod(method_text, "", makeDivUpdater(div_text));
}

function makeDivUpdater(div_text){
  var that = this;
  that.div_text = div_text;
  return function(text, status, xml){
    var foo = document.getElementById(that.div_text);
    if(foo != null) {
      document.getElementById(that.div_text).innerHTML = text;
    } else {
      // console.log("Attempt to update unknown div: " + div_text);
    }
  }
}

function ModeChanged(text, status, xml){
  if(status != 200) {
    alert("Mode change failed");
  } else {
    console.log("mode changed");
    Update();
  }
}

function ChangeMode(op, mode){
  PosdaGetRemoteMethod(op, 'value='+mode , ModeChanged);
}

function Update(){ 
  // UpdateMenu();
  //  UpdateContent();
  // UpdateLogin();
}
function UpdateOne(){ 
  // UpdateHeader();
  // UpdateMenu();
  // UpdateContent();
  // UpdateLogin();
}
function UpdateAct(){ 
  // UpdateActivityTaskStatus();
}
function ResetZoom(){
  var xform = ctx.setTransform(1,0,0,1,0,0);
  LineWidth = 1;
  RenderImage(canvas,ctx);
}
function Reload(){
  window.location.reload();
}

var spinner_opts = {
  lines: 13 // The number of lines to draw
, length: 28 // The length of each line
, width: 14 // The line thickness
, radius: 42 // The radius of the inner circle
, scale: 0.15 // Scales overall size of the spinner
, corners: 1 // Corner roundness (0..1)
, color: '#000' // #rgb or #rrggbb or array of colors
, opacity: 0.25 // Opacity of the lines
, rotate: 0 // The rotation offset
, direction: 1 // 1: clockwise, -1: counterclockwise
, speed: 1 // Rounds per second
, trail: 60 // Afterglow percentage
, fps: 20 // Frames per second when using setTimeout() as a fallback for CSS
, zIndex: 2e9 // The z-index (defaults to 2000000000)
, className: 'spinnerobj' // The CSS class to assign to the spinner
, top: '' // Top position relative to parent
, left: '' // Left position relative to parent
, shadow: false // Whether to render a shadow
, hwaccel: false // Whether to use hardware acceleration
, position: 'relative' // Element positioning
};

\$(function() {
  \$('[data-toggle="popover"]').popover();
});
EOF

sub JsContent{
  my($self, $http, $dyn) = @_;
  return $self->RefreshEngine($http, $dyn, $js_content);
}


my $dicom_image_disp_js = <<EOF;
  <!-- line __LINE__ of __FILE__ -->

  var ImageToDraw = new Image;
  var ImageUrl;
  var ImageLabels;
  var ImageUrlPending = false;
  var ImageLabelsPending = false;
  var ContoursPending = false;
  var BaseSessionUrl;
  var LineWidth = 1;
  var ToolType = "None";
  var TrackingEnabled = "Off";
  var SelectionEnabled = "Off";
  var CineEnabled = "No";
  var CineDir = "+";
//  var ContoursToDraw = [];
  var ContourResp;
  var ContoursToDraw = [
  ];

  function RenderImage (canvas, ctx) {
      // Clear the entire canvas
      var p1 = ctx.transformedPoint(0,0);
      var p2 = ctx.transformedPoint(canvas.width,canvas.height);
      var td = document.getElementById('DebugInfo');
      var tf = ctx.getTransform();
      td.innerHTML = 'a: ' + tf.a + ' b: ' + tf.b + ' c:' 
        + tf.c + ' d: ' + tf.d + ' e: ' + tf.e + ' f: ' + tf.f;
      ctx.clearRect(p1.x,p1.y,p2.x-p1.x,p2.y-p1.y);

      // Alternatively:
      // ctx.save();
      // ctx.setTransform(1,0,0,1,0,0);
      // ctx.clearRect(0,0,canvas.width,canvas.height);
      // ctx.restore();

      ctx.drawImage(ImageToDraw,0,0);
//      if(ToolType == "PanZoom"){
//      } else {
        var i;
        for(i = 0; i < ContoursToDraw.length; i++){
           var contour = ContoursToDraw[i];
           ctx.beginPath();
           ctx.moveTo(contour.points[0][0], contour.points[0][1]);
           for(j = 0; j < contour.points.length - 1; j++){
             ctx.lineTo(contour.points[j+1][0],contour.points[j+1][1]);
           }
           ctx.closePath();
           ctx.lineWidth = LineWidth;
           ctx.strokeStyle = contour.color;
           ctx.stroke();
        }
 //     }
      ctx.save();
  };
  function SetCineMode(cine_mode){
    var oldCine = CineEnabled;
    if(cine_mode == "Cine -"){
      CineEnabled = "On";
      CineDir = "-";
    } else if (cine_mode == "Cine +"){
      CineEnabled = "On";
      CineDir = "+";
    } else {
      CineEnabled = "Off";
    }
    if(oldCine = 'Off'){
      UpdateImage();
    }
  }
  function SetToolType(sel_type){
    if(ToolType == sel_type) { return; }
    if(ToolType == "Pan/Zoom"){
      DisableTracking();
    } else if (ToolType == "Select"){
      DisableSelection();
    }
    ToolType = sel_type;
    if(ToolType == "Pan/Zoom"){
      EnableTracking();
    } else if (ToolType == "Select"){
      EnableSelection();
    }
  }
  function InstallSelectionTrackers(canvas, ctx){
    var lastX=canvas.width/2, lastY=canvas.height/2;
    var dragStart,dragged;
    PanZoomMouseDown = function(evt){
    document.body.style.mozUserSelect = 
        document.body.style.webkitUserSelect = 
          document.body.style.userSelect = 'none';
      lastX = evt.offsetX || (evt.pageX - canvas.offsetLeft);
      lastY = evt.offsetY || (evt.pageY - canvas.offsetTop);
      dragStart = ctx.transformedPoint(lastX,lastY);
      var td = document.getElementById('MousePosition');
      td.innerHTML = 'Last mouse click: (' + dragStart.x +
        ', ' + dragStart.y + ')';
      dragged = false;
    };
    canvas.addEventListener('mousedown',PanZoomMouseDown, false);
    PanZoomMouseMove = function(evt){
      lastX = evt.offsetX || (evt.pageX - canvas.offsetLeft);
      lastY = evt.offsetY || (evt.pageY - canvas.offsetTop);
      dragged = true;
      if (dragStart){
        var pt = ctx.transformedPoint(lastX,lastY);
        ctx.translate(pt.x-dragStart.x,pt.y-dragStart.y);
        RenderImage(canvas, ctx);
      }
    };
    canvas.addEventListener('mousemove',PanZoomMouseMove, false);
    PanZoomMouseUp = function(evt){
      dragStart = null;
      if (!dragged) zoom(evt.shiftKey ? -1 : 1 );
    };
    canvas.addEventListener('mouseup',PanZoomMouseUp, false);

    var scaleFactor = 1.025;
    var currentScaleFactor = 1.0;
    var zoom = function(clicks){
      var pt = ctx.transformedPoint(lastX,lastY);
      ctx.translate(pt.x,pt.y);
      var factor = Math.pow(scaleFactor,clicks);
      LineWidth /= factor;
      currentScaleFactor  = factor;
      ctx.scale(factor,factor);
      ctx.translate(-pt.x,-pt.y);
      RenderImage(canvas, ctx);
    }

    PanZoomScroll = function(evt){
      var delta = evt.wheelDelta ? 
        evt.wheelDelta/40 : evt.detail ? -evt.detail : 0;
      if (delta) zoom(delta);
      return evt.preventDefault() && false;
    };
    canvas.addEventListener('DOMMouseScroll',PanZoomScroll,false);
    canvas.addEventListener('mousewheel',PanZoomScroll,false);
  };
  function RemoveSelectionTrackers(canvas, ctx){
    canvas.removeEventListener('mousedown',PanZoomMouseDown, false);
    canvas.removeEventListener('mousemove',PanZoomMouseMove, false);
    canvas.removeEventListener('mousemove',PanZoomMouseMove, false);
    canvas.removeEventListener('DOMMouseScroll',PanZoomScroll,false);
    canvas.removeEventListener('mousewheel',PanZoomScroll,false);
  }
  
  // Adds ctx.getTransform() - returns an SVGMatrix
  // Adds ctx.transformedPoint(x,y) - returns an SVGPoint
  function trackTransforms(ctx){
    var svg = document.createElementNS("http://www.w3.org/2000/svg",'svg');
    var xform = svg.createSVGMatrix();
    xform.a = 1; xform.b = 0; xform.c = 0, xform.d = 1;
    xform.e = 0; xform.f = 0;
    ctx.getTransform = function(){ return xform; };
    
    var savedTransforms = [];
    var save = ctx.save;
    ctx.save = function(){
      savedTransforms.push(xform.translate(0,0));
      return save.call(ctx);
    };
    var restore = ctx.restore;
    ctx.restore = function(){
      xform = savedTransforms.pop();
      return restore.call(ctx); };

    var scale = ctx.scale;
    ctx.scale = function(sx,sy){
      xform = xform.scaleNonUniform(sx,sy);
      return scale.call(ctx,sx,sy);
    };
    var rotate = ctx.rotate;
    ctx.rotate = function(radians){
      xform = xform.rotate(radians*180/Math.PI);
      return rotate.call(ctx,radians);
    };
     var translate = ctx.translate;
     ctx.translate = function(dx,dy){
      xform = xform.translate(dx,dy);
      return translate.call(ctx,dx,dy);
    };
    var transform = ctx.transform;
    ctx.transform = function(a,b,c,d,e,f){
      var m2 = svg.createSVGMatrix();
      m2.a=a; m2.b=b; m2.c=c; m2.d=d; m2.e=e; m2.f=f;
      xform = xform.multiply(m2);
      return transform.call(ctx,a,b,c,d,e,f);
    };
    var setTransform = ctx.setTransform;
    ctx.setTransform = function(a,b,c,d,e,f){
      xform.a = a;
      xform.b = b;
      xform.c = c;
      xform.d = d;
      xform.e = e;
      xform.f = f;
      return setTransform.call(ctx,a,b,c,d,e,f);
    };
    var pt  = svg.createSVGPoint();
    ctx.transformedPoint = function(x,y){
      pt.x=x; pt.y=y;
      return pt.matrixTransform(xform.inverse());
    }
  }
  var PanZoomMouseDown, PanZoomMouseMove, PanZoomMouseUp, PanZoomScroll;
  function InstallPanZoomTrackers(canvas, ctx){
    var lastX=canvas.width/2, lastY=canvas.height/2;
    var dragStart,dragged;
    PanZoomMouseDown = function(evt){
    document.body.style.mozUserSelect = 
        document.body.style.webkitUserSelect = 
          document.body.style.userSelect = 'none';
      lastX = evt.offsetX || (evt.pageX - canvas.offsetLeft);
      lastY = evt.offsetY || (evt.pageY - canvas.offsetTop);
      dragStart = ctx.transformedPoint(lastX,lastY);
      var td = document.getElementById('MousePosition');
      td.innerHTML = 'Last mouse click: (' + dragStart.x +
        ', ' + dragStart.y + ')';
      dragged = false;
    };
    canvas.addEventListener('mousedown',PanZoomMouseDown, false);
    PanZoomMouseMove = function(evt){
      lastX = evt.offsetX || (evt.pageX - canvas.offsetLeft);
      lastY = evt.offsetY || (evt.pageY - canvas.offsetTop);
      dragged = true;
      if (dragStart){
        var pt = ctx.transformedPoint(lastX,lastY);
        ctx.translate(pt.x-dragStart.x,pt.y-dragStart.y);
        RenderImage(canvas, ctx);
      }
    };
    canvas.addEventListener('mousemove',PanZoomMouseMove, false);
    PanZoomMouseUp = function(evt){
      dragStart = null;
      if (!dragged) zoom(evt.shiftKey ? -1 : 1 );
    };
    canvas.addEventListener('mouseup',PanZoomMouseUp, false);

    var scaleFactor = 1.025;
    var currentScaleFactor = 1.0;
    var zoom = function(clicks){
      var pt = ctx.transformedPoint(lastX,lastY);
      ctx.translate(pt.x,pt.y);
      var factor = Math.pow(scaleFactor,clicks);
      LineWidth /= factor;
      currentScaleFactor  = factor;
      ctx.scale(factor,factor);
      ctx.translate(-pt.x,-pt.y);
      RenderImage(canvas, ctx);
    }

    PanZoomScroll = function(evt){
      var delta = evt.wheelDelta ? 
        evt.wheelDelta/40 : evt.detail ? -evt.detail : 0;
      if (delta) zoom(delta);
      return evt.preventDefault() && false;
    };
    canvas.addEventListener('DOMMouseScroll',PanZoomScroll,false);
    canvas.addEventListener('mousewheel',PanZoomScroll,false);
  };
  function RemovePanZoomTrackers(canvas, ctx){
    canvas.removeEventListener('mousedown',PanZoomMouseDown, false);
    canvas.removeEventListener('mousemove',PanZoomMouseMove, false);
    canvas.removeEventListener('mousemove',PanZoomMouseMove, false);
    canvas.removeEventListener('DOMMouseScroll',PanZoomScroll,false);
    canvas.removeEventListener('mousewheel',PanZoomScroll,false);
  }
  
  // Adds ctx.getTransform() - returns an SVGMatrix
  // Adds ctx.transformedPoint(x,y) - returns an SVGPoint
  function trackTransforms(ctx){
    var svg = document.createElementNS("http://www.w3.org/2000/svg",'svg');
    var xform = svg.createSVGMatrix();
    xform.a = 1; xform.b = 0; xform.c = 0, xform.d = 1;
    xform.e = 0; xform.f = 0;
    ctx.getTransform = function(){ return xform; };
    
    var savedTransforms = [];
    var save = ctx.save;
    ctx.save = function(){
      savedTransforms.push(xform.translate(0,0));
      return save.call(ctx);
    };
    var restore = ctx.restore;
    ctx.restore = function(){
      xform = savedTransforms.pop();
      return restore.call(ctx); };

    var scale = ctx.scale;
    ctx.scale = function(sx,sy){
      xform = xform.scaleNonUniform(sx,sy);
      return scale.call(ctx,sx,sy);
    };
    var rotate = ctx.rotate;
    ctx.rotate = function(radians){
      xform = xform.rotate(radians*180/Math.PI);
      return rotate.call(ctx,radians);
    };
     var translate = ctx.translate;
     ctx.translate = function(dx,dy){
      xform = xform.translate(dx,dy);
      return translate.call(ctx,dx,dy);
    };
    var transform = ctx.transform;
    ctx.transform = function(a,b,c,d,e,f){
      var m2 = svg.createSVGMatrix();
      m2.a=a; m2.b=b; m2.c=c; m2.d=d; m2.e=e; m2.f=f;
      xform = xform.multiply(m2);
      return transform.call(ctx,a,b,c,d,e,f);
    };
    var setTransform = ctx.setTransform;
    ctx.setTransform = function(a,b,c,d,e,f){
      xform.a = a;
      xform.b = b;
      xform.c = c;
      xform.d = d;
      xform.e = e;
      xform.f = f;
      return setTransform.call(ctx,a,b,c,d,e,f);
    };
    var pt  = svg.createSVGPoint();
    ctx.transformedPoint = function(x,y){
      pt.x=x; pt.y=y;
      return pt.matrixTransform(xform.inverse());
    }
  }
  function ImageLabelsReturned(obj) {
    if(ImageLabels == null) {
      //console.error("ImageLabels is null");
      return;
    }
    if(ImageLabels.d == null) {
      //console.error("ImageLabels.d is null");
      return;
    }
    \$('#LeftPositionText').html(ImageLabels.d.left_text);
    \$('#RightPositionText').html(ImageLabels.d.right_text);
    \$('#TopPositionText').html(ImageLabels.d.top_text);
    \$('#BottomPositionText').html(ImageLabels.d.bottom_text);
    \$('#CurrentInstance').html(ImageLabels.d.current_instance);
    ImageLabelsPending = false;
    RenderImageIfReady();
  }
  var canvas;
  var ctx;
  WaitingForUpdates = function(){
    if(ContoursPending) { return true };
    if(ImageUrlPending) { return true };
    if(ImageLabelsPending) { return true };
    return false;
  }
  EnableImageControlButtons = function(){
    document.getElementById('NextButton').disabled = false;
    document.getElementById('PrevButton').disabled = false;
  }
  DisableImageControlButtons = function(){
    document.getElementById('NextButton').disabled = true;
    document.getElementById('PrevButton').disabled = true;
  }
  RenderImageIfReady = function(){
    if(WaitingForUpdates()){
      return;
    }
    RenderImage(canvas, ctx);
    if(WaitingForUpdates()){
      console.log("Waiting for updates right after RenderCanvas");
    }
    EnableImageControlButtons();
    if(CineEnabled == "On"){
      if(CineDir == "+"){
        document.getElementById('NextButton').click();
      } else {
        document.getElementById('PrevButton').click();
      }
    }
  }
  ImageToDraw.onload = function(){
    ImageUrlPending = false;
    RenderImageIfReady();
  };
  function ImageUrlReturned(obj) {
    var td = document.getElementById('div_image_pending');
    td.innerHTML="&nbsp;";
    if(ImageUrl == null){
      //console.error("ImageUrl is null");
      return;
    }
    if(ImageUrl.d == null){
      //console.error("ImageUrl.d is null");
      return;
    }
    if(ImageUrl.d.url_type == "absolute"){
      ImageToDraw.src = ImageUrl.d.image;
    } else {
      ImageToDraw.src = BaseSessionUrl + ImageUrl.d.image;
    }
  }
  function ContoursReturned(obj) {
    ContoursPending = false;
    var td = document.getElementById('div_contours_pending');
    td.innerHTML="&nbsp;";
    if(ContourResp == null){
      console.error("ContourResp is null");
      return;
    }
    if(ContourResp.d == null){
      console.error("ContourResp.d is null");
      return;
    }
    ContoursToDraw = ContourResp.d;
    RenderImageIfReady(canvas, ctx);
  }
  function UpdateImage(){
    //  Here get image from server, get overlays from server
    //  When complete:
    if(ImageLabelsPending){
      //console.error("Update when ImageLabels Pending");
    } else {
      ImageLabelsPending = true;
      ImageLabels = 
        new PosdaAjaxObj("ImageLabels", ObjPath, ImageLabelsReturned);
    }
    if(ImageUrlPending){
      //console.error("Update when ImageUrl Pending");
    } else {
      ImageUrlPending = true;
      var td = document.getElementById('div_image_pending');
      td.innerHTML="<small>pending</small>";
      ImageUrl =
        new PosdaAjaxObj("ImageUrl", ObjPath, ImageUrlReturned);
    }
    if(ContoursPending){
      console.error("Update when Contours Pending");
    } else {
      ContoursPending = true;
      //ContoursToDraw = [];
      //RenderImage(canvas, ctx);
      var td = document.getElementById('div_contours_pending');
      td.innerHTML="<small>pending</small>";
      ContourResp = 
        new PosdaAjaxMethod("GetContoursToRender", ObjPath, ContoursReturned);
    }
    if(WaitingForUpdates()){
      DisableImageControlButtons();
    }
  }
  function EnableCine(){
    CineEnabled = "On";
  }
  function DisableCine(){
    CineEnabled = "Off";
  }
  function ToggleCine(){
    if(CineEnabled == "On"){
      CineEnabled = "Off";
    } else {
      CineEnabled = "On";
    }
    UpdateImage();
  }
  function ToggleCineDir(){
    if(CineDir == "+"){
      CineDir = "-";
    } else {
      CineDir = "+";
    }
    UpdateImage();
  }
  function EnableTracking(){
    if(TrackingEnabled == "Off"){
      TrackingEnabled = "On";
      InstallPanZoomTrackers(canvas, ctx);
    } else {
      console.log('EnableTracking called when Tracking Enabled = ' +
        TrackingEnabled);
    }
  }
  function DisableTracking(){
    if(TrackingEnabled == "On"){
      TrackingEnabled = "Off";
      RemovePanZoomTrackers(canvas, ctx);
    } else {
      console.log('DisableTracking called when Tracking Enabled = ' +
        TrackingEnabled);
    }
  }
  function EnableSelection(){
    if(SelectionEnabled == "Off"){
      SelectionEnabled = "On";
      InstallSelectionTrackers(canvas, ctx);
    } else {
      console.log('SelectionTracking called when Selection Enabled = ' +
        SelectionEnabled);
    }
  }
  function DisableSelection(){
    if(SelectionEnabled == "On"){
      SelectionEnabled = "Off";
      RemoveSelectionTrackers(canvas, ctx);
    } else {
      console.log('DisableSelection called when Selection Enabled = ' +
        SelectionEnabled);
    }
  }
  function TogglePz(){
    console.log('TogglePz called');
    if(TrackingEnabled == "On"){
      DisableTracking();
    } else {
      EnableTracking();
    }
    UpdateImage();
  }
  function Init() {
    canvas = document.getElementById('MyCanvas');
    LineWidth = 1;
//    console.error("Init");
    ctx = canvas.getContext('2d');
    trackTransforms(ctx);
//    EnableTracking();
    ImageToDraw.src = '/ITCLogoWeb.jpg';
    UpdateImage();
    var Loc = new String(document.location);
    var ques = Loc.indexOf('?');
    var base_one = Loc.substring(0, ques);
    var last_slash = base_one.lastIndexOf("/");
    BaseSessionUrl = base_one.substring(0, last_slash+1);
    console.log('BaseSessionUrl: "' + BaseSessionUrl + '"');
  }

  \$(document).ready(function(){ Init(); }) 
EOF

sub DicomImageDispJs{
  my($self, $http, $dyn) = @_;
  return $self->RefreshEngine($http, $dyn, $dicom_image_disp_js);
}
sub AjaxObj{
  my($self, $http, $dyn) = @_;
  my $foo = <<EOF;
// Simple ajax object.
// Public domain From Patrick Hunlock <patrick\@hunlock.com>
// http://www.hunlock.com/blogs/The_Ultimate_Ajax_Object
function ajaxObject(url, callbackFunction) {
  var that=this;
  this.updating = false;
  this.abort = function() {
    if (that.updating) {
      that.updating=false;
      that.AJAX.abort();
      that.AJAX=null;
    }
  }
  this.update = function(passData,postMethod) {
    if (postMethod==null) {
      postMethod = "POST";
    }
    if (that.updating) {
      console.error("update when updating");
      return false;
    }
    that.AJAX = null;
    if (window.XMLHttpRequest) {
      that.AJAX=new XMLHttpRequest();
    } else {
      that.AJAX=new ActiveXObject("Microsoft.XMLHTTP");
    }
    if (that.AJAX==null) {
      return false;
    } else {
      that.AJAX.onreadystatechange = function() {
        if (that.AJAX.readyState==4) {
          that.updating=false;
          that.callback(that.AJAX.responseText,that.AJAX.status,that.AJAX.responseXML);
          that.AJAX=null;
        }
      }
      that.updating = new Date();
      if (/post/i.test(postMethod)) {
        var uri=urlCall+'&ts='+that.updating.getTime();
        // alert('ajaxObject::update POST called, url: '+uri);
        that.AJAX.open("POST", uri, true);
        that.AJAX.setRequestHeader(
          "Content-type", "text/plain");
          // "Content-type", "application/x-www-form-urlencoded");
        that.AJAX.send(passData);
      } else {
      var uri=urlCall+'?'+passData+'&timestamp='+(that.updating.getTime());
        // alert('ajaxObject::update GET called, url: '+uri);
        that.AJAX.open("GET", uri, true);
        that.AJAX.send(null);
      }
      return true;
    }
  }
  var urlCall = url;
  this.callback = callbackFunction || function () { };
}
function PosdaAjaxObj(r_obj, path, cb) {
  var that=this;
  this.r_obj = r_obj;
  this.cb = cb || function () { };
  this.ajaxObj =
    new ajaxObject("AjaxPosdaGet?obj_path="+path+"&obj="+r_obj,
      function(responseText) {
        // alert("PosdaAjaxObj::response: "+responseText);
        that.d = JSON.parse(responseText);
        that.cb(that.r_obj);
      }
    );
  this.update = function(passData,cb) {
    if (cb!=null) { this.cb = cb; }
    return this.ajaxObj.update(passData);
  }
  this.ajaxObj.update("");
}
function PosdaAjaxMethod(r_meth, path, cb) {
  var that=this;
  this.r_meth = r_meth;
  this.cb = cb || function () { };
  this.ajaxObj =
    new ajaxObject(r_meth + "?obj_path="+path,
      function(responseText) {
        // alert("PosdaAjaxObj::response: "+responseText);
        that.d = JSON.parse(responseText);
        that.cb(that.r_meth);
      }
    );
  this.update = function(passData,cb) {
    if (cb!=null) { this.cb = cb; }
    return this.ajaxObj.update(passData);
  }
  this.ajaxObj.update("");
}
function CloseThisWindow(){
  var that=this;
  PosdaAjaxMethod("JavascriptCloseWindow", ObjPath,
    function(responseText){
      window.close();
    }
  );
}
EOF
  $self->RefreshEngine($http, $dyn, $foo);
}

my $js_controller_local = <<EOF;
var server_timer;
function rt(n,u,w,h,x) {
  args="width="+w+",height="+h+",resizable=yes,scrollbars=yes," +
    "status=0,left=100,top=100,location=yes";
  remote=window.open(u,n,args);
  if (remote != null) {
    remote.opener = self;
    remote.location.href = u;
//    remote.location.reload(true);
    remote.focus();
  }
  if (x == 1) { return remote; }
}

//xyzzy

var ObjPath = '<?dyn="echo" field="path"?>';
var IsExpert = <?dyn="QueueIsExpert"?>;
var CanDebug = <?dyn="QueueCanDebug"?>;
function AjaxObj(url, cb){
  var that=this;
  this.updating = false;
  this.abort = function(){
    if(that.updating) {
      that.updating = false;
      that.AJAX.abort();
      that.AJAX=null;
    }
  }
  this.post = function(data){
    if(that.updating) { alert('reload before update finished'); return }
    that.AJAX = null;
    if (window.XMLHttpRequest) {
      that.AJAX=new XMLHttpRequest();
    } else {
      that.AJAX=new ActiveXObject("Microsoft.XMLHTTP");
    }
    if (that.AJAX==null) {
      alert('unable to create XMLHttpRequest');
      return false;
    } else {
      that.AJAX.onreadystatechange = function() {
        if (that.AJAX.readyState==4) {
          that.updating=false;
          that.callback(that.AJAX.responseText,
            that.AJAX.status,that.AJAX.responseXML);
          that.AJAX=null;
        }
      }
      that.updating = new Date();
      var uri=saveUrl+'&ts='+that.updating.getTime();
      //alert('ajaxObject::update POST called, url: '+uri);
      that.AJAX.open("POST", uri, true);
      that.AJAX.setRequestHeader(
        "Content-type", "text/plain");
        // "Content-type", "application/x-www-form-urlencoded");
      that.AJAX.send(data);
    }
  }
  this.get = function(){
    if(that.updating) { alert('reload before update finished'); return }
    that.AJAX = null;
    if (window.XMLHttpRequest) {
      that.AJAX=new XMLHttpRequest();
    } else {
      that.AJAX=new ActiveXObject("Microsoft.XMLHTTP");
    }
    if (that.AJAX==null) {
      alert('unable to create XMLHttpRequest');
      return false;
    } else {
      that.AJAX.onreadystatechange = function() {
        if (that.AJAX.readyState==4) {
          that.updating=false;
          that.callback(that.AJAX.responseText,
            that.AJAX.status,that.AJAX.responseXML);
          that.AJAX=null;
        }
      }
      that.updating = new Date();
      var uri=saveUrl+'&ts='+that.updating.getTime();
      that.AJAX.open("GET", uri, true);
      that.AJAX.setRequestHeader(
        "Content-type", "text/plain");
        // "Content-type", "application/x-www-form-urlencoded");
      that.AJAX.send(null);
    }
  }
  var saveUrl = url;
  this.callback = cb || function () { };
}
function AJAXPostForm(formId){
  var elem = document.getElementById(formId).elements;
  var params = "";
  url = document.getElementById(formId).action;
  for(var i = 0; i < elem.length; i++){
      if (elem[i].tagName == "SELECT"){
          params += elem[i].name + "=" +
            encodeURIComponent(elem[i].options[elem[i].selectedIndex].value)
            + "&";
      }else{
          params += elem[i].name + "=" +
          encodeURIComponent(elem[i].value) + "&";
      }
  }
  xmlhttp=new XMLHttpRequest();
  xmlhttp.open("POST",url,false);
  xmlhttp.setRequestHeader("Content-type",
    "application/x-www-form-urlencoded");
  xmlhttp.setRequestHeader("Content-length", params.length);
  xmlhttp.setRequestHeader("Connection", "close");
  xmlhttp.send(params);
  return xmlhttp.responseText;
}
function PosdaPostRemoteMethod(meth, content, cb){
  var ajax = new AjaxObj(meth + "?obj_path=" + ObjPath, cb);
  ajax.post(content);
}
function PosdaNewPostRemoteMethod(url, content, cb){
  var ajax = new AjaxObj(url,  cb);
  ajax.post(content);
}
function PosdaGetRemoteMethod(meth, args, cb){
  var url = meth + "?obj_path=" + ObjPath;
  if(args != '') url = url + "&" + args;
  var ajax = new AjaxObj(url, cb);
  ajax.get();
}
function CloseThisWindow(){
  var that=this;
  PosdaGetRemoteMethod("JavascriptCloseWindow", '',
    function(responseText){
      window.close();
    }
  );
}
function NewQueueRepeatingServerCmd(method, t){
  //console.log("queue repeating server command");
  var chk_cmd = "NewCheckServer(" + '"' +method+'"' + " ,2500);";
  server_timer = setTimeout(chk_cmd, t);
}
function NewCheckServer(method, t){
  PosdaGetRemoteMethod(method, '', function(text, status, xml){
    if(status == 200){
      if(text == null) {
        alert('nothing returned');
      } else if (text == '0'){
      } else {
        eval(text);
      }
      NewQueueRepeatingServerCmd(method, t);
    } else {
      console.log("status: %d", status);
      //alert('Bad Ajax Response');
      //window.location.reload();
      document.write("<h1>Bad Ajax Response</h1>");
      document.write("<p>Your connection to the server was lost.</p>");
      document.write("<p>This could be due to a server error, or a disruption ");
      document.write("in your internet connection.</p>");
      document.write("<p>Refreshing this page may help.</p>");
    }
  });
}
function DetachAndRedirect(url){
  PosdaGetRemoteMethod('Detach', '', function(text, status, xml){
    if(status == 200){
      window.location = url;
    } else {
      alert('Detach failed');
    }
  });
}
window.onload = function(){
  NewQueueRepeatingServerCmd('ServerCheck', 500);
  Update();
}
function ChangeSelection(myNewSelected){
  var substohide = document.getElementsByClassName("subdiv");
  for (var i=0,len=substohide.length|0;i<len; i=i+1|0){
    substohide[i].style.display = "none"
  }
  document.getElementById(myNewSelected).style.display= "block";
}
EOF
sub JsControllerLocal{
  my($self, $http, $dyn) = @_;
  $dyn->{path} = $self->{path};
  $self->RefreshEngine($http, $dyn, $js_controller_local);
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
  $self->SetImageUrlAndContour;
}
sub ToolTypeSelector{
  my($self, $http, $dyn) = @_;
  unless(defined $self->{ToolType}){
    $self->{ToolType} = "None";
  }
  $http->queue("Tool type: ");
  $self->SelectDelegateByValue($http, {
    op => "SelectToolType",
    id => "SelectToolTypeDropdown",
    class => "form-control",
    style => "",
    sync => "InitToolType();"
  });
  for my $i ("None", "Pan/Zoom", "Select"){
   $http->queue("<option value=\"$i\"");
   if($i eq $self->{ToolType}){
     $http->queue(" selected");
   }
   $http->queue(">$i</option>");
  }
  $http->queue("</select>");
}
sub SelectToolType{
  my($self, $http, $dyn) = @_;
  $self->{ToolType} = $dyn->{value};
}
1;
