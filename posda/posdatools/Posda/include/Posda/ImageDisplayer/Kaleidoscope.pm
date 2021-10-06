#!/usr/bin/perl -w
#
use strict;
package Posda::ImageDisplayer::Kaleidoscope;
use Posda::ImageDisplayer;
use Posda::DB qw( Query );
use Dispatch::LineReader;
use VectorMath;
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
  $self->{ToolTypes} = [["Pan/Zoom", "P/Z tool"]];
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
      $self->{IndexToEquiv}->{$#{$self->{JpegImageUrls}}} =
        $image_equivalence_class_id;
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
<?dyn="ToolTypeSelector"?>
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
  my @FileList;
  my %SopToFile;
  my $equiv_class = 
    $self->{IndexToEquiv}->{$self->{CurrentUrlIndex}};
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
  @FileList = sort {
    $a->{instance_number} <=> $b->{instance_number} ||
    $a->{offset} <=> $b->{offset}
  } @FileList;
  my $params = {
    vis_review_id => $self->{params}->{vis_review_id},
    user => $self->get_user,
    FileList => \@FileList,
    SopToFile => \%SopToFile,
    tmp_dir => $self->{params}->{tmp_dir},
    equiv_class => $equiv_class,
    rows => $rows,
    cols => $cols,
    rois => {},
    series => $series
  };
  my $class = "Posda::ImageDisplayer::KaleidoscopeSub";
  eval "require $class";
  if($@){
    print STDERR "Class $class failed to compile\n$@";
    return;
  }

  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  my $name = "$self->{name}" . "_sub_$self->{sequence_no}";
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
1;
