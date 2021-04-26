#!/usr/bin/perl -w
#
use strict;
package Posda::ImageDisplayer::KaleidoscopeSub;
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
  $self->{params} = $parms;
  $self->{ImageLabels} = {
    top_text => "",
    bottom_text => "",
    right_text => "",
    left_text => "",
  };
  $self->{title} =
    "Kaleidoscope Image: Visual Review id: $self->{params}->{vis_review_id}" .
    "Image Equivalence Class: $self->{params}->{equiv_class}";
  $self->InitializeImageList;
  $self->{CurrentUrlIndex} = 0;
  $self->SetImageUrl;
}

sub InitializeImageList{
  my($self) = @_;
  $self->{JpegImageUrls} = [];
  for my $file_id (keys %{$self->{params}->{files}}){
    my $rows = $self->{params}->{files}->{$file_id}->{rows};
    my $cols = $self->{params}->{files}->{$file_id}->{cols};
    if($rows > 1000) {$rows = 1000};
    if($cols > 1000) {$cols = 1000};
    $self->{width} = $cols + 20;
    $self->{canvas_width} = $cols;
    $self->{height} = $rows + 100;
    $self->{canvas_height} = $rows;
    my $url = "FetchDicomJpeg?obj_path=$self->{path}&" .
     "file_id=$file_id";
    push @{$self->{JpegImageUrls}}, {
      url_type => "relative",
      image => $url
    };
    $self->{IndexToFileId}->{$#{$self->{JpegImageUrls}}} = $file_id;
  }
  $self->{CurrentUrlIndex} = 0;
  $self->SetImageUrl;
}

sub SetImageUrl{
  my($self)= @_;
  $self->{ImageUrl} = $self->{JpegImageUrls}->[$self->{CurrentUrlIndex}];
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
<canvas id="MyCanvas" width="<?dyn="CanvasWidth"?>" height="<?dyn="CanvasHeight"?>"></canvas>
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
<div id="divPrev" width="10%">&nbsp;<?dyn="PrevButton"?></div>
<div id="divNext" width="10%">&nbsp;<?dyn="NextButton"?></div>
</div>
<div id="div_control_buttons_1" style="display: flex; flex-direction: row; align-items: flex-end; margin-left: 10px">
</div>
</div>
<div style="display: flex; flex-direction: row; align-items: flex-end; margin-left: 10px">
</div>
EOF

sub Content{
  my($self, $http, $dyn) = @_;
  $self->RefreshEngine($http, $dyn, $content);
}

1;
