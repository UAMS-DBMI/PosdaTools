#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/FileDist/include/FileDist/StructLinkVal.pm,v $
#$Date: 2014/09/30 20:54:15 $
#$Revision: 1.5 $
#
use strict;
use Posda::HttpApp::GenericMfWindow;
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::SubController;
use Posda::HttpApp::WindowButtons;
use Posda::Dataset;
use FileDist::ShowFile;
my $header = <<EOF;
<table style="width:100%" summary="window header">
  <tr>
    <td valign="top" align="left" width="160">
      <?dyn="Logo"?>
    </td>
    <td valign="top">
      <h2>File Distribution Application</h2>
      <h3><?dyn="title"?></h3>
      </td>
    <td valign="top" align="right" width="180" height="120">
<?dyn="iframe" height="0" width="0" style="visibility:hidden;display:none" child_path="Controller"?>
<?dyn="iframe" frameborder="0" height="100%" child_path="WindowButtons"?>
    </td>
  </tr>
</table>
<?dyn="iframe" height="768" child_path="Content"?>
EOF
{
  package FileDist::StructLinkVal;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericMfWindow" );
  sub new {
    my($class, $sess, $path, $series, $info, $summary) = @_;
    my $this = Posda::HttpApp::GenericMfWindow->new($sess, $path);
    $this->{title} = "Validate Structure Set Linkages";
    bless $this, $class;
    $this->{w} = 1024;
    $this->{h} = 700;
    Posda::HttpApp::SubController->new($this->{session}, 
      $this->child_path("Controller"));
    Posda::HttpApp::WindowButtons->new($this->{session},
      $this->child_path("WindowButtons"));
    FileDist::StructLinkVal::Content->new($this->{session}, 
      $this->child_path("Content"), $series, $info, $summary);
    ###  If you want Debug capabilities
    Posda::HttpApp::DebugWindow->new($sess, "Debug");
    $this->SetInitialExpertAndDebug;
    ###
    $this->ReOpenFile();
    return $this;
  }
  sub Logo{
    my($this, $http, $dyn) = @_;
    my $image = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoImage};
    my $height = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoHeight};
    my $width = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoWidth};
    my $alt = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoAlt};
    $http->queue("<img src=\"$image\" height=\"$height\" width=\"$width\" " ,
      "alt=\"$alt\">");
  }
  sub Content {
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, $header);
  }
  sub DESTROY{
    my($this) = @_;
    $this->delete_descendants();
  }
}
{
  package FileDist::StructLinkVal::Content;
  use Posda::HttpApp::GenericIframe;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericIframe" );
  sub new{
    my($class, $sess, $path, $series, $info, $summary) = @_;
    my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
    $this->{ImportsFromAbove}->{GetFileList} = 1;
    $this->{ImportsFromAbove}->{GetDicomNicknamesByFile} = 1;
    $this->{ImportsFromAbove}->{GetEntityNicknameByEntityId} = 1;
    bless $this, $class;
    my $file_list = $this->FetchFromAbove("GetFileList");
    my $fm = $this->get_obj("FileManager");
    for my $i (@$file_list) {
      $this->{DicomFiles}->{$i} = $fm->DicomInfo($i);
    }
    for my $i (keys %{$this->{DicomFiles}}){
      my $fi = $this->{DicomFiles}->{$i};
      my $sop_inst_uid = $fi->{sop_inst_uid};
      my $sop_class_uid = $fi->{sop_class_uid};
      my $series = $fi->{series_uid};
      my $study = $fi->{study_uid};
      my $modality = $fi->{modality};
      my $study_nn = $this->FetchFromAbove("GetEntityNicknameByEntityId",
        "Study", $study);
      my $series_nn = $this->FetchFromAbove("GetEntityNicknameByEntityId",
        "Series", $series);
      my($for, $for_nn);
      if(defined $fi->{for_uid}){
         $for = $fi->{for_uid};
         $for_nn = $this->FetchFromAbove("GetEntityNicknameByEntityId",
           "FoR", $for);
      }
      if($modality eq "RTSTRUCT"){
        $this->{RtStructs}->{$i}->{series_refs} = $fi->{series_refs};
        for my $j (@{$fi->{series_refs}}){
          my $series_nn = $this->FetchFromAbove("GetEntityNicknameByEntityId",
            "Series", $j->{ref_series});
          $this->{RtStructs}->{$i}->{series_ref_nn}->{$j->{ref_series}} =
            $series_nn;
          my $study_nn = $this->FetchFromAbove("GetEntityNicknameByEntityId",
            "Study", $j->{ref_study});
          $this->{RtStructs}->{$i}->{study_ref_nn}->{$j->{ref_study}} =
            $study_nn;
        }
        $this->{RtStructs}->{$i}->{rois} = $fi->{rois};
        for my $r (keys %{$this->{RtStructs}->{$i}->{rois}}){
          my $roi = $this->{RtStructs}->{$i}->{rois};
          if(defined $roi->{ref_for}){
            my $for_nn = $this->FetchFromAbove("GetEntityNicknameByEntityId",
              "FoR", $roi->{ref_for});
            $this->{RtStructs}->{$i}->{RoiForNickname}->{$r} = $for_nn;
          }
        }
      } elsif($modality eq "CT" || $modality eq "MR"){
        $this->{ImageSops}->{$sop_inst_uid}->{files}->{$i} = 1;
        $this->{ImageSops}->{$sop_inst_uid}->{series}->{$series} = 1;
        $this->{ImageSops}->{$sop_inst_uid}->{modalities}->{$modality} = 1;
        $this->{ImageSops}->{$sop_inst_uid}->{sop_class_uid}->{$sop_class_uid}
           = 1;
	$this->{ImageSeries}->{$series}->{study}->{$study} = $study_nn;
        $this->{ImageSeries}->{$series}->{series_nn} = $series_nn;
        $this->{ImageSeries}->{$series}->{for}->{$for} = $for_nn;
        $this->{ImageSeries}->{$series}->{modalities}->{$modality} = 1;
        $this->{ImageSeries}->{$series}->{sop_class_uid}->{$sop_class_uid} = 1;
        $this->{ImageSeries}->{$series}->{files}->{$i} = {
          norm_iop => $fi->{norm_iop},
          norm_x => $fi->{norm_x},
          norm_y => $fi->{norm_y},
          norm_z => $fi->{norm_z},
        };
      }
    }
    return $this;
  }

  sub Content{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn,
      '<hr><?dyn="Description"?>' .
      '<hr><small><?dyn="Results"?></small>'
    );
  }
  sub Description{
    my($this, $http, $dyn) = @_;
    if(scalar(keys %{$this->{RtStructs}}) < 1){
      return $http->queue("No Structure Sets");
    } elsif(scalar(keys %{$this->{RtStructs}}) == 1){
      $this->{SelectedRtStruct} = [ keys %{$this->{RtStructs}} ]->[0];
      my $struct_nn = 
        $this->FetchFromAbove("GetDicomNicknamesByFile",
          $this->{SelectedRtStruct}
        );
      $http->queue("Only one struct: $struct_nn->[0]\n");
    } else {
      $this->RefreshEngine($http, $dyn,
      'Select a struct: <?dyn="SelectNsByValue" op="SelectStruct"?>' .
      '<?dyn="StructSelection"?></select>');
    }
  }
  sub StructSelection{
    my($this, $http, $dyn) = @_;
    unless(defined $this->{SelectedRtStruct}){
      $this->{SelectedRtStruct} = "--- select ---";
    }
    $http->queue('<option value="--- select ---"' .
      ($this->{SelectedRtStruct} eq "--- select ---" ? " selected" : "") .
      ">--- select---</option>");
    for my $ss (keys %{$this->{RtStructs}}){
      my $struct_nn = 
        $this->FetchFromAbove("GetDicomNicknamesByFile",
          $ss
        )->[0];
      $http->queue('<option value="' . $ss .'"' .
        ($this->{SelectedRtStruct} eq $ss ? " selected" : "") .
        ">$struct_nn</option>");
    }
  }
  sub SelectStruct{
    my($this, $http, $dyn) = @_;
    $this->{SelectedRtStruct} = $dyn->{value};
    $this->AutoRefresh;
  }
  sub Results{
    my($this, $http, $dyn) = @_;
    unless(
      $this->{SelectedRtStruct} && $this->{SelectedRtStruct} ne "--- select ---"
    ){
      return $http->queue("No RTSTRUCT Selected");
    }
    my $struct = $this->{RtStructs}->{$this->{SelectedRtStruct}};
    my @errors;
    unless(scalar(@{$struct->{series_refs}}) == 1){
      return $http->queue("This RTSTRUCT has more than one series reference");
    }
    my $for_nn = $this->FetchFromAbove("GetEntityNicknameByEntityId", "FoR",
      $struct->{series_refs}->[0]->{ref_for});
    my $series_nn = $this->FetchFromAbove("GetEntityNicknameByEntityId",
      "Series", $struct->{series_refs}->[0]->{ref_series});
    my $study_nn = $this->FetchFromAbove("GetEntityNicknameByEntityId",
      "Study", $struct->{series_refs}->[0]->{ref_study});
    my $num_good_refs = 0;
    my $num_dups = 0;
    my $num_bad_series = 0;
    my $unknown = 0;
    reference:
    for my $r (@{$struct->{series_refs}->[0]->{img_list}}){
      unless(exists $this->{ImageSops}->{$r}) { $unknown += 1; next reference; }
      unless(scalar(keys %{$this->{ImageSops}->{$r}->{files}}) == 1){
        $num_dups += 1; next reference;
      }
      my $ref_series = [ keys %{$this->{ImageSops}->{$r}->{series}} ]->[0];
      unless($ref_series eq $struct->{series_refs}->[0]->{ref_series}){
        $num_bad_series += 1; next reference;
      }
      $num_good_refs += 1;
    }
    my $num_images = $struct->{series_refs}->[0]->{num_images};
    my $struct_nn = 
      $this->FetchFromAbove("GetDicomNicknamesByFile",
        $this->{SelectedRtStruct}
      )->[0];
    
    $http->queue(
      "$struct_nn references $num_images images in for $for_nn in" .
      "$series_nn of $study_nn (in Referenced Frame of Reference Seq)<br />");
    if($num_good_refs) {
      $http->queue("$num_good_refs references " . 
        ($num_good_refs > 1 ? "are " : "is ") .
        "good<br />");
    }
    if($unknown) {
      $http->queue("$unknown references" . ($unknown > 1 ? "are " : "is ") .
        "to unknown files<br />");
    }
    if($num_dups) {
      $http->queue("$num_dups references" . ($num_dups > 1 ? "are " : "is ") .
        "to duplicate SOP Instance UIDS<br />");
    }
    if($num_bad_series) {
      $http->queue("$num_bad_series references" . 
        ($num_bad_series > 1 ? "are " : "is ") .
        "to files in a different series<br />");
    }
    $http->queue("<table border><tr>" .
      "<th>roi_num</th><th>roi_name</th>" .
      "<th>ROI observation label</th>" .
      "<th>#contours</th>" .
      "<th>contour types</th>" .
      "<th>interp type</th><th>Frame of Ref</th>" .
      "<th>good refs</th><th>bad refs</th><th>missing refs</th>" .
      "<th>? refs</th>" .
      "</tr>");
    for my $roi_num (sort {$a <=> $b} keys %{$struct->{rois}}){
      my $roi = $struct->{rois}->{$roi_num};
      my $roi_name = $roi->{roi_name};
      my $roi_obs_label = $roi->{roi_obser_label};
      unless(defined $roi_obs_label) { $roi_obs_label = "" }
      my $contour_types;
      for my $t (keys %{$roi->{contour_types}}){
        $contour_types .= ($contour_types ? "$contour_types<br />" : "") .
          "$t ($roi->{contour_types}->{$t})";
      }
      my $num_contours = $roi->{tot_contours};
      my $interp_type = $roi->{roi_interpreted_type};
      my $roi_for = $this->FetchFromAbove("GetEntityNicknameByEntityId", "FoR",
        $roi->{ref_for});
      if($roi->{ref_for} ne $struct->{series_refs}->[0]->{ref_for}){
        push @errors,
          "Roi number $roi_num ($roi_name) references a wrong FoR";
      }
      my $good_refs = 0;
      my $bad_refs = 0;
      my $missing_refs = 0;
      my $ques_refs = 0;
      contour:
      for my $i (0 .. $#{$roi->{contours}}){
        my $contour = $roi->{contours}->[$i];
        my $type = $roi->{contours}->[$i]->{type};
        my $sop_ref;
        if(exists $roi->{sop_refs}->{$i}) { $sop_ref = $roi->{sop_refs}->{$i} }
        if($type ne "CLOSED_PLANAR"){
          if(defined $sop_ref) { $ques_refs += 1 }
          next contour;
        }
        unless(defined $sop_ref) { $missing_refs += 1; next contour }
        my $error;
        if(
          $this->NotInList($sop_ref, $struct->{series_refs}->[0]->{img_list})
        ){
          $error = "In $roi_num ($roi_name) contour [$i] reference " .
            "to image not in " .
            "Referenced Frame of Reference Sequence";
        }
        if(defined $error) { push @errors, $error; $bad_refs += 1 } 
        else { $good_refs += 1 }
      }
      $http->queue("<tr><td>$roi_num</td><td>$roi_name</td>" .
        "<td>$roi_obs_label</td>" .
        "<td>$num_contours</td>" .
        "<td>$contour_types</td>" .
        "<td>$interp_type</td><td>$roi_for</td>" .
        "<td>$good_refs</td><td>$bad_refs</td>" .
        "<td>$missing_refs</td><td>$ques_refs</td>" .
        "</tr>");
    }
    $http->queue("</table>");
    if($#errors >= 0){
      $http->queue("Errors: <ul>");
      for my $i (@errors){
        $http->queue("<li>$i</li>");
      }
      $http->queue("</ul>");
    }
  }
  sub NotInList{
    my($this, $item, $list) = @_;
    for my $i (@$list){
      if($i eq $item) { return undef }
    }
    return 1;
  }
}
1;
