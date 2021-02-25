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
  $self->MakeRefSeriesSeq();
  $self->GetCommonImageParms;
  $self->GetPerFrameInfo;
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
  $http->queue("<th rowspan=2></th><th rowspan=2>file_id</th><th rowspan=2>offset</th>" .
    "<th rowspan=2>x_err</th><th rowspan=2>y_err</th>" .
    "<th colspan=$num_rois>ROIs</th></tr>");
  $http->queue("<tr>");
  for my $i (sort {$a <=> $b} @rois){
    #my $roi_num = $self->{params}->{rois}->{$i}->{roi_num};
    my $roi_name = $self->{params}->{rois}->{$i}->{roi_name};
    $http->queue("<th>$i ($self->{params}->{rois}->{$i}->{roi_name})</th>");
  }
  $http->queue("</tr>");
  my $index = 0;
  for my $spec (@{$self->{params}->{file_sort}}){
    my $file_id = $spec->{file_id};
    my $offset = $spec->{offset};
    my $x_diff = $spec->{x_diff};
    my $y_diff = $spec->{y_diff};
    $http->queue("<tr><td>$index</td><td>$file_id</td><td>$offset</td><td>$x_diff</td>" .
      "<td>$y_diff</td>");
    for my $i (sort {$a <=> $b} @rois){
      if(exists($self->{params}->{seg_files}->{$i}->{$file_id})){
        $http->queue("<td>+</td>");
      } else {
        $http->queue("<td>-</td>");
      }
    }
    $http->queue("</tr>");
    $index += 1;
  }
  $http->queue("</table>");
};

sub DisplayRefSeriesSeq{
  my ($self, $http, $dyn) = @_;
  $http->queue("<pre>");
  for my $i (0 .. $#{$self->{RefSeriesSeq}}){
    $http->queue("(0008,1115)[$i](0020,000e):" .
      "$self->{RefSeriesSeq}->[$i]->{series}\n");
    for my $j (0 .. $#{$self->{RefSeriesSeq}->[$i]->{ref_sop_seq}}){
      my $sop_cl = Posda::DataDict->GetSopClassFromName(
        $self->{RefSeriesSeq}->[$i]->{ref_sop_seq}->[$j]->{dicom_file_type});
      $http->queue("(0008,1115)[$i](0008,114a)[$j](0008,1150): $sop_cl\n");
      $http->queue("(0008,1115)[$i](0008,114a)[$j](0008,1155): " .
        "$self->{RefSeriesSeq}->[$i]->{ref_sop_seq}->[$j]->{sop}\n");
    }
  }
  $http->queue("</pre>");
};

sub DisplayRgbCie{
  my ($self, $http, $dyn) = @_;
  $http->queue("<pre>");
  for my $roi_num (keys %{$self->{params}->{rois}}){
    my $roi = $self->{params}->{rois}->{$roi_num};
    $http->queue("Roi num: $roi_num\n" .
      "roi_name: $roi->{roi_name}\n" .
      "rgb: [$roi->{color}->[0], $roi->{color}->[1], $roi->{color}->[2]]\n");
    my $cie = VectorMath::RgbToCie($roi->{color});
    $http->queue("cie: [$cie->[0], $cie->[1], $cie->[2]]\n\n");
  }
  $http->queue("</pre>");
}

sub DisplayDimensionOrganization{
  my ($self, $http, $dyn) = @_;
  $http->queue("<pre>(0020,9221)[0](0020,9164):(UI, 1): &lt;new uid 1&gt;\n");
  $http->queue("(0020,9222)[0](0020,9164): &lt;new uid 1&gt;\n");
  $http->queue("(0020,9222)[0](0020,9165): 0x000b0062\n");
  $http->queue("(0020,9222)[0](0020,9167): 0x000a0062\n");
  $http->queue("(0020,9222)[0](0020,9421): ReferencedSegmentNumber\n");
  $http->queue("(0020,9222)[1](0020,9164): &lt;new uid 1&gt;\n");
  $http->queue("(0020,9222)[1](0020,9165): 0x00320020\n");
  $http->queue("(0020,9222)[1](0020,9167): 0x91130020\n");
  $http->queue("(0020,9222)[1](0020,9421): ImagePositionPatient\n");
}

