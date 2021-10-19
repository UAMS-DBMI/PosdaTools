package Posda::FileVisualizer::RtDose;
use strict;

use Posda::PopupWindow;
use Posda::DB qw( Query );
use Posda::Try;
use Posda::FlipRotate;
use Digest::MD5;
use Dispatch::LineReader;
use File::Temp qw/ tempfile /;


use vars qw( @ISA );
@ISA = ("Posda::FileVisualizer");

sub SpecificInitialize {
  my ($self) = @_;
  $self->{title} = "Generic Rt Dose Visualizer";
  $self->{is_RtDose} = 1;
  $self->GatherDoseInfo();
  $self->{mode} = "show_dose_data";
  $self->{params}->{notify} = $self->get_user;
}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  if($self->{mode} eq "show_dicom_dump"){
    return $self->DisplayDicomDump($http,$dyn);
  } elsif ($self->{mode} eq "show_dose_data"){
    return $self->DisplayDoseData($http,$dyn);
  } else{
    $http->queue("Unknown mode $self->{mode}");
  }
}

sub GatherDoseInfo{
  my($self) = @_;
  $self->{struct_analysis_status} = 'Analysis of DICOM in progress';
  $self->SemiSerializedSubProcess("DicomInfoAnalyzer.pl $self->{file_path}",
    $self->HandleDoseInfo);
}

