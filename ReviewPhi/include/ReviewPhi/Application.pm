#!/usr/bin/perl -w
#
use strict;
package ReviewPhi::Application;
use Posda::HttpApp::JsController;
use Dispatch::NamedObject;
use Posda::HttpApp::DebugWindow;
use Posda::HttpApp::Authenticator;
use Posda::FileCollectionAnalysis;
use Posda::Nicknames;
use Posda::UUID;
use Dispatch::NamedFileInfoManager;
use Dispatch::LineReader;
use Fcntl qw(:seek);
use File::Path 'remove_tree';
use Digest::MD5;
use JSON::PP;
use Debug;
use Storable;
my $dbg = sub {print STDERR @_ };
use utf8;
use vars qw( @ISA );
@ISA = ( "Posda::HttpApp::JsController", "Posda::HttpApp::Authenticator" );
my $expander = <<EOF;
<?dyn="BaseHeader"?>
<script type="text/javascript">
<?dyn="JsController"?>
<?dyn="JsContent"?>
</script>
</head>
<body>
<?dyn="Content"?>
<?dyn="Footer"?>
EOF
my $bad_config = <<EOF;
<?dyn="BadConfigReport"?>
EOF
sub new {
  my($class, $sess, $path) = @_;
  my $this = Dispatch::NamedObject->new($sess, $path);
  bless $this, $class;

  if(exists $main::HTTP_APP_CONFIG->{BadJson}){
    $this->{BadConfigFiles} = $main::HTTP_APP_CONFIG->{BadJson};
  }
  $this->{expander} = $expander;
  $this->{Identity} = $main::HTTP_APP_CONFIG->{config}->{Identity};
  $this->{Environment} = $main::HTTP_APP_CONFIG->{config}->{Environment};
  $this->{LoginTempDir} = "$this->{Environment}->{LoginTemp}/$this->{session}";
  unless(mkdir $this->{LoginTempDir}) {
    die "can't mkdir $this->{LoginTempDir}"
  }
  my $width = $this->{Identity}->{width};
  my $height = $this->{Identity}->{height};
  $this->{title} = $this->{Identity}->{Title};
  $this->{height} = $height;
  $this->{width} = $width;
  $this->{menu_width} = 300;
  $this->{content_width} = $this->{width} - $this->{menu_width};
  $this->SetInitialExpertAndDebug("bbennett");
  if($this->CanDebug){
    Posda::HttpApp::DebugWindow->new($sess, "Debug");
  }
  $this->{JavascriptRoot} =
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{JavascriptRoot};
  $this->QueueJsCmd("Update();");
  my $session = $this->get_session;
  $session->{DieOnTimeout} = 1;
  if(
    exists $main::HTTP_APP_SINGLETON->{token} &&
    defined $main::HTTP_APP_SINGLETON->{token}
  ){
    $session->{logged_in} = 1;
    $session->{AuthUser} = $main::HTTP_APP_SINGLETON->{token};
    $session->{real_user} = $main::HTTP_APP_SINGLETON->{token};
    $this->SetUserPrivs($main::HTTP_APP_SINGLETON->{token});
  }
  $this->{ExitOnLogout} = 1;
  $this->{DicomInfoCache} =
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{DicomInfoCache};
  $this->{ExtractionRoot} =
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{ExtractionRoot};
  if($this->can("SpecificInitialize")){
    $this->SpecificInitialize;
  }
  return $this;
}
sub DirLine{
  my($this) = @_;
  my $sub = sub {
    my($line) = @_;
    my($coll, $site, $subj, $dir) = split(/\|/, $line);
    $this->{Collections}->{$coll}->{$site}->{$subj}->{$dir} = 1;
  };
  return $sub;
}
sub DirEnd{
  my($this) = @_;
  my $sub = sub {
    $this->{SelectedCollection} = "none";
    $this->{SelectedSite} = "none";
    $this->{SelectedSubj} = "none";
    $this->{SelectedDir} = "none";
    $this->{Mode} = "Selection";
    $this->AutoRefresh;
  };
  return $sub;
}
sub user{
  my($this, $http, $dyn) = @_;
  $http->queue($this->get_user);
}
my $content = <<EOF;
<div id="container" style="width:<?dyn="width"?>px">
<div id="header" style="background-color:#E0E0FF;">
<table width="100%"><tr width="100%"><td>
<?dyn="Logo"?>
</td><td>
<h1 style="margin-bottom:0;"><?dyn="title"?></h1>
User: <?dyn="user"?>
</td><td valign="top" align="right">
<div id="login">&lt;login&gt;</div>
</td></tr></table></div>
<div id="menu" style="background-color:#F0F0FF;height:<?dyn="height"?>px;width:<?dyn="menu_width"?>px;float:left;">
&lt;wait&gt;
</div>
<div id="content" style="overflow:auto;background-color:#F8F8F8;width:<?dyn="content_width"?>px;float:left;">
&lt;Content&gt;</div>
<div id="footer" style="background-color:#E8E8FF;clear:both;text-align:center;">
Posda.com</div>