sub DisplaySegments{
  my ($self, $http, $dyn) = @_;
  $http->queue("<pre>");
  my $index = 0;
  for my $i (sort { $a <=> $b} keys %{$self->{params}->{rois}}){
    my $roi = $self->{params}->{rois}->{$i};
    $http->queue("(0062,0002)[$index](0062,0004): $i\n"); 
    $http->queue("(0062,0002)[$index](0062,0005): $roi->{roi_label}\n");
    $http->queue("(0062,0002)[$index](0062,0006): $roi->{roi_obser_desc}\n");
    $http->queue("(0062,0002)[$index](0062,0008): AUTOMATIC\n");
    $http->queue("(0062,0002)[$index](0062,0009): PointsInContours\n");
    my $cie = VectorMath::RgbToCie($roi->{color});
    $http->queue("(0062,0002)[$index](0062,000d): ");
    $http->queue("$cie->[0]\\$cie->[1]\\$cie->[2]\n");
    $index += 1;
  }
  $http->queue("</pre>");
}

sub DisplaySharedFunc{
  my ($self, $http, $dyn) = @_;
  $http->queue("<pre>");
  $http->queue("(5200,9229)[0](0020,9116)[0](0020,0037): ");
  $http->queue("$self->{CommonIparms}->{iop}\n");
  $http->queue("(5200,9229)[0](0028,9110)[0](0018,0050): ");
  $http->queue("$self->{CommonIparms}->{slice_thickness}\n");
  $http->queue("(5200,9229)[0](0028,9110)[0](0018,0088): ");
  $http->queue("$self->{CommonIparms}->{slice_spacing}\n");
  $http->queue("(5200,9229)[0](0028,9110)[0](0028,0030): " .
    "$self->{CommonIparms}->{pixel_spacing}\n");
  $http->queue("</pre>");
}

sub DisplayPerFrameFunc{
  my ($self, $http, $dyn) = @_;
  $http->queue("<pre>");
  for my $fi (0 .. $#{$self->{PerFrameItems}}){
    my $item = $self->{PerFrameItems}->[$fi];
    my $sop_cl = Posda::DataDict->GetSopClassFromName(
      $item->{image_info}->{dicom_file_type});
    $http->queue("(5200,9230)[$fi](0008,9124)[0](0008,2112)[0](0008,1150): $sop_cl\n");
    $http->queue("(5200,9230)[$fi](0008,9124)[0](0008,2112)[0](0008,1155): $item->{image_info}->{sop_instance_uid}\n");
    $http->queue("(5200,9230)[$fi](0008,9124)[0](0008,2112)[0](0040,a170)[0](0008,0100): 121322\n");
    $http->queue("(5200,9230)[$fi](0008,9124)[0](0008,2112)[0](0040,a170)[0](0008,0102): DCM\n");
    $http->queue("(5200,9230)[$fi](0008,9124)[0](0008,2112)[0](0040,a170)[0](0008,0104): Source image for image processing operation\n");
    $http->queue("(5200,9230)[$fi](0008,9124)[0](0008,9215)[0](0008,0100): 113076\n");
    $http->queue("(5200,9230)[$fi](0008,9124)[0](0008,9215)[0](0008,0102): DCM\n");
    $http->queue("(5200,9230)[$fi](0008,9124)[0](0008,9215)[0](0008,0104): Segmentation\n");
    $http->queue("(5200,9230)[$fi](0020,9111)[0](0020,9157): $item->{index}\n");
    $http->queue("(5200,9230)[$fi](0020,9113)[0](0020,0032): $item->{image_info}->{ipp}\n");
    $http->queue("(5200,9230)[$fi](0062,000a)[0](0062,000b): $item->{roi_num}\n");
  }
}

