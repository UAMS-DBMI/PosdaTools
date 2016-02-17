#!/usr/bin/perl -w
#
use strict;
package PosdaCuration::InfoExpander;
use Posda::ElementNames;
use PosdaCuration::FileView;
use PosdaCuration::SeriesReport;
use PosdaCuration::CompareFiles;
use PosdaCuration::CompareRevisions;
sub ExpandStudyCounts{
  my($this, $http, $dyn, $struct) = @_;
  my $num_studies = keys %{$struct};
  my $num_series = 0;
  my $num_images = 0;
  for my $std (keys %$struct){
    $num_series += keys %{$struct->{$std}->{series}};
    for my $ser ( keys %{$struct->{$std}->{series}}){
      $num_images += $struct->{$std}->{series}->{$ser}->{num_files};
    }
  }
  $this->{LastImageCountSeen} = $num_images;
  $http->queue("Studies: $num_studies<br/>Series: $num_series<br/>" .
    "Images: $num_images");
}
sub ExpandStudyCountsExtraction{
  my($this, $http, $dyn, $struct) = @_;
  my $num_studies = keys %{$struct};
  my $num_series = 0;
  my $num_images = 0;
  for my $std (keys %$struct){
    $num_series += keys %{$struct->{$std}->{series}};
    for my $ser ( keys %{$struct->{$std}->{series}}){
      $num_images += keys %{$struct->{$std}->{series}->{$ser}->{files}};
    }
  }
  if($num_images eq $this->{LastImageCountSeen}){
    $http->queue("Studies: $num_studies<br/>Series: $num_series<br/>" .
      "Images: $num_images");
  } else {
    $http->queue("Studies: $num_studies<br/>Series: $num_series<br/>" .
      "Images: <span style=\"background-color:red\">$num_images</span>");
  }
}
sub ExpandStudyHierarchy{
  my($this, $http, $dyn, $studies) = @_;
  unless(exists $this->{NickNames}){
    $this->{NickNames} = Posda::Nicknames->new;
  }
  $http->queue('<table width="100%" border="1">');
  for my $study_uid(sort keys %$studies){
    my $study_nn = $this->{NickNames}->GetEntityNicknameByEntityId(
      "STUDY", $study_uid
    );
    my $study = $studies->{$study_uid};
    my $study_id;
    my $accession_number;
    my $study_date;
    my $study_description;
    if(keys %{$study->{st_desc}} > 1){
      $study_description = "&lt;inconsistent&gt;"
    } else { $study_description = [ keys %{$study->{st_desc}} ]->[0] }
    if(keys %{$study->{st_id}} > 1){ $study_id = "&lt;inconsistent&gt;" }
    else { $study_id = [ keys %{$study->{st_id}} ]->[0] }
    if(keys %{$study->{accession_num}} > 1){
      $accession_number = "&lt;inconsistent&gt;" 
    } else { $accession_number = [ keys %{$study->{accession_num}} ]->[0] }
    if(keys %{$study->{st_date}} > 1){ $study_date = "&lt;inconsistent&gt;" }
    else { $study_date = [ keys %{$study->{st_date}} ]->[0] }
    my $num_series = keys %{$study->{series}};
    $http->queue('<tr><td colspan="2">' . $study_nn . 
      ((defined($study_id) && ($study_id ne "")) ? " ($study_id)" : "") .
      '</td>');
    $http->queue('<td colspan="4">' . 
      "$study_date:$study_description:$accession_number" . 
      '</td></tr>');
    for my $series_uid (sort keys %{$study->{series}}){
      my $s = $study->{series}->{$series_uid};
      my $modality;
      my $series_date;
      my $series_desc;
      my $body_part;
      if(keys %{$s->{modality}} > 1) { $modality = '&lt;inconsistent&gt;' }
      else { $modality = [ keys %{$s->{modality}} ]->[0] }
      if(keys %{$s->{ser_date}} > 1) { $series_date = '&lt;inconsistent&gt;' }
      else { $series_date = [ keys %{$s->{ser_date}} ]->[0] }
      if(keys %{$s->{ser_desc}} > 1) { $series_desc = '&lt;inconsistent&gt;' }
      else { $series_desc = [ keys %{$s->{ser_desc}} ]->[0] }
      if(keys %{$s->{body_part}} > 1) { $body_part = '&lt;inconsistent&gt;' }
      else { $body_part = [ keys %{$s->{body_part}} ]->[0] }
      my $series_nn = 
        $this->{NickNames}->GetEntityNicknameByEntityId("SERIES", $series_uid);
      $http->queue('<tr><td>==&gt;</td><td>' . $series_nn . '</td>');
      $http->queue("<td>$modality</td><td>$body_part</td>");
      $http->queue("<td>$series_date:$series_desc</td><td>$s->{num_files}</td></tr>");
    }
  }
  $http->queue("</table>");
}
sub ExpandStudyHierarchyExtraction{
  my($this, $http, $dyn, $studies) = @_;
  unless(exists $this->{NickNames}) {
    $this->{NickNames} = Posda::Nicknames->new;
  }
  $http->queue('<table width="100%" border="1">');
  for my $study (
    sort {
      $studies->{$a}->{uid} cmp $studies->{$b}->{uid}
    } keys %{$studies}
  ){
    my $study_uid = $studies->{$study}->{uid};
    my $study_nn =
      $this->{NickNames}->GetEntityNicknameByEntityId("STUDY", $study_uid);
    my $study_id = $studies->{$study}->{id};
    if(ref($study_id)){ $study_id = "&lt;inconsistent&gt;" }
    $http->queue('<tr><td colspan="2">' . $study_nn .
      ((defined($study_id) && ($study_id ne "")) ? " ($study_id)" : "") .
      '</td>');
    $http->queue('<td colspan="3">' .
      (ref($studies->{$study}->{desc})eq "ARRAY" ?
        "&lt;inconsistent&gt;" : $studies->{$study}->{desc}));
    $http->queue('</td></tr>');
    my $s_st = $studies->{$study}->{series};
    for my $series (
      sort {
        $s_st->{$a}->{uid} cmp $s_st->{$b}->{uid}
      } keys %$s_st
    ){
      my $series_uid =
        $studies->{$study}->{series}->{$series}->{uid};
      my $series_nn =
        $this->{NickNames}->GetEntityNicknameByEntityId("SERIES", $series_uid);
      my $s = $studies->{$study}->{series}->{$series};
      $http->queue('<tr><td>==&gt;</td><td>' . $series_nn . '</td>');
      $http->queue("<td>$s->{modality}</td><td>" .
        (ref($s->{desc}) eq "ARRAY" ? "&lt;inconsistent&gt;" : $s->{desc}) .
        "</td>");
      my $count = keys %{$s->{files}};
      $http->queue("<td>" .
        (ref($s->{body_part}) eq "ARRAY" ?
          "&lt;inconsistent&gt;" :
          $s->{body_part}) .
        "</td><td>$count</td></tr>");
    }
  }
  $http->queue('</table>');
}
sub ExpandStudyHierarchyWithPatientInfo{
  my($this, $http, $dyn, $studies) = @_;
  unless(exists $this->{NickNames}) {
    $this->{NickNames} = Posda::Nicknames->new;
  }
  $http->queue('<table width="100%" border="1">');
  $http->queue('<tr><td colspan="7"></td><td colspan="2">');
  $this->DelegateButton($http, {
    op => "CompareImages", caption => "Compare"
    });
  $http->queue('</td></tr>' .
    '<tr><td colspan="7"></td><td>Fr</td><td>To</td></tr>');
  for my $study (
    sort {
      $studies->{$a}->{uid} cmp $studies->{$b}->{uid}
    } keys %{$studies}
  ){
    my $study_uid = $studies->{$study}->{uid};
    my $pid = $studies->{$study}->{pid};
    my $pname = $studies->{$study}->{pname};
    my $study_nn =
      $this->{NickNames}->GetEntityNicknameByEntityId("STUDY", $study_uid);
    $http->queue('<tr><td colspan="3">' . $study_nn .
    " (pid = $pid; pname = $pname)" .
    '</td>');
    $http->queue('<td colspan="3">' .
      (ref($studies->{$study}->{desc})eq "ARRAY" ?
        "&lt;inconsistent&gt;" : $studies->{$study}->{desc}));
    $http->queue('</td></tr>');
    my $s_st = $studies->{$study}->{series};
    for my $series (
      sort {
        $s_st->{$a}->{uid} cmp $s_st->{$b}->{uid}
      } keys %$s_st
    ){
      my $series_uid =
        $studies->{$study}->{series}->{$series}->{uid};
      my $series_nn =
        $this->{NickNames}->GetEntityNicknameByEntityId("SERIES", $series_uid);
      my $s = $studies->{$study}->{series}->{$series};
      $this->RefreshEngine($http, $dyn,
        '<tr><td>==&gt;</td><td><table width="100%"><tr>' .
        '<td align="left">' .
        $series_nn .
        '</td><td align="right">' .
        '<?dyn="DelegateButton" caption="rpt" op="SeriesReport" ' .
        "series_nn=\"$series_nn\" series_uid=\"$series_uid\" " .
        "study_nn=\"$study_nn\" study_uid=\"$study_uid\"" .
        "?>" .
        '<?dyn="DelegateButton" caption="hide" op="SeriesHideOk" ' .
        "series_nn=\"$series_nn\" series_uid=\"$series_uid\" " .
        "study_nn=\"$study_nn\" study_uid=\"$study_uid\" " .
        'sync="Update();"' .
        "?>" .
        '</td></tr></table></td>');
      $http->queue("<td>$s->{modality}</td><td>" .
        (ref($s->{desc}) eq "ARRAY" ? "&lt;inconsistent&gt;" : $s->{desc}) .
        "</td>");
      my $count = keys %{$s->{files}};
      $http->queue("<td>" .
        (ref($s->{body_part}) eq "ARRAY" ?
          "&lt;inconsistent&gt;" :
          $s->{body_part}) .
        "</td><td>$count</td><td>");
      my @files;
      my %digests;
      for my $i (keys %{$studies->{$study}->{series}->{$series}->{files}}){
        my $dig = $this->{DisplayInfoIn}->{dicom_info}->{FilesToDigest}->{$i};
        $digests{$dig} = $i;
      }
      my $fbd = $this->{DisplayInfoIn}->{dicom_info}->{FilesByDigest};
      for my $dig (
#        sort
#        {
#          $fbd->{$a}->{normalized_loc} <=> $fbd->{$b}->{normalized_loc}
#        }
        keys %digests
      ){
        my $di = $fbd->{$dig};
        my $f_uid_nn = $this->{NickNames}->GetDicomNicknamesByFile(
          $digests{$dig}, $di);
        push(@files, $f_uid_nn->[0]);

      }
      @files = sort { NumericFileSort($a, $b) } @files;
      $this->MakeFileInspector($http, $dyn, $series, \@files);
      $http->queue("</td><td>");
      $this->MakeFileFromSelector($http, $dyn, $series, \@files);
      $http->queue("</td><td>");
      $this->MakeFileToSelector($http, $dyn, $series, \@files);
      $http->queue("</td></tr>");
    }
  }
  $http->queue('</table>');
}
sub NumericFileSort{
  my($a, $b) = @_;
  my($left, $right);
  if($a =~ /^[^\d]+(\d+)$/) {
    $left = $1;
  };
  if($b =~ /^[^\d]+(\d+)$/){
    $right = $1;
  }
  if(defined($left) && defined($right)){
    return $left <=> $right;
  }else{
    return $left cmp $right;
  }
}
sub MakeFileInspector{
  my($this, $http, $dyn, $series, $file_list) = @_;
  if($#{$file_list} == 0){
    $http->queue($file_list->[0]);
    $this->{DisplayInfoIn}->{SelectedFileToView}->{$series} = $file_list->[0];
  } else {
    $this->RefreshEngine($http, $dyn,
      '<?dyn="SelectDelegateByValue" op="FileToView" ' .
      "series=\"$series\"?>");
    unless(exists $this->{DisplayInfoIn}->{SelectedFileToView}->{$series}){
      $this->{DisplayInfoIn}->{SelectedFileToView}->{$series} = $file_list->[0];
    }
    for my $nn (@{$file_list}){
      my $files = $this->{NickNames}->GetFilesByFileNickname($nn);
      my $file = $files->[0];
      $http->queue('<option value="' . $nn . '"' .
        ($nn eq $this->{DisplayInfoIn}->{SelectedFileToView}->{$series} ?
           " selected" : "") .
        ">$nn</option>");
    }
    $http->queue("</select>");
  }
  $this->RefreshEngine($http, $dyn,
    '<?dyn="DelegateButton" caption="dmp" op="ViewFile" series="' .
    $series . '"?>' .
    '<?dyn="DelegateButton" caption="hide" op="HideFileOk" series="' .
    $series . '"?>'
  );
}
sub MakeFileFromSelector{
  my($this, $http, $dyn, $series) = @_;
  unless(exists $this->{DisplayInfoIn}->{SelectedFromCompare}->{$series}){
    $this->{DisplayInfoIn}->{SelectedFromCompare}->{$series} = "false";
  }
  $http->queue(
    $this->RadioButtonSync(
      "SelectedFromCompare",
      $series,
      "SelectFromCompare",
      ($this->{DisplayInfoIn}->{SelectedFromCompare}->{$series} eq "true" ?
         1 : 0),
       '', 'Update();')
  );
}
sub MakeFileToSelector{
  my($this, $http, $dyn, $series) = @_;
  unless(exists $this->{DisplayInfoIn}->{SelectedToCompare}->{$series}){
    $this->{DisplayInfoIn}->{SelectedToCompare}->{$series} = "false";
  }
  $http->queue(
    $this->RadioButtonSync(
      "SelectedToCompare",
      $series,
      "SelectToCompare",
      ($this->{DisplayInfoIn}->{SelectedToCompare}->{$series} eq "true" ?
         1 : 0),
       '', 'Update();')
  );
}
sub SelectFromCompare{
  my($this, $http, $dyn) = @_;
  delete $this->{DisplayInfoIn}->{SelectedFromCompare};
  $this->{DisplayInfoIn}->{SelectedFromCompare}->{$dyn->{value}} =
    $dyn->{checked};
}
sub SelectToCompare{
  my($this, $http, $dyn) = @_;
  delete $this->{DisplayInfoIn}->{SelectedToCompare};
  $this->{DisplayInfoIn}->{SelectedToCompare}->{$dyn->{value}} =
    $dyn->{checked};
}
sub FileToView{
  my($this, $http, $dyn) = @_;
  $this->{DisplayInfoIn}->{SelectedFileToView}->{$dyn->{series}} =
   $dyn->{value};
}
sub ViewFile{
  my($this, $http, $dyn) = @_;
  my $file_nn = $this->{DisplayInfoIn}->{SelectedFileToView}->{$dyn->{series}};
  my $files = $this->{NickNames}->GetFilesByFileNickname($file_nn);
  my $file = $files->[0];
  my $child_path = $this->child_path("View_$file_nn");
  my $child_obj = $this->get_obj($child_path);
  unless(defined $child_obj){
    $child_obj = PosdaCuration::FileView->new($this->{session},
      $child_path, $file_nn, $file);
    if($child_obj){
      $this->InvokeAbove("StartChildDisplayer", $child_obj);
    } else {
      print STDERR 'PosdaCuration::FileView->new failed!!!' . "\n";
    }
  }
}
sub SeriesHideOk{
  my($this, $http, $dyn) = @_;
  my $series_nn = $dyn->{series_nn};
  my $series_uid = $dyn->{series_uid};
  my $study_nn = $dyn->{study_nn};
  my $study_uid = $dyn->{study_uid};
  $this->{PendingHideSeriesNn} = $series_nn;
  $this->{PendingHideSeriesUid} = $series_uid;
  $this->{PendingHideSeriesRevertCollectionMode} = $this->{CollectionMode};
  $this->{CollectionMode} = "PendingHideSeries";
}
sub PendingHideSeries{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
    '<h3>Are you sure you want to hide this series:</h3>' .
    '<h5>This will also discard this extraction (as a side effect)</h5>' .
    '<h5>And will discard the Intake Check</h5>' .
    "<ul><li>Nickname: $this->{PendingHideSeriesNn}</li>" .
    "<li>Uid: $this->{PendingHideSeriesUid}</li>" .
    '<?dyn="NotSoSimpleButton" caption="Yes, Hide" ' .
    "series_nn=\"$this->{PendingHideSeriesNn}\" " .
    "series_uid=\"$this->{PendingHideSeriesUid}\" " .
    'op="HideSeries" sync="Update();"?></td><td>' .
    '<?dyn="NotSoSimpleButton" caption="No, Don' . "'" . 't Hide" ' .
    'op="DontHideSeries" sync="Update();"?></td><td>'
  );
}
sub DontHideSeries{
  my($this, $http, $dyn) = @_;
  $this->{CollectionMode} = $this->{PendingHideSeriesRevertCollectionMode};
  delete $this->{PendingHideSeriesNn};
  delete $this->{PendingHideSeriesUid};
  delete $this->{PendingHideSeriesRevertCollectionMode};
}
sub HideSeries{
  my($this, $http, $dyn) = @_;
  my $series = $this->{PendingHideSeriesUid};
  my $cmd = "HideSeries.pl " .
    "\"$this->{Environment}->{database_name}\" " .
    "\"$this->{SelectedCollection}\" " .
    "\"$this->{SelectedSite}\" " .
    "\"$series\"";
print STDERR "Cmd: $cmd\n";
  Dispatch::LineReader->new_cmd($cmd, $this->HideSeriesLine, 
    $this->DoneWithHideSeries($http, $dyn)
  );
}
sub HideSeriesLine{
  my($this) = @_;
  my $sub = sub {
    my($line) = @_;
  };
  return $sub;
}
sub DoneWithHideSeries{
  my($this, $http, $dyn) = @_;
  my $sub = sub {
    $this->ClearIntakeData($http, $dyn);
    $this->DiscardExtraction($http, {
      collection => $this->{DisplayInfoIn}->{Collection},
      site => $this->{DisplayInfoIn}->{Site},
      subj => $this->{DisplayInfoIn}->{subj}
    });
  };
  return $sub;
}
sub SeriesReport{
  my($this, $http, $dyn) = @_;
  my $series_nn = $dyn->{series_nn};
  my $series_uid = $dyn->{series_uid};
  my $study_nn = $dyn->{study_nn};
  my $study_uid = $dyn->{study_uid};
  my $child_path = $this->child_path("Report_$series_nn");
  my $child_obj = $this->get_obj($child_path);
  my $disp_info_in = $this->{DisplayInfoIn};
print STDERR "Series_nn: $series_nn, Series_uid: $series_uid\n";
  unless(defined $child_obj){
  $child_obj = PosdaCuration::SeriesReport->new($this->{session},
    $child_path, $series_nn, $series_uid, $study_nn, $study_uid,
    $disp_info_in
  );
  $this->InvokeAbove("StartChildDisplayer", $child_obj);
  }
}
sub CompareImages{
  my($this, $http, $dyn) = @_;
  my $selected_from_series;
  for my $ser (keys %{$this->{DisplayInfoIn}->{SelectedFromCompare}}){
    if($this->{DisplayInfoIn}->{SelectedFromCompare}->{$ser} eq "true"){
      $selected_from_series = $ser;
      last;
    }
  }
  my $selected_to_series;
  for my $ser (keys %{$this->{DisplayInfoIn}->{SelectedToCompare}}){
    if($this->{DisplayInfoIn}->{SelectedToCompare}->{$ser} eq "true"){
      $selected_to_series = $ser;
      last;
    }
  }
  my $from_file_nn = $this->{DisplayInfoIn}->{SelectedFileToView}->{$selected_from_series};
  my $to_file_nn = $this->{DisplayInfoIn}->{SelectedFileToView}->{$selected_to_series};
  my $from_files = $this->{NickNames}->GetFilesByFileNickname($from_file_nn);
  my $from_file = $from_files->[0];
  my $to_files = $this->{NickNames}->GetFilesByFileNickname($to_file_nn);
  my $to_file = $to_files->[0];
  print STDERR "Here's where we compare $from_file to $to_file\n";
  my $child_path = $this->child_path("compare_${from_file_nn}_$to_file_nn");
  my $child_obj = $this->get_obj($child_path);
  unless(defined $child_obj){
    $child_obj = PosdaCuration::CompareFiles->new($this->{session},
      $child_path, $from_file_nn, $from_file, $to_file_nn, $to_file);
    if($child_obj){
      $this->InvokeAbove("StartChildDisplayer", $child_obj);
    } else {
      print STDERR 'PosdaCuration::CompareFiles->new failed!!!' . "\n";
    }
  }
}
sub ErrorReportCommon{
  my($this, $http, $dyn, $error_info, $ignored_error_info, $hierarchy) = @_;
  unless(defined($error_info) && ref($error_info) eq "ARRAY"){
    if(defined($ignored_error_info) && ref($ignored_error_info) eq "ARRAY"){
      return $this->RefreshEngine($http, $dyn,
        '<small>Errors ignored ' .
        '<?dyn="NotSoSimpleButton" caption="Unignore Errors" ' .
        'op="UnIgnoreErrors" sync="Update();"?>');
    } else {
      return $http->queue('<small>No errors</small>');
    }
  }
  $this->RefreshEngine($http, $dyn,
    '<small>Errors: ' .
    '<?dyn="NotSoSimpleButton" caption="Ignore Errors" ' .
    'op="IgnoreErrors" sync="Update();"?>' .
    '<ul>');
  for my $err(@{$error_info}){
    $http->queue("<li>$err->{message}");
    $http->queue("<ul>");
    for my $i (
      "type", "sub_type", "ele", "study_uid", "series_uid", "sop_inst"
    ){
      if(exists $err->{$i}){
        $http->queue("<li>$i: $err->{$i}");
        if($i eq "study_uid"){
          my $nn =
            $this->{NickNames}->GetEntityNicknameByEntityId("STUDY",
              $err->{$i});
          $http->queue(" ($nn)");
        } elsif($i eq "series_uid"){
          my $nn =
            $this->{NickNames}->GetEntityNicknameByEntityId("SERIES",
              $err->{$i});
          $http->queue(" ($nn)");
        } elsif($i eq "ele"){
          my $ele_name = Posda::ElementNames::FromSig($err->{$i});
          $http->queue(" ($ele_name)");
        }
        $http->queue("</li>");
      }
    }
    if(exists $err->{values} && ref($err->{values}) eq "ARRAY"){
      $http->queue("<li>Values: <ul>");
      for my $v (@{$err->{values}}){
        $http->queue("<li>");
        if($v eq "<undef>"){
          $http->queue("&lt;not present&gt;")
        } elsif ($v eq ""){
          $http->queue("&lt;present but null&gt;")
        } else {
          $http->queue($v)
        }
        $http->queue("</li>");
      }
      $http->queue("</ul></li>");
    }
    $http->queue("</ul></li>");
  }
  $http->queue("</ul></small>");
}
sub UnIgnoreErrors{
  my($this, $http, $dyn) = @_;
  my $Collection = $this->{SelectedCollection};
  my $Site = $this->{SelectedSite};
  my $Subject = $dyn->{subj};
  my $Revision = $this->{DisplayInfoIn}->{rev_hist}->{CurrentRev};
  my $error_file = 
    "$this->{ExtractionRoot}/$Collection/$Site/$Subject/revisions/$Revision/" .
    "error.pinfo";
  my $ignored_error_file =  
    "$this->{ExtractionRoot}/$Collection/$Site/$Subject/revisions/$Revision/" .
    "ignored_error.pinfo";
  if(-f $ignored_error_file && !(-f $error_file)){
    if(link $ignored_error_file, $error_file) {
      my $count = unlink $ignored_error_file;
      unless($count == 1) {
        print STDERR "#################################\n" .
          "Error can't unlink ($!) file:\n" .
          "\t$ignored_error_file\n" .
          "#################################\n";
        return;
      }
    } else {
      print STDERR "#################################\n" .
        "Error can't link ($!) files:\n" .
        "\tfrom: $ignored_error_file\n" .
        "\tto: $error_file\n" .
        "#################################\n";
      return;
    }
    $this->{DisplayInfoIn}->{error_info} = 
      $this->{DisplayInfoIn}->{ignored_error_info};
    delete $this->{DisplayInfoIn}->{ignored_error_info};
    $this->RefreshDirData;
  } else {
    print STDERR "#################################\n" .
      "Error can't ignore errors for $Collection/$Site/$Subject/$Revision\n";
    unless(-f $ignored_error_file){
      print STDERR "$error_file doesn't exist\n";
    }
    if(-f $error_file){
      print STDERR "$ignored_error_file exists\n";
    }
    print STDERR  "#################################\n";
  }
}
sub IgnoreErrors{
  my($this, $http, $dyn) = @_;
  my $Collection = $this->{SelectedCollection};
  my $Site = $this->{SelectedSite};
  my $Subject = $dyn->{subj};
  my $Revision = $this->{DisplayInfoIn}->{rev_hist}->{CurrentRev};
  my $error_file = 
    "$this->{ExtractionRoot}/$Collection/$Site/$Subject/revisions/$Revision/" .
    "error.pinfo";
  my $ignored_error_file =  
    "$this->{ExtractionRoot}/$Collection/$Site/$Subject/revisions/$Revision/" .
    "ignored_error.pinfo";
  if(-f $error_file && !(-f $ignored_error_file)){
    if(link $error_file, $ignored_error_file) {
      my $count = unlink $error_file;
      unless($count == 1) {
        print STDERR "#################################\n" .
          "Error can't unlink ($!) file:\n" .
          "\t$error_file\n" .
          "#################################\n";
        return;
      }
    } else {
      print STDERR "#################################\n" .
        "Error can't link ($!) files:\n" .
        "\tfrom: $error_file\n" .
        "\tto: $ignored_error_file\n" .
        "#################################\n";
      return;
    }
    $this->{DisplayInfoIn}->{ignored_error_info} = 
      $this->{DisplayInfoIn}->{error_info};
    delete $this->{DisplayInfoIn}->{error_info};
    $this->RefreshDirData;
    $this->HideInfo;
  } else {
    print STDERR "#################################\n" .
      "Error can't ignore errors for $Collection/$Site/$Subject/$Revision\n";
    unless(-f $error_file){
      print STDERR "$error_file doesn't exist\n";
    }
    if(-f $ignored_error_file){
      print STDERR "$ignored_error_file exists\n";
    }
    print STDERR  "#################################\n";
  }
}
sub RevisionHistory{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
    '<table border><tr><th colspan="6">Revision History</th></tr>' .
    '<tr><th>Revision</th><th>At</th><th>User</th>' .
    '<th>Elapsed</th>' .
    '<th>Copied</th>' .
    '<th>Changed</th>' .
    '<th colspan="2">' .
    '<?dyn="NotSoSimpleButton" caption="Compare" ' .
    'op="CompareRevisions" synch="Update();"?></th></tr>' .
    '<?dyn="RevisionList"?>' .
    '<tr><td colspan="2" align="left">' .
    '<?dyn="NotSoSimpleButton" caption="Discard Last Revision" ' .
    'op="DiscardLastRevision" sync="Update();"?></td></tr>' .
    '</table>');
}
sub RevisionList{
  my($this, $http, $dyn) = @_;
  for my $r (
    sort {$a <=> $b} keys %{$this->{DisplayInfoIn}->{rev_hist}->{Revisions}}
  ){
    my $item = $this->{DisplayInfoIn}->{rev_hist}->{Revisions}->{$r};
    my $copied = $this->{DisplayInfoIn}->{rev_desc}->{$r}->{Copied};
    my $changed = $this->{DisplayInfoIn}->{rev_desc}->{$r}->{Edited};
    my @months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
    my @days = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
      localtime($item->{start});
    $year += 1900;
    my $elapsed = $item->{end} - $item->{start};
    $this->RefreshEngine($http, $dyn,
      "<tr><td>$r</td><td>$year-$months[$mon]-$mday $hour:$min:$sec</td>" .
      "<td>$item->{user}</td><td>$elapsed</td>" .
      "<td>$copied</td><td>$changed</td>" .
      '<td><?dyn="FromRevision" index="' . $r .
      '"?></td><td><?dyn="ToRevision" index="' . $r .
      '"?></td>');
  }
}
sub FromRevision{
  my($this, $http, $dyn) = @_;
  my $rev = $dyn->{index};
  unless(exists $this->{DisplayInfoIn}->{SelectedFromRevision}->{$rev}){
    $this->{DisplayInfoIn}->{SelectedFromRevision}->{$rev} = "false";
  }
  $http->queue(
    $this->RadioButtonSync(
      "SelectedFromRevision",
      $rev,
      "SelectFromRevision",
      ($this->{DisplayInfoIn}->{SelectedFromRevision}->{$rev} eq "true" ?
         1 : 0),
       '', 'Update();')
  );
}
sub SelectFromRevision{
  my($this, $http, $dyn) = @_;
  delete $this->{DisplayInfoIn}->{SelectedFromRevision};
  $this->{DisplayInfoIn}->{SelectedFromRevision}->{$dyn->{value}} =
    $dyn->{checked};
}
sub ToRevision{
  my($this, $http, $dyn) = @_;
  my $rev = $dyn->{index};
  unless(exists $this->{DisplayInfoIn}->{SelectedToRevision}->{$rev}){
    $this->{DisplayInfoIn}->{SelectedToRevision}->{$rev} = "false";
  }
  $http->queue(
    $this->RadioButtonSync("SelectedToRevision", $rev, "SelectToRevision",
      ($this->{DisplayInfoIn}->{SelectedToRevision}->{$rev} eq "true" ?
         1 : 0),
      '', 'Update();')
  );
}
sub SelectToRevision{
  my($this, $http, $dyn) = @_;
  delete $this->{DisplayInfoIn}->{SelectedToRevision};
  $this->{DisplayInfoIn}->{SelectedToRevision}->{$dyn->{value}} =
    $dyn->{checked};
}
sub CompareRevisions{
  my($this, $http, $dyn) = @_;
  my $from;
  for my $i (keys %{$this->{DisplayInfoIn}->{SelectedFromRevision}}){
    if($this->{DisplayInfoIn}->{SelectedFromRevision}->{$i} eq "true"){
      $from = $i;
    }
  };
  my $to;
  for my $i (keys %{$this->{DisplayInfoIn}->{SelectedToRevision}}){
    if($this->{DisplayInfoIn}->{SelectedToRevision}->{$i} eq "true"){
      $to = $i;
    }
  };
  unless(defined($from) && defined($to) && $from != $to){
    print STDERR "CompareRevisions: from ($from) and to ($to) improper\n";
    return;
  }
  my $child_path = $this->child_path("CompareRevisions_$from" . "_$to");
  my $child_obj = $this->get_obj($child_path);
  unless(defined $child_obj){
    $child_obj = PosdaCuration::CompareRevisions->new($this->{session},
      $child_path, $from, $to);
    if($child_obj){
      $this->InvokeAbove("StartChildDisplayer", $child_obj);
    } else {
      print STDERR 'PosdaCuration::CompareRevisions->new failed!!!' . "\n";
    }
  }
}
1;
