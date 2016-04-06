#!/usr/bin/perl -w

use strict;
package PhiFixer::Application;
use PhiFixer::PrivateTagInfo;
use PhiFixer::DicomRootInfo;
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
use Digest::MD5 'md5_hex';
use JSON;
use Debug;
use Storable;
use File::Basename;
use Data::Dumper;
use Time::Piece;
use Time::Seconds;
my $dbg = sub {print STDERR @_ };
use utf8;
use vars qw( @ISA );

use constant UNKNOWN => '&lt;unknown&gt;';

@ISA = ( "Posda::HttpApp::JsController", "Posda::HttpApp::Authenticator" );

sub DEBUG {
  print @_, "\n";
}

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

my $disposition_map = {
  Z => 'Zero',
  X => 'Delete',
  K => 'Keep',
  C => 'Clean',
  R => 'Review',
  0 => 'None (Review)',
};

my $phi_disposition_map = {
  S => 'Shift',
  H => 'Hash',
  X => 'Delete',
  C => 'Clear',
  K => 'Keep',
};


sub get_subj_files_path {
  # Return the portion of the file path up to files/
  # TODO: Make this better, it will explode for a collection called "files"
  my ($file) = @_;

  $file =~ /(.*\/files\/)/;

  return $1;
}

sub get_dicom_in_dir {
  # Return an arrayref of all DICOM files in the given directory
  # TODO: This should probably be loading the dicom.pinfo file
  # from the revision dir, rather than scanning for .dcm files
  # some more info could be returned as well!
  my ($dir) = @_;

  # Assumes $dir ends with /
  my @files = glob($dir . '*.dcm');
  return \@files;
}


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
  $this->{Site} = $dyn->{site};
  $this->{Round} = $dyn->{round};
  $this->{file} = $dyn->{file};
  $this->{selections_file} = $dyn->{selections};
  $this->{submission_file} = $dyn->{submission};
  $this->{file_info_file} = $dyn->{file_info};
  $this->{private_tag_info_file} = $dyn->{private_tag_info};
  $this->{RootsInfo} = PhiFixer::DicomRootInfo::get_info($this->{Collection},$this->{Site});

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
    $this->{ContentMode} = "WaitingForTag";
    $this->{SelectedPriv} = -1;  # a value that can't exist
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
  $this->{ContentMode} = 'WaitingForTag';  # also clear content 
  $this->{SelectedPriv} = -1;  # clear selected private tag, if any
}
sub PrivateTagReview{
  my($this, $http, $dyn) = @_;
  unless(exists $this->{PrivateTagsToReview}){
    $this->{PrivateTagsToReview} = [ 
      sort keys %{$this->{PrivateTagInfo}}
    ];
  }

  # TODO: button is for testing only
  # TESTING DEBUG
  $this->NotSoSimpleButton($http, {
    op => "FinishEarly",
    caption => "Finish NOW!",
    sync => "Update();",
  });

  $http->queue(qq{<div style="margin-left: 5px;">});
  for my $id (0 .. $#{$this->{PrivateTagsToReview}}) {
    $http->queue(
      $this->CheckBoxDelegate("SelectedPriv", $id,
        ($this->{SelectedPriv} == $id),
        { op => "SetSelectedPriv", sync => "Update();" }
      ) 
    );
    $http->queue("$this->{PrivateTagsToReview}->[$id]</input><br>");
  }
  $http->queue("</div>");
}

sub FinishEarly {
  my($this, $http, $dyn) = @_;

  $this->{ContentMode} = "AllTagsDisposed";
  $this->{Mode} = "MenuAllTagsDisposed";
}

