#!/usr/bin/perl -w
#
use strict;
package Posda::ImageDisplayer::RenderedStructureSet;
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
sub Init{
  my($self, $parms) = @_;
  $self->{ImageUrl} = { url_type => "absolute", image => "/LoadingScreen.png" };
  $self->{params} = $parms;
  $self->{x_shift} = "0.5";
  $self->{y_shift} = "0.5";

  $self->{title} = "Structure Set File: $self->{params}->{ss_file_id}" .
    "; All Rendered Contours";
  $self->{height} = 750;
  $self->{width} = 700;
  $self->{canvas_height} = 512;
  $self->{canvas_width} = 512;
  $self->{CurrentUrlIndex} = 0;
  $self->{WindowWidth} = "";
  $self->{WindowCenter} = "";
  $self->{FileList} = $parms->{FileListForDisplay};
  for my $i (keys %{$parms->{rois}}){
    my $id = "roi_num_$i";
    $self->{ImageLabels}->{VisibleContours}->{$id} = 1;
  }
  $self->{contour_root_file_id} = $parms->{ss_file_id};
  $self->InitializeUrls;
  $self->SetImageUrl;
}

my $content = <<EOF;
<div style="display: flex; flex-direction: column; align-items: flex-beginning; margin-bottom: 5px" id="div_content">
<div style="display: flex; flex-direction: row; align-items: flex-beginning; margin-bottom: 5px" id="div_content">
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
<?dyn="OffsetSelector"?>
</div>
<div id="divIndexSelector" width="10%">
<?dyn="IndexSelector"?>
</div>
</div>
<div id="div_control_buttons_1" style="display: flex; flex-direction: row; align-items: flex-end; margin-left: 10px">
<div id="CtPresets">
<?dyn="PresetWidgetCt"?>
</div>
<div id="div_annotation_ctrl">
</div>
</div>
<div>
<p>
<pre>
<div id="CurrentIndex"></div>
<div id="CurrentOffset"></div>
<div id="CurrentInstance"></div>
Transform: <div id="divTransform"></div>
<div id="MousePosition"></div>
<div id="div_contours_pending">&nbsp;</div>
<div id="div_image_pending">&nbsp;</div>
</pre>
</p>
</div>
</div>
<div style="display: flex; flex-direction: column; align-items: flex-beginning; margin-top: 5px; margin-left: 5px" id="roi_select">
<?dyn="RoiSelector"?>
</div>
</div>
EOF

sub Content{
  my($self, $http, $dyn) = @_;
  $self->RefreshEngine($http, $dyn, $content);
}


1;