sub DisplayPixelInfo{
  my ($self, $http, $dyn) = @_;
  unless(exists $self->{pixel_path}){
    $self->RenderPixelData();
  }
  $http->queue("<pre>");
  $http->queue("Pixel temp file: $self->{pixel_path}\n");
  $http->queue("</pre>");
}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  if($self->{mode} eq "show_file_sorting"){
    return $self->DisplayFileSorting($http, $dyn);
  } elsif ($self->{mode} eq "show_ref_series_seq"){
    return $self->DisplayRefSeriesSeq($http, $dyn);
  } elsif ($self->{mode} eq "show_rgb_cie"){
    return $self->DisplayRgbCie($http, $dyn);
  } elsif ($self->{mode} eq "show_dimension_organ"){
    return $self->DisplayDimensionOrganization($http, $dyn);
  } elsif ($self->{mode} eq "show_segments"){
    return $self->DisplaySegments($http, $dyn);
  } elsif ($self->{mode} eq "show_shared_func"){
    return $self->DisplaySharedFunc($http, $dyn);
  } elsif ($self->{mode} eq "show_per_frame_func"){
    return $self->DisplayPerFrameFunc($http, $dyn);
  } elsif ($self->{mode} eq "show_pixel_info"){
    return $self->DisplayPixelInfo($http, $dyn);
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
  $self->NotSoSimpleButton($http, {
    op => "ShowRefSeriesSeq",
    caption => "ShowRefSeriesSequence",
    sync => "Reload();"
  });
  $self->NotSoSimpleButton($http, {
    op => "ShowRgbToCIELab",
    caption => "Show Rgb to CIELab",
    sync => "Reload();"
  });
  $self->NotSoSimpleButton($http, {
    op => "ShowDimensionOrganization",
    caption => "Show Dimension Organization",
    sync => "Reload();"
  });
  $self->NotSoSimpleButton($http, {
    op => "ShowSegments",
    caption => "Show Segment Sequence",
    sync => "Reload();"
  });
  $self->NotSoSimpleButton($http, {
    op => "ShowSharedFunc",
    caption => "Show Shared Function Group Sequence",
    sync => "Reload();"
  });
  $self->NotSoSimpleButton($http, {
    op => "ShowPerFrameFunc",
    caption => "Show Per Frame Function Group Sequence",
    sync => "Reload();"
  });
  $self->NotSoSimpleButton($http, {
    op => "ShowPixelInfo",
    caption => "Show Pixel Info",
    sync => "Reload();"
  });
}

sub ShowFileSorting{
  my ($self, $http, $dyn) = @_;
  $self->{mode} = "show_file_sorting";
}
sub ShowRefSeriesSeq{
  my ($self, $http, $dyn) = @_;
  $self->{mode} = "show_ref_series_seq";
}
sub ShowRgbToCIELab{
  my ($self, $http, $dyn) = @_;
  $self->{mode} = "show_rgb_cie";
}
sub ShowDimensionOrganization{
  my ($self, $http, $dyn) = @_;
  $self->{mode} = "show_dimension_organ";
}
sub ShowSegments{
  my ($self, $http, $dyn) = @_;
  $self->{mode} = "show_segments";
}
sub ShowSharedFunc{
  my ($self, $http, $dyn) = @_;
  $self->{mode} = "show_shared_func";
}
sub ShowPerFrameFunc{
  my ($self, $http, $dyn) = @_;
  $self->{mode} = "show_per_frame_func";
}
sub ShowPixelInfo{
  my ($self, $http, $dyn) = @_;
  $self->{mode} = "show_pixel_info";
}