sub GetDispositionFromDetails {
  # Return a dispo only if all elements agree
  my($this, $http, $dyn, $details) = @_;

  # details will be an array.

  # TODO: is there a better way? only using a hash here
  # so that it is easy to determine if all the rows match.. 
  my %disps;

  for my $row (@{$details}) {
    $disps{$row->{pt_consensus_disposition}} = 1;
  }

  # If anything other than a single result, there is no consensus
  # disposition!
  if (scalar(keys %disps) != 1) {
    return 0;
  }

  # TODO: This is the most terrible thing I have ever written
  # but is there actually a better way to return the first
  # element from a hash? [ values %disps ]->[0], but that is uglier!
  for my $dispo (%disps) {
    return $dispo;
  }
}
sub PrivateTagReviewContent {
  my($this, $http, $dyn) = @_;

  my $selected_tag = $this->{PrivateTagsToReview}->[$this->{SelectedPriv}];
  if (not defined $selected_tag) {
    return;
  }
  my $affected_files = scalar keys %{$this->{PrivateTagInfo}->{$selected_tag}};

  my $details = PhiFixer::PrivateTagInfo::get_info($selected_tag);

  my $disposition = $this->GetDispositionFromDetails($http, $dyn, $details);
  $this->{DispositionRecommended} = $disposition;

  my $also_in_phi_list = '';
  if (defined $this->{PrivateTags}->{$selected_tag}) {
    $also_in_phi_list = qq{
      <span class="label label-danger">
        This tag is also in the PHI List!
      </span>
    };
  }

  $this->RefreshEngine($http, $dyn, qq{
    <h1>$selected_tag</h1>
    <h3>
      Affected Files: <span class="label label-info">$affected_files</span>
      $also_in_phi_list
    </h3>
    <h3>Recommended Disposition: <span class="label label-default">$disposition_map->{$disposition}</span></h3>
    <div class="form-group" style="width:60%;">
      <div class="input-group">
        <span class="input-group-btn">
          <?dyn="NotSoSimpleButton" op="ApplyDispositionToAll" caption="Apply Disposition" sync="Update();" class="btn btn-warning"?>
        </span>
        <?dyn="DrawDispoDropdown"?>
      </div>
    </div>
    <div class="panel panel-default">
      <div class="panel-heading">
        Tag Details
      </div>
      <div class="panel-body">
  });

  $this->DrawTagDetails($http, $dyn, $details);

  $this->RefreshEngine($http, $dyn, qq{
    </div>
  });
}

sub DrawDispoDropdown {
  my($this, $http, $dyn) = @_;

  if (not defined $this->{DispositionSelected}) {
    $this->{DispositionSelected} = $this->{DispositionRecommended};
  }

  $this->DrawSelectFromHash($http, $dyn, "SetDispoDropdown", 
    $disposition_map, $this->{DispositionSelected});
}

sub SetDispoDropdown {
  my($this, $http, $dyn) = @_;

  $this->{DispositionSelected} = $dyn->{value};
}