sub HandleDoseInfo{
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

sub CrunchAnalysis{
  my($self, $analysis) = @_;
  $self->{RtDoseAnalysis}->{dvhs} = $analysis->{dvhs};
  $self->{RtDoseAnalysis}->{ref_ss} = $analysis->{ref_ss};
  Query('GetFromToFileForSopActivity')->RunQuery(sub {
    my($row) = @_;
    $self->{RtDoseAnalysis}->{ref_ss_file_id} = $row->[0];
    $self->{RtDoseAnalysis}->{ref_ss_file_path} = $row->[1];
  }, sub {}, $analysis->{ref_ss}, $self->{params}->{activity_id});
  $self->{RtDoseAnalysis}->{ds_offset} = $analysis->{dataset_start_offset};
  $self->{RtDoseAnalysis}->{dose_grid_analysis} = {};
  my $dga = $self->{RtDoseAnalysis}->{dose_grid_analysis};
  $dga->{bounding_box} = $analysis->{DoseBoundingBox};
  $dga->{rows} = $analysis->{"(0028,0010)"};
  $dga->{cols} = $analysis->{"(0028,0011)"};
  $dga->{frames} = $analysis->{"(0028,0008)"};
  $dga->{bits_alloc} = $analysis->{"(0028,0100)"};
  $dga->{iop} = [ split (/\\/, $analysis->{"(0020,0037)"}) ];
  $dga->{ipp} = [ split (/\\/, $analysis->{"(0020,0032)"}) ];
  $dga->{gfov} = [ split (/\\/, $analysis->{"(3004,000c)"}) ];
  $dga->{pix_sp} = [ split (/\\/, $analysis->{"(0028,0030)"}) ];
  $dga->{dose_units} = $analysis->{"(3004,0002)"};
  $dga->{dose_type} = $analysis->{"(3004,0004)"};
  $dga->{dose_summation_type} = $analysis->{"(3004,000a)"};
  $dga->{dose_grid_scaling} = $analysis->{"(3004,000e)"};
  $dga->{tissue_heterogeneity_correction} = $analysis->{"(3004,0014)"};
  $dga->{pixel_position} = $analysis->{pix_pos};
  $dga->{pixel_length} = $analysis->{pixel_length};
  $dga->{max_dose} = $analysis->{max_dose_in_Gy};
  $dga->{min_dose} = $analysis->{min_dose_in_Gy};
  $dga->{z_of_max_dose} = $analysis->{max_dose_at_z};
  $dga->{frame_of_ref} = $analysis->{for_uid};
}

sub DisplayDoseData{
  my($self, $http, $dyn) = @_;
  $http->queue("<div id=\"DoseGridReport\">");
  $self->DoseGridReport($http, $dyn);
  $http->queue("</div>");
  $http->queue("<div id=\"DvhReport\">");
  $self->DvhReport($http, $dyn);
  $http->queue("</div>");
}

sub DoseGridReport{
  my($self, $http, $dyn) = @_;
  unless(exists $self->{RtDoseAnalysis}->{dose_grid_analysis}){
    $http->queue("<h4>No Dose Grid Analysis (yet)</h4>");
    return;
  }
  $http->queue("<h4>DoseGridAnalysis&nbsp;");
  $http->queue($self->CheckBoxDelegate("ShowDoseGridReport", 0,
      $self->{show_dose_grid_report},
      { op => "ShowDoseGridReport", sync => "Update();" }
    )
  );
  $http->queue("&nbsp;show");
  $http->queue("</h4>");
  unless($self->{show_dose_grid_report}){ return }
  $http->queue("Coming soon");
}

sub ShowDoseGridReport{
  my($self, $http, $dyn) = @_;
  if($dyn->{checked} eq "false"){
    $self->{show_dose_grid_report} = 0;
  } else {
    $self->{show_dose_grid_report} = 1;
  }
}

sub ShowRelatedStruct{
  my($self, $http, $dyn) = @_;
  my $params = {
    file_id => $self->{RtDoseAnalysis}->{ref_ss_file_id},
    activity_id => $self->{params}->{activity_id}
  };
  my $class = "Posda::FileVisualizer";
  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  my $name = "$self->{name}" . "RelStruct_$self->{sequence_no}";
  $self->{sequence_no} += 1;

  my $child_path = $self->child_path($name);
  my $child_obj = $class->new($self->{session},
                              $child_path, $params);
  $self->StartJsChildWindow($child_obj);

}

sub DvhReport{
  my($self, $http, $dyn) = @_;
  unless(exists $self->{RtDoseAnalysis}->{dvhs}){
    $http->queue("<h4>No DVH Analysis (yet)</h4>");
    return;
  }
  $self->ObtainRoiNames($self->{RtDoseAnalysis}->{ref_ss_file_id});
  my $num_dvhs = @{$self->{RtDoseAnalysis}->{dvhs}};
  if($num_dvhs == 0){
    $http->queue("<h4>No DVHs to in Dose</h4>");
    return;
  }
  $http->queue("<h4>$num_dvhs DVHs found&nbsp;");
  $http->queue($self->CheckBoxDelegate("ShowDvhReport", 0,
      $self->{show_dvh_report},
      { op => "ShowDvhReport", sync => "Update();" }
    )
  );
  $http->queue("&nbsp;show");
  $http->queue("</h4>");
  unless($self->{show_dvh_report}){ return }
  $http->queue("<p>Referenced SS: $self->{RtDoseAnalysis}->{ref_ss}" .
    "&nbsp;");
  if(exists $self->{RtDoseAnalysis}->{ref_ss_file_id}){
    $self->NotSoSimpleButton($http, {
       op => "ShowRelatedStruct",
       caption => "view",
       sync => "Update();"
    });
  } else {
    $http->queue("(not in activity)");
  }
  $http->queue("</p>");
  my @tab_cols = ("Sel", "Inc Rois", "Excluded Rois", "DVH type",
    "DoseType", "Dose Units", "Max Dose", "Min Dose",
    "Vol Units", "Dose Scaling", "Num Bins");
  $http->queue("<table class=\"table table-striped\"><tr>");
  for my $h (@tab_cols){
    $http->queue("<th>$h</th>");
  }
  $http->queue("<th>");
  $self->DownloadDvhButton($http, {type => "Selected"});
  $http->queue("</th></tr>");
  for my $i (0 .. $#{$self->{RtDoseAnalysis}->{dvhs}}){
    my $dvh = $self->{RtDoseAnalysis}->{dvhs}->[$i];
    my @included;
    my @excluded;
    for my $d (@{$dvh->{rois}}){
      if($d->{type} eq "INCLUDED"){
        push(@included, $d->{num});
      } elsif ($d->{type} eq "EXCLUDED"){
        push(@excluded, $d->{num});
      }
    }
    $http->queue("<tr>");
    unless(exists $self->{SelectedDvh}){
      $self->SelectDvh($http, { value => 0 });
    }
    for my $c (@tab_cols){
      $http->queue("<td>");
      if($c eq "Inc Rois"){
        for my $j (0 .. $#included){
          unless($j == 0){ $http->queue(", ") }
          $http->queue("$included[$j]");
        }
      } elsif($c eq "Excluded Rois"){
        for my $j (0 .. $#excluded){
          unless($j == 0){ $http->queue(", ") }
          $http->queue("$excluded[$j]");
        }
      } elsif($c eq "DVH type"){
        $http->queue($dvh->{type})
      } elsif($c eq "DoseType"){
        $http->queue($dvh->{dose_type})
      } elsif($c eq "Dose Units"){
        $http->queue($dvh->{dose_units})
      } elsif($c eq "Max Dose"){
        $http->queue($dvh->{max_dose})
      } elsif($c eq "Min Dose"){
        $http->queue($dvh->{min_dose})
      } elsif($c eq "Vol Units"){
        $http->queue($dvh->{vol_units})
      } elsif($c eq "Dose Scaling"){
        $http->queue($dvh->{dose_scaling})
      } elsif($c eq  "Num Bins"){
        $http->queue($dvh->{num_bins})
      } elsif($c eq  "Sel"){
        $http->queue($self->CheckBoxDelegate("Dvh", "$i",
        $self->{SelectedDvh} == $i ? 1: 0,
        { op => "SelectDvh",
          sync => "Update();" }));
        $http->queue("</td>");
      }
      $http->queue("</td>");
    }
    $http->queue("<td>");
    my $roi_num = $included[0];
    my $roi_name = $self->{RtDoseAnalysis}->{roi_names}->{$roi_num};
    $http->queue($self->CheckBoxDelegate("IncludedDvh", "$i",
    $self->{IncludedDvh}->{$i} eq 'true' ? 1: 0,
     { op => "IncludeDvh",
       sync => "Update();" }));
    if(defined $roi_name){
      $http->queue($roi_name);
    }else{
      $http->queue("--");
    }
    $http->queue("</td>");
    $http->queue("</tr>");
  }
  if(exists $self->{SelectedDvhData}){
    $http->queue("</table>");
    $self->DownloadDvhButton($http, {type => "Single"});
    $http->queue("<table class=\"table\"><tr>");
    $http->queue("<th>bin width</th><th>volume</th>" .
      "<th>percent volume</th><th>has dose greater than or equal</th>" .
      "</tr>");
    my $tot_area = $self->{SelectedDvhData}->[1];
    my $cum_dose = 0;
    for my $i (0 .. $#{$self->{SelectedDvhData}}/2){
      my $bw = $self->{SelectedDvhData}->[$i * 2];
      my $area = $self->{SelectedDvhData}->[($i * 2) + 1];
      $http->queue("<tr><td>$bw</td>");
      $http->queue("<td>$area</td>");
      my $low = sprintf("%3.2f", $cum_dose);
      my $high = $cum_dose + $bw;
      $cum_dose = $high;
      my $percent = ($area / $tot_area) * 100;
      $http->queue("<td>$percent</td><td>$low</td></tr>");
    }
    $http->queue("</table>");
  }
}

sub DownloadDvhButton{
  my($self, $http, $dyn) = @_;
  $http->queue("<a class=\"btn btn_primary\" " .
    "href=\"DownloadDvh?obj_path=$self->{path}&type=$dyn->{type}\">" .
    "Download</a>");
}

sub DownloadDvh{
  my($self, $http, $dyn) = @_;
  my $type = $dyn->{type};
  if($type eq "Single"){
    $self->DownloadSingleDvh($http, $dyn);
  } elsif($type eq "Selected"){
    $self->DownloadSelectedDvhs($http, $dyn);
  }
  print STDERR "Unknown type: $type in DownloadDvh\n";
}
sub DownloadSelectedDvhs{
  my($self, $http, $dyn) = @_;
  $http->DownloadHeader("text/csv", "Dvh_sel_Dose_$self->{file_id}.csv");
  my %dvh_data;
  for my $i (keys %{$self->{IncludedDvh}}){
    if($self->{IncludedDvh}->{$i} eq "true"){
      my $j = $self->{RtDoseAnalysis}->{dvhs}->[$i]->{rois}->[0]->{num};
      my $h = {
        name => $self->{RtDoseAnalysis}->{roi_names}->{$j},
        dvh_data => $self->GetDvhData($i)
      };
      $dvh_data{$i} = $h;
    }
  }
  $http->queue("Dose (mGy),");
  my @keys = sort keys %dvh_data;
  my $max_rows;
  for my $i (0 .. $#keys){
    my $k = $keys[$i];
    $dvh_data{$k}->{tot_vol} = $dvh_data{$k}->{dvh_data}->[1];
    my $num_rows = ($#{$dvh_data{$k}->{dvh_data}} - 1) / 2;
    $dvh_data{$k}->{num_rows} = $num_rows;
    unless(defined $max_rows){ $max_rows = $num_rows }
    if($num_rows > $max_rows){ $max_rows = $num_rows }
    $http->queue("$dvh_data{$k}->{name},");
  }
  for my $i (0 .. $#keys){
    my $k = $keys[$i];
    $http->queue("$dvh_data{$k}->{name}");
    if($i == $#keys){
      $http->queue("\n");
    } else {
      $http->queue(", ");
    }
  }
  $http->queue(",");
  for my $i (0 .. $#keys){
    $http->queue("Tot Vol,");
  }
  for my $i (0 .. $#keys){
    $http->queue("Per Cent Vol");
    if($i == $#keys){
      $http->queue("\n");
    } else {
      $http->queue(", ");
    }
  }
  my $dose = 0;
  for my $i (0  .. $max_rows){
    $dose += 0.1;
    my $dose_t = sprintf("%1.2f", $dose);
    $http->queue("$dose_t,");
    for my $j (0 .. $#keys){
      my $k = $keys[$j];
      if($dvh_data{$k}->{num_rows} >= $i) {
        $http->queue($dvh_data{$k}->{dvh_data}->[($i * 2)+1]);
      }
      $http->queue(",");
    }
    for my $j (0 .. $#keys){
      my $k = $keys[$j];
      if($dvh_data{$k}->{num_rows} >= $i) {
        my $tot_vol = $dvh_data{$k}->{tot_vol};
        my $vol = $dvh_data{$k}->{dvh_data}->[($i * 2)+1];
        my $percent = sprintf("%3.4f", ($vol/$tot_vol)*100);
        $http->queue($percent);
      }
      if($j eq $#keys){
        $http->queue("\n");
      } else {
        $http->queue(",");
      }
    }
  }
  $self->{DebugSelectedDvhs} = \%dvh_data;
}
sub GetDvhData{
  my($self, $dvh_index) = @_;
  my $dvh_struct = $self->{RtDoseAnalysis}->{dvhs}->[$dvh_index];
  my $file_offset = $dvh_struct->{file_pos};
  my $length = $dvh_struct->{file_len};
  my $cmd = "GetFilePart.pl \"$self->{file_path}\" $file_offset $length";
  my $dvh_txt = `$cmd`;
  my $dvh_data = [ split(/\\/, $dvh_txt) ];
}
sub DownloadSingleDvh{
  my($self, $http, $dyn) = @_;
  my $dvh_desc = $self->{RtDoseAnalysis}->{dvhs}->[$self->{SelectedDvh}];
  my $rois = $dvh_desc->{rois};
  my $rtext = "_";
  my $roi_num;
  for my $i (0 .. $#$rois){
    my $r =$rois->[$i];
    $rtext .= "$r->{type}:$r->{num}";
    if($i == $#{$rois}){
     $rtext .= "_";
    } else {
     $rtext .= "_";
    }
    $roi_num = $r->{num};
  }
#  $http->DownloadHeader("text/csv", "Dvh_$roi_num" . "_Dose_$self->{file_id}.csv");
  $http->DownloadHeader("text/csv", "Dvh_$rtext" . "_Dose_$self->{file_id}.csv");
  print STDERR "################\n" .
    "Dvh_$rtext" . "_Dose_$self->{file_id}.csv\n" .
    "################\n";
  
  $http->queue("bin width, value, percent area, has dose greater than or equal\n");
    my $tot_area = $self->{SelectedDvhData}->[1];
    my $cum_dose = 0;
    for my $i (0 .. $#{$self->{SelectedDvhData}}/2){
      my $bw = $self->{SelectedDvhData}->[$i * 2];
      my $area = $self->{SelectedDvhData}->[($i * 2) + 1];
      $http->queue("$bw, ");
      $http->queue("$area, ");
      my $low = sprintf("%3.2f", $cum_dose);
      my $high = $cum_dose + $bw;
      $cum_dose = $high;
      my $percent = ($area / $tot_area) * 100;
      $http->queue("$percent, $low\n");
    }
}

sub IncludeDvh{
  my($self, $http, $dyn) = @_;
  $self->{IncludedDvh}->{$dyn->{value}} = $dyn->{checked};;
}

sub SelectDvh{
  my($self, $http, $dyn) = @_;
  $self->{SelectedDvh} = $dyn->{value};
  $self->{SelectedDvhStruct} = $self->{RtDoseAnalysis}->{dvhs}->[$dyn->{value}];
  $self->LoadSelectedDvh($http, $dyn);
}

sub LoadSelectedDvh{
  my($self, $http, $dyn) = @_;
#  my $file_offset = $self->{RtDoseAnalysis}->{ds_offset} +
#    $self->{SelectedDvhStruct}->{file_pos};
  my $file_offset = $self->{SelectedDvhStruct}->{file_pos};
  my $length = $self->{SelectedDvhStruct}->{file_len};
  my $cmd = "GetFilePart.pl \"$self->{file_path}\" $file_offset $length";
  my $dvh_txt = `$cmd`;
  $self->{SelectedDvhData} = [ split(/\\/, $dvh_txt) ];
}

sub ShowDvhReport{
  my($self, $http, $dyn) = @_;
  if($dyn->{checked} eq "false"){
    $self->{show_dvh_report} = 0;
  } else {
    $self->{show_dvh_report} = 1;
  }
}

sub ShowDoseData{
  my ($self, $http, $dyn) = @_;
  $self->{mode} = "show_dose_data";
}

sub MenuResponse {
  my ($self, $http, $dyn) = @_;
  if($self->{mode} eq "show_dose_data"){
    $self->NotSoSimpleButton($http, {
       op => "ShowDicomDump",
       caption => "ShowDicomDump",
       sync => "Reload();"
    });
  } else {
    $self->NotSoSimpleButton($http, {
       op => "ShowDoseData",
       caption => "Show Dose Data",
       sync => "Update();"
    });
  }
}
sub ObtainRoiNames{
  my($self, $ss_file_id) = @_;
  my %roi_names;
  Dispatch::LineReader->new_cmd("GetRoiNames.pl $ss_file_id",
    $self->HandleRoiLine(\%roi_names),
    $self->RoiComplete(\%roi_names)
  );
}
sub HandleRoiLine{
  my($self, $rois) = @_;
  my $sub = sub {
    my $line = shift;
    chomp $line;
    my ($num, $name) = split (/:/, $line);
    $rois->{$num} = $name;
  };
  return $sub;
}
sub RoiComplete{
  my($self, $rois) = @_;
  my $sub = sub {
    $self->{RtDoseAnalysis}->{roi_names} = $rois;
  };
  return $sub;
}

1;