sub MakeRefSeriesSeq{
  my ($self, $http, $dyn) = @_;
  my %Series;
  for my $i (keys %{$self->{params}->{image_files}}){
    my $f_info = $self->{params}->{image_files}->{$i};
    $Series{$f_info->{series_instance_uid}}->{$f_info->{sop_instance_uid}}
      = $f_info->{dicom_file_type};
  }
  my @RefSeriesSeq;
  for my $series (keys %Series){
    my $h = {
      series => $series,
      ref_sop_seq => []
    };
    my $list = $h->{ref_sop_seq};
    for my $sop (keys %{$Series{$series}}){
      push @$list, {
        sop => $sop,
        dicom_file_type => $Series{$series}->{$sop}
      };
    }
    push @RefSeriesSeq, $h;
  }
  $self->{RefSeriesSeq} = \@RefSeriesSeq;
}

sub GetCommonImageParms{
  my($self) = @_;
  my %Iparms;
  for my $i (keys %{$self->{params}->{image_files}}){
    my $h = $self->{params}->{image_files}->{$i};
    for my $j (keys %$h){
      $Iparms{$j}->{$h->{$j}} = 1;
    }
  }
  my %Common;
  for my $i (keys %Iparms){
    my @keys = keys %{$Iparms{$i}};
    if(@keys == 1){
      $Common{$i} = $keys[0];
    }
  }
  $self->{AllIparms} = \%Iparms;
  $self->{CommonIparms} = \%Common;
  $self->GetSliceSpacingThickness;
}

sub GetSliceSpacingThickness{
  my($self) = @_;
  my $last;
  my @slice_dist;
  my $tot_dist;
  for my $fi (@{$self->{params}->{file_sort}}){
    my $loc = $fi->{offset};
    if(defined $last){
      my $diff = $loc - $last;
      push @slice_dist, $diff;
      $tot_dist += $diff;
    }
    $last = $loc;
  }
  my $num_dist = @slice_dist;
  my $avg = $tot_dist/$num_dist;
  $self->{CommonIparms}->{slice_thickness} = $avg;
  $self->{CommonIparms}->{slice_spacing} = $avg;
}

sub GetPerFrameInfo{
  my($self) = @_;
  my $idex = 0;
  my $next_item_no = 0;
  $self->{PerFrameItems} = [];
  for my $roi_num (sort {$a <=> $b} keys %{$self->{params}->{rois}}){
    $idex += 1;
    my $roi = $self->{params}->{rois}->{$roi_num};
    my $jdex = 0;
    seg_file:
    for my $fs (@{$self->{params}->{file_sort}}){
      $jdex += 1;
      my $file_id = $fs->{file_id};
      unless(exists $self->{params}->{seg_files}->{$roi_num}->{$file_id}){
        next seg_file;
      }
      my $seg_file_id = $self->{params}->{seg_files}->{$roi_num}->{$file_id}->{file_id};
      my $seg_file_path = $self->{params}->{seg_files}->{$roi_num}->{$file_id}->{file_path};
      my $h = {
        roi => $roi,
        roi_num => $roi_num,
        index => "$roi_num\\$jdex",
        item_index => $next_item_no,
        seg_file_id => $seg_file_id,
        seg_file_path => $seg_file_path,
        image_info => $self->{params}->{image_files}->{$file_id},
      };
      push @{$self->{PerFrameItems}}, $h;
      $next_item_no += 1;
    }
  }
}

sub RenderPixelData{
  my($self) = @_;
#  {
    my $tmpfh;
    ($tmpfh, $self->{pixel_path}) = tempfile();
#  }
  print STDERR "Creating pixel temp file ($self->{pixel_path})\n";
  my $seq = 0;
  for my $pfi (@{$self->{PerFrameItems}}){
    $seq += 1;
    my $cmd = "cat $pfi->{seg_file_path}|CmdCtoRbm.pl";
    my $data = `$cmd`;
    my $len = length($data);
    print $tmpfh $data;
    print STDERR "Wrote $len bytes to temp file ($seq)\n";
  }
  close $tmpfh;
}

sub DESTROY{
  my($self) = @_;
  if(exists $self->{pixel_path}){
    print STDERR "Unlinking pixel temp file ($self->{pixel_path})\n";
  }
}

1;
