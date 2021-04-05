#!/usr/bin/perl -w
#
use strict;
package Posda::ImageDisplayer::Kaleidoscope;
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
my $expander_test;
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
    "Kaleidoscope: Visual Review id: $self->{params}->{vis_review_id}";
  $self->InitializeImageList;
  $self->{CurrentUrlIndex} = 0;
  $self->SetImageUrl;
}
sub InitializeImageList{
  my($self)= @_;
  my $gfp = Query('GetFilePath');
  my %WithFile;
  my %WithoutFile;
  Query('GetProjections')->RunQuery(sub{
    my($row) = @_;
    my($image_equivalence_class_id,
      $series_instance_uid,
      $equivalence_class_number,
      $processing_status,
      $review_status,
      $file_id) = @$row;
    my($path, $rows, $cols);
    if(defined $file_id){
      $gfp->RunQuery(sub{
        my($row) = @_;
        $path = $row->[0];
      },sub{}, $file_id);
      my $cr = `file $path`;
      if($cr =~ /,\s*([\d]+)x([\d]+),/){
        $cols = $1;
        $rows = $2;
      }
      $self->{width} = $cols + 20;
      $self->{canvas_width} = $cols;
      $self->{height} = $rows + 100;
      $self->{canvas_height} = $rows;
    }
    if(defined $file_id){
      $WithFile{$processing_status}->{$image_equivalence_class_id} = {
        id => $image_equivalence_class_id,
        series => $series_instance_uid,
        num => $equivalence_class_number,
        review_status => $review_status,
        path => $path,
        file_id => $file_id,
        rows => $rows,
        cols => $cols,
      };
      $self->{JpegFiles}->{$file_id} = $path;
      unless(exists $self->{JpegImageUrls}) {
        $self->{JpegImageUrls} = [];
      }
      my $jpeg_url = {
        url_type => "relative",
        image => "FetchJpeg?obj_path=$self->{path}&file_id=$file_id",
      };
      push(@{$self->{JpegImageUrls}}, $jpeg_url);
    } else {
      $WithoutFile{$processing_status}->{$image_equivalence_class_id} = {
        id => $image_equivalence_class_id,
        series => $series_instance_uid,
        num => $equivalence_class_number,
        review_status => $review_status,
      };
    }
  }, sub{}, $self->{params}->{vis_review_id});
  $self->{WithFile} = \%WithFile;
  $self->{WithoutFile} = \%WithoutFile;
};

sub SetImageUrl{
  my($self) = @_;
  $self->{ImageUrl} = $self->{JpegImageUrls}->[$self->{CurrentUrlIndex}];
};

sub FetchJpeg{
  my($self, $http, $dyn) = @_;
  my $jpeg_file_id = $dyn->{file_id};
  my $path = $self->{JpegFiles}->{$jpeg_file_id};
  ##  get path
  $self->SendCachedJpeg($http, $dyn, $path)
} 
sub SendCachedJpeg{
  my($self, $http, $dyn, $jpeg_path) = @_;
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
<div id="Images" width="10%">&nbsp;<?dyn="ImageDisplayPopupButton"?></div>
<div id="div_annotation_ctrl"></div>
</div>
<div id="div_control_buttons_1" style="display: flex; flex-direction: row; align-items: flex-end; margin-left: 10px">
</div>
</div>
<div style="display: flex; flex-direction: row; align-items: flex-end; margin-left: 10px">
</div>
EOF

sub CanvasWidth{
  my($self, $http, $dyn) = @_;
  $http->queue("$self->{canvas_width}");
}

sub CanvasHeight{
  my($self, $http, $dyn) = @_;
  $http->queue("$self->{canvas_height}");
}

sub ImageDisplayPopupButton{
  my($self, $http, $dyn) = @_;
  $self->NotSoSimpleButton($http, {
    op => "ImageDisplayPopup",
    caption => "Images",
    id => "ImageDisplayPopup",
  });
}

sub ImageDisplayPopup{
  my($self, $http, $dyn) = @_;
  my %Files;
  Query('InputImagesByImageEquivalenceClass')->RunQuery(sub {
    my($row) = @_;
  }, sub {}, $self->{params}->{vis_review_instance});
  my $params = {
    vis_review_id => $self->{params}->{vis_review_instance},
    user => $self->get_user,
    files => \%Files,
    tmp_dir => $self->{params}->{tmp_dir},
  };
  my $class = "Posda::ImageDisplayer::KaleidoscopeSub";
  eval "require $class";
  if($@){
    print STDERR "Class failed to compile\n\t$@\n";
    return;
  }

  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  my $name = "$self->{name}" . "_k_scope_$self->{sequence_no}";
  $self->{sequence_no} += 1;
  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);
}



sub Content{
  my($self, $http, $dyn) = @_;
  $self->RefreshEngine($http, $dyn, $content);
}
sub GetContoursToRender{
  my($self, $http, $dyn) = @_;
  my $content_type = "application/json";
  $http->HeaderSent;
  $http->queue("HTTP/1.0 200 OK\n");
  $http->queue("Content-type: $content_type\n\n");
  $http->queue("[]");
}

1;
