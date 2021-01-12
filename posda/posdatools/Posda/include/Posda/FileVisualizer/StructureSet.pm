package Posda::FileVisualizer::StructureSet;
use strict;

use Posda::PopupWindow;
use Posda::DB qw( Query );
use Posda::Try;
use Digest::MD5;


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
  my @headers = ("roi_num", "roi_name", "roi_obser_desc",
    "roi_obser_label", "roi_interpreted_type",
    "tot_contours", "tot_points", "num_sops_referenced");
  $http->queue("<table class=\"table table-striped\">");
  $http->queue("<tr>");
  for my $i (@headers){
    $http->queue("<th>$i</th>");
  }
  $http->queue("</tr>");
  for my $roi (@rois){
    my $rh = $self->{StructureSetAnalysis}->{rois}->{$roi};
    $http->queue("<tr>");
    $http->queue("<td>$roi</td>");
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
    $http->queue("</tr>");
  }
  $http->queue("</table>");
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
        $http->queue("<td>$r->{$i}</td>");
      }
    $http->queue("</tr>");
    }
    $http->queue("</table>");
  }
}

sub MenuResponse {
  my ($self, $http, $dyn) = @_;
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
#      ref_img_list => {        # sops in series not referenced
#        <sop_instance_uid> => 1,
#        ...
#        },
#        ...
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
      errors => \%errors,
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
#      ref_img_list => {        # sops in series not referenced
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
      $roi->{contours} = $irh->{contours};
      for my $cont_idx (0 .. $#{$irh->{contours}}){
        my $c = $irh->{contours}->[$cont_idx];
        if(defined($c->{ref})){
          unless(exists $roi->{referencing_contours_by_reference}->{$c->{ref}}){
            $roi->{referencing_contours_by_reference}->{$c->{ref}} = [];
          }
          push @{$roi->{referencing_contours_by_reference}->{$c->{ref}}},
            $cont_idx;
        } else {
          unless(exists $roi->{unreferenced_contours}){
            $roi->{referencing_contours_by_reference} = [];
          }
          push @{$roi->{referencing_contours_by_reference}}, $cont_idx;
        }
      }
    }
  } 
}  
1;