sub ApplyDispositionToAll {
  my($this, $http, $dyn) = @_;

  my $selected_tag = $this->{PrivateTagsToReview}->[$this->{SelectedPriv}];
  my $disposition = $this->{DispositionSelected};

  $this->{DisposedPrivate}->{$selected_tag} = $disposition;

  unless ($disposition eq 'R' or $disposition eq '0') {
    # if this tag is in the list for PHI review, we can
    # remove it now, as any action other than (R)eview
    # will eliminate any possible PHI.

    $this->{Disposed}->{$selected_tag} = 1;
  }

  DEBUG "ApplyDispositionToAll: $selected_tag => $disposition";

  # remove the selected tag from the list
  splice(@{$this->{PrivateTagsToReview}}, $this->{SelectedPriv}, 1);

  # move the selected index up one if we were at the end of the list
  if ($this->{SelectedPriv} >= scalar(@{$this->{PrivateTagsToReview}})) {
    $this->{SelectedPriv} -= 1;
  }

  # if there is nothing more to do here, move on to PHI display
  if ($this->{SelectedPriv} == -1) {
    $this->{InfoMode} = 'InfoTagValueMode';
  }

  # clear the disposition setting
  delete $this->{DispositionSelected};
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
      $http->queue("$tags{$i}<br></input>");
    } else {
      $http->queue("...<br></input>");
      last render;
    }
  }
}
sub SetSelectedPriv{
  my($this, $http, $dyn) = @_;
  my $value = $dyn->{value};

  # unset the selected disposition
  delete $this->{DispositionSelected};

  if($dyn->{checked} eq "true"){
     $this->{SelectedPriv} = $value;
     $this->{ContentMode} = "PrivateTagReviewContent";
  } else {
    $this->{SelectedPriv} = -1;  # a value that can't exist
    $this->{ContentMode} = "WaitingForTag";
  }
  # $this->ClearFileSelection($http, $dyn);
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
  delete $this->{DispoChecks}; # ensure old checks aren't carried over
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
sub GetAffectedFilesCount {
  my($this, $http, $dyn, $tag) = @_;
  # Get the number of files affected by the tag
  # It may be in both sets (PHI and Private), but the numbers should match

  if (defined $this->{PrivateTagInfo}->{$tag}) {
    return scalar keys %{$this->{PrivateTagInfo}->{$tag}};
  }

  if (defined $this->{ByTag}->{$tag}) {
    # have to count the files in every sub-key of the tag
    my $total = 0;
    while (my ($sub, $files) = each %{$this->{ByTag}->{$tag}}) {
      $total += scalar keys %{$files};
    }

    return $total;
  }

  # something bad has happened
  return -1;
}

sub DrawSelectionSummary {
  my($this, $http, $dyn, $selection, $map) = @_;

  # sort tags into groups based on their disposition
  my $selection_by_disp = {};

  while (my ($tag, $disp) = each %{$selection}) {
    $selection_by_disp->{$disp}->{$tag} = 1;
  }

  $http->queue(qq{
    <table class="table">
    <tr>
      <th>Disposition</ht>
      <th>Tag</th>
      <th>Files</th>
    </tr>
  });
  for my $disp (sort keys %{$selection_by_disp}) {
    my $tag_hash = $selection_by_disp->{$disp};
    $http->queue(qq{
      <tr>
        <td>$map->{$disp}</td>
      </tr>
    });
    for my $tag (sort keys %{$tag_hash}) {
      my $count = $this->GetAffectedFilesCount($http, $dyn, $tag);
      $http->queue(qq{
        <tr>
          <td></td>
          <td>$tag</td>
          <td>$count</td>
        </tr>
      });
    }
    # $http->queue(qq{
    # });
  }

  $http->queue(qq{
    </table>
  });
}

sub AllTagsDisposed {
  my($this, $http, $dyn) = @_;

  $http->queue(qq{
    <h2>Private Tag Selections</h2>
  });
  $this->DrawSelectionSummary($http, $dyn,
    $this->{DisposedPrivate}, $disposition_map);

  $http->queue(qq{
    <h2>PHI Tag Selections</h2>
  });

  # Add in CPLX just before drawing summary
  # This was omitted originally to keep it out of the disposition dropdown
  $phi_disposition_map->{CPLX} = 'Complex, per-value';
  $this->DrawSelectionSummary($http, $dyn,
    $this->{DisposedPHI}, $phi_disposition_map);


  $this->RefreshEngine($http, $dyn, qq{
    <p>The above changes will be applied immediately. Do you wish to continue?</p>
    <div class="btn-group">
      <?dyn="NotSoSimpleButton" caption="Yes, Continue" op="FixAllYes" sync="Update();"?>
      <?dyn="NotSoSimpleButton" caption="No, Don't Continue" op="FixAllNo" sync="Update();"?>
    </div>
  });

}

sub shift_temp {
  my ($this, $tag, $file) = @_;
  #TODO: This default value is almost certainly wrong!
  my $val = 'SHIFT';

  if (defined $this->{ByFile}->{$file}->{$tag}) {
    my $orig_val = [keys %{$this->{ByFile}->{$file}->{$tag}}]->[0];

    # For now, only going to do this for date VRs
    my $VR = $this->{DD}->get_ele_by_sig($tag)->{VR};
    my $format;

    if ($VR eq 'DA') {
      # parse as a date
      $format = '%Y%m%d';
    } 
    if ($VR eq 'DT') {
      # parse as datetime
      $format = '%Y%m%d%H%M%S';
    }

    if (defined $format) {
      my $date = Time::Piece->strptime($orig_val, $format);
      $date += (ONE_DAY * $this->{RootsInfo}->{date_inc});
      $val = $date->strftime($format);
    }
  }
  return ['short_ele_replacements', $val];
}

sub hash_temp {
  my ($this, $tag, $file) = @_;
  # same for every tag/file
  my $info = $this->{RootsInfo};
  my $uid_root = "1.3.6.1.4.1.14519.5.2.1.$info->{site_code}.$info->{collection_code}";

  return ['hash_unhashed_uid', $uid_root];
}

sub translate_dispositions {
  my ($this, $tags, $from_file, $to_file) = @_;
  # Translate the dispos into actions for the subprocess editor

  # the possible actions
  my $action_map = {
    Z => 'full_ele_replacements',
    X => 'full_ele_deletes',
    K => 'none',
    C => 'full_ele_replacements',
    R => 'none',
    0 => 'none',
    S => \&shift_temp,
    H => \&hash_temp,
  };

  my $actions = {};

  for my $tag (keys %$tags) {
    my $disp = $tags->{$tag};
    my $action = $action_map->{$disp};

    my $val = 1;  # default value, will work for delete

    if ($action eq 'full_ele_replacements') {
      # replace the value with a blank
      $val = " ";
    }

    # if action is code
    if (ref($action) eq 'CODE') {
      ($action, $val) = @{&$action($this, $tag, $from_file)};
    }

    $actions->{$action}->{$tag} = $val;

  }

  delete $actions->{none};  # nothing to do for them
  $actions->{to_file} = $to_file;
  $actions->{from_file} = $from_file;

  # print Dumper($actions);
  return $actions;
}

sub FixAllYes {
  my($this, $http, $dyn) = @_;

  # first some things that we'll need
  $this->{Collection};
  $this->{FileInfo}; # may be a list of every file in the collection?
                     # No, Bill says this is the files this PHI list concerns


  # Let's start by looking at some of the files to fix, Private first.

  # Affected filenames are here:
  # $this->{PrivateTagInfo}->{$tag}

  my $subjects = {};
  # Add the private tags to the list
  for my $tag (keys %{$this->{DisposedPrivate}}) {
    for my $file (keys %{$this->{PrivateTagInfo}->{$tag}}){
      if (defined $this->{FileInfo}->{$file}) {
        $subjects->{$this->{FileInfo}->{$file}->{patient_id}}->{$file}->{$tag}
          = $this->{DisposedPrivate}->{$tag};
      }
    }
  }
  # Add the PHI tags/files to the list
  for my $tag (keys %{$this->{DisposedPHI}}) {
    for my $val (keys %{$this->{ByTag}->{$tag}}) {
      for my $file (keys %{$this->{ByTag}->{$tag}->{$val}}) {
        if (defined $this->{FileInfo}->{$file}) {
          # if its a complex dispo, set correctly here
          if ($this->{DisposedPHI}->{$tag} eq 'CPLX') {
            $subjects->{$this->{FileInfo}->{$file}->{patient_id}}->{$file}->{$tag}
              = $this->{ComplexDispo}->{$tag}->{$val};
          } else {
            $subjects->{$this->{FileInfo}->{$file}->{patient_id}}->{$file}->{$tag}
              = $this->{DisposedPHI}->{$tag};
          }
        }
      }
    }
  }


  for my $subj (sort keys %$subjects) {
    my $files_with_changes = [keys %{$subjects->{$subj}}];

    my $f = $files_with_changes->[0];  # the first file

    my $source_path = dirname($f);

    my $files_dir = get_subj_files_path($f);
    my $all_files = get_dicom_in_dir($files_dir);

    # now.. get the difference of them.. found this on some StackOverflow ans
    my @unchanged_files = grep(!defined $subjects->{$subj}->{$_}, @$all_files);

    $this->RequestLockForEdit($subj, sub {
      my($lines) = @_;

      my %args;
      for my $line (@$lines){
        if($line =~ /^(.*):\s*(.*)$/){
          my $k = $1; my $v = $2;
          $args{$k} = $v;
        }
      }

      unless (defined $args{Locked} and $args{Locked} eq 'OK') {
        print "Failed to get lock! Aborting!\n";
        return;
      }

      my $destination_path = $args{'Destination File Directory'};

      # print Dumper(\%args);

      # unchanged -> link
      # changed -> make the required adjustments

      my $files_to_link = {};
      for my $f (@unchanged_files) {
        my $bn = basename($f);
        $files_to_link->{$bn} = md5_hex($bn);  # just hash the filename,
                                               # should be enough
      }

      # Build the list of changes
      my $change_list = {};
      for my $f (@$files_with_changes) {
        my $file = basename($f);
        my $tags = $subjects->{$subj}->{$f};

        $change_list->{$f} = translate_dispositions($this, $tags, 
                                                    "$source_path/$file",
                                                    "$destination_path/$file");
      }

      my $revision_dir = $args{'Revision Dir'};
      # put things together
      my $fix_hash = {
        source => $source_path,
        destination => $destination_path,
        operation => 'EditAndAnalyze',
        parallelism => 5,
        FileEdits => $change_list,
        files_to_link => $files_to_link,
        info_dir => $revision_dir,  # required
        cache_dir => "$this->{DicomInfoCache}/dicom_info",
      };

      my $pinfo = "$revision_dir/edits.pinfo";
      DEBUG "Saving pinfo to: $pinfo";
      store($fix_hash, $pinfo);

      $this->TestTestTestAfterLock($args{Id}, $pinfo);

    });
  }

  $this->{ContentMode} = "AllDoneHere";
  $this->AutoRefresh;
}

sub AllDoneHere {
  my($this, $http, $dyn) = @_;

  $http->queue("All done!");

  $this->NotSoSimpleButton($http, {
    op => "ResetEverything",
    caption => "Begin again",
    sync => "Update();",
  });
}

sub ResetEverything {
  my($this, $http, $dyn) = @_;

}

################################################################################
# TODO: cleanup
################################################################################
sub RequestLockForEdit{
  my($this, $subj, $at_end) = @_;

  DEBUG "RequestLockForEdit";

  my $collection = $this->{Collection};
  my $site = $this->{Site};
  my $user = $this->get_user;
  my $session = $this->{session};
  my $pid = $$;
  $this->LockExtractionDirectory({
    Collection => $collection,
    Site => $site,
    Subject => $subj,
    Session => $session,
    User => $user,
    Pid => $pid,
    For => "Edit",
   }, $at_end);
}

sub LockExtractionDirectory{
  my($this, $args, $when_done) = @_;
  # delete $this->{DirectoryLocks};
  DEBUG "LockExtractionDirectory";
  my @lines;
  push(@lines, "LockForEdit");
  for my $k (keys %$args){
    unless(defined($k) && defined($args->{$k})){ next }
    push(@lines, "$k: $args->{$k}");
  }

  DEBUG "Locking with these lines:";
  DEBUG Dumper(@lines);

  if($this->SimpleTransaction($this->{Environment}->{ExtractionManagerPort},
    [@lines],
    $when_done)
  ){
    return;
  }
}

sub TestTestTestAfterLock {
  my($this, $id, $commands) = @_;

  # Look here for a good example:
  # WhenExtractionLockComplete

  my $session = $this->{session};
  my $pid = $$;
  my $user = $this->get_user;
  my $new_args = [
    "ApplyEdits", 
    "Id: $id",
    "Session: $session", 
    "User: $user", 
    "Pid: $pid" ,
    "Commands: $commands" 
  ];

  DEBUG "==========================";
  DEBUG Dumper($new_args);
  DEBUG "==========================";
  $this->SimpleTransaction($this->{Environment}->{ExtractionManagerPort},
    $new_args,
    $this->TestWhenDoneTest());
}

sub TestWhenDoneTest {
  return sub {
    DEBUG "TestTestTest completed?";
  };
}

################################################################################
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
  $this->RefreshEngine($http, $dyn, qq{
    <h1>$tag</h1>
    <div class="form-group" style="width:60%;">
      <div class="input-group">
        <span class="input-group-btn">
          <?dyn="NotSoSimpleButton" op="DisposeTag" caption="Apply Disposition" sync="Update();" class="btn btn-warning"?>
        </span>
        <?dyn="DrawPHIDispoDropdown"?>
      </div>
    </div>
    <hr/>
  });
  my @constituents = split(/\[<\d+>\]/,$tag);
  for my $i (@constituents){
    $this->TagInfo($http, $dyn, $i);
  }
  $this->TagValueReport($http, $dyn, $tag);
}

