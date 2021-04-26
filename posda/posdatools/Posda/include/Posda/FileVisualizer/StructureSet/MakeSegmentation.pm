package Posda::FileVisualizer::StructureSet::MakeSegmentation;
use strict;

use Dispatch::LineReader;
use Posda::PopupWindow;
use Posda::DB qw( Query );
use Posda::Try;
use Posda::FlipRotate;
use Posda::File::Import 'insert_file';
use Posda::UUID;
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
  $self->FilterSortedFiles;
  $self->{mode} = "show_file_sorting";
  $self->MakeRefSeriesSeq();
  $self->GetCommonImageParms;
  $self->GetPerFrameInfo;
  $self->{NewSopInstance} = Posda::UUID::GetUUID;
  $self->{NewSeriesInstance} = Posda::UUID::GetUUID;
  $self->{NewDimOrgUID} = Posda::UUID::GetUUID;
}

sub FilterSortedFiles{
  my ($self) = @_;
  $self->{params}->{file_sort} = [];
  for my $f_info (@{$self->{params}->{all_file_sort}}){
    my $file_id = $f_info->{file_id};
    if(exists $self->{params}->{image_files}->{$file_id}){
      push(@{$self->{params}->{file_sort}}, $f_info);
    }
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
  if($self->{RenderingPixels}){
    if($self->{PixelsRendered}){
      $http->queue("<pre>");
      $http->queue("Pixels Rendered:\n");
      for my $i (@{$self->{PixelRenderingResponse}}){
        $http->queue("$i\n");
      }
      $http->queue("Pixel temp file: $self->{pixel_path}\n");
      $http->queue("</pre>");
    } else {
      $http->queue("<pre>");
      $http->queue("RenderingPixelData:\n");
      for my $i (@{$self->{PixelRenderingResponse}}){
        $http->queue("$i\n");
      }
      $http->queue("</pre>");
    }
  } else {
    $self->RenderPixelData();
    $http->queue("<pre>");
    $http->queue("StartingPixelRendering\n");
    $http->queue("</pre>");
  }
}

sub DisplayDicomRendering{
  my ($self, $http, $dyn) = @_;
  unless(exists $self->{DicomRendering}){
    $self->RenderDicomSpec();
  }
  $http->queue("<pre>");
  for my $i (@{$self->{DicomRendering}}){
    $i =~ s/</&lt;/;
    $i =~ s/>/&gt;/;
    $http->queue("$i\n");
  }
  $http->queue("</pre>");
}

sub DisplayFinalDicomRendering{
  my ($self, $http, $dyn) = @_;
  if($self->{WritingRenderedDicomRendering}){
    if($self->{DicomRenderingRendered}){
      $http->queue("<pre>");
      open FILE, "<$self->{DicomRenderingPath}" or 
        die "can't open $self->{DicomRenderingPath} ($!)";
      while (my $l = <FILE>){
        chomp $l;
        $l =~ s/</&lt;/;
        $l =~ s/>/&gt;/;
        $http->queue("$l\n");
      }
      close FILE;
      $http->queue("</pre>");
    }else {
      $http->queue("<pre>");
      $http->queue("Rendering Macros being expanded:\n");
      for my $i (@{$self->{RenderRenderResp}}){
        $http->queue("$i\n");
      }
      $http->queue("</pre>");
    }
  } else {
    $self->WriteRenderedDicomRendering();
  }
}

sub ProduceSegmentation{
  my ($self, $http, $dyn) = @_;
  $http->queue("<pre>");
  if($self->{ProducingSegmentation}){
    if($self->{SegmentationProduced}){
      if($self->{SegmentationImported}){
        $http->queue("Segmentation Imported:\n");
      } else {
        $http->queue("Importing Segmentation:\n");
      }
    } else {
    $http->queue("Producing Segmentation:\n");
    }
    for my $i (@{$self->{SegmentationProductionResponseLines}}){
      $http->queue("$i\n");
    }
  } else {
    $self->{ProducingSegmentation} = 1;
    $http->queue("Initiating Production of Segmentation\n");
    my $dest_file = $self->{params}->{temp_path} . "/Segmentation.dcm";
    my $cmd = "cat $self->{DicomRenderingPath}|" .
     "ConstructDicomFromStruct.pl $dest_file";
    Dispatch::LineReader->new_cmd($cmd, $self->HandleConstructionLine,
      $self->HandleConstructionComplete($dest_file));
  }
  $http->queue("</pre>");
}

sub HandleConstructionLine{
  my($self) = @_;
  my $sub = sub {
    my($line) = @_;
    push @{$self->{SegmentationProductionResponseLines}}, $line;
    $self->AutoRefresh;
  };
  return $sub;
}

sub HandleConstructionComplete{
  my($self, $dest_file) = @_;
  my $sub = sub {
    $self->{SegmentationProduced} = 1;
    my $cmd = "ImportSingleFileIntoPosdaAndReturnId.pl $dest_file " .
      "'Segmentation Derived from RTSTRUCT'";
    Dispatch::LineReader->new_cmd($cmd, $self->HandleConstructionLine,
     $self->HandleImportComplete($dest_file));
    $self->AutoRefresh;
  };
  return $sub;
}

sub HandleImportComplete{
  my($self, $dest_file) = @_;
  my $sub = sub {
    $self->{SegmentationImported} = 1;
    $self->AutoRefresh;
  };
  return $sub;
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
  } elsif ($self->{mode} eq "show_dicom_rendering"){
    return $self->DisplayDicomRendering($http, $dyn);
  } elsif ($self->{mode} eq "show_final_dicom_rendering"){
    return $self->DisplayFinalDicomRendering($http, $dyn);
  } elsif ($self->{mode} eq "produce_segmentation"){
    return $self->ProduceSegmentation($http, $dyn);
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
  $self->NotSoSimpleButton($http, {
    op => "ShowDicomRendering",
    caption => "Show Dicom Rendering",
    sync => "Reload();"
  });
  if(exists $self->{DicomRendering}){
    $self->NotSoSimpleButton($http, {
      op => "ShowFinalDicomRendering",
      caption => "Write Final Dicom Rendering",
      sync => "Reload();"
    });
  }
  if(
    $self->{WritingRenderedDicomRendering} &&
    $self->{DicomRenderingRendered}
  ){
    $self->NotSoSimpleButton($http, {
      op => "ProduceSegmentationFile",
      caption => "Produce Segmentation File",
      sync => "Reload();"
    });
  }
}

sub ProduceSegmentationFile{
  my ($self, $http, $dyn) = @_;
  $self->{mode} = "produce_segmentation";
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
sub ShowDicomRendering{
  my ($self, $http, $dyn) = @_;
  $self->{mode} = "show_dicom_rendering";
}
sub ShowFinalDicomRendering{
  my ($self, $http, $dyn) = @_;
  $self->{mode} = "show_final_dicom_rendering";
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
  my $tmpfh;
  $self->{RenderingPixels} = 1;
  $self->{PixelsRendered} = 0;
  $self->{pixel_path} = "$self->{params}->{temp_path}/pixel_data.raw";
  $self->{pixel_rendering_inst} = $self->{params}->{temp_path} .
    "/pixel_rendering_spec.txt";
  open SPEC, ">$self->{pixel_rendering_inst}" or die
    "Can't open $self->{pixel_rendering_inst} ($!0)";
  for my $pfi( @{$self->{PerFrameItems}}){
    print SPEC "$pfi->{seg_file_path}\n";
  }
  close SPEC;
  my $cmd = "RenderSegmentationPixels.pl $self->{pixel_rendering_inst} " .
    "$self->{pixel_path}";
  Dispatch::LineReader->new_cmd($cmd, $self->HandlePixelRenderLine,
    $self->HandlePixelRenderComplete);
}

sub HandlePixelRenderLine{
  my($self) = @_;
  my $sub = sub {
    my($line) = @_;
    push @{$self->{PixelRenderingResponse}}, $line;
    if($line =~ /^Total frames: (.*)$/){
      $self->{NumFrames} = $1;
    }
    if($line =~ /^Pixel bytes: (.*)$/){
      $self->{pixel_bytes} = $1;
    }
    $self->AutoRefresh;
  };
}

sub HandlePixelRenderComplete{
  my($self) = @_;
  my $sub = sub {
    $self->{PixelsRendered} = 1;
  };
}

sub RenderDicomSpec{
  my($self) = @_;
  $self->{DicomRendering} = [];
  push @{$self->{DicomRendering}}, "#General DICOM Stuff:";
  push @{$self->{DicomRendering}}, "(0008,0005): ISO_IR 100";
  push @{$self->{DicomRendering}}, "(0008,0008): DERIVED\\PRIMARY";
  push @{$self->{DicomRendering}}, "(0008,0016): 1.2.840.10008.5.1.4.1.1.66.4";
  push @{$self->{DicomRendering}}, "(0008,0018): $self->{NewSopInstance}";
  push @{$self->{DicomRendering}}, "(0008,0020): <?inherit file_id=$self->{params}->{ss_file_id}?>";
  push @{$self->{DicomRendering}}, "(0008,0021): <?inherit file_id=$self->{params}->{ss_file_id}?>";
  push @{$self->{DicomRendering}}, "(0008,0023): <?inherit file_id=$self->{params}->{ss_file_id}?>";
  push @{$self->{DicomRendering}}, "(0008,0030): <?inherit file_id=$self->{params}->{ss_file_id}?>";
  push @{$self->{DicomRendering}}, "(0008,0031): <?inherit file_id=$self->{params}->{ss_file_id}?>";
  push @{$self->{DicomRendering}}, "(0008,0033): <?inherit file_id=$self->{params}->{ss_file_id}?>";
  push @{$self->{DicomRendering}}, "(0008,0050): <?inherit file_id=$self->{params}->{ss_file_id}?>";
  push @{$self->{DicomRendering}}, "(0008,0060): SEG";
  push @{$self->{DicomRendering}}, "(0008,0070): POSDA";
  push @{$self->{DicomRendering}}, "(0008,0090): <?inherit file_id=$self->{params}->{ss_file_id}?>";
  push @{$self->{DicomRendering}}, "(0008,1030): <?inherit file_id=$self->{params}->{ss_file_id}?>";
  push @{$self->{DicomRendering}}, "(0008,103e): <?inherit file_id=$self->{params}->{ss_file_id}?>";
  push @{$self->{DicomRendering}}, "(0008,1090): MakeSegmentation.pm";

  push @{$self->{DicomRendering}}, "#RefSeriesSeq:";
  for my $i (0 .. $#{$self->{RefSeriesSeq}}){
    push @{$self->{DicomRendering}}, "(0008,1115)[$i](0020,000e):" .  
      "$self->{RefSeriesSeq}->[$i]->{series}";
    for my $j (0 .. $#{$self->{RefSeriesSeq}->[$i]->{ref_sop_seq}}){
      my $sop_cl = Posda::DataDict->GetSopClassFromName(
        $self->{RefSeriesSeq}->[$i]->{ref_sop_seq}->[$j]->{dicom_file_type});
      push @{$self->{DicomRendering}}, 
        "(0008,1115)[$i](0008,114a)[$j](0008,1150): $sop_cl";
      push @{$self->{DicomRendering}}, 
        "(0008,1115)[$i](0008,114a)[$j](0008,1155): " .
        "$self->{RefSeriesSeq}->[$i]->{ref_sop_seq}->[$j]->{sop}";
    }
  }

  push @{$self->{DicomRendering}}, "#More pass thru:";
  push @{$self->{DicomRendering}}, "(0010,0010): <?inherit file_id=$self->{params}->{ss_file_id}?>";
  push @{$self->{DicomRendering}}, "(0010,0020): <?inherit file_id=$self->{params}->{ss_file_id}?>";
  push @{$self->{DicomRendering}}, "(0010,0030): <?inherit file_id=$self->{params}->{ss_file_id}?>";
  push @{$self->{DicomRendering}}, "(0010,0040): <?inherit file_id=$self->{params}->{ss_file_id}?>";
  push @{$self->{DicomRendering}}, "(0012,0050): <?inherit file_id=$self->{params}->{ss_file_id}?>";
  push @{$self->{DicomRendering}}, "(0012,0060): <?inherit file_id=$self->{params}->{ss_file_id}?>";
  push @{$self->{DicomRendering}}, "(0012,0071): <?inherit file_id=$self->{params}->{ss_file_id}?>";
  push @{$self->{DicomRendering}}, "(0013,\"CTP\",10): <?inherit file_id=$self->{params}->{ss_file_id}?>";
  push @{$self->{DicomRendering}}, "(0013,\"CTP\",11): <?inherit file_id=$self->{params}->{ss_file_id}?>";
  push @{$self->{DicomRendering}}, "(0013,\"CTP\",12): <?inherit file_id=$self->{params}->{ss_file_id}?>";
  push @{$self->{DicomRendering}}, "(0013,\"CTP\",13): <?inherit file_id=$self->{params}->{ss_file_id}?>";
  push @{$self->{DicomRendering}}, "(0018,0015): <?inherit file_id=$self->{params}->{ss_file_id}?>";
  push @{$self->{DicomRendering}}, "(0018,1000): 0";
  push @{$self->{DicomRendering}}, "(0018,1020): 0.8.x";
  push @{$self->{DicomRendering}}, "(0020,000d): <?inherit file_id=$self->{params}->{ss_file_id}?>";
  push @{$self->{DicomRendering}}, "(0020,000e): $self->{NewSeriesInstance}";
  push @{$self->{DicomRendering}}, "(0020,0010): <?inherit file_id=$self->{params}->{ss_file_id}?>";
  push @{$self->{DicomRendering}}, "(0020,0011): <null>";
  push @{$self->{DicomRendering}}, "(0020,0013): 1";
  push @{$self->{DicomRendering}}, "(0020,0052): " .
    "$self->{CommonIparms}->{for_uid}";

  push @{$self->{DicomRendering}}, "#DimensionOrgSeq:";
  push @{$self->{DicomRendering}}, "(0020,9221)[0](0020,9164): " .
    "$self->{NewDimOrgUID}";
  push @{$self->{DicomRendering}}, "(0020,9222)[0](0020,9164): " .
    "$self->{NewDimOrgUID}";
  push @{$self->{DicomRendering}}, "(0020,9222)[0](0020,9165): " .
    "0x000b0062";
  push @{$self->{DicomRendering}}, "(0020,9222)[0](0020,9167): " .
    "0x000a0062";
  push @{$self->{DicomRendering}}, "(0020,9222)[0](0020,9421): " .
    "ReferencedSegmentNumber";
  push @{$self->{DicomRendering}}, "(0020,9222)[1](0020,9164): " .
    "$self->{NewDimOrgUID}";
  push @{$self->{DicomRendering}}, "(0020,9222)[1](0020,9165): " .
    "0x00320020";
  push @{$self->{DicomRendering}}, "(0020,9222)[1](0020,9167): " .
    "0x91130020";
  push @{$self->{DicomRendering}}, "(0020,9222)[1](0020,9421): " .
    "ImagePositionPatient";


  push @{$self->{DicomRendering}}, "#Pixel organization:";
  push @{$self->{DicomRendering}}, "(0028,0002): 1";
  push @{$self->{DicomRendering}}, "(0028,0004): MONOCHROME2";
  push @{$self->{DicomRendering}}, "(0028,0008): $self->{NumFrames}";
##### Might be wrong to hard code these:
  push @{$self->{DicomRendering}}, "(0028,0010): 512";
  push @{$self->{DicomRendering}}, "(0028,0011): 512";
##### Might be wrong to hard code these^^^
  push @{$self->{DicomRendering}}, "(0028,0100): 1";
  push @{$self->{DicomRendering}}, "(0028,0101): 1";
  push @{$self->{DicomRendering}}, "(0028,0102): 0";
  push @{$self->{DicomRendering}}, "(0028,0103): 0";
  push @{$self->{DicomRendering}}, "(0062,0001): BINARY";

  push @{$self->{DicomRendering}}, "#SegmentSeq:";
  my $index = 0;
  for my $i (sort { $a <=> $b} keys %{$self->{params}->{rois}}){
    my $roi = $self->{params}->{rois}->{$i};
    push @{$self->{DicomRendering}}, "(0062,0002)[$index](0062,0004): " .
      "$i";
    push @{$self->{DicomRendering}}, "(0062,0002)[$index](0062,0005): " .
      "$roi->{roi_label}";
    push @{$self->{DicomRendering}}, "(0062,0002)[$index](0062,0006): " .
      "$roi->{roi_obser_desc}";
    push @{$self->{DicomRendering}}, "(0062,0002)[$index](0062,0008): " .
      "AUTOMATIC";
    push @{$self->{DicomRendering}}, "(0062,0002)[$index](0062,0009): " .
      "PointsInContours";
    my $cie = VectorMath::RgbToCie($roi->{color});
    push @{$self->{DicomRendering}}, "(0062,0002)[$index](0062,000d): " .
      "$cie->[0]\\$cie->[1]\\$cie->[2]";
    $index += 1;
  }
  push @{$self->{DicomRendering}}, "#Content Creation Info:";
  push @{$self->{DicomRendering}}, "(0070,0080): POSDA";
  push @{$self->{DicomRendering}}, "(0070,0080): " .
    "POSDA Conversion from RTSTRUCT";
  push @{$self->{DicomRendering}}, "(0070,0081): POSDA";
  push @{$self->{DicomRendering}}, "(0070,0084): $self->{params}->{user}";

  push @{$self->{DicomRendering}}, "#SharedFuncGroupSeq:";
  push @{$self->{DicomRendering}}, "(5200,9229)[0](0020,9116)[0](0020,0037): " .
    "$self->{CommonIparms}->{iop}";
  push @{$self->{DicomRendering}}, "(5200,9229)[0](0028,9110)[0](0018,0050): " .
    "$self->{CommonIparms}->{slice_thickness}";
  push @{$self->{DicomRendering}}, "(5200,9229)[0](0028,9110)[0](0018,0088): " .
    "$self->{CommonIparms}->{slice_spacing}";
  push @{$self->{DicomRendering}}, "(5200,9229)[0](0028,9110)[0](0028,0030): " .
    "$self->{CommonIparms}->{pixel_spacing}";

  push @{$self->{DicomRendering}}, "#PerFrameFuncGroupSeq:";
  for my $fi (0 .. $#{$self->{PerFrameItems}}){
    my $item = $self->{PerFrameItems}->[$fi];
    my $sop_cl = Posda::DataDict->GetSopClassFromName(
      $item->{image_info}->{dicom_file_type});
    push @{$self->{DicomRendering}}, "(5200,9230)[$fi](0008,9124)[0](0008,2112)[0](0008,1150): $sop_cl";
    push @{$self->{DicomRendering}}, "(5200,9230)[$fi](0008,9124)[0](0008,2112)[0](0008,1155): $item->{image_info}->{sop_instance_uid}";
    push @{$self->{DicomRendering}}, "(5200,9230)[$fi](0008,9124)[0](0008,2112)[0](0040,a170)[0](0008,0100): 121322";
    push @{$self->{DicomRendering}}, "(5200,9230)[$fi](0008,9124)[0](0008,2112)[0](0040,a170)[0](0008,0102): DCM";
    push @{$self->{DicomRendering}}, "(5200,9230)[$fi](0008,9124)[0](0008,2112)[0](0040,a170)[0](0008,0104): Source image for image processing operation";
    push @{$self->{DicomRendering}}, "(5200,9230)[$fi](0008,9124)[0](0008,9215)[0](0008,0100): 113076";
    push @{$self->{DicomRendering}}, "(5200,9230)[$fi](0008,9124)[0](0008,9215)[0](0008,0102): DCM";
    push @{$self->{DicomRendering}}, "(5200,9230)[$fi](0008,9124)[0](0008,9215)[0](0008,0104): Segmentation";
    push @{$self->{DicomRendering}}, "(5200,9230)[$fi](0020,9111)[0](0020,9157): $item->{index}";
    push @{$self->{DicomRendering}}, "(5200,9230)[$fi](0020,9113)[0](0020,0032): $item->{image_info}->{ipp}";
    push @{$self->{DicomRendering}}, "(5200,9230)[$fi](0062,000a)[0](0062,000b): $item->{roi_num}";
  }

  push @{$self->{DicomRendering}}, "#Pixel Data:";
  if(exists $self->{pixel_bytes}){
    push @{$self->{DicomRendering}}, "(7fe0,0010): " .
      "<?external_file path=$self->{pixel_path} offset=0 size=$self->{pixel_bytes}?>";
  } else {
    push @{$self->{DicomRendering}}, "(7fe0,0010): ### Not yet rendered ###";
  }
}

sub WriteRenderedDicomRendering{
  my($self) = @_;
  $self->{WritingRenderedDicomRendering} = 1;
  $self->{DicomRenderingRendered} = 0;
  $self->{RenderRenderResp} = [];
  $self->{UnexpandedRenderingPath} = $self->{params}->{temp_path} .
    "/DicomRenderingUnexpanded.raw";
  open REND, ">$self->{UnexpandedRenderingPath}" or
    die  "Can't open $self->{UnexpandedRenderingPath} ($!)";
  for my $i (@{$self->{DicomRendering}}){
    $i =~ s/&lt;/</;
    $i =~ s/&gt;/>/;
    print REND "$i\n";
  }
  close REND;
 
  $self->{DicomRenderingPath} = 
    "$self->{params}->{temp_path}/DicomRendering.raw";
  my $inherit_path;
  Query('GetFilePath')->RunQuery(sub {
    my($row) = @_;
    $inherit_path = $row->[0];
  }, sub{}, $self->{params}->{ss_file_id});
  my $cmd = "ExpandMacrosInDicomRenderSpec.pl " .
    "$self->{UnexpandedRenderingPath} $inherit_path " .
    "$self->{DicomRenderingPath}";
print STDERR "Cmd: $cmd\n";
  Dispatch::LineReader->new_cmd($cmd, $self->HandleRenderLine,
    $self->HandleRenderComplete);
}

sub HandleRenderLine{
  my($self) = @_;
  my $sub = sub {
    my($line) = @_;
    push @{$self->{RenderRenderResp}}, $line;
    $self->AutoRefresh;
  };
}

sub HandleRenderComplete{
  my($self) = @_;
  my $sub = sub {
    $self->{DicomRenderingRendered} = 1;
    $self->AutoRefresh;
  };
}

sub DESTROY{
  my($self) = @_;
  if(exists $self->{pixel_path}){
    print STDERR "Unlinking pixel temp file ($self->{pixel_path})\n";
  close FILE;
  }
}

1;
