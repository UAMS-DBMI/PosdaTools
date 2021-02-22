package Posda::FileVisualizer::StructureSet::MakeSegmentation;
use strict;

use Posda::PopupWindow;
use Posda::DB qw( Query );
use Posda::Try;
use Posda::FlipRotate;
use Posda::File::Import 'insert_file';
use Digest::MD5;
use File::Temp qw/ tempfile /;

use vars qw( @ISA );
@ISA = ("Posda::FileVisualizer");

sub SpecificInitialize {
  my ($self, $params) = @_;
  $self->{title} = "Make Segmentation from Structures";
  $self->{params} = $params;
  Query('GetStructSegsByStructId')->RunQuery(sub{
    my($row) = @_;
    my($image_file_id, $roi_num, $segmentation_slice_file_id,
      $path) = @$row;
    if(
      exists($self->{params}->{image_files}->{$image_file_id}) &&
      exists($self->{params}->{rois}->{$roi_num})
    ){
      if(exists $self->{params}->{seg_files}->{$roi_num}->{$image_file_id}){
        print STDERR
          "multiple rows slices for roi: $roi_num, image: $image_file_id\n";
      } else {
        $self->{params}->{seg_files}->{$roi_num}->{$image_file_id} = 
          { file_id => $segmentation_slice_file_id,
            file_path => $path };
      }
    }
  }, sub {}, $self->{params}->{ss_file_id});
  $self->{errors} = [];
  $self->SortFilesByOffset;
  $self->{mode} = "show_file_sorting";
}

sub SortFilesByOffset{
  my ($self, $params) = @_;
  my %file_offset_info;
  my $iop;
  file:
  for my $f_id (keys %{$self->{params}->{image_files}}){
    my $f_info = $self->{params}->{image_files}->{$f_id};
    unless(defined $f_info->{iop}) {
      my $msg = "Error: file $f_id has no iop";
      print STDERR "####################\n$msg\n####################\n";
      push(@{$self->{errors}}, $msg);
      next file;
    }
    unless(defined $iop) {$iop = $f_info->{iop}};
    unless($iop eq $f_info->{iop}){
      my $msg = "Error: file $f_id non matching iop " .
        "($iop vs $f_info->{iop})";
      print STDERR "####################\n$msg\n####################\n";
      push(@{$self->{errors}}, $msg);
      next file;
    }
    my @iop = split(/\\/, $iop);
    my $dx = [$iop[0], $iop[1], $iop[2]];
    my $dy = [$iop[3], $iop[4], $iop[5]];
    my $dz = VectorMath::cross($dx, $dy);
    my $rot = [$dx, $dy, $dz];
    my @ipp = split(/\\/, $f_info->{ipp});
    my $rot_dx = VectorMath::Rot3D($rot, $dx);
    my $rot_dy = VectorMath::Rot3D($rot, $dy);
    my $rot_iop = [$rot_dx, $rot_dy];
    my $rot_ipp = VectorMath::Rot3D($rot, \@ipp);
    my $h = { rot_iop => $rot_iop, rot_ipp => $rot_ipp };
    $file_offset_info{$f_id} = $h;
  }
  my $min_z; my $fid_min; my $max_z; my $fid_max;
  my $tot_x = 0;  my $tot_y = 0; my $num_slice = 0;
  for my $i (keys %file_offset_info){
    my $offset_info = $file_offset_info{$i};
    $num_slice += 1;
    $tot_x += $offset_info->{rot_ipp}->[0];
    $tot_y += $offset_info->{rot_ipp}->[1];
    my $z = $offset_info->{rot_ipp}->[2];
    unless(defined $min_z) {
      $min_z = $z;
      $fid_min = $i;
    }
    unless(defined $max_z) {
      $max_z = $z;
      $fid_max = $i;
    }
    if($z < $min_z){
      $min_z = $z;
      $fid_min = $i;
    }
    if($z > $max_z){
      $max_z = $z;
      $fid_max = $i;
    }
  }
  my $avg_x = $tot_x / $num_slice;
  my $avg_y = $tot_y / $num_slice;
#  $self->{partial_sort} = {
#    min_z => $min_z,
#    fid_min => $fid_min,
#    max_z => $max_z,
#    fid_max => $fid_max,
#    avg_x => $avg_x,
#    avg_y => $avg_y,
#  };
#  $self->{params}->{offset_info} = \%file_offset_info;
  for my $i (keys %file_offset_info){
    my $off_info = $file_offset_info{$i};
    $off_info->{z_diff} = $off_info->{rot_ipp}->[2] - $min_z;
    $off_info->{x_diff} = $off_info->{rot_ipp}->[0] - $avg_x;
    $off_info->{y_diff} = $off_info->{rot_ipp}->[1] - $avg_y;
  }
  $self->{params}->{file_sort} = [];
  for my $f (
    sort {
      $file_offset_info{$a}->{z_diff} <=> $file_offset_info{$b}->{z_diff}
    }
    keys %file_offset_info
  ){
    push @{$self->{params}->{file_sort}}, {
      file_id => $f,
      offset => $file_offset_info{$f}->{z_diff},
      x_diff => $file_offset_info{$f}->{x_diff},
      y_diff => $file_offset_info{$f}->{y_diff},
    };
  }
}

sub DisplayFileSorting{
  my ($self, $http, $dyn) = @_;
  my @rois = sort {
    $self->{params}->{rois}->{$a}->{roi_name} cmp
    $self->{params}->{rois}->{$b}->{roi_name}
  }
  keys %{$self->{params}->{rois}};

  my $num_rois = @rois;
  $http->queue("<table class=\"table table-striped\">");
  $http->queue("<tr>");
  $http->queue("<th rowspan=2>file_id</th><th rowspan=2>offset</th>" .
    "<th rowspan=2>x_err</th><th rowspan=2>y_err</th>" .
    "<th colspan=$num_rois>ROIs</th></tr>");
  $http->queue("<tr>");
  for my $i (@rois){
    $http->queue("<th>$self->{params}->{rois}->{$i}->{roi_name}</th>");
  }
  $http->queue("</tr>");
  for my $spec (@{$self->{params}->{file_sort}}){
    my $file_id = $spec->{file_id};
    my $offset = $spec->{offset};
    my $x_diff = $spec->{x_diff};
    my $y_diff = $spec->{y_diff};
    $http->queue("<tr><td>$file_id</td><td>$offset</td><td>$x_diff</td>" .
      "<td>$y_diff</td>");
    for my $i (@rois){
      if(exists($self->{params}->{seg_files}->{$i}->{$file_id})){
        $http->queue("<td>+</td>");
      } else {
        $http->queue("<td>-</td>");
      }
    }
    $http->queue("</tr>");
  }
  $http->queue("</table>");
};

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  if($self->{mode} eq "show_file_sorting"){
    return $self->DisplayFileSorting($http, $dyn);
  }
  $http->queue("unknown mode $self->{mode}");
}

sub MenuResponse{
  my ($self, $http, $dyn) = @_;
  $self->NotSoSimpleButton($http, {
    op => "ShowFileSorting",
    caption => "ShowFileSortingReport",
    sync => "Reload();"
  });
}

sub ShowFileSorting{
  my ($self, $http, $dyn) = @_;
  $self->{mode} = "show_file_sorting";
}


1;
