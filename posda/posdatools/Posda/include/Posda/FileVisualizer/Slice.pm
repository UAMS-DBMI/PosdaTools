package Posda::FileVisualizer::Slice;
use strict;

use Posda::PopupWindow;
use Posda::DB qw( Query );
use Digest::MD5;
use ActivityBasedCuration::Quince;


use vars qw( @ISA );
@ISA = ("Posda::FileVisualizer");

sub SpecificInitialize {
  my ($self) = @_;
#########################
## take note of
#  $self->{file_id} 
#  $self->{file_path}
#  $self->{SelectedSegmentation}
#  $self->{SelectedSlice}
#  $self->{SegBitmapInfo} (describes file)
#  $self->{SegmentationInfo} (describes segmentations)
#  $self->{SegmentationSliceInfo} (describes slices)
#########################
   $self->{title} = "Segmentation Slice Visualizer";
   delete $self->{compressed_bitmap_file_path};
   delete $self->{contour_file_path};
   delete $self->{contour_file_id};
   $self->{slice_related_images} = [];
   if(
     defined( $self->{SegmentationSliceInfo}->{$self->{SelectedSlice}}
       ->{contour_file_id})
   ){
     $self->{contour_file_id} = 
       $self->{SegmentationSliceInfo}->{$self->{SelectedSlice}}
         ->{contour_file_id};
   }
   $self->{compressed_bitmap_file_id} = 
     $self->{SegmentationSliceInfo}->{$self->{SelectedSlice}}
       ->{contour_file_id};

   Query('GetFilePath')->RunQuery(sub{ my($row) = @_;
     $self->{compressed_bitmap_file_path} = $row->[0];
   }, sub {}, $self->{compressed_bitmap_file_id});

   if(
     defined($self->{SegmentationSliceInfo}->{$self->{SelectedSlice}}
       ->{contour_file_id})
   ){
     Query('GetFilePath')->RunQuery(sub{ my($row) = @_;
       $self->{contour_file_path} = $row->[0];
     }, sub {},
     $self->{contour_file_id});
   }
   Query('GetSliceBitmapFileRelatedImages')->RunQuery(sub{
     my($row) = @_;
     push(@{$self->{slice_related_images}}, $row->[0]);
   }, sub {}, $self->{file_id}, $self->{SelectedSlice});
}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  $http->queue("<h4>Slice $self->{SelectedSlice} of " .
    "Segmentation $self->{file_id}</h4>");
  $http->queue("<pre>");
  $http->queue("Segment info:\n");
  my $seg_info = $self->{SegmentationInfo}->{$self->{SelectedSegmentation}};
  $http->queue("  seg_num: $self->{SelectedSlice}\n");
  for my $i ("label", "description", "category", "type"){
    $http->queue("  $i: $seg_info->{$i}\n");
  }
  $http->queue("</pre>");
  $http->queue("<pre>");
  $http->queue("Slice info:\n");
  my $slice_info = $self->{SegmentationSliceInfo}->{$self->{SelectedSlice}};
  $http->queue("  slice_num: $self->{SelectedSlice}\n");
  for my $i (
    "iop", "ipp", "seg_slice_bitmap_file_id", "total_one_bits", "num_bare_points"
  ){
    $http->queue("  $i: $slice_info->{$i}\n");
  }
  if(defined $slice_info->{contour_file_id}){
    for my $i ("contour_file_id", "num_contours", "num_points"){
      $http->queue("  $i: $slice_info->{$i}\n");
    }
  } else {
    $http->queue("  no contours\n");
  }
  if(defined($slice_info->{sops}) && ref($slice_info->{sops}) eq "HASH"){
    my $sops = $slice_info->{sops};
    if((keys %{$sops}) == 1){
      $http->queue("  related sop: " . [keys %$sops]->[0] ."\n");
    } elsif((keys %{$sops}) > 1){
      $http->queue("  related sops:\n");
      for my $i (keys %$sops){
      $http->queue("    $i\n");
      }
    }
  }
  $http->queue("</pre>");
}

sub Return{
  my ($self, $http, $dyn) = @_;
  $self->{title} = "Generic Segmentation Visualizer";
  bless $self, "Posda::FileVisualizer::Segmentation";
}

sub MenuResponse {
  my ($self, $http, $dyn) = @_;
  $self->NotSoSimpleButton($http, {
     op => "Return",
     caption => "Return",
     sync => "Reload();"
  });
}

1;