sub DrawPHIDispoDropdown {
  my($this, $http, $dyn) = @_;


  # Set a default when first drawing
  if (not defined $this->{PHIDispositionSelected}) {
    $this->{PHIDispositionSelected} = 'C';
  }

  $this->DrawSelectFromHash($http, $dyn, "SetPHIDispoDropdown", 
    $phi_disposition_map, $this->{PHIDispositionSelected});
}
sub SetPHIDispoDropdown {
  my($this, $http, $dyn) = @_;

  $this->{PHIDispositionSelected} = $dyn->{value};
}

sub TagInfo{
  my($this, $http, $dyn, $tag) = @_;
  my $tag_name = UNKNOWN;
  my $vr = UNKNOWN;
  my $vm = UNKNOWN;
  my $keyword = UNKNOWN;

  $http->queue(qq{
    <div class="panel panel-default">
      <div class="panel-heading">
        <strong>Tag:</strong> $tag
      </div>
      <div class="panel-body">
  });
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
    # this is a private tag


    my $owner = $2;
    my $grp = hex($1);
    my $ele = hex($3);
    if(exists $this->{DD}->{PvtDict}->{$owner}->{$grp}->{$ele}){
      my $d = $this->{DD}->{PvtDict}->{$owner}->{$grp}->{$ele};
      $http->queue(" <p>$d->{VR}, $d->{VM}, $d->{Name}</p>");
    } else {
      $http->queue(" Unknown private tag");
    }

    my $details = PhiFixer::PrivateTagInfo::get_info($tag);
    $this->DrawTagDetails($http, $dyn, $details);

  } else {
    $http->queue(" no pattern match\n");
  }
  $http->queue("</div></div>");
}