</div>

EOF
sub Content{
  my($this, $http, $dyn) = @_;
  if($this->{BadConfigFiles}) {
    return $this->RefreshEngine($http, $dyn, $bad_config);
  }
  $this->RefreshEngine($http, $dyn, $content);
}
sub width{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{width});
}
sub menu_width{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{menu_width});
}
sub content_width{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{content_width});
}
sub height{
  my($this, $http, $dyn) = @_;
  $http->queue($this->{height});
}
sub GetHeight{
  my($this) = @_;
  return $this->{height};
}
sub GetWidth{
  my($this) = @_;
  return $this->{width};
}
sub GetJavascriptRoot{
  my($this) = @_;
  return $this->{JavascriptRoot};
}
sub BadConfigReport{
  my($this, $http, $dyn) = @_;
  for my $i (keys %{$this->{BadConfigFiles}}){
    $http->queue(
      "<tr><td>$i</td><td>$this->{BadConfigFiles}->{$i}</td></tr>");
  }
}
sub Logo{
  my($this, $http, $dyn) = @_;
    my $image = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoImage};
    my $height = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoHeight};
    my $width = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoWidth};
    my $alt = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoAlt};
    $http->queue("<img src=\"$image\" height=\"$height\" width=\"$width\" " .
      "alt=\"$alt\">");
}
sub JsContent{
  my($this, $http, $dyn) = @_;
  my $js_file = "$this->{JavascriptRoot}/Application.js";
  unless(-f $js_file) { return }
  my $fh;
  open $fh, "<$js_file" or die "can't open $js_file";
  while(my $line = <$fh>) { $http->queue($line) }
}
sub DebugButton{
  my($this, $http, $dyn) = @_;
  if($this->CanDebug){
    $this->RefreshEngine($http, $dyn,
      '<span onClick="javascript:' .
      "rt('DebugWindow','Refresh?obj_path=Debug'" .
      ',1600,1200,0);">debug</span><br>');
  } else {
    print STDERR "Can't debug\n";
  }
}
# above line is generic
#######################################################
# below is app specific
sub SpecificInitialize{
  my($this) = @_;
  $this->{ContentMode} = "ContentSelecting";
  $this->{GrepString} = "foo";
  my $root = $this->{Environment}->{PhiAnalysisRoot};
  unless(-d $root){
    $this->ReportError("PhiAnalysisRoot is configured improperly:<ul>" .
      "<li>$this->{Environment}->{PhiAnalysisRoot} is not a directory</li>" .
      "</ul>");
  }
  unless(opendir DIR, $root){
    $this->ReportError("PhiAnalysisRoot is configured improperly:<ul>" .
      "<li>Can't opendir($this->{Environment}->{PhiAnalysisRoot}) ($!)</li>" .
      "</ul>");
  }
  my @reports;
  coll:
  while(my $coll = readdir(DIR)){
print STDERR "Coll: $coll\n";
    if($coll =~ /^\./) { next coll }
    unless(-d "$root/$coll") {
      print STDERR "'$root/$coll' is not a directory\n";
      next;
    }
    unless(opendir DIR1, "$root/$coll"){
      print STDERR "Can't opendir ($!) $root/$coll\n";
    }
    site:
    while(my $site = readdir(DIR1)){
print STDERR "Site: $site\n";
      if($site =~ /^\./) { next site }
      unless(-d "$root/$coll/$site") {
        print STDERR "'$root/$coll/$site' is not a directory\n";
        next;
      }
      unless(opendir DIR2, "$root/$coll/$site"){
        print STDERR "Can't opendir ($!) $root/$coll/$site\n";
      }
      round:
      while(my $round = readdir(DIR2)){
print STDERR "Round: $round\n";
        if($round =~ /^\./) { next round }
        unless(-d "$root/$coll/$site/$round") {
          print STDERR "'$root/$coll/$site/$round' is not a directory\n";
          next;
        }
        my $dir = "$root/$coll/$site/$round";
        if(
          -f "$dir/consolidated.pinfo" &&
          -f "$dir/consolidation_bom.txt"
        ){
          push @reports, {
            collection => $coll,
            site => $site,
            round => $round,
            bom => "$dir/consolidation_bom.txt",
            info => "$dir/consolidated.pinfo",
            selections => "$dir/selection.txt",
            submission => "$dir/submission.pinfo",
            file_info => "$dir/file_info.pinfo",
          };
        } else {
          print STDERR "One of these files doesn't exist\n" .
            "\t $dir/consolidation_bom.txt\n" .
            "\t $dir/consolidated.pinfo\n";
        }
      }
    }
  }
  $this->{ReportsAvailable} = \@reports;
  $this->{Mode} = "Initialized";
}
sub ReportError{
  my($this, $message) = @_;
  $this->{Mode} = "ErrorReported";
  $this->{ErrorReport} = $message;
}
sub MenuResponse{
  my($this, $http, $dyn) = @_;
  my $mode = $this->{Mode};
  if($this->can($mode)){ return $this->$mode($http, $dyn) }
  return $http->queue("Unknown mode $mode");
}
sub Initialized{
  my($this, $http, $dyn) = @_;
  if($#{$this->{ReportsAvailable}} < 0){
    return $http->queue("No reports available");
  }
  $http->queue("Reports available:<table border>" .
    "<tr><th>Collection</th><th>Site</th><th>Round</th></tr>");
  for my $r (@{$this->{ReportsAvailable}}){
    $http->queue("<tr><td>$r->{collection}</td>");
    $http->queue("<td>$r->{site}</td>");
    $http->queue("<td>$r->{round}</td><td>");
    $this->NotSoSimpleButton($http, {
      op => "SelectReport",
      caption => "Load Analysis",
      collection => $r->{collection},
      site => $r->{site},
      round => $r->{round},
      file => $r->{info},
      selections => $r->{selections},
      submission => $r->{submission},
      file_info => $r->{file_info},
#      sync => "AlertAndUpdate('foo');",
      sync => "Update();",
    });
    $http->queue("</td></tr>");
  }
  $http->queue("</table>");
}
sub SelectReport{
  my($this, $http, $dyn) = @_;
  if(exists $this->{Collection}){
    print STDERR "Select twice!!!!!\n";
    return;
  }
  $this->{Collection} = $dyn->{collection};
  $this->{Site} = $dyn->{Site};
  $this->{Round} = $dyn->{Round};
  $this->{file} = $dyn->{file};
  $this->{selections_file} = $dyn->{selections};
  $this->{submission_file} = $dyn->{submission};
  $this->{FileInfoFile} = $dyn->{file_info};
  Dispatch::Select::Background->new($this->RetrieveInfo)->queue;
  if(-r $this->{selections_file}){
    Dispatch::LineReader->new_file($this->{selections_file},
      $this->ReadSelectionLine,
      $this->ReadSelectionEnd);
  }
#  $http->queue("This is a test");
#  $http->finish;
};
sub ReadSelectionLine{
  my($this) = @_;
  my $sub = sub {
    my($line) = @_;
    $this->{SelectedValues}->{$line} = 1;
  };
  return $sub;
}
sub ReadSelectionEnd{
  my $sub = sub {
  };
  return $sub;
}
sub RetrieveInfo{
  my($this) = @_;
  my %s_date;
  my %f_info;
  my $sub = sub {
    $this->{info} = Storable::retrieve $this->{file};
    $this->{Mode} = "Info";
    my $count = keys %{$this->{info}};
    my %vr_counts;
    my %by_vr;
    my %owner_strings;
    for my $v (keys %{$this->{info}}){
      my %vrs;
      for my $ele (keys %{$this->{info}->{$v}}){
        if(
          $ele eq "(0008,0016)" ||
          $ele eq "(0008,0018)" ||
          $ele eq "(0008,0020)" ||
          $ele eq "(0008,0021)" ||
          $ele eq "(0008,0060)" ||
          $ele eq "(0010,0020)" ||
          $ele eq "(0020,000d)" ||
          $ele eq "(0020,000e)"
        ){
          for my $f (keys %{$this->{info}->{$v}->{$ele}->{files}}){
            if($ele eq "(0008,0016)"){       # SOP Class
              $f_info{$f}->{sop_class} = $v;
            } elsif($ele eq "(0008,0018)") { # SOP Instance
              $f_info{$f}->{sop_instance} = $v;
            } elsif($ele eq "(0008,0020)") { # Study Date
              $f_info{$f}->{study_date} = $v;
            } elsif($ele eq "(0008,0021)") { # Series Date
              $f_info{$f}->{series_date} = $v;
            } elsif($ele eq "(0008,0060)") { # Modality
              $f_info{$f}->{modality} = $v;
            } elsif($ele eq "(0010,0020)") { # Patient Id
              $f_info{$f}->{patient_id} = $v;
            } elsif($ele eq "(0020,000d)") { # Study Instance
              $f_info{$f}->{study_instance} = $v;
            } elsif($ele eq "(0020,000e)") { # Series Instance
              $f_info{$f}->{series_instance} = $v;
            }
            if($ele eq "(0008,0021)" || $ele eq "(0008,0060)"){
              $s_date{$f} = $v;
            }
          }
        }
        my $owner_string;
        if($ele =~ /^\(....,\"([^\"]+)\",/){
          $owner_string = $1;
          $owner_strings{$owner_string} = 1;
        }
        my $vr = $this->{info}->{$v}->{$ele}->{vr};
        $vrs{$vr} = 1;
        $by_vr{$vr}->{$v}->{$ele} = 1;
      }
      for my $vr (keys %vrs){
        $vr_counts{$vr} += 1;
      }
    }
    $this->{VrCounts} = \%vr_counts;
    $this->{StringCount} = $count;
    $this->{ByVr} = \%by_vr;
    $this->{Owners} = \%owner_strings;
    $this->{Sdates} = \%s_date;
    $this->{FileInfo} = \%f_info;
  };
  return $sub;
}
sub Info{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
      '<?dyn="NotSoSimpleButton" op="ShowSelections" ' .
      'caption="Show Selections" sync="Update();"?><br>' .
      "Info loaded: $this->{StringCount} unique text strings<br>" .
      'Counts By Vr:<table border><tr><th>VR</th><th>Count</th>' .
      '<th>Display</th></tr>');
  for my $vr (sort keys %{$this->{VrCounts}}){
    $http->queue("<tr><td>$vr</td><td>$this->{VrCounts}->{$vr}</td><td>" .
      $this->CheckBoxDelegate("SelectedVr", $vr,
        exists($this->{SelectedVrs}->{$vr}),
        { op => "SetSelectedVr", sync => "Update();" }
      ) .
      "</td></tr>");
  }
  $http->queue("</table>");
  if(exists $this->{SelectedVrs}->{UI}){ 
    $this->UidOptions($http, $dyn);
  }
  if(
    exists $this->{SelectedVrs}->{DA} ||
    exists $this->{SelectedVrs}->{DT}
  ){ 
    $this->DateOptions($http, $dyn);
  }
  if(
    exists $this->{SelectedVrs}->{OB} ||
    exists $this->{SelectedVrs}->{UN}
  ){
    $this->OtherOptions($http, $dyn);
  }
}
sub SetSelectedVr{
  my($this, $http, $dyn) = @_;
  if($dyn->{checked} eq "true"){
    if($dyn->{value} eq "DA"){
      $this->{SelectedVrs} = { DA => 1, DT => 1 };
    } else {
      $this->{SelectedVrs} = { $dyn->{value}, 1 };
    }
  } else {
    delete $this->{SelectedVrs}->{$dyn->{value}};
  }
}
sub SetSelectedValue{
  my($this, $http, $dyn) = @_;
  if($dyn->{checked} eq "true"){
    $this->{SelectedValues}->{$dyn->{value}} = 1;
  } else {
    delete $this->{SelectedValues}->{$dyn->{value}};
  }
};
sub SelectionMenu{
  my($this, $http, $dyn) = @_;
  $this->NotSoSimpleButton($http, {
    op => "SelectInfo",
    caption => "Return To Selecting",
    sync => "Update();",
  });
  $this->NotSoSimpleButton($http, {
    caption => "Save And Exit",
    op => "SaveAndExit",
    sync => "window.close();",
  });
  $this->NotSoSimpleButton($http, {
    caption => "Submit And Exit",
    op => "SubmitAndExit",
    sync => "window.close();",
  });
};
sub SelectInfo{
  my($this, $http, $dyn) = @_;
  $this->{Mode} = "Info";
  $this->{ContentMode} = "ContentSelecting";
}
###########################
sub ContentResponse{
  my($this, $http, $dyn) = @_;
  my $mode = $this->{ContentMode};
  if($this->can($mode)){ $this->$mode($http, $dyn) } else {
    $http->queue("Unknown ContentMode: \"$mode\"");
  }
}
sub ContentSelecting{
  my($this, $http, $dyn) = @_;
  if(
    exists($this->{SelectedVrs}->{DA})
    && exists($this->{SelectedVrs}->{DT})
  ){
    return $this->BothDates($http, $dyn);
  } elsif (
    (exists $this->{SelectedVrs}->{OB} ||
    exists $this->{SelectedVrs}->{UN}) &&
    $this->{GrepString}
  ){
    return $this->Grepped($http, $dyn);
  } elsif (exists $this->{SelectedVrs}->{UI}){
    return $this->Uids($http, $dyn);
  }
  $http->queue("<pre>");
  for my $i (keys %{$this->{SelectedVrs}}){
    for my $v (sort keys %{$this->{ByVr}->{$i}}){
      $http->queue($this->CheckBoxDelegate("SelectedValue", $v,
        exists($this->{SelectedValues}->{$v}), 
        { op => "SetSelectedValue", sync => "" }) . " $v\n");
    }
  }
  $http->queue("</pre>");
}
sub SetGrepPattern{
  my($this, $http, $dyn) = @_;
  $this->{GrepString} = $this->{GrepStringPending};
}
sub Grepped{
  my($this, $http, $dyn) = @_;
  $http->queue("<pre>");
  for my $vr (keys %{$this->{SelectedVrs}}){
    value:
    for my $v (keys %{$this->{ByVr}->{$vr}}){
      if($v =~ /$this->{GrepString}/){
        $http->queue($this->CheckBoxDelegate("SelectedValue", $v,
          exists($this->{SelectedValues}->{$v}), 
          { op => "SetSelectedValue", sync => "" }) . " $v\n");
      }
    }
  }
}
sub SelectAllShownOther{
  my($this, $http, $dyn) = @_;
  for my $vr (keys %{$this->{SelectedVrs}}){
    value:
    for my $v (keys %{$this->{ByVr}->{$vr}}){
      if($v =~ /$this->{GrepString}/){
        $this->{SelectedValues}->{$v} = 1;
      }
    }
  }
}
sub BothDates{
  my($this, $http, $dyn) = @_;
  my @dates;
  $http->queue("<pre>");
  for my $v (keys %{$this->{ByVr}->{DA}}){
    my %s_dates;
    ele:
    for my $e (keys %{$this->{info}->{$v}}){
      unless(
        $this->{info}->{$v}->{$e}->{vr} eq "DT" ||
        $this->{info}->{$v}->{$e}->{vr} eq "DA"
      ){ next ele }
      for my $f (keys %{$this->{info}->{$v}->{$e}->{files}}){
        my $s_date = "&lt;undef&gt;";
        if(exists $this->{Sdates}->{$f}) { $s_date = $this->{Sdates}->{$f} }
        $s_dates{$s_date} = 1;
      }
    }
    for my $s (sort keys %s_dates){
      push @dates, [$v, $s];
    }
  }
  for my $v (keys %{$this->{ByVr}->{DT}}){
    my %s_dates;
    ele:
    for my $e (keys %{$this->{info}->{$v}}){
      unless(
        $this->{info}->{$v}->{$e}->{vr} eq "DT" ||
        $this->{info}->{$v}->{$e}->{vr} eq "DA"
      ){ next ele }
      for my $f (keys %{$this->{info}->{$v}->{$e}->{files}}){
        my $s_date = "&lt;undef&gt;";
        if(exists $this->{Sdates}->{$f}) { $s_date = $this->{Sdates}->{$f} }
        $s_dates{$s_date} = 1;
      }
    }
    for my $s (sort keys %s_dates){
      push @dates, [$v, $s];
    }
  }
  $this->{ShownDates} = {};
  for my $d (sort {$a->[0] cmp $b->[0]} @dates){
    my $date_cmp = $d->[0];
    if($date_cmp =~ /^(........)......\./){ $date_cmp = $1 }
    if($date_cmp eq $d->[1] && exists $this->{HideMatchingDates}) { next }
    $http->queue($this->CheckBoxDelegate("SelectedValue", $d->[0],
      exists($this->{SelectedValues}->{$d->[0]}), 
      { op => "SetSelectedValue", sync => "" }) . " $d->[0] ($d->[1])\n");
    $this->{ShownDates}->{$d->[0]} = 1;
  }
}
sub Uids{
  my($this, $http, $dyn) = @_;
  $http->queue("<pre>");
  my %dates;
  for my $v ( sort keys %{$this->{ByVr}->{UI}}){
    unless(exists $this->{UidOptions}->{ShowHashedUids}){
      if($v =~ /^1\.3\.6\.1\.4\.1\.14519\.5\.2\.1/){ next }
    }
    unless(exists $this->{UidOptions}->{ShowDicomUids}){
      if($v =~ /^1\.2\.840\.10008\./){ next }
    }
    $http->queue($this->CheckBoxDelegate("SelectedValue", $v,
      exists($this->{SelectedValues}->{$v}), 
      { op => "SetSelectedValue", sync => "" }) . " $v\n");
  }
}
sub UidOptions{
  my($this, $http, $dyn) = @_;
  $http->queue("UidOptions:<ul>");
  for my $o ("ShowHashedUids", "ShowDicomUids"){
    $http->queue("<li>");
    $http->queue($this->CheckBoxDelegate("SelectedUidOption", $o,
      exists($this->{UidOptions}->{$o}), 
      { op => "SetSelectedUidOption", sync => "Update();" }) . " $o\n");
    $http->queue("</li>");
  }
  $http->queue("</ul>");
  $this->NotSoSimpleButton($http, {
    op => "SelectUidsNotFiltered",
    caption => "Select Shown UIDs",
    sync => "Update();"
  });
}
sub SelectUidsNotFiltered{
  my($this, $http, $dyn) = @_;
  for my $v ( sort keys %{$this->{ByVr}->{UI}}){
    unless(exists $this->{UidOptions}->{ShowHashedUids}){
      if($v =~ /^1\.3\.6\.1\.4\.1\.14519\.5\.2\.1/){ next }
    }
    unless(exists $this->{UidOptions}->{ShowDicomUids}){
      if($v =~ /^1\.2\.840\.10008\./){ next }
    }
    $this->{SelectedValues}->{$v} = 1;
  }
}
sub DateOptions{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
  'Date Options:<br>');
  $http->queue(
    $this->CheckBoxDelegate("HideMatchingDates", 0, 
      exists($this->{HideMatchingDates}), 
      { op=> "SetHideMatchingDates", sync => "Update();" })
  );
  $this->RefreshEngine($http, $dyn,
  'Hide matching<br>' .
  '<?dyn="NotSoSimpleButton" caption="Select All Shown" ' .
  'op="SelectShownDates" sync="Update();"?>');
