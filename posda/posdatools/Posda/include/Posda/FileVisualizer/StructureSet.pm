package Posda::FileVisualizer::StructureSet;
use strict;

use Posda::PopupWindow;
use Posda::DB qw( Query );
use Posda::Try;
use Posda::FlipRotate;
use Digest::MD5;
use File::Temp qw/ tempfile /;


use vars qw( @ISA );
@ISA = ("Posda::FileVisualizer");

sub SpecificInitialize {
  my ($self) = @_;
  $self->{title} = "Generic Structure Set Visualizer";
  $self->{is_StructureSet} = 1;
  $self->GatherStructureInfo();
  $self->{mode} = "show_structure_data";
  $self->{show_series_report} = 1;
  $self->{show_roi_report} = 1;
}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  if($self->{mode} eq "show_dicom_dump"){
    return $self->DisplayDicomDump($http,$dyn);
  } elsif ($self->{mode} eq "show_structure_data"){
    return $self->DisplayStructureData($http,$dyn);
  } elsif ($self->{mode} eq "show_selected_roi"){
    return $self->DisplaySelectedRoi($http,$dyn);
  } elsif ($self->{mode} eq "show_selected_sop"){
    return $self->DisplaySelectedSop($http,$dyn);
  } elsif ($self->{mode} eq "show_selected_roi_and_sop"){
    return $self->DisplaySelectedRoiAndSop($http,$dyn);
  }
  $http->queue("Status: $self->{struct_analysis_status}");
}

sub ShowStructureInfo{
  my($self, $http, $dyn) = @_;
  $self->{mode} = "show_structure_data";
}

sub GatherStructureInfo{
  my($self) = @_;
  $self->{struct_analysis_status} = 'Analysis of DICOM in progress';
  $self->SemiSerializedSubProcess("DicomInfoAnalyzer.pl $self->{file_path}",
    $self->HandleStructureInfo);
}

sub HandleStructureInfo{
  my($self) = @_;
  my $sub = sub {
    my($status, $result) = @_;
    if($status eq 'Succeeded'){
      $self->CrunchAnalysis($result);
    }
    $self->{struct_analysis_result} = $result;
    $self->{struct_analysis_status} = $status;
    $self->SortFilesByOffset;
    $self->AutoRefresh();
  };
  return $sub;
}

sub DisplayStructureData{
  my($self, $http, $dyn) = @_;
  $http->queue("<div id=\"SsRefSeriesReport\">");
  $self->SsRefSeriesReport($http, $dyn);
  $http->queue("</div>");
  $http->queue("<div id=\"SsRoiReport\">");
  $self->SsRoiReport($http, $dyn);
  $http->queue("</div>");
}

sub ShowRoiReport{
  my($self, $http, $dyn) = @_;
  if($dyn->{checked} eq "false"){
    $self->{show_roi_report} = 0;
  } else {
    $self->{show_roi_report} = 1;
  }
}

