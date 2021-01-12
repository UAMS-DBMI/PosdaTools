package Posda::FileVisualizer::Segmentation;
use strict;

use Posda::PopupWindow;
use Posda::FileVisualizer::Slice;
use Posda::DB qw( Query );
use Digest::MD5;
use ActivityBasedCuration::Quince;


use vars qw( @ISA );
@ISA = ("Posda::FileVisualizer");

sub SpecificInitialize {
  my ($self) = @_;
  $self->{title} = "Generic Segmentation Visualizer";
  $self->{is_Segmentation} = 1;
  $self->SeeIfBitmap();
  if($self->{IsSegBitmap}){ 
    $self->{mode} = "show_seg_bitmap_info"
  } else {
    $self->{mode} = "show_dicom_dump";
  }
}
sub SeeIfBitmap{
  my($self) = @_;
  $self->{IsSegBitmap} = 0;
  Query('GetSegBitmapFileByFileId')->RunQuery(sub{
    my($row) = @_;
    my($seg_bitmap_file_id, $number_segmentations, $num_slices, 
      $rows, $cols, $patient_id, $study_instance_uid, 
      $series_instance_uid, $sop_instance_uid, $frame_of_reference_uid,
      $pixel_offset) = @$row;
    $self->{IsSegBitmap} = 1;
    $self->{SegBitmapInfo} = {
      num_segs => $number_segmentations, 
      num_slices => $num_slices,
      num_rows => $rows, 
      num_cols => $cols, 
      patient_id => $patient_id, 
      study_instance_uid => $study_instance_uid, 
      series_instance_uid => $series_instance_uid,
      sop_instance_uid =>  $sop_instance_uid,
      frame_of_reference_uid =>  $frame_of_reference_uid,
      pixel_offset => $pixel_offset
    };
  }, sub{}, $self->{file_id});
}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  if($self->{mode} eq "show_dicom_dump"){
    $self->DisplayDicomDump($http, $dyn);
    return;
  }elsif($self->{mode} eq "show_seg_bitmap_info"){
    $self->DisplaySegBitmapInfo($http, $dyn);
    $self->DisplaySegmentationInfo($http, $dyn);
    $self->GatherSegmentationSliceInfo($http, $dyn);
    $self->DisplaySegmentationSliceInfo($http, $dyn);
    return;
  }
}

sub DisplaySegBitmapInfo{
  my ($self, $http, $dyn) = @_;
  $http->queue("<h3>DICOM file $self->{file_id} is BINARY Segmentation" . 
    "</h3><pre>");
  for my $k ("num_rows", "num_cols", "num_segs", "num_slices"){
    $http->queue("$k: $self->{SegBitmapInfo}->{$k}\n");
  }
  $http->queue("</pre>");

}

sub DisplaySegmentationInfo{
  my ($self, $http, $dyn) = @_;
  my @fields = ("num", "label", "description",
    "color", "alg_type", "alg_name", "category", "type");
  $http->queue("<table class=\"table table-striped\">");
  $http->queue("<tr><th>num</th><th>label</th><th>description</th>" .
    "<th>color</th><th>alg_type</th><th>alg_name</th>" .
    "<th>category</th><th>type</th></tr>");
  Query('GetSegBitmapSegmentations')->RunQuery(sub{
    my($row) = @_;
    for my $i (1 .. $#fields){
      $self->{SegmentationInfo}->{$row->[1]}->{$fields[$i]}  = $row->[$i + 1];
    }
    my $num = $row->[1];
    unless(defined $self->{SelectedSegmentation}){
      $self->{SelectedSegmentation} = $num;
    }
    $http->queue("<tr>");
    for my $i (1 .. $#{$row}){
      if($i == 1){
        $http->queue("<td>");
        my $seg_num = $row->[$i];
        $http->queue($seg_num . "&nbsp;");
        $http->queue($self->CheckBoxDelegate("Segmentation", "$seg_num",
        $self->{SelectedSegmentation} == $seg_num ? 1: 0,
        { op => "SelectSegmentation",
          sync => "Update();" }));
        $http->queue("</td>");
      } else {
        $http->queue("<td>$row->[$i]</td>");
      }
    }
    $http->queue("</tr>");
  }, sub{}, $self->{file_id});
  $http->queue("</table>");
}

