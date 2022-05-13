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
use VectorMath;
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
  if(!exists $parms->{equiv_class} && exists $parms->{image_equivalence_class_id}){
    $parms = $self->ParmInit($parms);
  }
  $self->{params} = $parms;
  $self->{ImageLabels} = {
    top_text => "",
    bottom_text => "",
    right_text => "",
    left_text => "",
    AnnotationsToDraw => [],
  };
  $self->{title} =
    "Kaleidoscope Image: Visual Review id: $self->{params}->{vis_review_id} " .
    "Image Equivalence Class: $self->{params}->{equiv_class}";
  $self->{ToolTypes} = [["Pan/Zoom", "P/Z tool"], ["Rect", "Rect tool"]];
  $self->{FileList} = $parms->{FileList};
  my $rows = $self->{params}->{rows};
  my $cols = $self->{params}->{cols};
  if($rows > 1000) {$rows = 1000};
  if($cols > 1000) {$cols = 1000};
  $self->{width} = $cols + 20;
  $self->{canvas_width} = $cols;
  $self->{height} = $rows + 100;
  $self->{canvas_height} = $rows;
  $self->InitializeUrls;
  $self->{CurrentUrlIndex} = 0;
  $self->SetImageUrl;
}
sub ParmInit{
  my($self, $dyn) = @_;
  my @FileList;
  my %SopToFile;
  my $equiv_class = $dyn->{image_equivalence_class_id};
print STDERR "################################\nIn ImageDisplayPopup: $equiv_class\n";
  my $tmp_dir = $self->parent->{TempDir};
  unless(-d $tmp_dir){
    unless(mkdir($tmp_dir) == 1){
      die "Can't mkdir $tmp_dir";
    }
  }
  my($rows, $cols);
  my $series;
  Query('FilesInImageEquivalenceClass')->RunQuery(sub {
    my($row) = @_;
    my $f_id = $row->[0];
    Query('FileInfoForFileInImageEquivalenceClass')->RunQuery(sub{
      my($row) = @_;
      my(
        $file_id,
        $series_instance_uid,
        $study_instance_uid,
        $sop_instance_uid,
        $instance_number,
        $modality,
        $dicom_file_type,
        $for_uid,
        $iop,
        $ipp,
        $pixel_data_digest,
        $samples_per_pixel,
        $pixel_spacing,
        $photometric_interpretation,
        $pixel_rows,
        $pixel_columns,
        $bits_allocated,
        $bits_stored,
        $high_bit,
        $pixel_representation,
        $planar_configuration,
        $number_of_frames
      ) = @$row;
      my $offset;
      if(defined($ipp) && defined($iop)){
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
        $offset = $rot_ipp->[2];
      }
      my $h = {
        dicom_file_id => $file_id,
        iop => $iop,
        instance_number => $instance_number,
        ipp => $ipp,
        offset => $offset
      };
      unless(defined $rows) { $rows = $pixel_rows }
      if($pixel_rows > $rows) { $rows = $pixel_rows }
      unless(defined $cols) { $cols = $pixel_columns }
      if($pixel_columns > $cols) { $cols = $pixel_columns }
      push @FileList, $h;
      $series = $series_instance_uid;
    }, sub {}, $f_id);
  }, sub {}, $equiv_class);
print STDERR "Back from query: FileInfoForFilesInImageEquivalenceClass\n";
  @FileList = sort {
    $a->{instance_number} <=> $b->{instance_number} ||
    $a->{offset} <=> $b->{offset}
  } @FileList;
  my $params = {
    vis_review_id => $self->{params}->{vis_review_id},
    user => $self->get_user,
    FileList => \@FileList,
    SopToFile => \%SopToFile,
    tmp_dir => $tmp_dir,
    equiv_class => $equiv_class,
    rows => $rows,
    cols => $cols,
    rois => {},
    series => $series,
  };
  return $params;
}
sub ProcessAnnotations{
  my($self, $http, $dyn) = @_;
  unless(
    exists($self->{Annotations}) &&
    ref($self->{Annotations}) eq "ARRAY" &&
    $#{$self->{Annotations}} >= 0
  ){
    $self->{ImageLabels}->{AnnotationsToDraw} = [];
    delete $self->{ImageLabels}->{text_Annotations};
    return;
  }
  $self->{ImageLabels}->{AnnotationsToDraw} = $self->{Annotations};
  my $str = '[';
  for my $i (0 .. $#{$self->{Annotations}}){
    my $box = $self->{Annotations}->[$i];
    my $x = $box->{x};
    my $y = $box->{y};
    my $w = $box->{width};
    my $h = $box->{height};
    $str .= "{\"box\": [$x, $y, $w, $h, \"black\"]}";
    if($i == $#{$self->{Annotations}}){
      $str .= ']';
    } else {
      $str .= ", ";
    }
  }
  $self->{ImageLabels}->{text_Annotations} = "$str";
  $http->queue($str);
}

sub DownloadSpreadsheet{
  my($self, $http, $dyn) = @_;
  my $series = $self->{params}->{series};
  $http->DownloadHeader("text/csv", "EditCommands_$series.csv");
  my $text = "<$self->{ImageLabels}->{text_Annotations}>";
  $text =~ s/"/""/g;
  $http->queue("series_instance_uid,op,tag,val1,val2,Operation\n");
  $http->queue("$series,,,,,BackgroundEditTp\n");
  $http->queue(",annotate_img,\"<(7fe0,0010)>\",\"$text\"\n");
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
</div>
<div style="display: flex; flex-direction: row; align-items: flex-end; margin-left: 10px">
Annotations:&nbsp;&nbsp; <div id="Annotations"></div>
<div><a class="btn btn_primary" href="DownloadSpreadsheet?obj_path=<?dyn="obj_path"?>">download</a>
</div>
EOF

sub obj_path{
  my($self, $http, $dyn) = @_;
  $http->queue("$self->{path}");
}

sub Content{
  my($self, $http, $dyn) = @_;
  $self->RefreshEngine($http, $dyn, $content);
}

1;