sub DisplaySelectedRoi{
  my($self, $http, $dyn) = @_;
  my $rp = $self->{StructureSetAnalysis}->{rois}->{$self->{SelectedRoi}};
  $http->queue("<h4>Report for roi $self->{SelectedRoi}</h4>");
  $http->queue("<pre>");
  for my $i (
    "roi_name", "roi_obser_desc", "roi_obser_label",
    "gen_alg", "ref_for", "tot_contours", "tot_points",
    "bounding_box", "color", "num_slices", "contour_types"
  ){
    my $v = "--";
    if($i eq "bounding_box"){
      $v = sprintf("[[%d,%d,%d],[%d,%d,%d]]", $rp->{$i}->[0]->[0],
        $rp->{$i}->[0]->[1], $rp->{$i}->[0]->[1], $rp->{$i}->[1]->[0],
        $rp->{$i}->[1]->[1], $rp->{$i}->[1]->[2]);
    } elsif($i eq "color"){
      $v = "$rp->{$i}->[0]\\$rp->{$i}->[1]\\$rp->{$i}->[2]";
    } elsif($i eq "num_slices"){
      $v = keys %{$rp->{referencing_contours_by_reference}};
    } elsif($i eq "contour_types"){
      my %types;
      for my $h (@{$rp->{contours}}){
        my $type = $h->{type};
        if(exists $types{$type}){
          $types{$type} += 1;
        } else {
          $types{$type} = 1;
        }
        my @t = keys %types;
        $v = "";
        for my $i (0 .. $#t){
          $v .= "$t[$i]: $types{$t[$i]}";
          unless($i == $#t){ $v .= ", " }
        }
      }
    } elsif(exists($rp->{$i})){
      $v = $rp->{$i};
    }
    $http->queue("$i: $v\n");
  }
  $http->queue("</pre>");
  $http->queue("<h5>Sops referenced in roi $self->{SelectedRoi}</h5>");
  my @headers = ("sop", "rendered", "num_contours", "num_points", "contour_types");
  $http->queue("<table class=\"table table-striped\">");
  $http->queue("<tr>");
  for my $i (@headers){
    $http->queue("<th>$i</th>");
  }
  $http->queue("</tr>");
  my $ei = $self->{StructureSetAnalysis}->{extracted_slice_images};
  for my $sop (keys %{$rp->{referencing_contours_by_reference}}){
    my $sd = $self->GetSelectedSopData($sop);
    $http->queue("<tr>");
    for my $k (@headers){
      my $v = "---";
      if($k eq "sop"){
        $v = $sop;
        $http->queue("<td>");
        $self->NotSoSimpleButton($http, {
          op => "SelectSopWithRoi",
          caption => "$sop",
          sop => $sop,
          sync => "Reload();"
        });
        $http->queue("</td>");
      } elsif ($k eq "rendered") {
        my $sop_file_id = $sd->{file_id};
        if(exists $ei->{$self->{SelectedRoi}}->{$sop_file_id}){
          $http->queue("<td>yes</td>");
        } else{
          $http->queue("<td>no</td>");
        }
      } elsif ($k eq "num_contours") {
        my $num_contours = @{$rp->{referencing_contours_by_reference}->{$sop}};
        $http->queue("<td>$num_contours</td>");
      } elsif ($k eq "num_points") {
        my $np = 0;
        for my $i (@{$rp->{referencing_contours_by_reference}->{$sop}}){
          my $c = $rp->{contours}->[$i];
          $np += $c->{num_pts};
        }
        $http->queue("<td>$np</td>");
      } elsif ($k eq "contour_types") {
        my %types;
        for my $i (@{$rp->{referencing_contours_by_reference}->{$sop}}){
          my $c = $rp->{contours}->[$i];
          $types{$c->{type}} = 1;
        }
        my @types = keys %types;
        my $t = "";
        for my $i (0 .. $#types){
          $t .= $types[$i];
          unless($i == $#types){ $t .= ", " }
        }
        $http->queue("<td>$t</td>");
      }
    }
    $http->queue("</tr>");
  }
  $http->queue("</table>");
}

sub SelectRoi{
  my($self, $http, $dyn) = @_;
  $self->{mode} = "show_selected_roi";
  $self->{SelectedRoi} = $dyn->{roi_num};
}

sub UnselectRoi{
  my($self, $http, $dyn) = @_;
  $self->{mode} = "show_structure_data";
  delete $self->{SelectedRoi};
}

sub SsRoiReport{
  my($self, $http, $dyn) = @_;
  my $num_rois = keys %{$self->{StructureSetAnalysis}->{rois}};
  if($num_rois == 0){
    $http->queue("<h4>No rois Analysis (yet)</h4>");
    return;
  }
  $http->queue("<h4>$num_rois rois found&nbsp;");
  $http->queue($self->CheckBoxDelegate("ShowRoiReport", 0,
      $self->{show_roi_report},
      { op => "ShowRoiReport", sync => "Update();" }));
   
  $http->queue("&nbsp;show");
  $http->queue("</h4>");
  unless($self->{show_roi_report}){ return }
   my @rois = sort {$a <=> $b} keys %{$self->{StructureSetAnalysis}->{rois}};
  my $keys = {
     gen_alg => 1,
     roi_interpreted_type => 1,
     roi_name => 1,
     roi_obser_desc => 1,
     roi_obser_label => 1,
     tot_contours => 1,
     tot_points => 1
  };
  my %slices_rendered;
  Query('GetSliceRenderedCounts')->RunQuery(sub{
    my($row) = @_;
    $slices_rendered{$row->[0]} = $row->[1];
  }, sub{}, $self->{file_id});
  my @headers = ("roi_num", "roi_name", "roi_obser_desc",
    "roi_obser_label", "roi_interpreted_type",
    "tot_contours", "tot_points", "num_sops_referenced",
    "slices_rendered"
  );
  $http->queue("<table class=\"table table-striped\">");
  $http->queue("<tr>");
  for my $i (@headers){
    $http->queue("<th>$i</th>");
  }
  $http->queue("<th>");
    $self->NotSoSimpleButton($http, {
      op => "RenderSelectedRoiContours",
      caption => "Render",
      sync => "Reload();"
    });
  $http->queue("</th>");
  $http->queue("<th>");
    $self->NotSoSimpleButton($http, {
      op => "MakeSegmentationFile",
      caption => "Make SEG",
      sync => "Reload();"
    });
  $http->queue("</th>");
  $http->queue("</tr>");
  for my $roi (@rois){
    my $rh = $self->{StructureSetAnalysis}->{rois}->{$roi};
    $http->queue("<tr>");
    $http->queue("<td>");
    $self->NotSoSimpleButton($http, {
      op => "SelectRoi",
      caption => $roi,
      roi_num => $roi,
      sync => "Reload();"
    });
    $http->queue("</td>");
    for my $i (@headers){
      if(exists $keys->{$i}){
        my $v = $rh->{$i};
        unless(defined $v) { $v = "" }
        $http->queue(
          "<td>$v</td>");
      }
    }
    my $num_referenced = keys %{$rh->{referencing_contours_by_reference}};
    $http->queue("<td>$num_referenced</td>");
    my $num_rendered = 0;
    if(exists $slices_rendered{$roi}){
      $num_rendered = $slices_rendered{$roi};
    }
    $http->queue("<td>$num_rendered</td>");
    $http->queue("<td>");
    if($num_referenced > 0 && $num_rendered < $num_referenced){
      $http->queue($self->CheckBoxDelegate("SelectedRoiForRendering", 0,
          $self->{SelectedRoiForRendering}->{$roi},
      { op => "SelectRoiBatch",
        sync => "Update();",
        roi =>$roi
      }));
    } elsif (exists($self->{SelectedRoiForRendering}->{$roi})) {
        delete $self->{SelectedRoiForRendering}->{$roi};
    } else {
      $self->NotSoSimpleButton($http, {
        op => "DisplayRoi",
        caption => "disp",
        roi_num => $roi,
        sync => "Reload();"
      });
    }
    $http->queue("</td>");
    $http->queue("<td>");
    if($num_referenced > 0 && $num_rendered == $num_referenced){
      $http->queue($self->CheckBoxDelegate("SelectedRoiForSeg", 0,
          $self->{SelectedRoiForSeg}->{$roi},
      { op => "SelectRoiBatch",
        sync => "Update();",
        roi => $roi
      }));
    } elsif (exists($self->{SelectedRoiForSeg}->{$roi})) {
        delete $self->{SelectedRoiForSeg}->{$roi};
    }
    $http->queue("</td>");
    $http->queue("</tr>");
  }
  $http->queue("</table>");
}

sub SelectRoiBatch{
  my($self, $http, $dyn) = @_;
  my $group = $dyn->{group};
  my $roi = $dyn->{roi};
  if($dyn->{checked} eq "true"){
    $self->{$group}->{$roi} = 1;
  } else {
    delete $self->{$group}->{$roi};
  }
}

sub ShowSeriesReport{
  my($self, $http, $dyn) = @_;
  if($dyn->{checked} eq "false"){
    $self->{show_series_report} = 0;
  } else {
    $self->{show_series_report} = 1;
  }
}

sub SsRefSeriesReport{
  my($self, $http, $dyn) = @_;
  my $num_series = keys %{$self->{StructureSetAnalysis}->{series_ref}};
  if($num_series == 0){
    $http->queue("<h4>No referenced series (yet)</h4>");
     return;
  }
  $http->queue("<h4>$num_series referenced series&nbsp;");
  $http->queue($self->CheckBoxDelegate("ShowSeriesReport", 0,
      $self->{show_series_report},
      { op => "ShowSeriesReport", sync => "Update();" }));
   
  $http->queue("&nbsp;show");
  $http->queue("</h4>");
  unless($self->{show_series_report}){ return }
  for my $series (keys %{$self->{StructureSetAnalysis}->{series_ref}}){
    my $sq = $self->{StructureSetAnalysis}->{series_ref}->{$series};
    $http->queue("<h5>Report for series $series</h5>");
    $http->queue("<pre>");
    $http->queue("$sq->{num_images} SOPs were found in the timepoint " .
      "for this series\n");
    my $num_reffed = keys %{$sq->{ref_img_list}};
      $http->queue("$num_reffed are referenced in the structure set\n");
    $http->queue("The following elements are consistent across all " .
      "SOPs:<ul>");
    my $first_sop = [keys %{$sq->{ref_img_list}}]->[0];
    my %inconsist_attrs;
    my $fsq = $sq->{img_list}->{$first_sop};
    for my $e (keys %{$sq->{attr_consistency}}){
      if($sq->{attr_consistency}->{$e} <= 1){
        my $v = $fsq->{$e};
        unless(defined $v) { $v = "&lt;undef&gt;" };
        $http->queue("<li>$e: $v</li>");
      } else {
        $inconsist_attrs{$e} = $sq->{attr_consistency}->{$e};
      }
    }
    $http->queue("</ul>");
    $http->queue("The following attrs have diffent values:<ul>");
    for my $e (keys %inconsist_attrs){
      $http->queue("<li>$e: $inconsist_attrs{$e} values</li>");
    }
    $http->queue("</ul>");
    $http->queue("</pre>");
    $http->queue("<h6>SOP report for SOPs in series $series</h6>");
    $http->queue("<table class=\"table table-striped\">");
    my @head = sort keys %inconsist_attrs;
    $http->queue("<tr>");
    for my $h (@head) { $http->queue("<th>$h</th>") }
    $http->queue("<th>num_rois</th>");
    $http->queue("</tr>");
    my $il = $sq->{img_list};
    for my $sop (
      sort
      {
        $il->{$a}->{instance_number} <=> $il->{$b}->{instance_number} ||
        $il->{$a}->{ipp} cmp $il->{$b}->{ipp}
      }
      keys %$il
    ){
      my $r = $il->{$sop};
      $http->queue("<tr>");
        for my $i (@head){
        if($i eq "sop_instance_uid"){
          $http->queue("<td>");
          $self->NotSoSimpleButton($http, {
            op => "SelectSop",
            caption => $r->{$i},
            sop_instance_uid => $r->{$i},
            sync => "Reload();",
          });
          $http->queue("</td>");
        } else {
          $http->queue("<td>$r->{$i}</td>");
        }
      }
      {
        my $num_sops = "N/A";
        if(
          exists($sq->{ref_img_list}->{$sop}) &&
          ref($sq->{ref_img_list}->{$sop}) eq "HASH"
        ){
          $num_sops = keys %{$sq->{ref_img_list}->{$sop}};
        }
        $http->queue("<td>$num_sops</td>");
        $http->queue("</tr>");
      }
    }
    $http->queue("</table>");
  }
}

sub SelectSop{
  my ($self, $http, $dyn) = @_;
  $self->{mode} = "show_selected_sop";
  my $sop = $dyn->{sop_instance_uid};
  $self->{SelectedSop} = $sop;
  $self->{SopContourAnalysis} = $self->BuildSopContourAnalysis($sop);
}

sub UnselectSop{
  my ($self, $http, $dyn) = @_;
  delete $self->{SelectedSop};
  delete $self->{SopContourAnalysis};
  $self->{mode} = "show_structure_data";
}

sub DisplaySelectedSop{
  my ($self, $http, $dyn) = @_;
  my $num_rois = keys %{$self->{SopContourAnalysis}};
  $http->queue("<h4>$num_rois Rois have contours on SOP " .
    "$self->{SelectedSop}</h4>");
  $http->queue("<table class=\"table table-striped\">");
  $http->queue("<tr>");
  my @headers = (
    "roi_num",
    "roi_name",
    "roi_obser_desc",
    "roi_obser_label",
    "roi_interpreted_type",
    "tot_contours",
    "tot_points",
  );
  for my $i (@headers){ $http->queue("<th>$i</th>") }
  $http->queue("</tr>");
  for my $roi (sort { $a <=> $b } keys %{$self->{SopContourAnalysis}}){
    my $rd = $self->{StructureSetAnalysis}->{rois}->{$roi};
    my $srd = $self->{SopContourAnalysis}->{$roi};
    $http->queue("<tr>");
    for my $i (@headers){
      if($i eq "roi_num"){
        $http->queue("<td>");
        $self->NotSoSimpleButton($http, {
          op => "SelectRoiWithSop",
          caption => "$roi",
          roi => $roi,
          sync => "Reload();"
        });
        $http->queue("</td>");
      }elsif($i eq "tot_contours"){
        my $tot_conts = @$srd;
        $http->queue("<td>$tot_conts</td>");
      }elsif($i eq "tot_points"){
        my $tot_pts = $self->CountPoints($srd);
        $http->queue("<td>$tot_pts</td>");
      } elsif(exists $rd->{$i}){
        $http->queue("<td>$rd->{$i}</td>");
      } else {
        $http->queue("<td>---</td>");
      }
    }
    $http->queue("</tr>");
  }
  $http->queue("</table>");
}

sub SelectRoiWithSop{
  my ($self, $http, $dyn) = @_;
  $self->{SelectedRoi} = $dyn->{roi};
  $self->{return_mode} = "show_selected_sop";
  $self->InitSelectedRoiAndSop();
}

sub SelectSopWithRoi{
  my ($self, $http, $dyn) = @_;
  $self->{SelectedSop} = $dyn->{sop};
  $self->{return_mode} = "show_selected_roi";
  $self->InitSelectedRoiAndSop();
}

sub GetSelectedSopData{
  my ($self, $sop) = @_;
  for my $series (keys %{$self->{StructureSetAnalysis}->{series_ref}}){
    if(
      exists $self->{StructureSetAnalysis}->{series_ref}->
        {$series}->{img_list}->{$sop}
    ){
      return $self->{StructureSetAnalysis}->{series_ref}
          ->{$series}->{img_list}->{$sop};
    }
  }
  return undef;
}

sub InitSelectedRoiAndSop{
  my ($self) = @_;
  $self->{mode} = "show_selected_roi_and_sop";
  $self->{SelectedSopData} = $self->GetSelectedSopData($self->{SelectedSop});
  delete $self->{SelectedSegmentationSliceFileId};
  Query('GetStructContoursToSegByRoiAndImageId')->RunQuery(sub{
    my($row) = @_;
    $self->{SelectedSegmentationSliceFileId} = $row->[8];
  }, sub {}, $self->{SelectedRoi}, $self->{SelectedSopData}->{file_id});
  $self->{SelectedContours} = [];
  my $rp = $self->{StructureSetAnalysis}->{rois}->{$self->{SelectedRoi}};
  my $clp = $rp->{referencing_contours_by_reference}->{$self->{SelectedSop}};
  for my $i (@$clp){
    my $h = {};
    $h->{offset} = $rp->{contours}->[$i]->{ds_offset} +
      $self->{data_set_start};
    $h->{length} = $rp->{contours}->[$i]->{length};
    $h->{num_points} = $rp->{contours}->[$i]->{num_pts};
    push(@{$self->{SelectedContours}}, $h);
  }
}

sub GetPngImage{
  my ($self, $http, $dyn) = @_;
  my $file;
  Query('GetFilePath')->RunQuery(sub{
    my($row) = @_;
    $file = $row->[0];
  }, sub {}, $dyn->{file_id});
  my $content_type = "image/png";
  $http->HeaderSent;
  $http->queue("HTTP/1.0 200 OK\n");
  $http->queue("Content-type: $content_type\n\n");
  open FILE, "<$file" or die "Can't open $file for reading ($!)";
  my $bytes_sent = 0;
  while(1){
    my $buff;
    my $count = read(FILE, $buff, 1024);
    if($count <= 0) { last }
    $http->queue($buff);
  }
  close FILE;
  $http->finish();
}

sub MakeThisOneBad{
  my ($self, $http, $dyn) = @_;
  my $img_file_id = $self->{SelectedSopData}->{file_id};
  my $roi_num = $self->{SelectedRoi};
  Query('GetStructContoursToSegByRoiAndImageIdAndStructFileId')->RunQuery(sub{
    my($row) = @_;
    Query('InsertBadStructContoursToSeg')->RunQuery(sub{}, sub{}, @$row);
    Query('DeleteStructContoursToSegByRoiAndImageIdAndStructFileId')->RunQuery(
      sub{}, sub{}, $roi_num,
      $img_file_id, $self->{file_id});
  }, sub {}, $roi_num, $img_file_id, $self->{file_id});
  $self->{StructureSetAnalysis}->{extracted_slice_images} = 
    $self->InitializeExtractedSlices();
}

sub DisplaySelectedRoiAndSop{
  my ($self, $http, $dyn) = @_;
  $self->{StructureSetAnalysis}->{extracted_slice_images} = 
    $self->InitializeExtractedSlices();
  {
    my $img_file_id = $self->{SelectedSopData}->{file_id};
    my $roi_num = $self->{SelectedRoi};
    if(
      exists $self->{StructureSetAnalysis}->
        {extracted_slice_images}->{$roi_num}->{$img_file_id}
    ){
      my $png_file_id = $self->{StructureSetAnalysis}->{extracted_slice_images}
        ->{$roi_num}->{$img_file_id}->{png_slice_file_id};
      $http->queue("<pre>Display PNG file $png_file_id here</pre>");
      $http->queue("<img src=\"GetPngImage?obj_path=$self->{path}" .
        "&file_id=$png_file_id\">");
   }
  }
  $http->queue("<h4>Selected roi: $self->{SelectedRoi}; " .
    "Selected SOP: $self->{SelectedSop}</h4>");
  $self->{ExtractedContours} = [];
  for my $i (0 .. $#{$self->{SelectedContours}}){
    my $c = $self->{SelectedContours}->[$i];
    my $cmd = "GetFilePart.pl \"$self->{file_path}\" " .
      "$c->{offset} $c->{length}";
    my $cont_txt = `$cmd`;
    my @nums = split /\\/, $cont_txt;
    my $num_n = @nums;
    unless (($num_n % 3) == 0){
      print STDERR "number of nums is not a multiple of three\n";
    }
    my $num_pts = $num_n / 3;
    my @pts;
    for my $j (0 .. $num_pts - 1){
      $pts[$j] = [$nums[$j * 3], $nums[($j * 3) + 1], $nums[($j * 3)+ 2]];
    }
    push @pts, $pts[0]; # close contour
    $self->{ExtractedContours}->[$i] = \@pts;
  }
  my $iop = [split /\\/, $self->{SelectedSopData}->{iop}];
  my $ipp = [split /\\/, $self->{SelectedSopData}->{ipp}];
  my $rows = $self->{SelectedSopData}->{pixel_rows};
  my $cols = $self->{SelectedSopData}->{pixel_columns};
  my $pix_sp = [split /\\/, $self->{SelectedSopData}->{pixel_spacing}];
  $self->{ConvertedContours} = [];
  for my $i (0 .. $#{$self->{ExtractedContours}}){
    for my $j (0 .. $#{$self->{ExtractedContours}->[$i]}){
      $self->{ConvertedContours}->[$i]->[$j] =
        Posda::FlipRotate::ToPixCoords($iop, $ipp, $rows, $cols, $pix_sp,
          $self->{ExtractedContours}->[$i]->[$j]);
    }
  }
  my @headers = ("Dicom x", "Dicom y", "Dicom z", "Pixel x",
   "Pixel y", "Pixel dist");
  $http->queue("<table class=\"table table-striped\">");
  $http->queue("<tr>");
  for my $i (@headers){
    $http->queue("<th>$i</th>");
  }
  $http->queue("</tr>");
  unless(
    exists($self->{SelectedContours}) && 
    ref($self->{SelectedContours}) eq "ARRAY"
  ) {
    $http->queue("</table> !!!!! No Selected Contours !!!!!");
    return;
  }
  selected_contour:
  for my $i (0 .. $#{$self->{SelectedContours}}){
    $http->queue("<tr><td colspan=6><hr></td></tr>");
    for my $j (0 .. $#{$self->{ExtractedContours}->[$i]}){
      $http->queue("<tr>");
      for my $k (@{$self->{ExtractedContours}->[$i]->[$j]}){
        $http->queue("<td>$k</td>");
      }
      for my $k (@{$self->{ConvertedContours}->[$i]->[$j]}){
        $http->queue("<td>$k</td>");
      }
      $http->queue("</tr>");
    }
  }
  $http->queue("</table>");
}

sub ExitDisplayRoiAndSop{
  my ($self, $http, $dyn) = @_;
  if($self->{return_mode} eq "show_selected_sop"){
    delete $self->{SelectedRoi};
    # further cleanup?
  } elsif($self->{return_mode} eq "show_selected_roi"){
    delete $self->{SelectedSop};
    # further cleanup?
  } else {
    print STDERR "In ExitDisplayRoiAndSop with mode $self->{mode}\n";
    return;
  }
  $self->{mode} = $self->{return_mode};
  delete $self->{return_mode};
}

sub CountPoints{
  my($self, $list) = @_;
  my $t = 0;
  for my $cont (@$list){ $t += $cont->{num_pts}}
  return $t;
}

sub CreateBitmap{
  my ($self, $http, $dyn) = @_;
  my $slice_file_path;
  my $cont_file_path;
  my $c_fhs;
  {
    my $t_fhs;
    ($c_fhs, $cont_file_path) = tempfile();
    ($t_fhs, $slice_file_path) = tempfile();
  }
  for my $c_cont (@{$self->{ConvertedContours}}){
    print $c_fhs "BEGIN\n";
    for my $p (@{$c_cont}){
      print $c_fhs "$p->[0],$p->[1]\n";
    }
    print $c_fhs "END\n";
  }
  close $c_fhs;

  my $cmd = "cat $cont_file_path | ContourToBitmapPixCoordsOnly.pl " .
     "$self->{SelectedSopData}->{pixel_rows} " .
     "$self->{SelectedSopData}->{pixel_columns} " .
     "\"$slice_file_path\"";
  open CMD, "$cmd|";
  my($total_ones, $total_zeros, $c_bytes, $c_ratio);
  while(my $line = <CMD>){
    chomp $line;
    if($line =~ /^total ones: (.*)$/){
      $total_ones = $1;
    }elsif($line =~ /^total zeros: (.*)$/){
      $total_zeros = $1;
    }elsif($line =~ /^bytes written: (.*)$/){
      $c_bytes = $1;
    }elsif($line =~ /^compression: (.*)$/){
      $c_ratio = $1;
    }
  }
  close CMD;
  $cmd = "cp $slice_file_path $self->{temp_path}/slice.cbmp";
  `$cmd`;
  $cmd = "cp $cont_file_path $self->{temp_path}/contours.txt";
  `$cmd`;
  $cmd = "cat $slice_file_path|CmdCtoPbm.pl " .
    "\"rows=$self->{SelectedSopData}->{pixel_rows}\" " .
    "\"cols=$self->{SelectedSopData}->{pixel_columns}\" " .
    ">$self->{temp_path}/current_slice.pbm";
  `$cmd`;
  $cmd = "convert $self->{temp_path}/current_slice.pbm " .
    "$self->{temp_path}/current_slice.png";
  `$cmd`;
  my $png_file_path = "$self->{temp_path}/current_slice.png";
  my $contour_slice_file_id;
  $cmd = "ImportSingleFileIntoPosdaAndReturnId.pl \"$cont_file_path\" " .
    "\"2D contours from SS ROI\"";
  my $res = `$cmd`;
  if($res =~ /File id: (.*)/){
    $contour_slice_file_id = $1;
  };
  my $segmentation_slice_file_id;
  $cmd = "ImportSingleFileIntoPosdaAndReturnId.pl \"$slice_file_path\" " .
    "\"Compressed Bitmap from 2D Contours\"";
  $res = `$cmd`;
  if($res =~ /File id: (.*)/){
    $segmentation_slice_file_id = $1;
  };
  my $png_slice_file_id;
  $cmd = "ImportSingleFileIntoPosdaAndReturnId.pl \"$png_file_path\" " .
    "\"Png from Compressed Bitmap\"";
  $res = `$cmd`;
  if($res =~ /File id: (.*)/){
    $png_slice_file_id = $1;
  };
  my $num_contours =  @{$self->{SelectedContours}};
  my $num_points = 0;
  for my $c (@{$self->{SelectedContours}}){
    $num_points += $c->{num_points};
  }
  unlink($cont_file_path);
  unlink($slice_file_path);
  unlink("$self->{temp_path}/slice.cbmp");
  unlink("$self->{temp_path}/contours.txt");
  unlink("$self->{temp_path}/current_slice.pbm");
  unlink("$self->{temp_path}/current_slice.png");
######
# here we need:
#   struct_set_file_id = $self->{file_id}
#   image_file_id = $self->{SelectedSopData}->{file_id}
#   roi_num = $self->{SelectedRoi}
#   rows = $self->{SelectedSopData}->{pixel_rows}
#   cols = $self->{SelectedSopData}->{pixel_cols}
#   num_contours = $num_contours
#   num_points = $num_points
#   total_one_bits = $total_ones
#   contour_slice_file_id = $contour_slice_file_id
#   segmenation_slice_file_id = $segmentation_slice_file_id
#   png_slice_file_id = $png_slice_file_id
#to create row in struct_contour_to_slice
  my @cols = (
    "structure_set_file_id",
    "image_file_id",
    "roi_num",
    "rows",
    "cols",
    "num_contours",
    "num_points",
    "total_one_bits",
    "contour_slice_file_id",
    "segmentation_slice_file_id",
    "png_slice_file_id",
  );
  my $existing_row;
  Query('GetStructContoursToSegByRoiAndImageIdAndStructFileId')->RunQuery(sub{
    my($row) = @_;
    $existing_row = $row;
  }, sub {},
    $self->{SelectedRoi}, 
    $self->{SelectedSopData}->{file_id},
    $self->{file_id}
  );
  unless(defined $existing_row){
    Query('InsertStructContoursToSeg')->RunQuery(sub{
    }, sub{}, 
      $self->{file_id},
      $self->{SelectedSopData}->{file_id},
      $self->{SelectedRoi},
      $self->{SelectedSopData}->{pixel_rows},
      $self->{SelectedSopData}->{pixel_columns},
      $num_contours,
      $num_points,
      $total_ones,
      $contour_slice_file_id,
      $segmentation_slice_file_id,
      $png_slice_file_id
    );
    $self->{StructureSetAnalysis}->{extracted_slice_images} = 
      $self->InitializeExtractedSlices();
    return;
  }
}

####################
# SopContourAnalysis
#$sca = {
#  roi_num => [
#    {
#      ds_offset => "86364"
#      length => "130"
#      num_pts => "6"
#      type => "CLOSED_PLANAR"
#    },
#  ],
#};
sub BuildSopContourAnalysis{
  my ($self, $sop) = @_;
  my %sca;
  my $rp = $self->{StructureSetAnalysis}->{rois};
  for my $roi (keys %$rp){
    my $rc = $rp->{$roi}->{contours};
    my $rr = $rp->{$roi}->{referencing_contours_by_reference};
    for my $s (keys %$rr){
      if($s eq $sop){
        for my $c (@{$rr->{$s}}){
          my $h = $rc->[$c];
          unless(exists $sca{$roi}){
            $sca{$roi} = [];
          }
          push @{$sca{$roi}}, $h;
        }
      }
    }
  }
  return \%sca;
}

sub MenuResponse {
  my ($self, $http, $dyn) = @_;
  if($self->{mode} eq "show_selected_roi"){
    $self->NotSoSimpleButton($http, {
       op => "UnselectRoi",
       caption => "Return",
       sync => "Reload();"
    });
  } elsif($self->{mode} eq "show_selected_sop"){
    $self->NotSoSimpleButton($http, {
       op => "UnselectSop",
       caption => "Return",
       sync => "Reload();"
    });
  } elsif($self->{mode} eq "show_selected_roi_and_sop"){
    $self->NotSoSimpleButton($http, {
       op => "ExitDisplayRoiAndSop",
       caption => "Return",
       sync => "Reload();"
    });
    if(defined $self->{SelectedSegFile}){
      $self->NotSoSimpleButton($http, {
         op => "RoundTripBitmap",
         caption => "Round Trip Bitmap",
         sync => "Reload();"
      });
    } else {
      $self->NotSoSimpleButton($http, {
         op => "CreateBitmap",
         caption => "Create Bitmap",
         sync => "Reload();"
      });
    }
  } else {
    $self->NotSoSimpleButton($http, {
       op => "ShowDicomDump",
       caption => "Show Dicom Dump",
       sync => "Update();"
    });
    $self->NotSoSimpleButton($http, {
       op => "ShowStructureInfo",
       caption => "Show Structure Info",
       sync => "Update();"
    });
  }
}

###########################################################
#Format of CrunchedStructureSetAnalysis:
#
#$self->{StructureSetAnalysis} = {
#  series_ref => {
#    <series_instance_uid> => {
#      num_images => <num_images>,
#      attr_consistency => { #consistency of attr across series
#        iop => 0 or 1 if consisent, > 1 if not,
#        ipp => 0 or 1 if consisent, > 1 if not,
#        pixel_spacing  => 0 or 1 if consisent, > 1 if not,
#        rows =>  0 or 1 if consisent, > 1 if not,
#        cols =>  0 or 1 if consisent, > 1 if not,
#        bits_allocated =>  0 or 1 if consisent, > 1 if not,
#        bits_stored =>  0 or 1 if consisent, > 1 if not,
#        high_bit =>  0 or 1 if consisent, > 1 if not,
#        photometric_interpretation => 0 or 1 if consisent, > 1 if not,
#        samples_per_pixel =>  0 or 1 if consisent, > 1 if not,
#        planar_configuration => 0 or 1 if consisent, > 1 if not,
#        for_uid => 0 or 1 if consisent, > 1 if not,
#        study_instance_uid => 0 or 1 if consisent, > 1 if not,
#      },
#      common_attrs => {
#        <attr_name> => <value>,
#        ...
#      },
#      img_list => {
#        <sop_instance_uid> = {
#          <attr_name> => <value>,
#          ...
#        },
#        ...
#      },
#      non_ref_img_list => {    # sops in series not referenced
#        <sop_instance_uid> => 1,
#        ...
#      },
#      ref_img_list => {        # sops in series referenced
#        <sop_instance_uid> => {
#          <roi> => 1,          # referencing roi
#          ...
#        },
#        ...
#      },
#      not_found_img_refs {     # sop references not found
#        <sop_instance_uid> => 1,
#        ...
#      },
#    },
#    rois => {
#      <roi_num> => {
#        color => [r,g,b],
#        contours => [
#          {
#            ds_offset => <dataset_offset>,
#            length => <length>,
#            num_pts => <num_points>,
#            ref => <sop_instance_uid>,
#            ref_type => <sop_class>,
#            type => <contour_type>,
#          },
#          ...
#        ],
#        gen_alg => <generation_algorithm>,
#        bounding_box => [[x,y,z],[x,y,z]],
#        ref_for => <for>,
#        roi_interpreted_type => <rot_interp_type>,
#        roi_name => <roi_name>
#        roi_obser_desc => <roi_obser_desc>,
#        roi_obser_label => <roi_obser_label>,
#        referencing_contours_by_reference=> {
#          <sop_instance_uid> => [
#            <contour_index>,
#            ...
#          ],
#          ...
#        },
#        un_referencing_contours => [
#          <contour_index>,
#        ],
#        tot_contours => <total_contours>
#        tot_points => <total_points>
#      },
#      ...
#    },
#    analysis_errors => {
#      <message>,
#      ...
#    },
#    extracted_slice_images => {
#      <roi_num> => {
#         <image_file_id> => {
#           rows => <rows>,
#           cols => <cols>,
#           num_contours => <num_contours>,
#           num_points => <num_points>,
#           total_one_bits => <total_one_bits>,
#           contour_slice_file_id => <contour_slice_file_id>,
#           segmentation_slice_file_id => <segmentation_slice_file_id>,
#           png_slice_file_id => <png_slice_file_id>,
#         },
#         ...
#      },
#      ...
#    },
#    <more to come>
#  },
#}
###########################################################
sub CrunchAnalysis{
  my($self, $analysis) = @_;
  for my $h (@{$analysis->{series_refs}}){
    my $series = $h->{ref_series};
    my %img_list;
    my $expected_study;
    my $expected_for;
    my %errors;
    my @q_cols = (
      "file_id",
      "series_instance_uid",
      "study_instance_uid",
      "sop_instance_uid",
      "instance_number",
      "modality",
      "dicom_file_type",
      "for_uid",
      "iop",
      "ipp",
      "pixel_data_digest",
      "samples_per_pixel",
      "pixel_spacing",
      "photometric_interpretation",
      "pixel_rows",
      "pixel_columns",
      "bits_allocated",
      "bits_stored",
      "high_bit",
      "pixel_representation",
      "planar_configuration",
      "number_of_frames",
    );
    Query('ReportForImageLinkageTestTpForSeries')->RunQuery(sub{
      my($row) = @_;
      my %q;
      for my $i (0 ..  $#q_cols){
        $q{$q_cols[$i]} = $row->[$i];
      }
      my $sop = $q{sop_instance_uid};
      if(exists $img_list{$sop}){
        $errors{"sop ($sop) apparently duplicated in series ($series)"} = 1;
      }
      $img_list{$sop} = \%q;
    }, sub{}, $self->{params}->{activity_id}, $series);
    $expected_study = $h->{ref_study};
    $expected_for = $h->{ref_for};
    $self->{StructureSetAnalysis} = {
      analysis_errors => \%errors,
      series_ref => {
        $series => {
          num_images => $h->{num_images},
          ref_img_list => {},
        },
      },
    };
#      ...
#      img_list => {
#        <sop_instance_uid> = {
#          <attr_name> => <value>,
#          ...
#        },
#        ...
#      },
#      non_ref_img_list => {    # sops in series not referenced
#        <sop_instance_uid> => 1,
#        ...
#      },
#      ref_img_list => {        # sops in series referenced
#        <sop_instance_uid> => 1,
#        ...
#        },
#        ...
#      not_found_img_refs {     # sop references not found
#        <sop_instance_uid> => 1,
#        ...
#      },
    my %ref_img_list;
    my %not_found_img_list;
    my %non_ref_img_list;
    my %ri;
    for my $i (@{$h->{img_list}}){
      $ri{$i} = 1;
    }
    for my $sop (keys %img_list){
      if(exists $ri{$sop}){
        $ref_img_list{$sop} = 1;
      } else {
        $non_ref_img_list{$sop} = 1;
      }
    }
    for my $sop (keys %ri){
      unless(exists $img_list{$sop}){
        $not_found_img_list{$sop} = 1;
      }
    }
    my $sq = $self->{StructureSetAnalysis}->{series_ref}->{$series};
    $sq->{ref_img_list} = \%ref_img_list;
    $sq->{img_list} = \%img_list;
    $sq->{non_refimg_list} = \%non_ref_img_list;
    $sq->{not_found_img_list} = \%not_found_img_list;
    my %att_values;
    for my $sop(keys %img_list){
      my $h = $img_list{$sop};
      for my $a (keys %$h){
        my $v = $h->{$a};
        unless(defined $v) { $v = ""}
        $att_values{$a}->{$v} = 1;
      }
    } 
    my %a_consist; 
    for my $a (keys %att_values){
      $a_consist{$a} = keys %{$att_values{$a}};
    }
    $sq->{attr_consistency} = \%a_consist;
    my %common_attrs;
    for my $a (keys %a_consist){
      if($a_consist{$a} == 1){
        $common_attrs{$a} = [ keys %{$att_values{$a}}]->[0];
      }
    }

    $sq->{common_attrs} = \%common_attrs;
#    rois => {
#      <roi_num> => {
#        color => [r,g,b],
#        gen_alg => <generation_algorithm>,
#        bounding_box => [[x,y,z],[x,y,z]],
#        ref_for => <for>,
#        roi_interpreted_type => <rot_interp_type>,
#        roi_name => <roi_name>
#        roi_obser_desc => <roi_obser_desc>,
#        roi_obser_label => <roi_obser_label>,
#        tot_contours => <total_contours>
#        tot_points => <total_points>
#      },
#      ...
#    },
    for my $roi_num(keys %{$analysis->{rois}}){
      my $irh = $analysis->{rois}->{$roi_num};
      my $roi = {
        color => $irh->{color},
        gen_alg => $irh->{gen_alg},
        bounding_box => [ [$irh->{min_x}, $irh->{max_y}, $irh->{min_z}],
          [$irh->{max_x}, $irh->{min_y}, $irh->{max_z}] ],
        ref_for => $irh->{ref_for},
        roi_interpreted_type => $irh->{roi_interpreted_type},
        roi_name => $irh->{roi_name},
        roi_obser_desc => $irh->{roi_obser_desc},
        roi_obser_label => $irh->{roi_obser_label},
        tot_contours => $irh->{tot_contours},
        tot_points => $irh->{tot_points},
      };
      $self->{StructureSetAnalysis}->{rois}->{$roi_num} = $roi;
#
#    <series_instance_uid> => {
#      ...
#      ref_img_list => {        # sops in series referenced
#        <sop_instance_uid> => {
#          <roi> => 1,          # referencing roi
#          ...
#        },
#        ...
#      },
#      ...
#    },
#    ...
#    rois => {
#      <roi_num> => {
#        contours => [
#          {
#            ds_offset => <dataset_offset>,
#            length => <length>,
#            num_pts => <num_points>,
#            ref => <sop_instance_uid>,
#            ref_type => <sop_class>,
#            type => <contour_type>,
#          },
#          ...
#        ],
#        referencing_contours_by_reference=> {
#          <sop_instance_uid> => [
#            <contour_index>,
#            ...
#          ],
#          ...
#        },
#        un_referencing_contours => [
#          <contour_index>,
#        ],
#      },
#      ...
#    },
      my $ril = 
        $self->{StructureSetAnalysis}->{series_ref}->{$series}->{ref_img_list};
      $roi->{contours} = $irh->{contours};
      for my $cont_idx (0 .. $#{$irh->{contours}}){
        my $c = $irh->{contours}->[$cont_idx];
        if(defined($c->{ref})){
          my $rsop = $c->{ref};
          unless(exists $roi->{referencing_contours_by_reference}->{$rsop}){
            $roi->{referencing_contours_by_reference}->{$rsop} = [];
          }
          unless(exists $ril->{$rsop}){
            my $mess = "$rsop is referenced in roi hierarchy, not in file " .
              "hierarchy.";
            $self->{StructureSetAnalysis}->{analysis_errors}->{$mess} = 1;
            $ril->{$rsop} = {};
          }
          unless(ref($ril->{$rsop}) eq "HASH"){ $ril->{$rsop} = {} }
          $ril->{$rsop}->{$roi_num} = 1;
          push @{$roi->{referencing_contours_by_reference}->{$rsop}}, $cont_idx;
        } else {
          unless(exists $roi->{unreferenced_contours}){
            $roi->{referencing_contours_by_reference} = [];
          }
          push @{$roi->{referencing_contours_by_reference}}, $cont_idx;
        }
      }
    }
  } 
  $self->{StructureSetAnalysis}->{extracted_slice_images} = 
    $self->InitializeExtractedSlices();
}
sub InitializeExtractedSlices{
  my($self) = @_;
print STDERR "In InitializeExtractedSlices\n";
#    },
#    extracted_slice_images => {
#      <roi_num> => {
#         <image_file_id> => {
#           rows => <rows>,
#           cols => <cols>,
#           num_contours => <num_contours>,
#           num_points => <num_points>,
#           total_one_bits => <total_one_bits>,
#           contour_slice_file_id => <contour_slice_file_id>,
#           segmentation_slice_file_id => <segmentation_slice_file_id>,
#           png_slice_file_id => <png_slice_file_id>,
#         },
#         ...
#      },
#      ...
#    },
#    ...
  my @cols = (
    "structure_set_file_id",
    "image_file_id",
    "roi_num",
    "rows",
    "cols",
    "num_contours",
    "num_points",
    "total_one_bits",
    "contour_slice_file_id",
    "segmentation_slice_file_id",
    "png_slice_file_id",
  );
  my %h;
  Query('GetStructContoursToSegByStructId')->RunQuery(sub{
    my($row) = @_;
    my $img_fid = $row->[1];
    my $roi_num = $row->[2];
    for my $i (3 .. $#cols){
      my $k = $cols[$i];
      my $v = $row->[$i];
      $h{$roi_num}->{$img_fid}->{$k} = $v;
    }
  }, sub {}, $self->{file_id});
  return \%h;
}

sub RenderSelectedRoiContours{
  my($self, $http, $dyn) = @_;
    my $class = "Posda::FileVisualizer::StructureSet::BulkRenderRoiSlices";
    eval "require $class";
    if($@){
      print STDERR "$class failed to compile\n\t$@\n";
      return;
    }
    unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
    my $name = "Render_$self->{sequence_no}";
    $self->{sequence_no}++;
    my $params = {
      Rois => $self->{StructureSetAnalysis}->{rois},
      Series => $self->{StructureSetAnalysis}->{series_ref},
      file_id => $self->{file_id},
      file_path => $self->{file_path},
      activity_id => $self->{params}->{activity_id},
      notify => $self->{params}->{notify}
    };
    for my $k (keys %{$self->{SelectedRoiForRendering}}){
      $params->{SelectedRoi}->{$k} = 1;
      for my $file_id (
        keys %{$self->{StructureSetAnalysis}->{extracted_slice_images}->{$k}}
      ){
        my $sop = $self->FileIdToSop($file_id);
        if(defined $sop){
          $params->{AlreadyRendered}->{$k}->{$sop} = 1;
        }
      }
    }
    my $child_path = $self->child_path($name);
    my $child_obj = $class->new($self->{session},
                              $child_path, $params);
    $self->StartJsChildWindow($child_obj);
    return;
}

sub DisplayRoi{
  my($self, $http, $dyn) = @_;
  my $params = {
    roi_num => $dyn->{roi_num},
    ss_file_id => $self->{file_id},
    file_sort => $self->{StructureSetAnalysis}->{file_sort},
    tmp_dir => $self->{temp_path},
    file_to_instance => $self->{FileToInstance}
  };
#  my $class = "Posda::FileVisualizer::ImageDisplayer";
  my $class = "Posda::HttpApp::SimplifiedImageDisp";
  eval "require $class";
  if($@){
    print STDERR "Class failed to compile\n\t$@\n";
    return;
  }

  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  my $name = "$self->{name}" . "_$self->{sequence_no}";
  $self->{sequence_no} += 1;

  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);
}

sub MakeSegmentationFile{
  my($self, $http, $dyn) = @_;
  my $params = {
    ss_file_id => $self->{file_id},
    rois => {},
    image_files => {},
    sops => {},
    all_file_sort => $self->{StructureSetAnalysis}->{file_sort}
  };
  my %ref_img;
  my $f_rois = $self->{StructureSetAnalysis}->{rois};
  my $t_rois = $params->{rois};
  roi:
  for my $i (keys %$f_rois){
    unless(exists $self->{SelectedRoiForSeg}->{$i}){ next roi }
    $t_rois->{$i} = {
      color => $f_rois->{$i}->{color},
      ref_for => $f_rois->{$i}->{ref_for},
      roi_interpreted_type => $f_rois->{$i}->{roi_interpreted_type},
      roi_name => $f_rois->{$i}->{roi_name},
      roi_obser_desc => $f_rois->{$i}->{roi_obser_desc},
      roi_label => $f_rois->{$i}->{roi_obser_label},
    };
    for my $sop (keys %{$f_rois->{$i}->{referencing_contours_by_reference}}){
      my $ser_p = $self->{StructureSetAnalysis}->{series_ref};
      for my $series (keys %$ser_p){
        if(exists $ser_p->{$series}->{img_list}->{$sop}){
          my $file_id = $ser_p->{$series}->{img_list}->{$sop}->{file_id};
          $params->{image_files}->{$file_id} =
            $ser_p->{$series}->{img_list}->{$sop};
          $params->{sops}->{$sop} = $file_id;
        }
      }
    }
  }
  my $class = "Posda::FileVisualizer::StructureSet::MakeSegmentation";
  eval "require $class";
  if($@){
    print STDERR "Class failed to compile\n\t$@\n";
    return;
  }

  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  my $name = "$self->{name}" . "MakeSeg_$self->{sequence_no}";
  $self->{sequence_no} += 1;

  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);

}