sub SelectSegmentation{
  my($self, $http, $dyn) = @_;
  $self->{SelectedSegmentation} = $dyn->{value};
}

sub GatherSegmentationSliceInfo{
  my($self, $http, $dyn) = @_;
  delete $self->{SegmentationSliceInfo};
  Query('GatherSegmentationSliceInfo')->RunQuery(sub{
    my($row) = @_;
    my($sn, $iop, $ipp, $total_one_bits,
      $num_bare_points, $sop_instance_uid, 
      $num_contours, $num_points, $bm_slice_file_id, $c_file_id) = @$row;
    $self->{SegmentationSliceInfo}->{$sn}->{iop} = $iop;
    $self->{SegmentationSliceInfo}->{$sn}->{ipp} = $ipp;
    $self->{SegmentationSliceInfo}->{$sn}->{total_one_bits} = $total_one_bits;
    $self->{SegmentationSliceInfo}->{$sn}->{num_bare_points} = $num_bare_points;
    if(defined $num_contours){
      $self->{SegmentationSliceInfo}->{$sn}->{num_contours} = $num_contours;
    }
    if(defined $num_points){
      $self->{SegmentationSliceInfo}->{$sn}->{num_points} = $num_points;
    }
    if(defined $sop_instance_uid){
      $self->{SegmentationSliceInfo}->{$sn}->{sops}->{$sop_instance_uid} = 1;
    }
    if(defined $bm_slice_file_id){
      $self->{SegmentationSliceInfo}->{$sn}->{seg_slice_bitmap_file_id} = 
        $bm_slice_file_id;
    }
    if(defined $c_file_id){
      $self->{SegmentationSliceInfo}->{$sn}->{contour_file_id} = 
        $c_file_id;
    }
  }, sub{}, $self->{file_id}, $self->{SelectedSegmentation});
}

sub DisplaySegmentationSliceInfo{
  my($self, $http, $dyn) = @_;
  $http->queue("Segmentations:");
  $http->queue("<table class=\"table table-striped\">");
  $http->queue("<tr><th>slice_no</th><th>iop</th><th>ipp</th>" .
    "<th>one_bits</th><th>bare_points</th><th>num_ref_sops</th>" .
    "<th>num_contours</th><th>num_points</th></tr>");
  for my $i (sort {$a <=> $b} keys %{$self->{SegmentationSliceInfo}}){
    my $info = $self->{SegmentationSliceInfo}->{$i};
    $http->queue("<tr>");
    $http->queue("<td>");
    $self->NotSoSimpleButton($http, {
       op => "SelectSlice",
       caption => "$i",
       slice_no => $i,
       sync => "Reload();"
    });
    $http->queue("</td>");
    $http->queue("<td>$info->{iop}</td><td>$info->{ipp}</td>" .
      "<td>$info->{total_one_bits}</td><td>$info->{num_bare_points}</td>");
    my $n = 0;
    if(defined $info->{sops}){
      $n = keys %{$info->{sops}};
    }
    $http->queue("<td>$n</td>");
    $http->queue("<td>$info->{num_contours}</td>");
    $http->queue("<td>$info->{num_points}</td>");
    $http->queue("</tr>");
  }
  $http->queue("</table>");
}

sub SelectSlice{
  my ($self, $http, $dyn) = @_;
  $self->{SelectedSlice} = $dyn->{slice_no};
  bless $self, "Posda::FileVisualizer::Slice";
  $self->SpecificInitialize();
}

sub ShowSegBitmapInfo{
  my ($self, $http, $dyn) = @_;
  $self->{mode} = "show_seg_bitmap_info";
}

sub MenuResponse {
  my ($self, $http, $dyn) = @_;
  $self->NotSoSimpleButton($http, {
     op => "ShowDicomDump",
     caption => "ShowDicomDump",
     sync => "Update();"
  });
  if($self->{IsSegBitmap}){
    $self->NotSoSimpleButton($http, {
       op => "ShowSegBitmapInfo",
       caption => "Show Bitmap Info",
       sync => "Update();"
    });
  };
}

1;
