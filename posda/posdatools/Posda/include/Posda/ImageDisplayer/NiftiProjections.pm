#!/usr/bin/perl -w
#
use strict;
package Posda::ImageDisplayer::NiftiProjections;
use Posda::ImageDisplayer;
use Posda::DB qw( Query );
use Dispatch::LineReader;
use VectorMath;
use Storable qw ( store_fd fd_retrieve );
use JSON;
use Debug;
use File::Temp qw/ tempfile /;
my $dbg = sub {print STDERR @_ };

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
    "Nifti Projection Viewer: " .
    "Visual Activity id: $self->{params}->{activity_id}";
  $self->Initialize();
  $self->InitializeImageList();
  $self->{CurrentIndexList} = 0;
}

sub Initialize{
  my($self) = @_;
  my $max_rows = 0;
  my $max_cols = 0;
  my %Reviewers;
  my %Statii;
  my $g_jpg = Query('NiftiProjectionsByNiftiFileId');
  Query('NiftiFileRenderingsByActvity')->RunQuery(sub{
    my($row) = @_;
    my($nifti_file_id, $jpeg_image_type, $reviewer, $status, $time) = @$row;
    my($rows, $cols);
    if($jpeg_image_type =~ /JPEG .*, (\d+)x(\d+),/){
      $rows = $1;
      $cols = $2;
      if($rows > $max_rows) { $max_rows = $rows }
      if($cols > $max_cols) { $max_cols = $cols }
    }
    unless(defined $reviewer){
      unless(exists $self->{NiftiFiles}->{$nifti_file_id}){
        $self->{NiftiFiles}->{$nifti_file_id} = {};
      }
    }
    if(defined($reviewer)){
      $self->{NiftiFiles}->{$nifti_file_id}->{$reviewer}->{$status}->{$time} = 1;
      $Reviewers{$reviewer} = 1;
    }
    if(defined $status){
      $Statii{$status}->{$nifti_file_id} = 1;
    }
    $g_jpg->RunQuery(sub{
      my($row) = @_;
      my($proj_type, $jfid,$path) = @$row;
      $self->{NiftiFiles}->{$nifti_file_id}->{$proj_type} = [$jfid, $path];
    }, sub {}, $nifti_file_id);
  }, sub {}, $self->{params}->{activity_id});
  $self->{image_width} = $max_cols * 2;
  $self->{image_height} = $max_rows * 2;
  $self->{width} = ($self->{image_width} * 3) + 20;
  $self->{height} = $self->{image_height} + 100;
}

sub InitializeImageList{
  my($self, $http, $dyn) = @_;
  #  He we implement the filter (later)
  $self->{ImageList} = [];
  for my $i (keys %{$self->{NiftiFiles}}){
    push @{$self->{ImageList}}, $i;
  }
}

sub FetchProjection{
  my($self, $http, $dyn) = @_;
  my $type = $dyn->{type};
  my $index = $self->{CurrentIndexList};
  my $nifti_file_id = $self->{ImageList}->[$index];
  my $path = $self->{NiftiFiles}->{$nifti_file_id}->{$type}->[1];
  $self->SendCachedJpeg($http, $dyn, $path);
}

sub ImageHeight{
  my($self, $http, $dyn) = @_;
  $http->queue($self->{image_height});
}

sub ImageWidth{
  my($self, $http, $dyn) = @_;
  $http->queue($self->{image_width});
}

my $content = <<EOF;
<div style="display: flex; flex-direction: row align-items: flex_beginning; margin-top: 5px; margin-right: 5px; margin-bottom: 5px; margin-left: 5px;">
<img src="FetchProjection?obj_path=<?dyn="q_path"?>&type=max" alt="max" width="<?dyn="ImageWidth"?>" height="<?dyn="ImageHeight"?>">
<img src="FetchProjection?obj_path=<?dyn="q_path"?>&type=avg" alt="avg" width="<?dyn="ImageWidth"?>" height="<?dyn="ImageHeight"?>">
<img src="FetchProjection?obj_path=<?dyn="q_path"?>&type=min" alt="min" width="<?dyn="ImageWidth"?>" height="<?dyn="ImageHeight"?>">
</div>
EOF


sub Content{
  my($self, $http, $dyn) = @_;
  $self->RefreshEngine($http, $dyn, $content);
}
1;