sub FileIdToSop{
  my($self, $file_id) = @_;
  for my $series (keys %{$self->{StructureSetAnalysis}->{series_ref}}){
    my $i_list = 
      $self->{StructureSetAnalysis}->{series_ref}->{$series}->{img_list};
    for my $sop (keys %{$i_list}){
      if($i_list->{$sop}->{file_id} == $file_id) { return $sop }
    }
  }
  return undef;
}

sub SortFilesByOffset{
  my ($self) = @_;
  my %file_offset_info;
  my $iop;
  my $file_list;
  # also - construct file_to_instance
  $self->{FileToInstance} = {};
  for my $ser (keys %{$self->{StructureSetAnalysis}->{series_ref}}){
    my $img_list = 
      $self->{StructureSetAnalysis}->{series_ref}->{$ser}->{img_list};
    for my $sop (keys %{$img_list}){
      my $f_info = $img_list->{$sop};
      my $file_id = $f_info->{file_id};
      $file_list->{$file_id} = $f_info;
      $self->{FileToInstance}->{$file_id} = $f_info->{instance_number};
    }
  }
  file:
  for my $f_id (keys %{$file_list}){
    my $f_info = $file_list->{$f_id};
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

  for my $i (keys %file_offset_info){
    my $off_info = $file_offset_info{$i};
    $off_info->{z_diff} = $off_info->{rot_ipp}->[2] - $min_z;
    $off_info->{x_diff} = $off_info->{rot_ipp}->[0] - $avg_x;
    $off_info->{y_diff} = $off_info->{rot_ipp}->[1] - $avg_y;
  }
  $self->{StructureSetAnalysis}->{file_sort} = [];
  for my $f (
    sort {
      $file_offset_info{$a}->{z_diff} <=> $file_offset_info{$b}->{z_diff}
    }
    keys %file_offset_info
  ){
    push @{$self->{StructureSetAnalysis}->{file_sort}}, {
      file_id => $f,
      offset => $file_offset_info{$f}->{z_diff},
      x_diff => $file_offset_info{$f}->{x_diff},
      y_diff => $file_offset_info{$f}->{y_diff},
    };
  }
}

1;