#      $this->CheckBoxDelegate("SelectedVr", $vr,
#        exists($this->{SelectedVrs}->{$vr}),
#        { op => "SetSelectedVr", sync => "Update();" }
}
sub SelectShownDates{
  my($this, $http, $dyn) = @_;
  for my $d (keys %{$this->{ShownDates}}){
    $this->{SelectedValues}->{$d} = 1;
  }
}
sub SetHideMatchingDates{
  my($this, $http, $dyn) = @_;
  if($dyn->{checked} eq "true"){
    $this->{HideMatchingDates} = 1;
  } else {
    delete $this->{HideMatchingDates};
  }
}
sub OtherOptions{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
    'Other options:><br>' .
    '<?dyn="NotSoSimpleButton" caption="grep" ' .
    'op="SetGrepPattern" sync="Update();"?>' .
    '<?dyn="LinkedDelegateEntryBox" linked="GrepStringPending" ' .
    'length="20"?><br>' .
    '<?dyn="NotSoSimpleButton" op="SelectAllShownOther" ' .
    'caption="Select All Shown" sync="Update();"?>');
}
sub SetGrepString{
  my($this, $http, $dyn) = @_;
  $this->{GrepString} = $this->{GrepStringPending};
}
sub SetSelectedUidOption{
  my($this, $http, $dyn) = @_;
  if($dyn->{checked} eq "true"){
    $this->{UidOptions}->{$dyn->{value}} = 1;
  } else {
    delete $this->{UidOptions}->{$dyn->{value}};
  }
}
sub SaveAndExit{
  my($this, $http, $dyn) = @_;
  open my $fh, ">$this->{selections_file}" or
    die "Can't open $this->{selections_file}\n";
  for my $i (keys %{$this->{SelectedValues}}){
    print $fh "$i\n";
  }
  close $fh;
  Storable::store $this->{FileInfo}, $this->{FileInfoFile};
  Dispatch::Select::Background->new($this->Exiter)->timer(2);
}
sub SubmitAndExit{
  my($this, $http, $dyn) = @_;
  for my $i (keys %{$this->{info}}){
    unless(exists $this->{SelectedValues}->{$i}){
      delete $this->{info}->{$i};
    }
  }
  Storable::store $this->{info}, $this->{submission_file};
  Dispatch::Select::Background->new($this->Exiter)->timer(2);
}
sub Exiter{
  my($this) = @_;
  my $sub = sub{
    $this->Die("Exit requested");
  };
  return $sub;
}
sub ShowSelections{
  my($this, $http, $dyn) = @_;
  $this->{ContentMode} = "ContentSelections";
  $this->{Mode} = "SelectionMenu";
}
sub ContentSelections{
  my($this, $http, $dyn) = @_;
  $http->queue("Selected Strings:<br><small><table border><tr>" .
    "<th>value</th><th>tags</th><th>VR</th><th># files</th></tr>)");
  for my $s (sort keys %{$this->{SelectedValues}}){
    $http->queue("<tr>");
    my $count = keys %{$this->{info}->{$s}};
    $http->queue("<td rowspan=\"$count\">$s</td>");
    for my $t (keys %{$this->{info}->{$s}}){
      my $f_count = keys %{$this->{info}->{$s}->{$t}->{files}};
      my $vr = $this->{info}->{$s}->{$t}->{vr};
      $http->queue("<td>$t</td><td>$vr</td><td>$f_count</td></tr>");
    }
  }
  $http->queue("</table></small>");
}
1;