sub DrawTagDetails {
  # Draw the details about the given tag,
  # #details should be the results from
  # PhiFixer::PrivateTagInfo::get_info
  my($this, $http, $dyn, $details) = @_;

    my $fields = {
      pt_signature => "Signature",
      pt_consensus_name => "Consensus Name",
      pt_consensus_vr => "Consensus VR",
      pt_consensus_vm => "Consensus VM",
      pt_consensus_disposition => "Disposition",
    };

    $http->queue(qq{
      <div class="panel panel-default panel-body">
      <table class="table table-condensed">
    });

    for my $detail_row (@{$details}) {
      for my $key (sort keys %{$fields}) {
        $http->queue(qq{
          <tr>
            <td>$fields->{$key}</td>
            <td>$detail_row->{$key}</td>
          </tr>
        });
      }
    }
    $http->queue("</table></div>");
}
sub TagValueReport{
  my($this, $http, $dyn, $tag) = @_;


  $http->queue(qq{
    <hr/>
    <table class="table table-condensed table-bordered">
    <tr>
      <th>Value</th>
      <th>Study Dates</th>
      <th>Unshifted Study Dates</th>
      <th># Patients</th>
      <th># Studies</th>
      <th># Series</th>
      <th># Modalities</th>
      <th># SOP Classes</th>
      <th># Files</th>
      <th>Dispose</th>
      <th>Select</th>
    </tr>
  });
  for my $v (keys %{$this->{ByTag}->{$tag}}){
    if (defined $this->{DispoChecks}->{$v} and $this->{DispoChecks}->{$v} == 2){
      # dispo already applied to this row
      next;
    }

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

    my $dates = $this->GetStudyDates([keys %{$this->{ByTag}->{$tag}->{$v}}]);
    if($dates->[0] eq $dates->[$#{$dates}]){  # if 0 ele eq last ele? should not just check for length?
      $http->queue("<td>$dates->[0]</td>");
    } else {
      $http->queue("<td>$dates->[0] - $dates->[$#{$dates}]</td>");
    }

    my $dates = $this->GetUnshiftedStudyDates([keys %{$this->{ByTag}->{$tag}->{$v}}]);
    if($dates->[0] eq $dates->[$#{$dates}]){
      $http->queue("<td>$dates->[0]</td>");
    } else {
      $http->queue("<td>$dates->[0] - $dates->[$#{$dates}]</td>");
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

    # default to on, so set it as so here
    if (not defined $this->{DispoChecks}->{$v}){
      $this->{DispoChecks}->{$v} = 1;
    }

    $http->queue(
      "<td>" . 
      $this->CheckBoxDelegate("DisposeCheck", $v,
        $this->{DispoChecks}->{$v},
        { op => "DisposeCheckClicked", sync => "Update();" }
      ) .
      "</td>"
    );

    # draw the select box
    $http->queue("<td>");
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

sub DisposeCheckClicked {
  my($this, $http, $dyn) = @_;
  my $id = $dyn->{value};

  if (defined $this->{DispoChecks}->{$id}){
    $this->{DispoChecks}->{$id} = !$this->{DispoChecks}->{$id};
  }
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
    delete $this->{SelectedTagFullValue};

    # Get the full tag value
    $this->{ReadingFullTagValue} = 1;

    $this->SemiSerializedSubProcess("GetElementValue2.pl \"" .
      $this->{SelectedFileForExtraction} . "\" '" .
      $this->{SelectedTagForExtraction} . "'",
      $this->FullTagRead);
  }
}
sub FileAndTagSelected{
  my($this, $http, $dyn) = @_;
  my $tag_disp = $this->{SelectedTagForExtraction};
  $tag_disp =~ s/</&lt;/g;
  $tag_disp =~ s/>/&gt;/g;
  $this->RefreshEngine($http, $dyn, qq{
    <p>
      <?dyn="NotSoSimpleButton" op="ClearFileSelection" caption="Clear File Selection" sync="Update();"?>
    </p>
    <div class="panel panel-default">
      <div class="panel-heading">File Selected</div>
      <div class="panel-body">
        $this->{SelectedFileForExtraction}
      </div>
    </div>

    <div class="panel panel-default">
      <div class="panel-heading">
        Tag Selected
      </div>
      <div class="panel-body">
        $tag_disp
      </div>
    </div>
  });
  $http->queue(qq{
    <div class="panel panel-default">
      <div class="panel-heading">
        Value Selected
      </div>
      <div class="panel-body">
        $this->{SelectedValueForExtraction}
      </div>
    </div>
  });
  $http->queue(qq{
    <div class="panel panel-default">
      <div class="panel-heading">
        Matching Tag Instances and Raw Data
      </div>
      <div class="panel-body">
  });

  if(exists $this->{ReadingFullTagValue}){
    $http->queue("&lt;waiting&gt;<br>");
  } else {
    $http->queue("<ul class=\"list-group\">");
    for my $k (sort keys %{$this->{SelectedTagFullValue}}) {
      $http->queue(qq{
        <li class="list-group-item">
          <p>$k</p>
          <pre style="overflow: auto; word-wrap: normal;">$this->{SelectedTagFullValue}->{$k}</pre>
        </li>
      });
    }
    $http->queue("</ul>");
  }
  $http->queue("</div></div>");

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
sub FullTagRead{
  my($this) = @_;
  my $sub = sub {
    my($status, $result) = @_;
    # TODO: Should this only set to $result if $success is good?
    $this->ProcessFullTagValues($result);
  };
  return $sub;
}
sub ProcessFullTagValues {
  my($this, $result) = @_;
    # drop all entries where the value does not contain our intended string
    my $val = $this->{SelectedValueForExtraction};

    for my $k (keys %{$result}) {
      my $testval = $result->{$k};

      my $compare = index($testval, $val);

      unless ($compare != -1) {
        delete $result->{$k};
      }
    }

    # last step after everything is good
    delete $this->{ReadingFullTagValue};
    $this->{SelectedTagFullValue} = $result;
    $this->AutoRefresh;
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
sub GetUnshiftedStudyDates{
  my($this, $list) = @_;
  my $format = '%Y%m%d';

  my $dates = $this->GetStudyDates($list);
  my $shifted_dates = [];

  for my $d (@$dates) {
    my $date = Time::Piece->strptime($d, $format);
    $date -= (ONE_DAY * $this->{RootsInfo}->{date_inc});
    push @$shifted_dates, $date->strftime($format);
  }

  return $shifted_dates;
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

  my $disposition = $this->{PHIDispositionSelected};

  # check to see if there are any Values without Dispo checked
  my $undisposed_exist = 0;
  for my $val (keys %{$this->{DispoChecks}}) {
    if ($this->{DispoChecks}->{$val} != 1){ # 0 or 2 trigger this
      $undisposed_exist = 1;
      last;
    }
  }

  if ($undisposed_exist) {  # This is a ComplexDisposition
    DEBUG "ComplexDisposition!";
    my $undisposed_remain = 0;

    for my $val (keys %{$this->{DispoChecks}}) {
      if ($this->{DispoChecks}->{$val} == 1){
        $this->{ComplexDispo}->{$tag}->{$val} = $disposition;
        $this->{DispoChecks}->{$val} = 2;  # mark it as done
        DEBUG "DisposeComplex $tag - $val => $disposition";
      } elsif ($this->{DispoChecks}->{$val} == 0) {
        $undisposed_remain = 1;
      }
    }

    if ($undisposed_remain) {
      return;
    } else {
      $disposition = 'CPLX';
    }
  }

  delete $this->{SelectedEles}->{$tag};
  delete $this->{SelectedFileForExtraction};
  delete $this->{SelectedTagForExtraction};
  delete $this->{SelectedValueForExtraction};
  delete $this->{DispoChecks};
  $this->{Disposed}->{$tag} = 1;
  $this->SelectNextAvailableTag;

  $this->{DisposedPHI}->{$tag} = $disposition;
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
