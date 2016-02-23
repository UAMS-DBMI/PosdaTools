#!/usr/bin/perl -w
#
use strict;
package PhiFixer::Application;
use Posda::HttpApp::JsController;
use Dispatch::NamedObject;
use Posda::HttpApp::DebugWindow;
use Posda::HttpApp::Authenticator;
use Posda::FileCollectionAnalysis;
use Posda::Nicknames;
use Posda::UUID;
use Posda::DataDict;
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

my $expander = qq{<?dyn="BaseHeader"?>
  <script type="text/javascript">
  <?dyn="JsController"?>
  <?dyn="JsContent"?>
  </script>
  </head>
  <body>
  <?dyn="Content"?>
  <?dyn="Footer"?>
};

my $bad_config = qq{
  <?dyn="BadConfigReport"?>
};

sub new {
  my($class, $sess, $path) = @_;
  my $this = Dispatch::NamedObject->new($sess, $path);
  $this->{DD} = Posda::DataDict->new;
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
my $content = qq{
  <div id="container" style="width:<?dyn="width"?>px">
  <div id="header" style="background-color:#E0E0FF;">
    <table width="100%">
    <tr width="100%">
      <td>
        <?dyn="Logo"?>
      </td>
      <td>
        <h1 style="margin-bottom:0;"><?dyn="title"?></h1>
        User: <?dyn="user"?>
      </td>
      <td valign="top" align="right">
        <div id="login">&lt;login&gt;</div>
      </td>
    </tr>
    </table>
  </div>
  <div id="menu" style="background-color:#F0F0FF;height:<?dyn="height"?>px;width:<?dyn="menu_width"?>px;float:left;">
    &lt;wait&gt;
  </div>
  <div id="content" style="overflow:auto;background-color:#F8F8F8;width:<?dyn="content_width"?>px;float:left;">
    &lt;Content&gt;
  </div>
  <div id="footer" style="background-color:#E8E8FF;clear:both;text-align:center;">
    Posda.com
  </div>
  </div>
};

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
    $this->RefreshEngine($http, $dyn, qq{
      <span class="btn btn-sm btn-info" 
       onClick="javascript:rt('DebugWindow',
       'Refresh?obj_path=Debug',1600,1200,0);">Debug</span>
    });
  } else {
    print STDERR "Can't debug\n";
  }
}
# above line is generic
#######################################################
# below is app specific
sub SpecificInitialize{
  my($this) = @_;
  $this->{ContentMode} = "WaitingForTag";
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
        if($round =~ /^\./) { next round }
        unless(-d "$root/$coll/$site/$round") {
          print STDERR "'$root/$coll/$site/$round' is not a directory\n";
          next;
        }
        my $dir = "$root/$coll/$site/$round";
        if(
          -f "$dir/consolidated.pinfo" &&
          -f "$dir/consolidation_bom.txt" &&
          -f "$dir/submission.pinfo"
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
            private_tag_info => "$dir/private_tag_info.pinfo",
          };
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
  $http->queue(qq{
    <p>Reports available:</p>
    <table class="table-sm table-bordered">
    <tr>
      <th>Collection</th>
      <th>Site</th>
      <th>Round</th>
    </tr>
  });
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
      private_tag_info => $r->{private_tag_info},
#      sync => "AlertAndUpdate('foo');",
      sync => "Update();",
      class => "btn btn-xs btn-default", # Extra small button, so it fits!
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
  $this->{file_info_file} = $dyn->{file_info};
  $this->{private_tag_info_file} = $dyn->{private_tag_info};
  Dispatch::Select::Background->new($this->RetrieveInfo)->queue;
#  $http->queue("This is a test");
#  $http->finish;
};
sub RetrieveInfo{
  my($this) = @_;
  my $sub = sub {
    $this->{FileInfo} = Storable::retrieve $this->{file_info_file};
    $this->{PrivateTagInfo} = Storable::retrieve $this->{private_tag_info_file};
    $this->{info} = Storable::retrieve $this->{submission_file};
    $this->{Mode} = "Info";
    $this->{ByTag} = {};
    $this->{ByFile} = {};
    $this->{PrivateTags} = {};
    for my $v (keys %{$this->{info}}){
      for my $t (keys %{$this->{info}->{$v}}){
        for my $f (keys %{$this->{info}->{$v}->{$t}->{files}}){
          $this->{ByTag}->{$t}->{$v}->{$f} = 1;
          $this->{ByFile}->{$f}->{$t}->{$v} = 1;
          if($t =~/^\([\da-f]{4},\"[^\"]+\",[\da-f]{2}\)$/){
            $this->{PrivateTags}->{$t}->{$f} = 1;
          }
        }
      }
    }
  };
  return $sub;
}
sub Info{
  my($this, $http, $dyn) = @_;
  my $modes = {
    PrivateTagReview => "Review Private Tags",
    InfoTagValueMode => "Review Potential PHI",
  };
  unless(defined($this->{InfoMode})){
    $this->{InfoMode} = "PrivateTagReview";
  }
  $this->SelectByValue($http, {
    op => "SetInfoMode",
    sync => "Update();",
  });
  for my $i (keys %$modes){
    $http->queue("<option value=\"$i\"" .
      ($this->{InfoMode} eq $i ? ' selected' : "") .
      ">$modes->{$i}</option>");
  }
  $http->queue("</select><hr>");
  if($this->can($this->{InfoMode})){
    my $meth = $this->{InfoMode};
    $this->$meth($http, $dyn);
  } else {
    $http->queue("Undefined InfoMode: $this->{InfoMode}");
  }
}
sub SetInfoMode{
  my($this, $http, $dyn) = @_;
  $this->{InfoMode} = $dyn->{value};
}
sub PrivateTagReview{
  my($this, $http, $dyn) = @_;
  unless(exists $this->{PrivateTagsToReview}){
    $this->{PrivateTagsToReview} = [ 
      sort keys %{$this->{PrivateTagInfo}}
    ];
  }
  $http->queue("PrivateTagReview");
}
sub InfoTagValueMode{
  my($this, $http, $dyn) = @_;
  $this->TagFilters($http, $dyn);
  unless(defined($this->{TagIndex})){$this->{TagIndex} = 0 }
  my %tags;
  tag:
  for my $i (sort keys %{$this->{ByTag}}){
    if($this->{Disposed}->{$i}){ next tag };
    my $ic = $i;
    $ic =~ s/([\"])/"%" . unpack("H2", $1)/eg;
    $tags{$ic} = $i;
  }
  my $tag_count = keys %tags;
  $http->queue("Tags Remaining ($tag_count):<br>");
  my $max_count = 30;
  render:
  for my $i (sort keys %tags){
    $max_count -= 1;
    if($max_count >= 0){
      $http->queue(
        $this->CheckBoxDelegate("SelectedEle", $i,
          exists($this->{SelectedEles}->{$tags{$i}}),
          { op => "SetSelectedEle", sync => "Update();" }
        ) 
      );
      $http->queue("$tags{$i}<br>");
    } else {
      $http->queue("...<br>");
      last render;
    }
  }
}
sub SetSelectedEle{
  my($this, $http, $dyn) = @_;
  my $value = $dyn->{value};
  $value =~ s/%(..)/pack("c",hex($1))/ge;
  if($dyn->{checked} eq "true"){
#    $this->{SelectedEles}->{$dyn->{value}} = 1;
     $this->{SelectedEles} = { $dyn->{value}, 1 };
    $this->{ContentMode} = "TagSelected";
  } else {
    delete $this->{SelectedEles}->{$dyn->{value}};
    $this->{ContentMode} = "WaitingForTag";
  }
  $this->ClearFileSelection($http, $dyn);
}
sub TagFilters{
  my($this, $http, $dyn) = @_;
  $http->queue("<small>");
  unless(defined $this->{TagFilters}->{OnlyPublic}){
    $this->{TagFilters}->{OnlyPublic} = "false";
  }
  unless(defined $this->{TagFilters}->{OnlyPrivate}){
    $this->{TagFilters}->{OnlyPrivate} = "false";
  }
  $http->queue($this->CheckBoxDelegate("TagFilters", 
    "OnlyPublic" ,  $this->{TagFilters}->{OnlyPublic} eq "true",
    { op => "SetCheckBox", sync => "Update();" }) . "Only public");
  $http->queue($this->CheckBoxDelegate("TagFilters", 
    "OnlyPrivate" ,  $this->{TagFilters}->{OnlyPrivate} eq "true",
    { op => "SetCheckBox", sync => "Update();" }) . "Only private");
  $http->queue("<hr>");
}
sub SetCheckBox{
  my($this, $http, $dyn) = @_;
  $this->{$dyn->{group}}->{$dyn->{value}} = $dyn->{checked};
}
###########################
sub ContentResponse{
  my($this, $http, $dyn) = @_;
  my $mode = $this->{ContentMode};
  if($this->can($mode)){ $this->$mode($http, $dyn) } else {
    $http->queue("Unknown ContentMode: \"$mode\"");
  }
}
sub WaitingForTag{
  my($this, $http, $dyn) = @_;
    $http->queue("Waiting for a Tag to be chosen.");
}
sub TagSelected{
  my($this, $http, $dyn) = @_;
  my $tag = [ keys %{$this->{SelectedEles}} ]->[0];
  if(exists $this->{SelectedFileForExtraction}){
    $this->{SelectedTagForExtraction} = $tag;
    return $this->FileAndTagSelected($http, $dyn);
  }
  $this->RefreshEngine($http, $dyn,
    '<small><?dyn="NotSoSimpleButton" op="DisposeTag" caption="Dispose" ' .
    'sync="Update();"?>' . 
    'Tag selected: '. $tag .
    '<hr>');
  my @constituents = split(/\[<\d+>\]/,$tag);
  for my $i (@constituents){
    $this->TagInfo($http, $dyn, $i);
  }
  $this->TagValueReport($http, $dyn, $tag);
  $http->queue("</small>");
}
sub TagInfo{
  my($this, $http, $dyn, $tag) = @_;
  my $tag_name = "&lt;unknown&gt;";
  my $vr = "&lt;unknown&gt;";
  my $vm = "&lt;unknown&gt;";
  my $keyword = "&lt;unknown&gt;";
  $http->queue("$tag: ");
  if($tag =~/^\(([\da-f]{4}),([\da-f]{4})\)$/){
    my $grp = hex($1);
    my $ele = hex($2);
    if(exists($this->{DD}->{Dict}->{$grp}->{$ele})){
      $tag_name = $this->{DD}->{Dict}->{$grp}->{$ele}->{Name};
      $vr = $this->{DD}->{Dict}->{$grp}->{$ele}->{VR};
      $vm = $this->{DD}->{Dict}->{$grp}->{$ele}->{VM};
      $keyword = $this->{DD}->{Dict}->{$grp}->{$ele}->{KeyWord};
    }
    $http->queue(" $vr, $vm, $keyword, $tag_name");
  } elsif ($tag =~ /^\(([\da-f]{4}),\"([^\"]+)\",([\da-f]{2})\)$/){
    my $owner = $2;
    my $grp = hex($1);
    my $ele = hex($3);
    if(exists $this->{DD}->{PvtDict}->{$owner}->{$grp}->{$ele}){
      my $d = $this->{DD}->{PvtDict}->{$owner}->{$grp}->{$ele};
      $http->queue(" $d->{VR}, $d->{VM}, $d->{Name}");
    } else {
      $http->queue(" Unknown private tag");
    }
  } else {
    $http->queue(" no pattern match\n");
  }
  $http->queue("<br>");
}
sub TagValueReport{
  my($this, $http, $dyn, $tag) = @_;
  $http->queue("<hr>");
  $http->queue("<table border><th>Value</th></th><th># Patients</th>" .
    "<th># Studies</th><th># Series</th><th># Modalities</th>" .
    "<th># SOP Classes</th><th># Files</th><th>Study Dates</th>".
    "<th>Series Dates</th><th>Select</th>");
  for my $v (keys %{$this->{ByTag}->{$tag}}){
    $http->queue("<tr><td>$v</td>");
    my $num_files = keys %{$this->{ByTag}->{$tag}->{$v}};
    my %pats;
    my %studies;
    my %series;
    my %modalities;
    my %sop_classes;
    for my $f (keys %{$this->{ByTag}->{$tag}->{$v}}){
      my $pat_id = $this->{FileInfo}->{$f}->{patient_id};
      my $modality = $this->{FileInfo}->{$f}->{modality};
      my $sop_class = $this->{FileInfo}->{$f}->{sop_class};
      my $study = $this->{FileInfo}->{$f}->{study_instance};
      my $series = $this->{FileInfo}->{$f}->{series_instance};
      $pats{$pat_id} = 1;
      $modalities{$modality} = 1;
      $studies{$study} = 1;
      $series{$series} = 1;
      $sop_classes{$sop_class} = 1;
    }
    my $num_pats = keys %pats;
    my $num_studies = keys %studies;
    my $num_series = keys %series;
    my $num_modalities = keys %modalities;
    my $num_sop_classes = keys %sop_classes;
    $http->queue("<td>$num_pats</td>"); # Patients
    $http->queue("<td>$num_studies</td>"); # Studies
    $http->queue("<td>$num_series</td>"); # Series
    $http->queue("<td>$num_modalities</td>"); # Modalities
    $http->queue("<td>$num_sop_classes</td>"); # SOP Classes
    $http->queue("<td>$num_files</td>");
    my $dates = $this->GetStudyDates([keys %{$this->{ByTag}->{$tag}->{$v}}]);
    if($dates->[0] eq $dates->[$#{$dates}]){
      $http->queue("<td>$dates->[0]</td>");
    } else {
      $http->queue("<td>$dates->[0] - $dates->[$#{$dates}]</td>");
    }
    $dates = $this->GetSeriesDates([keys %{$this->{ByTag}->{$tag}->{$v}}]);
    if($dates->[0] eq $dates->[$#{$dates}]){
      $http->queue("<td>$dates->[0]</td><td>");
    } else {
      $http->queue("<td>$dates->[0] - $dates->[$#{$dates}]</td><td>");
    }
    my @files = sort keys %{$this->{ByTag}->{$tag}->{$v}};
    my $selected_file = "select";
    $this->{SelectedTagForExtraction} = $tag;
    if(
      defined($this->{SelectedFileForExtraction}) &&
      $this->{SelectedTagForExtraction} eq $tag &&
      $this->{SelectedValueForExtraction} eq $v
    ){
      $selected_file = $this->{SelectedFileForExtraction};
    }
    $this->SelectDelegateByValue($http,
      {
        op => "SelectFileForDisplay",
        tag_value => $v,
        sync => "Update();",
      }
    );
    my $options = ["select", @files];
    for my $i (0 .. $#{$options}){
      my $f = $options->[$i];
      $http->queue("<option value=\"$f\"" .
        ($f eq $selected_file ? "selected" : "") .
        ($f eq "select"? ">select": ">file_$i") . "</option>");
    }
    $http->queue("</select>");
    $http->queue("</td></tr>");
  }
  $http->queue("</table>");
}
sub SelectFileForDisplay{
  my($this, $http, $dyn) = @_;
  if($dyn->{value} eq "select"){
    delete $this->{SelectedFileForExtraction};
    delete $this->{SelectedTagForExtraction};
    delete $this->{SelectedValueForExtraction};
  } else {
    $this->{SelectedFileForExtraction} = $dyn->{value};
    $this->{SelectedValueForExtraction} = $dyn->{tag_value};
    delete $this->{SelectedTagInstances};
    if($this->{SelectedTagForExtraction} =~ /<\d+>/){
      $this->{ReadingTagInstances} = 1;
      Dispatch::LineReader->new_cmd("GetMatchingElements.pl \"" .
        $this->{SelectedFileForExtraction} . "\" '" .
        $this->{SelectedTagForExtraction} . "'",
        $this->ReadTagInstances,
        $this->TagInstancesRead);
    }
  }
}
sub FileAndTagSelected{
  my($this, $http, $dyn) = @_;
  my $tag_disp = $this->{SelectedTagForExtraction};
  $tag_disp =~ s/</&lt;/g;
  $tag_disp =~ s/>/&gt;/g;
  $this->RefreshEngine($http, $dyn,
    '<?dyn="NotSoSimpleButton" op="ClearFileSelection" ' .
    'caption="Clear File Selection" sync="Update();"?><br>' .
    "File Selected: $this->{SelectedFileForExtraction}<br>" .
    "Tag Selected: $tag_disp<br>");
  if($this->{SelectedTagForExtraction} =~ /<\d+>/){
    $http->queue("Tag Instances: ");
    if(exists $this->{ReadingTagInstances}){
      $http->queue("&lt;waiting&gt;<br>");
    } else {
      $http->queue("<ul>");
      for my $t (@{$this->{SelectedTagInstances}}){
        $http->queue("<li>$t</li>");
      }
      $http->queue("</ul>");
    }
  }
  $this->RefreshEngine($http, $dyn,
    "Value Selected: $this->{SelectedValueForExtraction}<br>");
}
sub ClearFileSelection{
  my($this, $http, $dyn) = @_;
  delete $this->{SelectedFileForExtraction};
  delete $this->{SelectedTagForExtraction};
  delete $this->{SelectedValueForExtraction};
  delete $this->{SelectedTagInstances};
}
sub ReadTagInstances{
  my($this) = @_;
  my $sub = sub {
    my($line) = @_;
    push @{$this->{SelectedTagInstances}}, $line;
  };
  return $sub;
}
sub TagInstancesRead{
  my($this) = @_;
  my $sub = sub {
    delete $this->{ReadingTagInstances};
    $this->AutoRefresh;
  };
  return $sub;
}
sub GetStudyDates{
  my($this, $list) = @_;
  my %dates;
  for my $f (@$list){
    my $study_date = $this->{FileInfo}->{$f}->{study_date};
    $dates{$study_date} = 1;
  }
  return [ sort keys %dates];
}
sub GetSeriesDates{
  my($this, $list) = @_;
  my %dates;
  for my $f (@$list){
    my $series_date = $this->{FileInfo}->{$f}->{series_date};
    $dates{$series_date} = 1;
  }
  return [ sort keys %dates];
}
sub DisposeTag{
  my($this, $http, $dyn) = @_;
  my $tag = [ keys %{$this->{SelectedEles}} ]->[0];
  delete $this->{SelectedEles}->{$tag};
  delete $this->{SelectedFileForExtraction};
  delete $this->{SelectedTagForExtraction};
  delete $this->{SelectedValueForExtraction};
  $this->{Disposed}->{$tag} = 1;
  $this->SelectNextAvailableTag;
}
sub SelectNextAvailableTag{
  my($this) = @_;
  my $tag;
  tag:
  for my $i (sort keys %{$this->{ByTag}}){
    unless(exists $this->{Disposed}->{$i}){
      $tag = $i;
      last tag;
    }
  }
  if(defined($tag)){
    $this->{SelectedEles} = {$tag, 1};
  } else {
    $this->{ContentMode} = "AllTagsDisposed";
    $this->{Mode} = "MenuAllTagsDisposed";
  }
}
sub MenuAllTagsDisposed{
  my($this, $http, $dyn) = @_;
  $http->queue("All tags disposed");
}
1;
