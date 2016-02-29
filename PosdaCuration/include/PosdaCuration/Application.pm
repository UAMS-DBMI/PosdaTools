#!/usr/bin/perl -w
#
use strict;
package PosdaCuration::Application;
use Posda::DataDict;
use PosdaCuration::GeneralPurposeEditor;
use Posda::HttpApp::JsController;
use Dispatch::NamedObject;
use Posda::HttpApp::DebugWindow;
use Posda::HttpApp::Authenticator;
use Posda::FileCollectionAnalysis;
use Posda::Nicknames;
use Posda::UUID;
use Dispatch::NamedFileInfoManager;
use Dispatch::LineReader;
use PosdaCuration::InfoExpander;
use PosdaCuration::DuplicateSopResolution;
use Fcntl qw(:seek);
use File::Path 'remove_tree';
use Digest::MD5;
use JSON::PP;
use Debug;
use Storable;
my $dbg = sub {print STDERR @_ };
use utf8;
use vars qw( @ISA );
@ISA = ( "Posda::HttpApp::JsController", "Posda::HttpApp::Authenticator",
  "PosdaCuration::InfoExpander" );

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
  $this->{title} = "Posda Curation Tools";
  $this->{RoutesBelow}->{GetHeight} = 1;
  $this->{RoutesBelow}->{GetWidth} = 1;
  $this->{RoutesBelow}->{GetJavascriptRoot} = 1;
  $this->{RoutesBelow}->{StartChildDisplayer} = 1;
  $this->{RoutesBelow}->{GetLoginTemp} = 1;
  $this->{RoutesBelow}->{ApplyGeneralEdits} = 1;
  $this->{RoutesBelow}->{GetDisplayInfoIn} = 1;
  $this->{RoutesBelow}->{GetExtractionRoot} = 1;
  $this->{Exports}->{GetHeight} = 1;
  $this->{Exports}->{GetWidth} = 1;
  $this->{Exports}->{GetJavascriptRoot} = 1;
  $this->{Exports}->{StartChildDisplayer} = 1;
  $this->{Exports}->{GetLoginTemp} = 1;
  $this->{Exports}->{ApplyGeneralEdits} = 1;
  $this->{Exports}->{GetDisplayInfoIn} = 1;
  $this->{Exports}->{GetExtractionRoot} = 1;
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
  my $width = 1400;
  # my $width = 1200;
  my $height = $this->{Identity}->{height};
  $this->{title} = $this->{Identity}->{Title};
  $this->{database_host} =
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{database_host};
  $this->{height} = $height;
  $this->{width} = $width;
  $this->{menu_width} = 100;
  $this->{content_width} = $this->{width} - $this->{menu_width};
  $this->SetInitialExpertAndDebug("bbennett");
  if($this->CanDebug){
    Posda::HttpApp::DebugWindow->new($sess, "Debug");
  }
  $this->{JavascriptRoot} =
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{JavascriptRoot};
  $this->{ExtractionManagerPort} =
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{ExtractionManagerPort};
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
  my $user_data_root =
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{UserInfoDir};
  unless(-d $user_data_root) { die "$user_data_root doesn't exist" }
  $this->{UserDataDir} = "$user_data_root/" . $this->get_user;
  unless(-d $this->{UserDataDir}){
    unless(mkdir $this->{UserDataDir}){
      die "Can't mkdir $this->{UserDataDir} ($!)";
    }
  }
  $this->{UserHistoryFile} = "$this->{UserDataDir}/History.pinfo";
  if(-f $this->{UserHistoryFile}){
    eval { $this->{UserHistory} =
      Storable::retrieve($this->{UserHistoryFile}) };
  } else {
    $this->{UserHistory} = {};
  }
  $this->{ExitOnLogout} = 1;
  $this->{DicomInfoCache} =
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{DicomInfoCache};
  $this->{ExtractionRoot} =
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{ExtractionRoot};
  $this->{mode} = "Collections";
  $this->StartLockChecker;
  return $this;
}
sub GetExtractionRoot{
  my($this) = @_;
  return $this->{ExtractionRoot};
}
sub GetDisplayInfoIn{
  my($this) = @_;
  return $this->{DisplayInfoIn};
}
sub SaveUserHistory{
  my($this) = @_;
  store $this->{UserHistory}, $this->{UserHistoryFile};
}
sub user{
  my($this, $http, $dyn) = @_;
  $http->queue($this->get_user);
}
sub GetLoginTemp{
  my($this) = @_;
  return $this->{LoginTempDir};
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
print STDERR "In Content\n";
  $this->RefreshEngine($http, $dyn, $content);
}
sub StartChildDisplayer{
  my($this, $obj) = @_;
  $this->StartJsChildWindow($obj);
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
sub MenuResponse{
  my($this, $http, $dyn) = @_;
  if($this->{mode} eq "Collections"){
    $this->CollectionsMenu($http, $dyn);
  } else {
    my $resp = 
     '<span onClick="javascript:alert(' . 
         "'This is a test'" .
         ');">test' .
         '</span>';
    $http->queue($resp);
  };
}
sub ContentResponse{
  my($this, $http, $dyn) = @_;
  unless(defined $this->{mode}){ $this->{mode} = "--- select mode ---" }
  if($this->{mode} eq "Collections"){
    return $this->Collections($http, $dyn);
  } elsif($this->{mode} eq "--- select mode ---"){
    return $http->queue("You need to select a mode above");
  }
  $http->queue("No handler yet for \"$this->{mode}\"");
}
sub ModeMenu{
  my($this, $http, $dyn) = @_;
  unless(defined $this->{mode}) { $this->{mode} = "--- select mode ---" }
  for my $i (
    "--- select mode ----", "Collections"
  ){
    $http->queue("<option value=\"$i\"" .
      ($i eq $this->{mode} ? " selected" : "") .
      ">$i</option>");
  }
}
sub ChangeMode{
  my($this, $http, $dyn) = @_;
  $this->{mode} = $dyn->{value};
}
sub CollectionsMenu{
  my($this, $http, $dyn) = @_;
  $this->MakeMenu($http, $dyn,
    [
      { type => "host_link_sync",
        condition => 1,
        style => "small",
        caption => "Refresh DB",
        method => "RefreshDbData",
        sync => "Update();",
      },
      { type => "host_link_sync",
        condition => 1,
        style => "small",
        caption => "Refresh Dir",
        method => "RefreshDirData",
        sync => "Update();",
      },
    ]);
}
sub CollectionLine{
  my($this, $http, $dyn, $lines) = @_;
  my $sub = sub {
    my($line) = @_;
    push(@$lines, $line);
  };
  return $sub;
}
sub CollectionEnd{
  my($this, $http, $dyn, $lines) = @_;
  my $sub = sub{
    $this->RefreshEngine($http, $dyn, qq{
      <div class="col-md-8">
      <div class="well">
        <div class="form-group">
          <label>Collection:</label>
          <?dyn="EntryBox" default="$this->{SelectingCollection}" op="EnterCollection" name="collection"?>
        </div>
        <div class="form-group">
          <label>Site:</label>
          <?dyn="EntryBox" default="$this->{SelectingSite}" op="EnterSite" name="site"?>
        </div>
        <?dyn="SimpleButton" op="SetCollectionAndSite" parm="foo" sync="Update();" caption="Query Database"?>
      </div>
      <div class="form-group">
        <?dyn="QueryHistory"?>
      </div>
    });

    $http->queue(qq{
      <table class="table table-hover">
      <tr>
        <th>
          Collection
        </th>
        <th>
          Site
        <th>
          Images
        </th>
        <th>
          Select
        </th>
      </tr>
    });
    for my $l (@$lines){
      my($col, $site, $num) = split(/\|/, $l);
      $http->queue(qq{
        <tr>
          <td>
            $col
          </td>
          <td>
            $site
          </td>
          <td>
            $num
          </td>
          <td>
      });
      $this->NotSoSimpleButton($http, {
        op=>"SetCollectionSiteButton",
        caption => "Select",
        sync => "Update();",
        col => $col,
        site => $site,
        class => "btn btn-primary"
      });
      $http->queue("</td></tr>");
    }
    $http->queue("</table></div>");
  };
  return $sub;
}
sub Collections{
  my($this, $http, $dyn) = @_;
  if(
    exists($this->{DbQueryInProgress}) ||
    exists $this->{ExtractionSearchInProgress}
  ){
    return $this->RefreshEngine($http, $dyn,
      '<?dyn="StatusOfDbQuery"?><hr>' .
      '<?dyn="StatusOfExtractionSearch"?><hr>');
  }
  unless(defined $this->{CollectionMode}) {
    $this->{CollectionMode} = "CollectionsSelection";
  }
  if($this->{CollectionMode} eq "CollectionsSelection"){
    unless(
      defined $this->{SelectedCollection} && defined $this->{SelectedSite}
    ){
      return $this->CollectionSelection($http, $dyn);
    }
    if($this->{CheckAgainstIntake}){
      return $this->CheckAgainstIntake($http, $dyn);
    }
    if($this->{CheckAgainstPublic}){
      return $this->CheckAgainstPublic($http, $dyn);
    }
    return $this->DbCollectionsAndExtractions($http, $dyn);
  } elsif($this->can($this->{CollectionMode})){
    my $meth = $this->{CollectionMode};
    $this->$meth($http, $dyn);
  } elsif($this->{CollectionMode} eq "MergeOpenDirectories"){
    return $this->MergeContent($http, $dyn);
  } elsif($this->{CollectionMode} eq "GeneralPurposeEditorContent"){
    return $this->GeneralPurposeEditorContent($http, $dyn);
  } else {
    die "Unknown CollectionMode: $this->{CollectionMode}";
  }
}

sub CollectionSelection{
  my($this, $http, $dyn) = @_;
  my @lines;
  Dispatch::LineReader->new_cmd(
  "GetCollectionId.pl \"$this->{Environment}->{database_name}\"",
  $this->CollectionLine($http, $dyn, \@lines),
  $this->CollectionEnd($http, $dyn, \@lines));
}
sub EnterCollection{
  my($this, $http, $dyn) = @_;
  $this->{SelectingCollection} = $dyn->{value};
}
sub EnterSite{
  my($this, $http, $dyn) = @_;
  $this->{SelectingSite} = $dyn->{value};
}
sub SetCollectionSiteButton{
  my($this, $http, $dyn) = @_;
  $this->{SelectingCollection} = $dyn->{col};
  $this->{SelectingSite} = $dyn->{site};
  $this->SetCollectionAndSite($http, $dyn);
}
sub SetCollectionAndSite{
  my($this, $http, $dyn) = @_;
  $this->{SelectedCollection} = $this->{SelectingCollection};
  $this->{SelectedSite} = $this->{SelectingSite};
  my $query_id = "$this->{SelectedCollection}//$this->{SelectedSite}";
  my $query_time = time;
  $this->{UserHistory}->{Queries}->{$query_id} = $query_time;
  $this->SaveUserHistory;
  delete $this->{DbResults};
  delete $this->{ExtractionsHierarchies};
  $this->{DbQueryInProgress} = 1;
  $this->{ExtractionSearchInProgress} = 1;
  $this->StartDbQuery;
  $this->StartExtractionSearch;
}
sub QueryHistory{
  my($this, $http, $dyn) = @_;
  my @queries = sort {
    $this->{UserHistory}->{Queries}->{$b}
  <=>
    $this->{UserHistory}->{Queries}->{$a}
  } keys %{$this->{UserHistory}->{Queries}};
  unless(@queries > 0) { return }
  unless(defined $this->{SelectedDicomDestination}){
    $this->{SelectedDicomDestination} = "---- select previous ----";
  }
  $this->RefreshEngine($http, $dyn, '<?dyn="SelectByValue" ' .
    'op="SetHistoricalQuery"?>');
  for my $i ("---- recent queries ----", @queries){
    $http->queue("<option value=\"$i\"" .
      ($i eq "---- recent queries ----" ? " selected" : "") .
      ">$i</option>");
  }
  $http->queue('</select>');
}
sub SetHistoricalQuery{
  my($this, $http, $dyn) = @_;
  my $value = $dyn->{value};
  if($value =~ /^([^\/]+)\/\/([^\/]+)$/){
     my $collection = $1;
     my $site = $2;
     $this->{SelectingCollection} = $collection;
     $this->{SelectingSite} = $site;
     $this->SetCollectionAndSite;
  }
}
#############################################
sub DbCollectionsAndExtractions{
  my($this, $http, $dyn) = @_;
  $this->GetExtractionLocks($this->ContinueDbCollectionsAndExtractions(
    $http, $dyn));
  if($this->{Environment}->{IsNlstCuration}){
    unless(
      exists($this->{PatientIdToName}) && exists($this->{PatientIdToSort})
    ){
      $this->{PatientIdToName} = {};
      $this->{PatientIdToSort} = {};
      for my $id (keys %{$this->{DbResults}}){
        my @names = keys %{$this->{DbResults}->{$id}->{pat_name}};
        my $pat_name = "0^ACRIN^INCONSISTENT";
        my $sort = 0;
        if(@names == 1){
          $pat_name = $names[0];
          my $foo;
          ($sort, $foo) = split(/\^/, $pat_name);
        }
        $this->{PatientIdToName}->{$id} = $pat_name;
        $this->{PatientIdToSort}->{$id} = $sort;
      }
    }
    unless(
      exists($this->{BadNlstPatientList}) && 
      exists($this->{GoodNlstPatientList})
    ){
      $this->{BadNlstPatientList} = {};
      $this->{GoodNlstPatientList} = {};
      my $good_file = $this->{Environment}->{NlstGoodPatlist};
      my $bad_file = $this->{Environment}->{NlstBadPatlist};
      if(defined($good_file) && -r $good_file){
        open my $fh, "<$good_file";
        while(my $line = <$fh>){
          chomp $line;
          $this->{GoodNlstPatientList}->{$line} = 1;
        }
      }
      if(defined($bad_file) && -r $bad_file){
        open my $fh, "<$bad_file";
        while(my $line = <$fh>){
          chomp $line;
          $this->{BadNlstPatientList}->{$line} = 1;
        }
      }
    }
  }
}
sub ContinueDbCollectionsAndExtractions{
  my($this, $http, $dyn) = @_;
  my $sub = sub {
    $this->{CollectionRows} = {};
    for my $subj (keys %{$this->{DbResults}}){
      $this->{CollectionRows}->{$subj} = 1;
    }
    for my $subj (keys %{$this->{ExtractionsHierarchies}}){
      $this->{CollectionRows}->{$subj} = 1;
    }
    $this->RefreshEngine($http, $dyn, qq{
      <?dyn="SimpleButton" op="NewQuery" caption="New Query" sync="Update();"?>
      <hr>

      <h3>Collection: $this->{SelectedCollection}</h3>
      <h4>Site: $this->{SelectedSite}</h4>

      <p><?dyn="Collection_Site_Counts"?></p>
      <p>
        <a class="btn btn-sm btn-primary" href="DownloadCounts?obj_path=$this->{path}\">Download CSV</a>
      </p>

      <div class="form-group">
        <div class="btn-group" role="group">
          <?dyn="IntakeCheckButtons"?>
          <?dyn="PublicCheckButtons"?>
        </div>
      </div>

      <div class="form-group">
        <div class="btn-group" role="group">
          <?dyn="NotSoSimpleButton" caption="Delete Incomplete Extractions" op="DiscardIncompleteExtractions" sync="Update();"?>
          <?dyn="NotSoSimpleButton" caption="Extact All Unextracted" op="ExtractAllUnextracted" sync="Update();"?>
        </div>
      </div>

      <div class="form-group">
        <div class="btn-group" role="group">
          <?dyn="NotSoSimpleButton" caption="Scan All For PHI" op="ScanAllForPhi" sync="Update();"?>
          <?dyn="NotSoSimpleButton" caption="Remove All PHI Scans" op="RemoveAllPhiScans" sync="Update();"?>
        </div>
      </div>

      <div class="form-group">
        <div class="btn-group" role="group">
          <?dyn="NotSoSimpleButton" caption="Fix Study Inconsistencies" op="FixStudyInconsistencies" sync="Update();"?>
          <?dyn="NotSoSimpleButton" caption="Fix Series Inconsistencies" op="FixSeriesInconsistencies" sync="Update();"?>
          <?dyn="NotSoSimpleButton" caption="Fix Patient Inconsistencies" op="FixPatientInconsistencies" sync="Update();"?>
        </div>
      </div>
      <table class="table table-striped" width="100%">
        <thead>
        <tr>
          <th width="10%">Subject</th>
          <th width="45%">DB Info</th>
          <th width="45%">Extraction Info</th>
        </tr>
        </thead>
        <tbody>
        <?dyn="ExpandRows"?>
        </tbody>
      </table>
    });
  };
  return $sub;
};
sub IntakeCheckButtons{
  my($this, $http, $dyn) = @_;
  my $button = '<?dyn="SimpleButton" op="SetCheckAgainstIntake" ' .
    'caption="Check Against Intake" sync="Update();"?>';
  if(exists $this->{IntakeCheckHierarchy}){
    $button = '<?dyn="SimpleButton" op="ClearIntakeData" ' .
      'caption="Clear Intake Check" sync="Update();"?>';
  }
  $this->RefreshEngine($http, $dyn, $button);
}
sub PublicCheckButtons{
  my($this, $http, $dyn) = @_;
  my $button = '<?dyn="SimpleButton" op="SetCheckAgainstPublic" ' .
    'caption="Check Against Public" sync="Update();"?>';
  if(exists $this->{PublicCheckHierarchy}){
    $button = '<?dyn="SimpleButton" op="ClearPublicData" ' .
      'caption="Clear Public Check" sync="Update();"?>';
  }
  $this->RefreshEngine($http, $dyn, $button);
}
sub Collection_Site_Counts{
  my($this, $http, $dyn) = @_;
  my $subjects = 0;
  my $studies = 0;
  my $series = 0;
  my $files = 0;
  for my $p (keys %{$this->{DbResults}}){
    $subjects += 1;
    for my $st (keys %{$this->{DbResults}->{$p}->{studies}}){
      $studies += 1;
      my $se = $this->{DbResults}->{$p}->{studies}->{$st}->{series};
      for my $s (keys %{$se}){
        $series += 1;
        $files += $se->{$s}->{num_files};
      }
    }
  }
  $http->queue("Subjects: $subjects, Studies: $studies, " .
    "Series: $series, Files: $files&nbsp;&nbsp;");
}
sub OldDownloadCounts{
  my($this, $http, $dyn) = @_;
  my $col = $this->{SelectedCollection};
  my $site = $this->{SelectedSite};
  my $file = $col . "_$site";
  $file =~ s/ /_/g;
  $http->DownloadHeader("text/csv", "$file.csv");
  $http->queue('"Subject_id","Subject Name","Number of Studies",' .
    '"Number of Series","Number of Files"' . "\n");
  my $tot_subjects = 0;
  my $tot_studies = 0;
  my $tot_series = 0;
  my $tot_files = 0;
  for my $p (sort keys %{$this->{DbResults}}){
    $tot_subjects += 1;
    my $studies = 0;
    my $series = 0;
    my $files = 0;
    my $patient_name;
    if(keys %{$this->{DbResults}->{$p}->{pat_name}} == 1){
      $patient_name = [keys %{$this->{DbResults}->{$p}->{pat_name}}]->[0];
    } elsif (keys %{$this->{DbResults}->{$p}->{pat_name}} < 1){
      $patient_name = "&lt;undef&gt;";
    } else {
      $patient_name = "&lt;inconsistent&gt;";
    }
    for my $st (keys %{$this->{DbResults}->{$p}->{studies}}){
      $tot_studies += 1;
      $studies += 1;
      my $se = $this->{DbResults}->{$p}->{studies}->{$st}->{series};
      for my $s (keys %{$se}){
        $tot_series += 1;
        $series += 1;
        $tot_files += $se->{$s}->{num_files};
        $files += $se->{$s}->{num_files};
      }
    }
    $http->queue("\"$p\",\"$patient_name\",\"$studies\"," .
      "\"$series\",\"$files\"\n");
  }
  $http->queue("\"Total\",$tot_subjects, $tot_studies," .
    "$tot_series, $tot_files\n");
}
sub DownloadCounts{
  my($this, $http, $dyn) = @_;
  my $col = $this->{SelectedCollection};
  my $site = $this->{SelectedSite};
  my $file = $col . "_$site";
  $file =~ s/ /_/g;
  $http->DownloadHeader("text/csv", "$file.csv");
  $http->queue('"PID","Image Type","Modality",' .
    '"Images","Study Date","Study Description","Series Description",' .
    '"Study Instance Uid","Series Instance UID", "Manufacturer",' .
    '"Model Name","Software Versions"' . "\n");
  my $cmd = "GetCountReportForDownload.pl " .
    "\"$this->{Environment}->{database_name}\" \"" .
    "$col\" \"" .
    "$site\"\n";
print STDERR "############################\nCommand:\n$cmd\n##########################\n";
  Dispatch::LineReader->new_cmd($cmd, $this->CountLine($http, $dyn),
    $this->DoneWithDownload);
}
sub CountLine{
  my($this, $http, $dyn) = @_;
  my $sub = sub {
    my($line) = @_;
    $http->queue("$line\n");
  };
}
sub DoneWithDownload{
  my($this) = @_;
  my $sub = sub {
  };
  return $sub;
}
sub NewQuery{
  my($this) = @_;
  delete $this->{SelectedCollection};
  delete $this->{SelectedSite};
  $this->ClearIntakeData;
  $this->ClearPublicData;
}
sub ExpandRows{
  my($this, $http, $dyn) = @_;
  my $col = $this->{SelectedCollection};
  my $site = $this->{SelectedSite};
  if($this->{Environment}->{IsNlstCuration}){
    for my $subj (
      sort {
        $this->{PatientIdToSort}->{$a} <=>
        $this->{PatientIdToSort}->{$b}
      } 
      keys %{$this->{CollectionRows}}
    ){
      $this->ExpandRow($http, $dyn, $col, $site, $subj);
    }
  } else{
    for my $subj (sort {$a cmp $b} keys %{$this->{CollectionRows}}){
      $this->ExpandRow($http, $dyn, $col, $site, $subj);
    }
  }
}
sub ExpandRow{
  my($this, $http, $dyn, $col, $site, $subj) = @_;
  if($this->{Environment}->{IsNlstCuration}){
    my $pat_name = $this->{PatientIdToName}->{$subj};
    if(exists $this->{BadNlstPatientList}->{$pat_name}){
      $http->queue("<tr style=\"background-color:Aqua\">");
    }elsif(exists $this->{GoodNlstPatientList}->{$pat_name}){
      $http->queue("<tr style=\"background-color:MistyRose\">");
    }elsif(exists $this->{GoodNlstPatientList}->{$pat_name}){
    }else{
      $http->queue("<tr style=\"background-color:white\">");
    }
  } else {
    $http->queue("<tr>");
  }
  $http->queue("<td valign=\"top\"><p>$subj</p>");
  $dyn->{subj} = $subj;
  if($this->{InfoSel}->{$col}->{$site}->{$subj}){
    $this->NotSoSimpleButton($http, {
       op => "CloseSubjInfo",
       subject => $subj,
       caption => "Close",
       sync => "Update();",
       class => "btn btn-sm btn-danger"
    });
  } else {
    $this->NotSoSimpleButton($http, {
       op => "OpenSubjInfo",
       subject => $subj,
       caption => "Open",
       sync => "Update();",
       class => "btn btn-sm btn-default"
    });
  }
  my @pat_name;
  for my $name (keys %{$this->{DbResults}->{$subj}->{pat_name}}){
    push @pat_name, $name;
  }
  my $patient_name;
   if($#{pat_name} > 0){
    $patient_name = "&lt;inconsistent&gt;";
  } else {
    $patient_name = $pat_name[0];
  }
  if($patient_name ne $subj){
    $http->queue("<p>$patient_name</p>");
  }
  $http->queue(qq{
    </td>
    <td valign="top" align="left">
      <table width="100%">
        <tr>
          <td valign="top" align="left">
  });
  $this->ExpandDbInfo($http, $dyn);
  $http->queue(qq{
          </td>
          <td valign="top" align="right">
          </td>
        </tr>
      </table>
    </td>
    <td valign="top">
  });
  $this->ExpandExtraction($http, $dyn);
  # TODO: This looks like too many tags?
  $http->queue(qq{
    </td>
    </tr>
    </td>
    </tr>});
}
sub ExpandDbInfo{
  my($this, $http, $dyn) = @_;
  my $col = $this->{SelectedCollection};
  my $site = $this->{SelectedSite};
  my $subj = $dyn->{subj};
  unless(exists $this->{DbResults}->{$subj}){
    return $http->queue("--");
  }
  unless(exists $this->{InfoSel}->{$col}->{$site}->{$subj}){
    $this->{InfoSel}->{$col}->{$site}->{$subj} = 0;
  }
  if($this->{InfoSel}->{$col}->{$site}->{$subj}){
    $this->ExpandSelectedDbInfo($http, $dyn);
  } else {
    $this->ExpandUnSelectedDbInfo($http, $dyn);
  }
}
sub ExpandSelectedDbInfo{
  my($this, $http, $dyn) = @_;
  unless(exists $this->{NickNames}) {
    $this->{NickNames} = Posda::Nicknames->new;
  }
  my $col = $this->{SelectedCollection};
  my $site = $this->{SelectedSite};
  my $subj = $dyn->{subj};
  my $studies = $this->{DbResults}->{$subj}->{studies};
  $this->ExpandStudyHierarchy($http, $dyn, $studies);
}
sub ExpandUnSelectedDbInfo{
  my($this, $http, $dyn) = @_;
  my $col = $this->{SelectedCollection};
  my $site = $this->{SelectedSite};
  my $subj = $dyn->{subj};
  $this->ExpandStudyCounts($http, $dyn, $this->{DbResults}->{$subj}->{studies});
}
sub ExpandExtraction{
  my($this, $http, $dyn) = @_;
  my $col = $this->{SelectedCollection};
  my $site = $this->{SelectedSite};
  my $subj = $dyn->{subj};
  if(exists $this->{DirectoryLocks}->{$col}->{$site}->{$subj}){
    my $lock_status = $this->{DirectoryLocks}->{$col}->{$site}->{$subj};
    my $reason = "edit";
    if($lock_status->{For} ne "PhiSearch"){
      if($lock_status->{NextRev} eq "0"){
        $reason = "extraction";
      } elsif($lock_status->{NextRev} eq "discard"){
        $reason = "discard";
      }
    }
    $reason = $lock_status->{For};
    my $status = $lock_status->{Status};
    $http->queue("locked for $reason ($status)");
    return;
  }
  unless(exists $this->{ExtractionsHierarchies}->{$dyn->{subj}}){
    unless($this->{mode} eq "Collections"){
      return $http->queue("--");
    }
  }
  unless(exists $this->{ExtractionsHierarchies}->{$dyn->{subj}}->{rev_hist}){
    my $rev_0_dir = "$this->{ExtractionRoot}/$this->{SelectedCollection}" .
      "/$this->{SelectedSite}/$dyn->{subj}/revisions/0";
    if(-d $rev_0_dir){
      $http->queue("Stale directory analysis");
    } else {
      $http->queue(qq{
        <div class="btn-group" role="group">
      });

      $http->queue($this->MakeHostLinkSync("Extract", "ExtractSubject", {
        subj => $dyn->{subj},
        for => "Extraction",
      }, 1, "Update();", "btn btn-xs btn-primary"));

      $http->queue($this->MakeHostLinkSync("Hide", "HideSubjectOK", {
        subj => $dyn->{subj},
      }, 1, "Update();", "btn btn-xs btn-default"));

      $http->queue(qq{
        </div>
      });
    }
    return;
  }
  if(exists $this->{ExtractionsHierarchies}->{$dyn->{subj}}){
    $dyn->{hierarchy} =
    $this->{ExtractionsHierarchies}->{$dyn->{subj}}->{hierarchy};
    $dyn->{rev_hist} =
      $this->{ExtractionsHierarchies}->{$dyn->{subj}}->{rev_hist};
    $dyn->{errors} =
      $this->{ExtractionsHierarchies}->{$dyn->{subj}}->{errors};
    $dyn->{send_hist} =
      $this->{ExtractionsHierarchies}->{$dyn->{subj}}->{send_hist};
    # If this collection is open, only call ExpandExtractionStudyInfo
    # otherwise draw the whole table
    if($this->{InfoSel}->{$col}->{$site}->{$subj}){
      $this->ExpandStudyHierarchyExtraction($http, $dyn,
        $dyn->{hierarchy}->{$dyn->{subj}}->{studies});
    } else {
      $http->queue(qq{
        <table width=100%">
          <tr>
            <td valign="top" align="left">
      });
      $this->ExpandExtractionStudyInfo($http, $dyn);
      $http->queue(qq{
          </td>
          <td valign="top" align="right">
      });
      $this->ExpandExtractionInfo($http, $dyn);
      $http->queue(qq{
            </td>
          </tr>
        </table>
      });
    }
  };
}
##########################
# Hiding Subject
sub HideSubjectOK{
  my($this, $http, $dyn) = @_;
  my $subj = $dyn->{subj};
  my $collection = $this->{SelectedCollection};
  my $site = $this->{SelectedSite};
  $this->{CollectionMode} = "PendingHideSubject";
  $this->{PendingHideSite} = $site;
  $this->{PendingHideCollection} = $collection;
  $this->{PendingHideSubject} = $subj;
}
sub PendingHideSubject{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, qq{
    <h3>Are you sure you want to hide this subject:</h3>
    <ul>
      <li>Collection: $this->{PendingHideCollection}</li>
      <li>Site: $this->{PendingHideSite}</li>
      <li>Subject: $this->{PendingHideSubject}</li>
    </ul>
    <div class="btn-group" role="group">
      <?dyn="NotSoSimpleButton" caption="Yes, Hide" subj="$this->{PendingHideSubject}" collection="$this->{PendingHideCollection}" site="$this->{PendingHideSite}" op="HideSubject" sync="Update();"?>
      <?dyn="NotSoSimpleButton" caption="No, Don't Hide" op="DontHideSubject" sync="Update();"?>
    </div>
  });
}
sub DontHideSubject{
  my($this, $http, $dyn) = @_;
  $this->{CollectionMode} = "CollectionsSelection";
  delete $this->{PendingDiscardSite};
  delete $this->{PendingDiscardCollection};
  delete $this->{PendingDiscardSubject};
}
sub HideSubject{
  my($this, $http, $dyn) = @_;
  my $subj = $dyn->{subj};
  my $collection = $dyn->{collection};
  my $site = $dyn->{site};
  $this->{CollectionMode} = "CollectionsSelection";
  my $cmd = "HideSubject.pl " .
    "\"$this->{Environment}->{database_name}\" \"" .
    "$collection\" \"" .
    "$site\" \"" .
    "$subj\"";
  Dispatch::LineReader->new_cmd($cmd, $this->IgnoreLine,
    $this->DoneWithHide($http, $dyn));
}
sub IgnoreLine{
  my($this) = @_;
  my $sub = sub {
  };
  return $sub;
}
sub DoneWithHide{
  my($this, $http, $dyn) = @_;
  my $sub = sub {
    $this->NewQuery($http, $dyn);
  };
  return $sub;
}
# Done Hiding Subject
##########################
sub ExpandExtractionStudyInfo{
  my($this, $http, $dyn) = @_;
  my $col = $this->{SelectedCollection};
  my $site = $this->{SelectedSite};
  my $subj = $dyn->{subj};
  unless(exists $this->{InfoSel}->{$col}->{$site}->{$subj}){
    $this->{InfoSel}->{$col}->{$site}->{$subj} = 0;
  }
  if($this->{InfoSel}->{$col}->{$site}->{$subj}){
    $this->ExpandStudyHierarchyExtraction($http, $dyn,
      $dyn->{hierarchy}->{$dyn->{subj}}->{studies});
  } else {
    my $col = $this->{SelectedCollection};
    my $site = $this->{SelectedSite};
    my $subj = $dyn->{subj};
    $this->ExpandStudyCountsExtraction($http, $dyn,
      $dyn->{hierarchy}->{$subj}->{studies});
  }
}
sub ExpandExtractionInfo{
  my($this, $http, $dyn) = @_;
  my $status = "Extracted";
  if($dyn->{rev_hist}->{CurrentRev} ne "0"){
    $status = "Current Rev: $dyn->{rev_hist}->{CurrentRev}";
  }
  if(defined $dyn->{errors}){
    $status .= '<br>with <span style="background-color:red;">' .
      'errors</span>';
  }
  if(defined $dyn->{send_hist}){
    $status .= "<br>with send";
  }
  if(exists $this->{IntakeCheckHierarchy}){
    my $check = $this->{IntakeCheckHierarchy}->{$dyn->{subj}};
    my $num_only_in_ext = keys %{$check->{OnlyInExt}};
    my $num_only_in_pub = keys %{$check->{OnlyInIntake}};
    if($num_only_in_ext != 0 || $num_only_in_pub != 0){
      $status .= '<br><span style="background-color:red;">' .
        "doesn't match intake</span>";
    } else {
      $status .= "<br>matches intake";
    }
  }
  if(exists $this->{PublicCheckHierarchy}){
    my $check = $this->{PublicCheckHierarchy}->{$dyn->{subj}};
    my $num_only_in_ext = keys %{$check->{OnlyInExt}};
    my $num_only_in_pub = keys %{$check->{OnlyInPublic}};
    if($num_only_in_ext != 0 || $num_only_in_pub != 0){
      $status .= '<br><span style="background-color:red;">' .
        "doesn't match public</span>";
    } else {
      $status .= "<br>matches public";
    }
  }
  my $link = $this->MakeHostLinkSync("Info", "ShowInfo", {
    subj => $dyn->{subj}
  }, 1, "Update();", "btn btn-xs btn-default");
  $http->queue("$status<br>$link");
}
sub ExtractSubject{
  my($this, $http, $dyn) = @_;
  my $cmd = "BuildExtractionCommands.pl " .
    "\"$this->{Environment}->{database_name}\" " .
    "\"$this->{SelectedCollection}\" " .
    "\"$this->{SelectedSite}\" " .
    "\"$dyn->{subj}\"";
  my $struct = {};
  Dispatch::LineReader->new_cmd($cmd,
    $this->BuildExtractionLine($this->{SelectedCollection},
      $this->{SelectedSite}, $dyn->{subj}, $struct),
    $this->BuildExtractionEnd($http, $dyn,
      $this->{SelectedCollection},
      $this->{SelectedSite}, $dyn->{subj}, $struct)
  );
}
sub BuildExtractionLine{
  my($this, $collection, $site, $subj, $struct) = @_;
  my $sub = sub{
    my($line) =@_;
    my($digest, $sop_inst, $path, $st_desc, $bp_x, $ser_desc, $modality,
      $size, $visi, $study_inst, $series_inst) = split(/\|/, $line);
    if($visi eq "hidden") { return }
    $struct->{$study_inst}->{pid} = $subj;
    $struct->{$study_inst}->{desc} = $st_desc;
    $struct->{$study_inst}->{uid} = $study_inst;
    unless(exists $struct->{$study_inst}->{series}->{$series_inst}){
      $struct->{$study_inst}->{series}->{$series_inst} = {};
    }
    my $series = $struct->{$study_inst}->{series}->{$series_inst};
    $series->{body_part} = $bp_x;
    $series->{desc} = $ser_desc;
    $series->{modality} = $modality;
    $series->{uid} = $series_inst;
    unless(exists $series->{files}->{$digest}){
      $series->{files}->{$digest} = {};
    }
    my $file = $series->{files}->{$digest};
    $file->{sop_instance_uid} = $sop_inst;
    $file->{file} = $path;
    $file->{file_size} = $size;
    $file->{md5} = $digest;
    $file->{visibility} = $visi;
  };
  return $sub;
}
sub BuildExtractionEnd{
  my($this, $http, $dyn, $collection, $site, $subj, $struct) = @_;
  my $sub = sub{
    $this->LockForExtractSubject($http, $dyn, $subj, $struct);
  };
  return $sub;
}
sub LockForExtractSubject{
  my($this, $http, $dyn, $subj, $struct) = @_;
  $this->RequestLock($http, $dyn,
    $this->WhenExtractionLockComplete($http, $dyn, $subj, $struct));
}
sub WhenExtractionLockComplete{
  my($this, $http, $dyn, $subj, $struct) = @_;
  my $sub = sub {
    my($lines) = @_;
    my %args;
    for my $line (@$lines){
      if($line =~ /^(.*):\s*(.*)$/){
        my $k = $1; my $v = $2;
        $args{$k} = $v;
      }
    }
    if(exists($args{Locked}) && $args{Locked} eq "OK"){
      my $extract_struct = {
        operation => "ExtractAndAnalyze",
        destination => $args{"Destination File Directory"},
        info_dir => $args{"Revision Dir"},
        cache_dir => "$this->{DicomInfoCache}/dicom_info",
        parallelism => 5,
        desc => {
          patient_id => $subj,
          studies => $struct,
        },
      };
      $extract_struct->{desc}->{patient_id} = $subj;
      my $commands = $args{"Revision Dir"} . "/creation.pinfo";
      store($extract_struct, $commands);
      my $session = $this->{session};
      my $pid = $$;
      my $user = $this->get_user;
      my $new_args = [ "ApplyEdits", "Id: $args{Id}",
        "Session: $session", "User: $user", "Pid: $pid" ,
        "Commands: $commands" ];
      $this->SimpleTransaction($this->{ExtractionManagerPort},
        $new_args,
        $this->WhenEditQueued($http, $dyn));
    } else {
      print STDERR "Extraction Lock Failed - probably double click\n";
    }
  };
  return $sub;
}
sub WhenEditQueued{
  my($this, $http, $dyn) = @_;
  my $sub = sub {
    # nothing to do here???
    my($lines) = @_;
  };
  return $sub;
}
sub OpenSubjInfo{
  my($this, $http, $dyn) = @_;
  my $subj = $dyn->{subject};
  my $col = $this->{SelectedCollection};
  my $site = $this->{SelectedSite};
  $this->{InfoSel}->{$col}->{$site}->{$subj} = 1;
}
sub CloseSubjInfo{
  my($this, $http, $dyn) = @_;
  my $subj = $dyn->{subject};
  my $col = $this->{SelectedCollection};
  my $site = $this->{SelectedSite};
  $this->{InfoSel}->{$col}->{$site}->{$subj} = 0;
  my $count = $this->CountOpenSubj($subj);
  if($count == 0){
    delete $this->{NickNames};
  }
}
sub CountOpenSubj{
  my($this) = @_;
  my $sum = 0;
  for my $coll (keys %{$this->{InfoSel}}){
    for my $site (keys %{$this->{InfoSel}->{$coll}}){
      for my $subj (keys %{$this->{InfoSel}->{$coll}->{$site}}){
        $sum += $this->{InfoSel}->{$coll}->{$site}->{$subj};
      }
    }
  }
  return $sum;
}
#############################################
# DB Query by Collection, Site
sub StartDbQuery{
  my($this) = @_;
  delete $this->{DbResults};
  $this->{QueryReader} = Dispatch::LineReader->new_cmd(
    "NewCollectionQuery.pl \"" .
    "$this->{Environment}->{database_name}\" \"" .
    "$this->{SelectedCollection}\" " .
    "\"$this->{SelectedSite}\" ",
    $this->QueryLine($this->{SelectedCollection}, $this->{SelectedSite}),
    $this->QueryEnd
  );
}
sub QueryLine{
  my($this, $collection, $site) = @_;
  my $sub = sub{
    my($line) = @_;
    my($pat_id, $pname, $st_inst, $st_date, $st_desc, 
      $ser_inst, $ser_date, $ser_desc, $modality, $sex, 
      $access, $st_id, $body_p, $count) = split(/\|/, $line);
    $this->{DbResults}->{$pat_id}->{pat_name}->{$pname} = 1;
    $this->{DbResults}->{$pat_id}->{sex}->{$sex} = 1;
    unless(exists $this->{DbResults}->{$pat_id}->{studies}->{$st_inst}){
      $this->{DbResults}->{$pat_id}->{studies}->{$st_inst} = {};
    }
    my $study = $this->{DbResults}->{$pat_id}->{studies}->{$st_inst};
    $study->{st_date}->{$st_date} = 1;
    $study->{st_desc}->{$st_desc} = 1;
    $study->{st_id}->{$st_id} = 1;
    $study->{accession_num}->{$access} = 1;
    unless(exists $study->{series}->{$ser_inst}){
      $study->{series}->{$ser_inst} = {};
    }
    my $series = $study->{series}->{$ser_inst};
    $series->{modality}->{$modality} = 1;
    $series->{ser_date}->{$ser_date} = 1;
    $series->{ser_desc}->{$ser_desc} = 1;
    $series->{body_part}->{$body_p} = 1;
    $series->{num_files} += $count;
  };
  return $sub;
}
sub QueryEnd{
  my($this) = @_;
  my $sub = sub{
    delete $this->{QueryReader};
    delete $this->{DbQueryInProgress};
    $this->AutoRefresh;
  };
  return $sub;
}
sub StatusOfDbQuery{
  my($this, $http, $dyn) = @_;
  my $num_subjects = 0;
  my $num_studies = 0;
  my $num_series = 0;
  my $num_files = 0;
  if(
    exists $this->{DbResults} &&
    ref($this->{DbResults}) eq "HASH"
  ){
    for my $subj (keys %{$this->{DbResults}}){
      $num_subjects += 1;
      for my $st (keys %{$this->{DbResults}->{$subj}->{studies}}){
        $num_studies += 1;
        for my $se (
          keys %{$this->{DbResults}->{$subj}->{studies}->{$st}->{series}}
        ){
          $num_series += 1;
          my $p =
            $this->{DbResults}->{$subj}->{studies}->{$st}->{series}->{$se};
          $num_files += $this->{DbResults}->{$subj}
            ->{studies}->{$st}->{series}->{$se}->{num_files};
        }
      }
    }
    if($this->{DbQueryInProgress}){
      $http->queue("<small>DB query in progress for ");
    } else {
      $http->queue("<small>DB query complete for ");
    }
    $http->queue( "Collection: $this->{SelectedCollection}, " .
      "Site: $this->{SelectedSite}<ul>" .
      "<li>$num_studies studies</li>" .
      "<li>$num_series series</li>" .
      "<li>$num_files files</li></ul></small>");
  } else {
      $http->queue("DbQuery Starting for");
      $http->queue( "Collection: $this->{SelectedCollection}, " .
      "Site: $this->{SelectedSite}");
  }
  $this->InvokeAfterDelay("AutoRefresh", 3);
}
#############################################
sub StartExtractionSearch{
  my($this, $http, $dyn) = @_;
  delete $this->{ExtractionsHierarchies};
  my $dir_to_search = $this->{ExtractionRoot} .
    "/$this->{SelectedCollection}/$this->{SelectedSite}";
  my $cmd = "/bin/ls \"$dir_to_search\"";
  $this->{DirSearcher} = Dispatch::LineReader->new_cmd($cmd,
    $this->ProcessDirectoryLine(
      $this->{SelectedCollection}, $this->{SelectedSite},
      $dir_to_search),
    $this->DirectorySearched($http, $dyn));
}
sub ProcessDirectoryLine{
  my($this, $coll, $site, $root) = @_;
  my $sub = sub {
    my($line) = @_;
    if($line =~ /^\./) { return }
    my $subj = $line;
    unless(-d "$root/$subj"){ return }
    my $rev_hist;
    unless(-f "$root/$subj/rev_hist.pinfo") { return }
    eval { $rev_hist = Storable::retrieve("$root/$subj/rev_hist.pinfo") };
    if($@){
      print STDERR "Error: \"$@\" retrieving $root/$subj/rev_hist.pinfo\n";
      return;
    }
    my $cur_rev = $rev_hist->{CurrentRev};
    unless(-d "$root/$subj/revisions/$cur_rev") {
      print STDERR "Error: no revision directory for current rev: " .
        "$cur_rev in $root/$subj/revisions\n";
      return;
    }
    my $hierarchy;
    unless(-f "$root/$subj/revisions/$cur_rev/hierarchy.pinfo"){
      print STDERR "Error: no hierarcy " .
        "in $root/$subj/revisions/$cur_rev\n";
      return;
    }
    eval { $hierarchy =
      Storable::retrieve("$root/$subj/revisions/$cur_rev/hierarchy.pinfo") };
    if($@){
      print STDERR "Error: \"$@\" retrieving " .
        "$root/$subj/revisions/$cur_rev/$hierarchy.pinfo\n";
      return;
    }
    my $errors;
    eval { $errors =
      Storable::retrieve("$root/$subj/revisions/$cur_rev/error.pinfo") };
    my $ignored_errors;
    eval { $ignored_errors =
      Storable::retrieve("$root/$subj/revisions/$cur_rev/ignored_error.pinfo")
    };
    my $send_hist;
    eval { $send_hist =
      Storable::retrieve("$root/$subj/revisions/$cur_rev/send_hist.pinfo") };
    $this->{ExtractionsHierarchies}->{$subj}->{rev_hist} = $rev_hist;
    $this->{ExtractionsHierarchies}->{$subj}->{hierarchy} = $hierarchy;
    $this->{ExtractionsHierarchies}->{$subj}->{errors} = $errors;
    $this->{ExtractionsHierarchies}->{$subj}->{ignored_errors} =
      $ignored_errors;
    $this->{ExtractionsHierarchies}->{$subj}->{send_hist} = $send_hist;
    $this->{ExtractionsHierarchies}->{$subj}->{InfoDir} =
      "$root/$subj/revisions/$cur_rev";
  };
  return $sub;
}
sub DirectorySearched{
  my($this, $http, $dyn) = @_;
  my $sub = sub {
    delete $this->{DirSearcher};
    delete $this->{ExtractionSearchInProgress};
    $this->AutoRefresh;
  };
  return $sub;
}
sub StatusOfExtractionSearch{
  my($this, $http, $dyn) = @_;
  if(exists $this->{ExtractionSearchInProgress}){
    $http->queue("Directory Search In Progress");
  } else {
    $http->queue("Directory Search Finished");
  }

}
#############################################
#Check Against Public
#
sub CheckAgainstPublic{
  my($this, $http, $dyn) = @_;
  if($this->{CheckAgainstPublic} < 3 ){
    my $num_found_patient = keys %{$this->{PublicData}};
    $this->RefreshEngine($http, $dyn,
      'Currently querying Public:<br>' . $num_found_patient .
      ' subjects found');
  } elsif ($this->{CheckAgainstPublic} == 3){
    my $num_subj = keys %{$this->{CollectionRows}};
    my $num_subj_in_intake = keys %{$this->{PublicData}};
    my $num_subj_waiting = @{$this->{PublicCheckSubjectsToDo}};
    my $num_subj_with_error = @{$this->{PublicCheckSubjectsWithError}};
    my $num_subj_ok = @{$this->{PublicCheckSubjectsOk}};
    my $num_subj_not_checked = @{$this->{PublicCheckSubjectsNotChecked}};
    $this->RefreshEngine($http, $dyn, qq{
      Checking subject in public against subjects in Posda:
      <ul>
        <li>Total Subjects: $num_subj</li>
        <li>Subjects in Public: $num_subj_in_intake</li>
        <li>Subjects Waiting: $num_subj_waiting</li>
        <li>Subjects With Error: $num_subj_with_error</li>
        <li>Subjects Ok: $num_subj_ok</li>
        <li>Subjects Not Checked: $num_subj_not_checked</li>
      </ul>
    });
  } else {
#    $this->RefreshEngine($http, $dyn,
#      'Checking against intake is curently under development:<br>' .
#      '<?dyn="SimpleButton" ' .
#      'caption="OK" op="ClearCheckAgainstPublic" sync="Update();"?>');
     $this->ClearCheckAgainstPublic($http, $dyn);
     $this->AutoRefresh;
  }
}
sub SetCheckAgainstPublic{
  my($this, $http, $dyn) = @_;
  $this->{CheckAgainstPublic} = 1;
  $this->{PublicData} = {};
  my $collection = $this->{SelectedCollection};
  my $site = $this->{SelectedSite};
  my $cmd = 'GetIntakeImagesForCollectionSite.pl 144.30.1.74 "'.
   $collection . '" "' . $site . '"';
  Dispatch::LineReader->new_cmd($cmd,
    $this->CheckAgainstPublicLine,
    $this->CheckAgainstPublicDone); 
  $this->{CheckAgainstPublic} = 2;
}
sub ClearCheckAgainstPublic{
  my($this, $http, $dyn) = @_;
  delete $this->{CheckAgainstPublic};
}
sub CheckAgainstPublicLine{
  my($this) = @_;
  my $sub = sub {
    my($line) = @_;
    my($pid, $SopInst, $StudyInst, $SeriesInst) = split(/\|/, $line);
    unless(exists $this->{PublicData}->{$pid}) { $this->AutoRefresh };
    $this->{PublicData}->{$pid}->{$StudyInst}->{$SeriesInst}->{$SopInst} = 1;
  };
  return $sub;
}
sub CheckAgainstPublicDone{
  my($this) = @_;
  my $sub = sub {
    $this->{CheckAgainstPublic} = 3;
    $this->AutoRefresh();
    $this->{PublicCheckSubjectsToDo} = [keys %{$this->{CollectionRows}} ];
    $this->{PublicCheckSubjectsWithError} = [];
    $this->{PublicCheckSubjectsOk} = [];
    $this->{PublicCheckSubjectsNotChecked} = [];
    $this->{PublicCheckHierarchy} = {};
    Dispatch::Select::Background->new($this->PublicCheckCrank)->queue;
  };
  return $sub;
}
sub PublicCheckCrank{
  my($this) = @_;
  my $sub = sub {
    my($disp) = @_;
    unless(exists $this->{CheckAgainstPublic}) { return }
    my $num_to_check = @{$this->{PublicCheckSubjectsToDo}};
    unless($num_to_check > 0){
      $this->{CheckAgainstPublic} = 4;
      return;
    }
    my $next = shift(@{$this->{PublicCheckSubjectsToDo}});
    $this->CheckPublicSubject($next);
    $disp->queue;
  };
  return $sub;
}
sub CheckPublicSubject{
  my($this, $subj) = @_;
  my $subj_hierarchy = $this->{ExtractionsHierarchies}->{$subj}->{hierarchy}
    ->{$subj}->{studies};
  my %ExtractionHierarchy;
  for my $st (keys %$subj_hierarchy){
    my $st_h = $subj_hierarchy->{$st};
    my $study_uid = $st_h->{uid};
    for my $se (keys %{$st_h->{series}}){
      my $se_h = $st_h->{series}->{$se};
      my $series_uid = $se_h->{uid};
      for my $f (keys %{$se_h->{files}}){
        my $f_h = $se_h->{files}->{$f};
        my $sop_uid = $f_h->{sop_instance_uid};
        $ExtractionHierarchy{$study_uid}->{$series_uid}->{$sop_uid} = 1;
      }
    }
  }
  my $PublicHierarchyToCompare = $this->{PublicData}->{$subj};
  # find files in both and only in extraction
  my %InAll;
  my %OnlyInExt;
  my %OnlyInPublic;
  for my $st (keys %ExtractionHierarchy){
    for my $se (keys %{$ExtractionHierarchy{$st}}){
      for my $f (keys %{$ExtractionHierarchy{$st}->{$se}}){
        if(exists $PublicHierarchyToCompare->{$st}->{$se}->{$f}){
          $InAll{$st}->{$se}->{$f} = 1;
        } else {
          $OnlyInExt{$st}->{$se}->{$f} = 1;
        }
      }
    }
  }
  # find files in intake, not in extraction
  for my $st (keys %$PublicHierarchyToCompare){
    for my $se (keys %{$PublicHierarchyToCompare->{$st}}){
      for my $f (keys %{$PublicHierarchyToCompare->{$st}->{$se}}){
        unless(exists $ExtractionHierarchy{$st}->{$se}->{$f}){
          $OnlyInPublic{$st}->{$se}->{$f} = 1;
        }
      }
    }
  }
  $this->{PublicCheckHierarchy}{$subj} = {
    InAll => \%InAll,
    OnlyInExt => \%OnlyInExt,
    OnlyInPublic => \%OnlyInPublic,
  };
  $this->AutoRefresh;
}
sub ClearPublicData{
  my($this, $http, $dyn) = @_;
  delete $this->{PublicCheckHierarchy};
  delete $this->{PublicCheckSubjectsNotChecked};
  delete $this->{PublicCheckSubjectsOk};
  delete $this->{PublicCheckSubjectsToDo};
  delete $this->{PublicCheckSubjectsWithError};
  delete $this->{PublicData};
}
#############################################
#############################################
#Check Against Intake
#
sub CheckAgainstIntake{
  my($this, $http, $dyn) = @_;
  if($this->{CheckAgainstIntake} < 3 ){
    my $num_found_patient = keys %{$this->{IntakeData}};
    $this->RefreshEngine($http, $dyn,
      'Currently querying Intake:<br>' . $num_found_patient .
      ' subjects found');
  } elsif ($this->{CheckAgainstIntake} == 3){
    my $num_subj = keys %{$this->{CollectionRows}};
    my $num_subj_in_intake = keys %{$this->{IntakeData}};
    my $num_subj_waiting = @{$this->{IntakeCheckSubjectsToDo}};
    my $num_subj_with_error = @{$this->{IntakeCheckSubjectsWithError}};
    my $num_subj_ok = @{$this->{IntakeCheckSubjectsOk}};
    my $num_subj_not_checked = @{$this->{IntakeCheckSubjectsNotChecked}};
    $this->RefreshEngine($http, $dyn, qq{
      Checking subject in intake against subjects in Posda:
      <ul>
        <li>Total Subjects: $num_subj</li>
        <li>Subjects in Public: $num_subj_in_intake</li>
        <li>Subjects Waiting: $num_subj_waiting</li>
        <li>Subjects With Error: $num_subj_with_error</li>
        <li>Subjects Ok: $num_subj_ok</li>
        <li>Subjects Not Checked: $num_subj_not_checked</li>
      </ul>
    });
  } else {
#    $this->RefreshEngine($http, $dyn,
#      'Checking against intake is curently under development:<br>' .
#      '<?dyn="SimpleButton" ' .
#      'caption="OK" op="ClearCheckAgainstIntake" sync="Update();"?>');
     $this->ClearCheckAgainstIntake($http, $dyn);
     $this->AutoRefresh;
  }
}
sub SetCheckAgainstIntake{
  my($this, $http, $dyn) = @_;
  $this->{CheckAgainstIntake} = 1;
  $this->{IntakeData} = {};
  my $collection = $this->{SelectedCollection};
  my $site = $this->{SelectedSite};
  my $cmd = 'GetIntakeImagesForCollectionSite.pl 144.30.1.71 "'.
   $collection . '" "' . $site . '"';
  Dispatch::LineReader->new_cmd($cmd,
    $this->CheckAgainstIntakeLine,
    $this->CheckAgainstIntakeDone); 
  $this->{CheckAgainstIntake} = 2;
}
sub ClearCheckAgainstIntake{
  my($this, $http, $dyn) = @_;
  delete $this->{CheckAgainstIntake};
}
sub CheckAgainstIntakeLine{
  my($this) = @_;
  my $sub = sub {
    my($line) = @_;
    my($pid, $SopInst, $StudyInst, $SeriesInst) = split(/\|/, $line);
    unless(exists $this->{IntakeData}->{$pid}) { $this->AutoRefresh };
    $this->{IntakeData}->{$pid}->{$StudyInst}->{$SeriesInst}->{$SopInst} = 1;
  };
  return $sub;
}
sub CheckAgainstIntakeDone{
  my($this) = @_;
  my $sub = sub {
    $this->{CheckAgainstIntake} = 3;
    $this->AutoRefresh();
    $this->{IntakeCheckSubjectsToDo} = [keys %{$this->{CollectionRows}} ];
    $this->{IntakeCheckSubjectsWithError} = [];
    $this->{IntakeCheckSubjectsOk} = [];
    $this->{IntakeCheckSubjectsNotChecked} = [];
    $this->{IntakeCheckHierarchy} = {};
    Dispatch::Select::Background->new($this->IntakeCheckCrank)->queue;
  };
  return $sub;
}
sub IntakeCheckCrank{
  my($this) = @_;
  my $sub = sub {
    my($disp) = @_;
    unless(exists $this->{CheckAgainstIntake}) { return }
    my $num_to_check = @{$this->{IntakeCheckSubjectsToDo}};
    unless($num_to_check > 0){
      $this->{CheckAgainstIntake} = 4;
      return;
    }
    my $next = shift(@{$this->{IntakeCheckSubjectsToDo}});
    $this->CheckIntakeSubject($next);
    $disp->queue;
  };
  return $sub;
}
sub CheckIntakeSubject{
  my($this, $subj) = @_;
  my $subj_hierarchy = $this->{ExtractionsHierarchies}->{$subj}->{hierarchy}
    ->{$subj}->{studies};
  my %ExtractionHierarchy;
  for my $st (keys %$subj_hierarchy){
    my $st_h = $subj_hierarchy->{$st};
    my $study_uid = $st_h->{uid};
    for my $se (keys %{$st_h->{series}}){
      my $se_h = $st_h->{series}->{$se};
      my $series_uid = $se_h->{uid};
      for my $f (keys %{$se_h->{files}}){
        my $f_h = $se_h->{files}->{$f};
        my $sop_uid = $f_h->{sop_instance_uid};
        $ExtractionHierarchy{$study_uid}->{$series_uid}->{$sop_uid} = 1;
      }
    }
  }
  my $IntakeHierarchyToCompare = $this->{IntakeData}->{$subj};
  # find files in both and only in extraction
  my %InAll;
  my %OnlyInExt;
  my %OnlyInIntake;
  for my $st (keys %ExtractionHierarchy){
    for my $se (keys %{$ExtractionHierarchy{$st}}){
      for my $f (keys %{$ExtractionHierarchy{$st}->{$se}}){
        if(exists $IntakeHierarchyToCompare->{$st}->{$se}->{$f}){
          $InAll{$st}->{$se}->{$f} = 1;
        } else {
          $OnlyInExt{$st}->{$se}->{$f} = 1;
        }
      }
    }
  }
  # find files in intake, not in extraction
  for my $st (keys %$IntakeHierarchyToCompare){
    for my $se (keys %{$IntakeHierarchyToCompare->{$st}}){
      for my $f (keys %{$IntakeHierarchyToCompare->{$st}->{$se}}){
        unless(exists $ExtractionHierarchy{$st}->{$se}->{$f}){
          $OnlyInIntake{$st}->{$se}->{$f} = 1;
        }
      }
    }
  }
  $this->{IntakeCheckHierarchy}{$subj} = {
    InAll => \%InAll,
    OnlyInExt => \%OnlyInExt,
    OnlyInIntake => \%OnlyInIntake,
  };
  $this->AutoRefresh;
}
sub ClearIntakeData{
  my($this, $http, $dyn) = @_;
  delete $this->{IntakeCheckHierarchy};
  delete $this->{IntakeCheckSubjectsNotChecked};
  delete $this->{IntakeCheckSubjectsOk};
  delete $this->{IntakeCheckSubjectsToDo};
  delete $this->{IntakeCheckSubjectsWithError};
  delete $this->{IntakeData};
}
#############################################

sub CleanUp{
  my($this) = @_;
print STDERR "In CleanUp\n";
  $this->{CleanedUp} = 1;
}
sub DESTROY{
  my($this) = @_;
  print STDERR "End of session: $this->{session}\n";
#  $this->DeleteMySession;
  if(exists $this->{LoginTempDir} && -d $this->{LoginTempDir}){
    print STDERR "Removing $this->{LoginTempDir}\n";
    remove_tree $this->{LoginTempDir};
  }
}

########################################################
sub GetExtractionLocks{
  my($this, $when_done) = @_;
  if(exists($this->{DirectoryLocks})){
    $this->{OldDirectoryLocks} = $this->{DirectoryLocks};
  }
  delete $this->{DirectoryLocks};
  if($this->SimpleTransaction($this->{ExtractionManagerPort},
    ["ListLocks"],
    $this->ExtractionLockLineHandler($when_done))
  ){
    return;
  }
  &{$when_done}();
}
sub ExtractionLockLineHandler{
  my($this, $when_done) = @_;
  my $sub = sub {
    my($lines) = @_;
    line:
    for my $line (@$lines){
      unless($line =~ /^Lock:\s*(.*)/){
        unless($line =~ /^$/) {
          print STDERR "unparsable ExtractionLockLine: \"$line\"\n";
        }
        next line;
      }
      my %h;
      my @args = split(/\|/, $1);
      arg:
      for my $a (@args) {
        unless($a =~ /^(.*)=(.*)$/) {
          print STDERR "bad arg ($a) in \"$line\"\n";
        }
        $h{$1} = $2;
      }
      $this->{DirectoryLocks}->{$h{Collection}}
        ->{$h{Site}}->{$h{Subj}} = \%h;
    }
    &{$when_done}();
  };
  return $sub;
}
########################################################
# possibly move to parent and inherit
sub SimpleTransaction{
  my($this, $port, $lines, $response) = @_;
  my $sock;
  unless(
    $sock = IO::Socket::INET->new(
     PeerAddr => "localhost",
     PeerPort => $port,
     Proto => 'tcp',
     Timeout => 1,
     Blocking => 0,
    )
  ){
    return 0;
  }
  my $text = join("\n", @$lines) . "\n\n";
  Dispatch::Select::Socket->new($this->WriteTransactionParms($text, $response),
    $sock)->Add("writer");
}
sub WriteTransactionParms{
  my($this, $text, $response) = @_;
  my $offset = 0;
  my $sub = sub {
    my($disp, $sock) = @_;
    my $length = length($text);
    if($offset == length($text)){
      $disp->Remove;
      Dispatch::Select::Socket->new($this->ReadTransactionResponse($response),
        $sock)->Add("reader");
    } else {
      my $len = syswrite($sock, $text, length($text) - $offset, $offset);
      if($len <= 0) {
        print STDERR "Wrote $len bytes ($!)\n";
        $offset = length($text);
      } else { $offset += $len }
    }
  };
  return $sub;
}
sub ReadTransactionResponse{
  my($this, $response) = @_;
  my $text = "";
  my @lines;
  my $sub = sub {
    my($disp, $sock) = @_;
    my $len = sysread($sock, $text, 65536, length($text));
    if($len <= 0){
      if($text) { push @lines, $text }
      $disp->Remove;
      &$response(\@lines);
    } else {
      while($text =~/^([^\n]*)\n(.*)$/s){
        my $line = $1;
        $text = $2;
        push(@lines, $line);
      }
    }
  };
  return $sub;
}
sub RequestLock{
  my($this, $http, $dyn, $at_end) = @_;
  my $subj = $dyn->{subj};
  my $for = $dyn->{for};
  my $collection = $this->{SelectedCollection};
  my $site = $this->{SelectedSite};
  my $user = $this->get_user;
  my $session = $this->{session};
  my $pid = $$;
#  my $url = $this->{BaseExternalNotificationUrl};
  $this->LockExtractionDirectory({
    Collection => $collection,
    Site => $site,
    Subject => $subj,
    Session => $session,
    User => $user,
    Pid => $pid,
    For => $dyn->{for},
#    Response => $url,
   }, $at_end);
}
sub LockExtractionDirectory{
  my($this, $args, $when_done) = @_;
  delete $this->{DirectoryLocks};
  my @lines;
  push(@lines, "LockForEdit");
  for my $k (keys %$args){
    unless(defined($k) && defined($args->{$k})){ next }
    push(@lines, "$k: $args->{$k}");
  }
  if($this->SimpleTransaction($this->{ExtractionManagerPort},
    [@lines],
    $when_done)
  ){
    return;
  }
}
############################################################
sub RefreshDirData{
  my($this, $http, $dyn) = @_;
  $this->{ExtractionSearchInProgress} = 1;
  $this->StartExtractionSearch;
}
############################################################
sub StartLockChecker{
  my($this) = @_;
  my $checker = sub {
    my($disp) = @_;
    if(exists($this->{CleanedUp})) {
print STDERR "LockChecker shutting down\n";
      return;
    }
    if(
      $this->{mode} eq "Collections" &&
      $this->{CollectionMode} eq "CollectionsSelection"
    ){
      unless(
        $this->{DbQueryInProgress} || $this->{ExtractionSearchInProgress}
      ){
        if(exists $this->{DirectoryLocks}){
          $this->GetExtractionLocks($this->ContinueLockChecker($disp));
          return;
        }
      }
    }
    $disp->timer(5);
  };
  Dispatch::Select::Background->new($checker)->queue;
}
sub ContinueLockChecker{
  my($this, $disp) = @_;
  my $sub = sub {
    my $update_required;
    check_locks:
    for my $coll (keys %{$this->{OldDirectoryLocks}}){
      for my $site (keys %{$this->{OldDirectoryLocks}->{$coll}}){
        for my $subj (keys %{$this->{OldDirectoryLocks}->{$coll}->{$site}}){
          my $lock = $this->{OldDirectoryLocks}->{$coll}->{$site}->{$subj};
          unless(
            exists($this->{DirectoryLocks}->{$coll}->{$site}->{$subj})
          ){
            $this->StartExtractionSearch;
            last check_locks
          }
          my $new_lock = $this->{DirectoryLocks}->{$coll}->{$site}->{$subj};
          for my $k (keys %$lock){
            unless($lock->{$k} eq $new_lock->{$k}){
              $this->StartExtractionSearch;
              last check_locks;
            }
          }
        }
      }
    }
    $disp->timer(5);
  };
  return $sub;
}
############################################################
sub ShowInfo{
  my($this, $http, $dyn) = @_;
  my $subj = $dyn->{subj};
  $this->{CollectionMode} = "DisplayInfo";
  unless(exists $this->{NickNames}) {
    $this->{NickNames} = Posda::Nicknames->new;
  }
  $this->{DisplayInfoIn} = {
    subj => $subj,
    Collection => $this->{SelectedCollection},
    Site => $this->{SelectedSite},
  };
  $this->{DisplayInfoIn}->{rev_hist} =
    $this->{ExtractionsHierarchies}->{$dyn->{subj}}->{rev_hist};
  for my $rev(keys %{$this->{DisplayInfoIn}->{rev_hist}->{Revisions}}){
    my $creation_file = "$this->{ExtractionRoot}/" .
      "$this->{SelectedCollection}/$this->{SelectedSite}/$subj/" .
      "revisions/$rev/" .
      "creation.pinfo";
    my $cmd = "GetRevisionCreationInfo.pl \"$creation_file\"";
    my $fh;
    my $h;
    open $fh, "$cmd|";
    while(my $line = <$fh>){
      chomp $line;
      my($key, $value) = split(/:/, $line);
      $h->{$key} = $value;
    }
    $this->{DisplayInfoIn}->{rev_desc}->{$rev} = $h;
  }
  my $error_info = $this->{ExtractionsHierarchies}->{$dyn->{subj}}->{errors};
  my $ignored_error_info = 
    $this->{ExtractionsHierarchies}->{$dyn->{subj}}->{ignored_errors};
  my $hierarchy = $this->{ExtractionsHierarchies}->{$dyn->{subj}}->{hierarchy}
    ->{$dyn->{subj}};
  my %sop_to_files;
  my $hierarchy_by_uid;
  for my $st (keys %{$hierarchy->{studies}}){
    my $st_uid = $hierarchy->{studies}->{$st}->{uid};
    for my $i ("desc", "pid"){
      $hierarchy_by_uid->{$st_uid}->{$i} = $hierarchy->{studies}->{$st}->{$i};
    }
    for my $se (keys %{$hierarchy->{studies}->{$st}->{series}}){
      my $ser_uid = $hierarchy->{studies}->{$st}->{series}->{$se}->{uid};
      $hierarchy_by_uid->{$st_uid}->{series}->{$ser_uid} =
        $hierarchy->{studies}->{$st}->{series}->{$se};
      for my $f (
        keys %{$hierarchy->{studies}->{$st}->{series}->{$se}->{files}}
      ){
        my $sop = $hierarchy->{studies}->{$st}->{series}->{$se}->{files}
          ->{$f}->{sop_instance_uid};
        unless(exists $sop_to_files{$sop}){
          $sop_to_files{$sop} = [];
        }
        push(@{$sop_to_files{$sop}}, $f);
      }
    }
  }
  $this->{DisplayInfoIn}->{sop_to_files} = \%sop_to_files;
  $this->{DisplayInfoIn}->{error_info} = $error_info;
  $this->{DisplayInfoIn}->{ignored_error_info} = $ignored_error_info;
  $this->{DisplayInfoIn}->{hierarchy} = $hierarchy;
  $this->{DisplayInfoIn}->{hierarchy_by_uid} = $hierarchy_by_uid;
  my $dicom_info_file =
    "$this->{ExtractionsHierarchies}->{$subj}->{InfoDir}/dicom.pinfo";
  my $dicom_info;
  eval {
    $dicom_info = Storable::retrieve($dicom_info_file);
  };
  if($@){
    print STDERR "Can't retrieve DicomInfo for $subj: $@\n";
  } else {
    $this->{DisplayInfoIn}->{dicom_info} = $dicom_info;
  }
  $this->{DisplayInfoIn}->{send_info} = 
    $this->{ExtractionsHierarchies}->{$dyn->{subj}}->{send_hist};
}
sub HideInfo{
  my($this, $http, $dyn) = @_;
  $this->{CollectionMode} = "CollectionsSelection";
}
sub RestoreInfo{
  my($this, $http, $dyn) = @_;
  $this->{CollectionMode} = "DisplayInfo";
}
sub DisplayInfo{
  my($this, $http, $dyn) = @_;
  my $info = $this->{DisplayInfoIn};
  $this->RefreshEngine($http, $dyn,
    "<h3>Info for Collection: $info->{Collection}, " .
    "Site: $info->{Site}, Subject: $info->{subj}:  " .
    '<?dyn="CollectionCounts"?>' .
    "</h3>");
  $this->RefreshEngine($http, $dyn,
    '<table width="100%">' .
    '<tr><td align="left" valign="top" width="50%">' .
    '<?dyn="NotSoSimpleButton" caption="Go Back" ' .
    'op="HideInfo" sync="Update();"?>&nbsp;&nbsp;' .
    '<?dyn="SendInfo"?>' .
    $this->NlstLinks($http, $dyn) .
    '</td><td align="right" valign="top" width="50%">' .
    '<?dyn="NotSoSimpleButton" caption="Discard This Extraction" ' .
    'subj="' . $this->{DisplayInfoIn}->{subj} . '" ' .
    'collection="' . $this->{DisplayInfoIn}->{Collection} . '" ' .
    'site="' . $this->{DisplayInfoIn}->{Site} . '" ' .
    'op="DiscardExtractionOK" sync="Update();"?></td></tr>' .
    '</table><hr><table width="100%">' .
    '<tr><td valign="top" align="left" width="60%">' .
    '<?dyn="ExtractionMenus"?></td>' .
    '<td valign="top" align="right" width="40%"><small>' .
    '<?dyn="RevisionHistory"?>' .
    '</small></td></tr></table>' .
    '<hr>' .
    '<table width="100%"><tr><td valign="top" align="left" width="75%">' .
    '<small>' .
    '<?dyn="ExpandExtractedInfo"?>' .
    '</small></td><td valign="top" align="left" width="25%">' .
    '<?dyn="RenderErrorList" subj="'. $this->{DisplayInfoIn}->{subj} . '"?>' .
    '</td></tr></table>'
  );
}
sub CollectionCounts{
  my($this, $http, $dyn) = @_;
  my($studies, $series, $files) = (0,0,0);
  for my $i (keys %{$this->{DisplayInfoIn}->{hierarchy}->{studies}}){
    $studies += 1;
    my $st = $this->{DisplayInfoIn}->{hierarchy}->{studies}->{$i};
    for my $j (keys %{$st->{series}}){
      $series += 1;
      my $se = $st->{series}->{$j};
      for my $k (keys %{$se->{files}}){
        $files += 1;
      }
    }
  }
  $http->queue("Studies: $studies, Series: $series, Files: $files");
}
sub SendInfo{
  my($this, $http, $dyn) = @_;
  if(
    defined($this->{DisplayInfoIn}->{send_info}) &&
    ref($this->{DisplayInfoIn}->{send_info}) eq "ARRAY"
  ){
    my $count = @{$this->{DisplayInfoIn}->{send_info}};
    $http->queue("<small>SendInfo($count): ");
    for my $i (0 .. $count - 1){
      my $s = $this->{DisplayInfoIn}->{send_info}->[$i];
      my $dest = $s->{called};
      my $sent = @{$s->{files_sent}};
      my $not_sent = @{$s->{files_not_sent}};
      my $errors = @{$s->{files_with_errors}};
      $http->queue("$dest($sent, $not_sent, $errors)");
      unless($i == $count - 1){
        $http->queue(", ");
      }
    }
    $http->queue("</small>");
  }
}
sub NlstLinks{
  my($this, $http, $dyn) = @_;
  unless($this->{Environment}->{IsNlstCuration}) { return }
  my $subj = $this->{DisplayInfoIn}->{subj};
  my $rev = $this->{DisplayInfoIn}->{rev_hist}->{CurrentRev};
  my @names = keys %{$this->{DbResults}->{$subj}->{pat_name}};
  if ($#names > 1) {
    return "<small>" .
      "&nbsp;&nbsp;&nbsp" .
      "NLST subj with inconsitent patient name</small>";
  }
  my $name = $names[0];
  my $ret = "<small>" .
    "&nbsp;&nbsp;&nbsp";
  my $good = 0;
  if(exists $this->{BadNlstPatientList}->{$name}){
    $good = 1;
    $ret .= "Bad NLST Patient";
  } else{
    $ret .= "Good NLST Patient";
  }
  if($rev == 0){
    if($good){
      $ret .= ': <?dyn="NotSoSimpleButton" ' .
        'caption="Make Edits From Nlst" ' .
        'op="ConstructEditsFromNlst"' .
        '?>';
    } else {
      $ret .= ': <?dyn="NotSoSimpleButton" ' .
        'caption="Fetch Corresponding From Nlst" ' .
        'op="FetchCorrespondingFromNlst"' .
        '?>';
    }
  }
  return $ret;
}
sub ExpandExtractedInfo{
  my($this, $http, $dyn) = @_;
  my $subj = $this->{DisplayInfoIn}->{subj};
  $this->ExpandStudyHierarchyWithPatientInfo($http, $dyn,
    $this->{ExtractionsHierarchies}->{$subj}->{hierarchy}->{$subj}->{studies});
}
sub ExtractionMenus{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
#    "<small><a href=\"DownloadTar?obj_path=$this->{path}\">download</a>" .
#     '<hr>' .
    '<?dyn="DupSops"?>' .
    '<?dyn="RenderEditMenu"?>' .
    '<?dyn="SendMenu"?><hr>'.
    '<?dyn="PhiMenu"?>')
}
sub FetchCorrespondingFromNlst{
  my($this, $http, $dyn) = @_;
  if($this->{NlstFetchInProgress}){
    print STDERR "###### NLST Fetch already in progress #########\n";
    return;
  }
  $this->{NlstFetchInProgress} = 1;
  $this->HideErrors($http, $dyn);
  my $site = $this->{DisplayInfoIn}->{Site};
  my $coll = $this->{DisplayInfoIn}->{Collection};
  my $subj = $this->{DisplayInfoIn}->{subj};
  my $dir_info =
      $this->GetExtractionEditDirsAndFiles($subj);
  unless(
    exists $dir_info->{dicom_info_file} && -f $dir_info->{dicom_info_file}
  ){
    $this->SetErrorState(
      "No Dicom Info File found for $coll $site $subj");
    return;
  }
  my $dicom_info = Storable::retrieve($dir_info->{dicom_info_file});
  my $edit_dir = "$this->{ExtractionRoot}/$coll/" .
    "$site/$subj/revisions";
  my $source_dir = "$edit_dir/$dir_info->{current_rev}/files";
  my $next_rev = $dir_info->{current_rev} + 1;
  my $dest_dir = "$edit_dir/$next_rev/files";
  $this->{NlstEditInstructionsUnderDevelopment} = {
    operation => "EditAndAnalyze",
    files_to_link => {},
    cache_dir => "$this->{DicomInfoCache}/dicom_info",
    parallelism => 3,
    destination => $dest_dir,
    source => $source_dir,
    info_dir => "$edit_dir/$next_rev",
#    source_info_dir => "$edit_dir/$dir_info->{current_rev}",
  };
  my $when_list_fetched = $this->WhenListFetched($http, $dyn);
  my %file_list;
  my $dii = $this->{DisplayInfoIn};
  for my $study (keys %{$dii->{hierarchy_by_uid}}){
    my $slp = $dii->{hierarchy_by_uid}->{$study}->{series};
    for my $series (keys %$slp){
      my $flp = $slp->{$series}->{files};
      for my $file (keys %$flp){
        $file_list{$file} = $flp->{$file};
      }
    }
  }
  $this->{NlstFetchList} = \%file_list;
  $this->{NlstFetchesInProgress} = {};
  $this->{NlstFetchesDone} = {};
  my @command_list;
  $this->FetchNextNlst($when_list_fetched, \@command_list);
}
sub FetchNextNlst{
  my($this, $when_list_fetched, $command_list) = @_;
  my $fetch_count = keys %{$this->{NlstFetchList}};
  my $in_progress = keys %{$this->{NlstFetchesInProgress}};
  my $done = keys %{$this->{NlstFetchesDone}};
  while ($fetch_count > 0 && $in_progress < 3){
    my $next_fetch_key = [keys %{$this->{NlstFetchList}}]->[0];
    unless(defined $next_fetch_key) { die "Bad foo" }
    my $next = $this->{NlstFetchList}->{$next_fetch_key};
    $this->{NlstFetchesInProgress}->{$next_fetch_key} = $next;
    delete $this->{NlstFetchList}->{$next_fetch_key};
    my $fh;
    my $sop = $next->{sop_instance_uid};
    my $file = $next_fetch_key;
    my $link;
    Dispatch::LineReader->new_cmd(
      "GetNlstLinkFromSop.pl 144.30.5.90 $sop",
      $this->ReadNlstLink(\$link),
      $this->NlstLinkRead(
        \$link, $when_list_fetched, $sop, $file, $command_list, $next_fetch_key)
    );
    $fetch_count = keys %{$this->{NlstFetchList}};
    $in_progress = keys %{$this->{NlstFetchesInProgress}};
    $done = keys %{$this->{NlstFetchesDone}};
  }
  if($fetch_count == 0 && $in_progress == 0){
    delete $this->{NlstFetchList};
    delete $this->{NlstFetchesInProgress};
    delete $this->{NlstFetchesDone};
    delete $this->{NlstFetchInProgress};
    &$when_list_fetched($command_list);
  }
}
sub ReadNlstLink{
  my($this, $linkp) = @_;
  my $sub = sub {
    my($line) = @_; 
    $$linkp = $line;
  };
  return $sub;
}
sub NlstLinkRead{
  my($this, $linkp, $when_list_fetched, $sop, $file, $command_list, $key) = @_;
  my $sub = sub {
    push(@$command_list, { sop => $sop, file => $file, from => $$linkp });
    my $last = $this->{NlstFetchesInProgress}->{$key};
    $this->{NlstFetchesDone}->{$key} = $last;
    delete $this->{NlstFetchesInProgress}->{$key};
    $this->FetchNextNlst($when_list_fetched, $command_list);
  };
  return $sub;
}
sub WhenListFetched{
  my($this, $http, $dyn) = @_;
  my $sub = sub {
    my($command_list) = @_;
    my $edit_instructions = $this->{NlstEditInstructionsUnderDevelopment};
    delete $this->{NlstEditInstructionsUnderDevelopment};
    command:
    for my $i (@$command_list){
      my $from_file = $i->{file};
      my $copy_from = $i->{from};
      my $from_dir = $edit_instructions->{source};
      unless($from_file =~/^(.*)\/([^\/]+)$/){
        print STDERR "Can't extract file to link from $from_file\n";
        next command;
      }
      my $dest_file = "$edit_instructions->{destination}/$2";
      $edit_instructions->{CopyFromOther}->{$from_file} = {
        from_file => $from_file,
        to_file => $dest_file,
        copy_from_other => $copy_from,
      };
    }
    $dyn->{subj} = $this->{DisplayInfoIn}->{subj};
    $dyn->{for} = "Edit";
    $this->RequestLock($http, $dyn,
    $this->WhenEditLockComplete($http, $dyn, $edit_instructions));
  };
  return $sub;
}

sub DownloadTar{
  my($this, $http, $dyn) = @_;
  my $Coll = $this->{DisplayInfoIn}->{Collection};
  my $Site = $this->{DisplayInfoIn}->{Site};
  my $subj = $this->{DisplayInfoIn}->{subj};
  my $rev = $this->{DisplayInfoIn}->{rev_hist}->{CurrentRev};
  my $file_name = "$Coll-$Site-$subj-Revision_$rev.tgz";
  my $dir = "$this->{ExtractionRoot}/$Coll/$Site/$subj/revisions/$rev";
  my $cmd = "cd \"$dir\";tar -zcvf - files 2>/dev/null";
  my $fh;
  if(open $fh, "$cmd|") {
    $http->DownloadHeader("application/x-tar", $file_name);
    Dispatch::Select::Socket->new(
      $this->SendCommandResults($http),
    $fh)->Add("reader");
  }
}
sub WaitHttpReady{
  my($this, $disp, $buff, $http) = @_;
  my $sub = sub {
    my($event) = @_;
    print STDERR "UnThrottling tar\n";
    $http->queue($buff);
    $disp->Add("reader");
  };
  return $sub;
}
sub SendCommandResults{
  my($this, $http) = @_;
  my $sub = sub {
    my($disp, $sock) = @_;
    my $buff;
    my $count = sysread($sock, $buff, 10240);
    if($count <= 0){
      $disp->Remove;
      return;
    }
    if($http->ready_out){
      $http->queue($buff);
    } else {
      print STDERR "Throttling tar\n";
      $disp->Remove("reader");
      my $event = Dispatch::Select::Event->new(
        Dispatch::Select::Background->new(
          $this->WaitHttpReady($disp, $buff, $http)));
      $http->wait_output($event);
    }
  };
  return $sub;
}
sub SendMenu{
  my($this, $http, $dyn) = @_;
  $dyn->{col} = $this->{DisplayInfoIn}->{Collection};
  $dyn->{site} = $this->{DisplayInfoIn}->{Site};
  $dyn->{subj} = $this->{DisplayInfoIn}->{subj};
  $this->RefreshEngine($http, $dyn,
    '<?dyn="NotSoSimpleButton" caption="Send This Extraction" ' .
    'op="SendThisExtraction" sync="Update();"?>' .
    '<?dyn="DestinationDropDown"?><?dyn="SubSendSelection"?>');
}
sub SubSendSelection{
  my($this, $http, $dyn) = @_;
  my %studies;
  my $hierarchy = $this->{DisplayInfoIn}->{hierarchy_by_uid};
  for my $study (sort keys %{$hierarchy}){
    my $study_nn = $this->{NickNames}->GetEntityNicknameByEntityId("STUDY",
      $study);
    $studies{$study_nn} = $study;
  }
  unless(
    exists($this->{DisplayInfoIn}->{SelectedStudyForSend}) &&
    exists($studies{$this->{DisplayInfoIn}->{SelectedStudyForSend}})
  ){
    $this->{DisplayInfoIn}->{SelectedStudyForSend} = "---Select Study---";
  }
  $this->RefreshEngine($http, $dyn,
    '<?dyn="SelectDelegateByValue" op="SelectSendStudy" sync="Update();"?>');
  for my $v ("---Select Study---", sort keys %studies){
    $http->queue("<option value=\"$v\"" .
      ($v eq $this->{DisplayInfoIn}->{SelectedStudyForSend} ?
        " selected" : "") .
      ">$v</option>");
  }
  $this->RefreshEngine($http, $dyn, '</select>');
}
sub SelectSendStudy{
  my($this, $http, $dyn) = @_;
  $this->{DisplayInfoIn}->{SelectedStudyForSend} = $dyn->{value};
}
sub PhiMenu{
  my($this, $http, $dyn) = @_;
  $dyn->{col} = $this->{DisplayInfoIn}->{Collection};
  $dyn->{site} = $this->{DisplayInfoIn}->{Site};
  $dyn->{subj} = $this->{DisplayInfoIn}->{subj};
  my $rev = $this->{DisplayInfoIn}->{rev_hist}->{CurrentRev};
  my $rev_dir = "$this->{ExtractionRoot}/$dyn->{col}/$dyn->{site}/" .
    "$dyn->{subj}/revisions/$rev";
  unless(-f "$rev_dir/PhiCheck.info"){
    return $this->RefreshEngine($http, $dyn,
    '<?dyn="NotSoSimpleButton" caption="Search For PHI" ' .
    'op="PhiSearch" sync="Update();"?>');
  }
  $this->RefreshEngine($http, $dyn,
    '<?dyn="NotSoSimpleButton" caption="Show Phi" ' .
    'op="ShowPhi" sync="Update();"?>');
}
sub DestinationDropDown{
  my($this, $http, $dyn) = @_;
  my $dest_desc = $this->{Environment}->{DicomDestinations};
  my @dests = sort keys %$dest_desc;
  unless(defined $this->{SelectedDicomDestination}){
    $this->{SelectedDicomDestination} = "---- select destination ----";
  }
  $this->RefreshEngine($http, $dyn, '<?dyn="SelectByValue" op="SetDest"?>');
  for my $i ("---- select destination ----", @dests){
    $http->queue("<option value=\"$i\"" .
      ($i eq $this->{SelectedDicomDestination} ? " selected" : "") .
      ">$i</option>");
  }
  $http->queue('</select>');
}
sub SetDest{
  my($this, $http, $dyn) = @_;
  $this->{SelectedDicomDestination} = $dyn->{value};
}
sub SendThisExtraction{
  my($this, $http, $dyn) = @_;
  $this->HideErrors;
  my $site = $dyn->{site};
  my $col = $dyn->{col};
  my $subj = $dyn->{subj};
  my $sess = $this->{session};
  my $user = $this->get_user;
  my $pid = $$;
  my $dest_desc = $this->{Environment}->{DicomDestinations};
  my $dest = $this->{SelectedDicomDestination};
  my $host = $dest_desc->{$dest}->{host};
  my $port = $dest_desc->{$dest}->{port};
  my $called = $dest_desc->{$dest}->{called_ae};
  my $calling = $dest_desc->{$dest}->{calling_ae};
#  my $url = $this->{BaseExternalNotificationUrl};

  my $new_args = [ "SendAllFiles",
    "Session: $sess", "User: $user", "Pid: $pid" ,
    "Collection: $col",
    "Site: $site",
    "Subject: $subj",
    "Host: $host" ,
    "Port: $port" ,
    "CallingAeTitle: $calling" ,
    "CalledAeTitle: $called" ,
    "For: Sending" ,
#    "Response: $this->{BaseExternalNotificationUrl}"
  ];
  if(
    exists($this->{DisplayInfoIn}->{SelectedStudyForSend}) &&
    $this->{DisplayInfoIn}->{SelectedStudyForSend} ne "---Select Study---"
  ){
    $new_args->[0] = "SendFilesInStudy";
    my $study_nn = $this->{DisplayInfoIn}->{SelectedStudyForSend};
    my $study_uid = $this->{NickNames}->GetEntityIdByNickname($study_nn);
    push @$new_args, "SelectedStudy: $study_uid";
  }
  if(
    $this->SimpleTransaction($this->{ExtractionManagerPort},
    $new_args,
    $this->WhenSendQueued($http, $dyn))
  ){
    return;
  } else {
    print STDERR "Send failed: probably double click\n";
  }
}
sub WhenSendQueued{
  my($this, $http, $dyn) = @_;
  my $sub = sub {
    my($lines) = @_;
    print STDERR "Response to Send Request:\n";
    for my $line (@$lines){
      print STDERR "$line\n";
    }
  };
  return $sub;
}
sub DupSops{
  my($this, $http, $dyn) = @_;
  my $dup_sops = [];
  for my $i (keys %{$this->{DisplayInfoIn}->{sop_to_files}}){
    unless(ref($this->{DisplayInfoIn}->{sop_to_files}->{$i}) eq "ARRAY"){
      die "Corrupted sop_to_files in DisplayInfoIn";
    }
    if($#{$this->{DisplayInfoIn}->{sop_to_files}->{$i}} > 0){
      push(@$dup_sops, $this->{DisplayInfoIn}->{sop_to_files}->{$i});
    }
    $this->{DisplayInfoIn}->{DuplicateSops} = $dup_sops;
    if($#{$dup_sops} < 0) { return }
    $http->queue("Duplicate SOPs exists!!!!<hr>");
  }
}
sub RenderErrorList{
  my($this, $http, $dyn) = @_;
  my $error_info = $this->{ExtractionsHierarchies}->{$dyn->{subj}}->{errors};
  my $ignored_error_info = 
    $this->{ExtractionsHierarchies}->{$dyn->{subj}}->{ignored_errors};
  my $hierarchy = $this->{ExtractionsHierarchies}->{$dyn->{subj}}->{hierarchy}
    ->{$dyn->{subj}};
  return $this->ErrorReportCommon(
   $http, $dyn, $error_info, $ignored_error_info, $hierarchy);
}
sub RenderEditMenu{
  my($this, $http, $dyn) = @_;
  $this->RenderResolveDuplicateSopsMenu($http, $dyn);
  $this->RenderSplitBySeriesDescMenu($http, $dyn);
  $this->RenderRehashSsMenu($http, $dyn);
  $this->RenderRelinkSsMenu($http, $dyn);
  $this->RefreshEngine($http, $dyn,
    '<?dyn="NotSoSimpleButton" caption="General Edits" ' .
    'op="GeneralPurposeEditor" sync="Update();"?>');
}
sub RenderResolveDuplicateSopsMenu{
  my($this, $http, $dyn) = @_;
  delete $this->{DupSopInstList};
  my %DupSopInstances;
  for my $e (@{$this->{DisplayInfoIn}->{error_info}}){
    if($e->{type} eq "duplicate sop_instance"){
      $DupSopInstances{$e->{sop_inst}} = 1;
    }
  }
  my @DupSops = keys %DupSopInstances;
  if(@DupSops) {
    $this->{DupSopInstList} = \@DupSops;
    $this->RefreshEngine($http, $dyn,
     '<?dyn="NotSoSimpleButton" caption="Resolve Dup Sop Instances" ' .
     'op="ResolveDupSopInstances" sync="Update();"?>');
  }
}
sub RenderSplitBySeriesDescMenu{
  my($this, $http, $dyn) = @_;
  my $split_by_series_needed = 0;
  my $normalize_series_needed = 0;
  my @series_to_split_on_desc;
  my @series_to_normalize;
  error_report:
  for my $i (@{$this->{DisplayInfoIn}->{error_info}}){
    if(
      $i->{type} eq "series_consistency" &&
      exists($i->{sub_type}) &&
      $i->{sub_type} eq "multiple element values" &&
      $i->{ele} eq "(0008,103e)"
    ){
      my $num_distinct_values = @{$i->{values}};
      my $num_images_in_series = 0;
      st:
      for my $st (keys %{$this->{DisplayInfoIn}->{hierarchy_by_uid}}){
        my $study = $this->{DisplayInfoIn}->{hierarchy_by_uid}->{$st};
        if(exists $study->{series}->{$i->{series_uid}}){
          my $series = $study->{series}->{$i->{series_uid}};
          $num_images_in_series = keys %{$series->{files}};
          last st;
        }
      }
      if($num_images_in_series == $num_distinct_values){
        $split_by_series_needed = 1;
        my $series_nn = $this->{NickNames}->GetEntityNicknameByEntityId(
          "SERIES", $i->{series_uid});
        push @series_to_split_on_desc, {
          series => $i->{series_uid},
          series_nn => $series_nn,
          count => scalar(@{$i->{values}}),
        };
      } else {
        print STDERR "Series needs to normalize series description\n";
      }
    } else {
    }
  }
  unless($split_by_series_needed) { return }
  my @series = sort {$a->{series_nn} cmp $b->{series_nn} }
    @series_to_split_on_desc;
  $this->RefreshEngine($http, $dyn,
    '<small><table><tr>' .
    '<td align="center" valign="bottom">' .
    '<?dyn="SelectAllSeriesLink"?><br>' .
    '<?dyn="SelectNoSeriesLink"?></td>' .
    '<td>' .
    '<?dyn="NotSoSimpleButton" ' .
    'op="SplitSelectedSeriesBySeriesDescription" ' .
    'caption="Split Selected Series By Series Description" ' .
    'collection="' . $this->{DisplayInfoIn}->{Collection} . '" ' .
    'site="' . $this->{DisplayInfoIn}->{Site} . '" ' .
    'subj="' . $this->{DisplayInfoIn}->{subj} . '" ' .
    'sync="Update();"?>' .
    '</td></tr>');
  for my $i (@series){
    unless(
      exists($this->{DisplayInfoIn}->{CheckedSeriesToSplit}->{$i->{series}})
    ){
      $this->{DisplayInfoIn}->{CheckedSeriesToSplit}->{$i->{series}} = "false"
    }
    $http->queue("<tr><td>");
    $http->queue(
      $this->CheckBox(
        "SelectedSplitSeries", $i->{series_nn},
        "SelectSplitSeries",
        $this->{DisplayInfoIn}->{CheckedSeriesToSplit}->{$i->{series}}
          eq "true",
        "series=$i->{series}"
      )
    );
    $http->queue("</td><td>$i->{series_nn} ($i->{count})</td></tr>");
  }
  $http->queue("</table></small><hr>");
}
sub SelectAllSeriesLink{
  my($this, $http, $dyn) = @_;
  $http->queue($this->MakeHostLinkSync("all", "SelectAllSplitSeries", undef, 1,
    "Update();"));
}
sub SelectAllSplitSeries{
  my($this, $http, $dyn) = @_;
  for my $i (keys %{$this->{DisplayInfoIn}->{CheckedSeriesToSplit}}){
    $this->{DisplayInfoIn}->{CheckedSeriesToSplit}->{$i} = "true";
  }
}
sub SelectNoSeriesLink{
  my($this, $http, $dyn) = @_;
  $http->queue($this->MakeHostLinkSync("none", "SelectNoSplitSeries", undef, 1,
    "Update();"));
}
sub SelectNoSplitSeries{
  my($this, $http, $dyn) = @_;
  for my $i (keys %{$this->{DisplayInfoIn}->{CheckedSeriesToSplit}}){
    $this->{DisplayInfoIn}->{CheckedSeriesToSplit}->{$i} = "false";
  }
}
sub SelectSplitSeries{
  my($this, $http, $dyn) = @_;
  $this->{DisplayInfoIn}->{CheckedSeriesToSplit}->{$dyn->{series}} =
    $dyn->{checked};
}
sub SplitSelectedSeriesBySeriesDescription{
  my($this, $http, $dyn) = @_;
  $this->HideErrors($http, $dyn);
  my $coll = $dyn->{collection};
  my $site = $dyn->{site};
  my $subj = $dyn->{subj};
  my $series_uid = $dyn->{series};
  my $new_uid_base = Posda::UUID::GetUUID;
  my $dir_info =
      $this->GetExtractionEditDirsAndFiles($dyn->{subj});
  unless(
    exists $dir_info->{dicom_info_file} && -f $dir_info->{dicom_info_file}
  ){
    $this->SetErrorState(
      "No Dicom Info File found for $coll $site $subj");
    return;
  }
  my $dicom_info = Storable::retrieve($dir_info->{dicom_info_file});
  my($files_to_link, $files_to_edit) =
    $this->MakeLinkEditLists($dicom_info,
      $this->SeriesSelectedCheck($series_uid));
## $dest_dir, $source__dir, $edit_dir/$next_rev
  my $edit_dir = "$this->{ExtractionRoot}/$coll/" .
    "$site/$subj/revisions";
  my $source_dir = "$edit_dir/$dir_info->{current_rev}/files";
  my $next_rev = $dir_info->{current_rev} + 1;
  my $dest_dir = "$edit_dir/$next_rev/files";
  my $edit_instructions = {
    operation => "EditAndAnalyze",
    files_to_link => {},
    cache_dir => "$this->{DicomInfoCache}/dicom_info",
    parallelism => 3,
    destination => $dest_dir,
    source => $source_dir,
    info_dir => "$edit_dir/$next_rev",
#      source_info_dir => "$edit_dir/$dir_info->{current_rev}",
    FileEdits => {},
  };
  file_to_link:
  for my $f (keys %$files_to_link){
    unless($f =~/^(.*)\/([^\/]+)$/){
      print STDERR "Can't extract file to link from $f\n";
      next file_to_link;
    }
    my $dir = $1;
    my $file = $2;
    my $f_info = $files_to_link->{$f};
    unless($dir eq $source_dir) {
      print STDERR "Wrong Source dir:\n\t \"$dir\"\nvs\n\t\"$source_dir\"\n";
      next file_to_link;
    }
    $edit_instructions->{files_to_link}->{$file} = $f_info->{digest};
  }
  my $increment = 0;
  file_to_edit:
  for my $f (
    sort
    { $files_to_edit->{$a}->{"(0008,103e)"}
      cmp
      $files_to_edit->{$b}->{"(0008,103e)"}
    }
    keys  %$files_to_edit
  ){
    unless($f =~ /^(.*)\/([^\/]+)$/){
      print STDERR "Can't extract file to edit from $f\n";
      next file_to_edit;
    }
    my $dir = $1;
    my $file = $2;
    unless($dir eq $source_dir) {
      print STDERR "Wrong Edit Source dir:\n" .
        "\t \"$dir\"\nvs\n\t\"$source_dir\"\n";
      next file_to_edit;
    }
    $increment += 1;
    $edit_instructions->{FileEdits}->{$file} = {
      from_file => $f,
      to_file => "$dest_dir/$file",
      full_ele_additions => {
        "(0020,000e)" => "$new_uid_base.$increment",
      },
    };
  }
  $dyn->{for} = "Edit";
  $this->RequestLock($http, $dyn,
    $this->WhenEditLockComplete($http, $dyn, $edit_instructions));
}
sub RenderRehashSsMenu{
  my($this, $http, $dyn) = @_;
  my $ss_relink_needed = 0;
  my @ss;
  for my $i (@{$this->{DisplayInfoIn}->{error_info}}){
    if($i->{type} eq "structure_set_linkage"){
      $ss_relink_needed = 1;
      my $series_nn = $this->{NickNames}->GetEntityNicknameByEntityId(
        "SERIES", $i->{series_uid});
      push @ss, {
        series => $i->{series_uid},
        series_nn => $series_nn,
        sop => $i->{sop_inst}
      };
    }
  }
  unless($ss_relink_needed) { return }
  @ss = sort {$a->{series_nn} cmp $b->{series_nn}} @ss;
}
sub RenderRelinkSsMenu{
  my($this, $http, $dyn) = @_;
  my $ss_relink_needed = 0;
  my @ss;
  for my $i (@{$this->{DisplayInfoIn}->{error_info}}){
    if($i->{type} eq "structure_set_linkage"){
      $ss_relink_needed = 1;
      my $series_nn = $this->{NickNames}->GetEntityNicknameByEntityId(
        "SERIES", $i->{series_uid});
      push @ss, {
        series => $i->{series_uid},
        series_nn => $series_nn,
        sop => $i->{sop_inst}
      };
    }
  }
  unless($ss_relink_needed) { return }
  @ss = sort {$a->{series_nn} cmp $b->{series_nn}} @ss;
  $this->RefreshEngine($http, $dyn,
      '<small><table><tr>' .
      '<td align="center" valign="bottom">' .
      '<?dyn="SelectAllStructsLink"?><br>' .
      '<?dyn="SelectNoStructsLink"?>' .
      '</td><td align="right" valign="top">' .
      '<?dyn="NotSoSimpleButton" op="RelinkSs" ' .
      'caption="Relink Structure Sets to Image Series" ' .
      'collection="' . $this->{DisplayInfoIn}->{Collection} . '" ' .
      'site="' . $this->{DisplayInfoIn}->{Site} . '" ' .
      'subj="' . $this->{DisplayInfoIn}->{subj} . '" ' .
      'sync="Update();"?></td>' .
      '<td align="left" valign="right">' .
      '<?dyn="RelinkFilters"?>' .
      '</td></tr>'
  );
  for my $i (0 .. $#ss){
    my $s = $ss[$i];
    my $series = $s->{series};
    my $sop = $s->{sop};
    my $series_nn = $s->{series_nn};
    if($#{$this->{DisplayInfoIn}->{sop_to_files}->{$sop}} == 0){
      my $file = $this->{DisplayInfoIn}->{sop_to_files}->{$sop}->[0];
      my $struct_nn = $this->{NickNames}->GetEntityNicknameByEntityId(
        "RTSTRUCT", $file
      );
      my $series_desc = $this->GetSeriesDescFromFile($file);
      unless(exists $this->{DisplayInfoIn}->{CheckedSs}->{$file}){
        $this->{DisplayInfoIn}->{CheckedSs}->{$file} = "false";
      }
      $http->queue('<tr><td align="left" valign="top">');
      $http->queue(
        $this->CheckBox(
          "SelectedRTSTRUCT", $i,
          "SelectRTSTRUCT",
          $this->{DisplayInfoIn}->{CheckedSs}->{$file} eq "true",
          "file=$file&sop=$sop&series=$series"
        )
      );
      $http->queue('</td><td align="left" valign="top">');
      $http->queue("$series_nn" . "::" . "$struct_nn   $series_desc");
      $http->queue('</td><td align="left" valign="top">');
      $this->LinkageSeriesSelection($http, $dyn, $file);
      $http->queue("</td></tr>");
    } elsif ($#{$this->{DisplayInfoIn}->{sop_to_files}->{$sop}} > 0){
      for my $file (@{$this->{DisplayInfoIn}->{sop_to_files}->{$sop}}){
        my $struct_nn = $this->{NickNames}->GetEntityNicknameByEntityId(
          "RTSTRUCT", $file
        );
        my $sop_nn = $this->{NickNames}->GetEntityNicknameByEntityId(
          "SOP", $sop
        );
        my $series_desc = $this->GetSeriesDescFromFile($file);
        unless(exists $this->{DisplayInfoIn}->{CheckedSs}->{$file}){
          $this->{DisplayInfoIn}->{CheckedSs}->{$file} = "false";
        }
        $http->queue('<tr><td align="left" valign="top">');
        $http->queue(
          $this->CheckBox(
            "SelectedRTSTRUCT", $i,
            "SelectRTSTRUCT",
            $this->{DisplayInfoIn}->{CheckedSs}->{$file} eq "true",
            "file=$file&sop=$sop&series=$series"
          )
        );
        $http->queue('</td><td align="left" valign="top">');
        $http->queue("$series_nn" . "::" . "$struct_nn($sop_nn)  $series_desc");
        $http->queue('</td><td align="left" valign="top">');
        $this->LinkageSeriesSelection($http, $dyn, $file);
        $http->queue("</td></tr>");
      }
    } else {
      $http->queue("<tr><td colspan=\"2\">Error in $series_nn</td></tr>");
    }
  }
  $http->queue("</table></small><hr>");
}
sub SelectAllStructsLink{
  my($this, $http, $dyn) = @_;
  $http->queue($this->MakeHostLinkSync("all", "SelectAllStructs", undef, 1,
    "Update();"));
}
sub SelectNoStructsLink{
  my($this, $http, $dyn) = @_;
  $http->queue($this->MakeHostLinkSync("none", "SelectNoStructs", undef, 1,
    "Update();"));
}
sub SelectAllStructs{
  my($this, $http, $dyn) = @_;
  for my $s (keys %{$this->{DisplayInfoIn}->{CheckedSs}}){
    $this->{DisplayInfoIn}->{CheckedSs}->{$s} = "true";
  }
}
sub SelectNoStructs{
  my($this, $http, $dyn) = @_;
  for my $s (keys %{$this->{DisplayInfoIn}->{CheckedSs}}){
    $this->{DisplayInfoIn}->{CheckedSs}->{$s} = "false";
  }
}
sub LinkageSeriesSelection{
  my($this, $http, $dyn, $file) = @_;
  my $file_nn = $this->{NickNames}->GetEntityNicknameByEntityId(
    "RTSTRUCT", $file);
  my $dig = $this->{DisplayInfoIn}->{dicom_info}->{FilesToDigest}->{$file};
  my $f_info = $this->{DisplayInfoIn}->{dicom_info}->{FilesByDigest}->{$dig};
  my $num_slices = $f_info->{series_refs}->[0]->{num_images};
  my $study_nn = $this->{NickNames}->GetEntityNicknameByEntityId(
    "STUDY", $f_info->{study_uid}
  );
  my $for_nn = $this->{NickNames}->GetEntityNicknameByEntityId(
   "FOR",
   $f_info->{for_uid});
  my $series_desc = $this->GetSeriesDescFromFile($file);
  my $series_to_link = $this->GetFilteredSeriesList($f_info->{study_uid},
    $f_info->{for_uid}, $num_slices, $series_desc);
  if($#{$series_to_link} < 0){
    $http->queue("All series filtered");
    return;
  }
  my %linkable_series;
  for my $i (@$series_to_link){
    $linkable_series{$i->{series_uid}} = 1;
  }
  if(exists $this->{DisplayInfoIn}->{SelectedSsLinkSeries}->{$file}){
    my $sel_series = $this->{DisplayInfoIn}->{SelectedSsLinkSeries}->{$file};
    unless(exists $linkable_series{$sel_series}){
      delete $this->{DisplayInfoIn}->{SelectedSsLinkSeries}->{$file};
    }
  }
  unless(exists $this->{DisplayInfoIn}->{SelectedSsLinkSeries}->{$file}){
    $this->{DisplayInfoIn}->{SelectedSsLinkSeries}->{$file} =
      $series_to_link->[0]->{series_uid};
  }

$this->{DebugSeriesToLink}->{$file} = $series_to_link;
  $this->RefreshEngine($http, $dyn,
   '<?dyn="SelectMethodByValue" method="SelectFilteredSeries" ' .
   'parm="file=' . $file . '" sync="Update();"' .
   '?>');
  for my $i (@$series_to_link){
    $http->queue("<option value=\"$i->{series_uid}\"" .
      ($i->{series_uid} eq $this->{DisplayInfoIn}->{SelectedSsLinkSeries}->{$file} ?
        " selected" : "") .
    ">$i->{series_nn}: $i->{desc}</option>");
  }
  $http->queue("</select>");
#  $http->queue("linkage for $file_nn goes here<br>");
#  $http->queue("num referenced images: $num_slices<br>");
#  $http->queue("Study $study_nn<br>");
#  $http->queue("Frame of Reference $for_nn<br>");
#  $http->queue("Series Desc $series_desc<br>");
}
sub GetFilteredSeriesList{
  my($this, $study_uid, $for_uid, $num_slices, $series_desc) = @_;
  my @series_list;
  if($this->{DisplayInfoIn}->{SelectedSsFilter}->{OnlyInStudy} eq "true"){
    $this->FilterSeries(
      $this->{DisplayInfoIn}->{hierarchy_by_uid}->{$study_uid}->{series},
      \@series_list,
      $for_uid, $num_slices, $series_desc);
  } else {
    for my $st (keys %{$this->{DisplayInfoIn}->{hierarchy_by_uid}}){
      $this->FilterSeries(
        $this->{DisplayInfoIn}->{hierarchy_by_uid}->{$st}->{series},
        \@series_list,
        $for_uid, $num_slices, $series_desc);
    }
  }
  return \@series_list;
}
sub FilterSeries{
  my($this, $series_hash, $results, $for_uid, $num_slices, $series_desc) = @_;
  my $options = $this->{DisplayInfoIn}->{SelectedSsFilter};
  unless(defined $series_hash && ref($series_hash) eq "HASH") { return }
  series:
  for my $s (keys %$series_hash){
    my $series = $series_hash->{$s};
    unless(exists $series->{FoR}) {
      $series->{FoR} = $this->GetSeriesFor($s)
    }
    if($series->{modality} eq "RTSTRUCT") { next series }
    if($options->{MatchingNumSlices} eq "true"){
      my $n = keys %{$series->{files}};
      unless($n == $num_slices) { next series }
    }
    if($options->{OnlySameFor} eq "true"){
      my $f = $series->{FoR};
      unless($f eq $for_uid) { next series }
    }
    if($options->{MatchingSeriesDescriptions} eq "true"){
      my $d = $series->{desc};
      unless($d eq $series_desc) { next series }
    }
    my $foo = {
      series_uid => $series->{uid},
      series_nn => $this->{NickNames}->GetEntityNicknameByEntityId(
        "SERIES", $series->{uid}
      ),
      desc => $series->{desc},
    };
    push @$results, $foo;
  }
}
sub GetSeriesDescFromFile{
  my($this, $file) = @_;
  my $dig = $this->{DisplayInfoIn}->{dicom_info}->{FilesToDigest}->{$file};
  my $f_info = $this->{DisplayInfoIn}->{dicom_info}->{FilesByDigest}->{$dig};
  my $series_desc = $f_info->{"(0008,103e)"};
  unless(defined $series_desc) { $series_desc = "&lt;not present&gt;" }
  unless($series_desc) { $series_desc = "&lt;present but null&gt;" }
  return $series_desc;
}
sub RelinkFilters{
  my($this, $http, $dyn) = @_;
  my $types = [
    [ "OnlyInStudy" => "Only in Same Study"],
    [ "OnlySameFor" => "Only with Same Frame of Reference"],
    [ "MatchingNumSlices" => "Only with Matching Number of Slices"],
    [ "MatchingSeriesDescriptions" => "Only with Matching Series Descriptions"],
  ];
  for my $i (@$types){
    unless(exists $this->{DisplayInfoIn}->{SelectedSsFilter}->{$i->[0]}){
      $this->{DisplayInfoIn}->{SelectedSsFilter}->{$i->[0]} = "false";
    }
    $http->queue($this->CheckBoxSync(
      "SelectedSsFilters", $i->[0],
      "SelectSsFilter",
      $this->{DisplayInfoIn}->{SelectedSsFilter}->{$i->[0]} eq "true",
      "type=$i->[0]",
      "Update();"
    ));
    $http->queue("$i->[1]<br>");
  }
}
sub SelectRTSTRUCT{
  my($this, $http, $dyn) = @_;
  $this->{DisplayInfoIn}->{CheckedSs}->{$dyn->{file}} = $dyn->{checked};
}
sub SelectSsFilter{
  my($this, $http, $dyn) = @_;
  $this->{DisplayInfoIn}->{SelectedSsFilter}->{$dyn->{value}} = $dyn->{checked};
  delete $this->{DisplayInfoIn}->{SelectedSsLinkSeries};
}
sub SelectFilteredSeries{
  my($this, $http, $dyn) = @_;
  $this->{DisplayInfoIn}->{SelectedSsLinkSeries}->{$dyn->{file}} = $dyn->{value};
}
sub GetSeriesFor{
  my($this, $series) = @_;
  my $the_series_hash;
  study_uid:
  for my $st (keys %{$this->{DisplayInfoIn}->{hierarchy_by_uid}}){
    my $ser_hash = $this->{DisplayInfoIn}->{hierarchy_by_uid}->{$st}->{series};
    if(exists($ser_hash->{$series}) && ref($ser_hash->{$series}) eq "HASH"){
      $the_series_hash = $ser_hash->{$series};
      last study_uid;
    }
  }
  if(defined $the_series_hash){
    my %for;
    for my $f (keys %{$the_series_hash->{files}}){
      my $d_info = $this->{DisplayInfoIn}->{dicom_info};
      my $dig = $d_info->{FilesToDigest}->{$f};
      my $f_info = $d_info->{FilesByDigest}->{$dig};
      my $for_uid = $f_info->{for_uid};
      $for{$for_uid} = 1;
      my $f_hash = $the_series_hash->{files}->{$f};
      $f_hash->{sop_class} = $f_info->{sop_class_uid};
      $f_hash->{norm_iop} = $f_info->{"(0020,0037)"};
      my @ipp = split(/\\/, $f_info->{"(0020,0032)"});
      $f_hash->{norm_x} = $ipp[0];
      $f_hash->{norm_y} = $ipp[1];
      $f_hash->{norm_z} = $ipp[2];
      $f_hash->{rows} = $f_info->{"(0028,0010)"};
      $f_hash->{cols} = $f_info->{"(0028,0011)"};
      $f_hash->{pixel_sp} = $f_info->{"(0028,0030)"};
    }
    my @fors = keys %for;
    my $ret = "&lt;inconsistent&gt;";
    if(@fors == 1) { $ret =  $fors[0] };
    if(@fors == 0) { $ret = "&lt;undefined&gt;" }
    return $ret;
  } else {
     print STDERR "Not finding series: $series\n";
    return "&lt;not found&gt;";
  }
}
## Called from Series Report (child)
sub ApplyInstanceNumbersFix{
  my($this, $http, $dyn, $edits) = @_;
  $this->HideErrors($http, $dyn);
  my $info = $this->{DisplayInfoIn};
  my $coll = $this->{DisplayInfoIn}->{Collection};
  my $site = $this->{DisplayInfoIn}->{Site};
  my $subj = $this->{DisplayInfoIn}->{subj};
  my $edit_dir = "$this->{ExtractionRoot}/$coll/" .
    "$site/$subj/revisions";
  my $dir_info =
      $this->GetExtractionEditDirsAndFiles($subj);
  my $source_dir = "$edit_dir/$dir_info->{current_rev}/files";
  my $next_rev = $dir_info->{current_rev} + 1;
  my $dest_dir = "$edit_dir/$next_rev/files";
  my $edit_instructions = {
    operation => "EditAndAnalyze",
    files_to_link => {},
    cache_dir => "$this->{DicomInfoCache}/dicom_info",
    parallelism => 3,
    destination => $dest_dir,
    source => $source_dir,
    info_dir => "$edit_dir/$next_rev",
    FileEdits => $edits,
  };
  file_to_link:
  for my $f (keys %{$info->{DicomInfo}->{FilesToDigest}}){
    unless(exists $edits->{$f}){
      unless($f =~/^(.*)\/([^\/]+)$/){
        print STDERR "Can't extract file to link from $f\n";
        next file_to_link;
      }
      my $dir = $1;
      my $file = $2;
      $edit_instructions->{files_to_link}->{$file} = 
        $info->{DicomInfo}->{FilesToDigest}->{$f};
    }
  }
  $this->{PendingEdits} = $edit_instructions;
  $dyn->{for} = "Edit";
  $dyn->{subj} = $subj;
  $this->RequestLock($http, $dyn,
    $this->WhenEditLockComplete($http, $dyn, $edit_instructions));
  $this->AutoRefresh($http, $dyn);
}
## Called from GeneralEdit (child);
sub ApplyGeneralEdits{
  my($this, $http, $dyn, $general_edits) = @_;
  $this->HideErrors($http, $dyn);
  my $site = $general_edits->{Site};
  my $coll = $general_edits->{Collection};
  my $subj = $general_edits->{subj};
  my $dicom_info = $general_edits->{dicom_info};
  my $dir_info =
      $this->GetExtractionEditDirsAndFiles($subj);
  my $files_to_link = $general_edits->{UnaffectedFiles};
  my $edit_dir = "$this->{ExtractionRoot}/$coll/" .
    "$site/$subj/revisions";
  my $source_dir = "$edit_dir/$dir_info->{current_rev}/files";
  my $next_rev = $dir_info->{current_rev} + 1;
  my $dest_dir = "$edit_dir/$next_rev/files";
  my $edit_instructions = {
    operation => "EditAndAnalyze",
    files_to_link => {},
    cache_dir => "$this->{DicomInfoCache}/dicom_info",
    parallelism => 3,
    destination => $dest_dir,
    source => $source_dir,
    info_dir => "$edit_dir/$next_rev",
    FileEdits => {},
  };
  file_to_link:
  for my $f (keys %$files_to_link){
    my $dig = $dicom_info->{FilesToDigest}->{$f};
    my $f_info = $dicom_info->{FilesByDigest}->{$dig};
    unless($f =~/^(.*)\/([^\/]+)$/){
      print STDERR "Can't extract file to link from $f\n";
      next file_to_link;
    }
    my $dir = $1;
    my $file = $2;
    unless($dir eq $source_dir) {
      print STDERR "Wrong Source dir:\n\t \"$dir\"\nvs\n\t\"$source_dir\"\n";
      next file_to_link;
    }
    $edit_instructions->{files_to_link}->{$file} = $f_info->{digest};
  }
  my $Edits = $edit_instructions->{FileEdits};
  ## Now build edits
  if(exists $general_edits->{ChangeUids}){
    file:
    for my $f (keys %{$general_edits->{ChangeUids}->{affected_files}}){
      my $dig = $dicom_info->{FilesToDigest}->{$f};
      my $f_info = $dicom_info->{FilesByDigest}->{$dig};
      unless($f =~/^(.*)\/([^\/]+)$/){
        print STDERR "Can't extract file to link from $f\n";
        next file;
      }
      my $dir = $1;
      my $file = $2;
      unless($dir eq $source_dir){
        print STDERR
          "Wrong Source dir:\n\t \"$dir\"\nvs\n\t\"$source_dir\"\n";
        next file;
      }
      my $si = $f_info->{sop_inst_uid};
      my $sc = $f_info->{sop_class_uid};
      unless(exists $general_edits->{ChangeUids}->{command}->[1]->{$si}){
        return $this->SetErrorState(
          "ChangeUids has no mapping for sop inst $si");
      }
      my $prefix = Posda::DataDict::GetSopClassPrefix($sc);
      my $new_file = $prefix . "_$si.dcm";
      $Edits->{$f}->{from_file} = $f;
      $Edits->{$f}->{to_file} = "$dest_dir/$new_file";
      $Edits->{$f}->{uid_substitutions} =
        $general_edits->{ChangeUids}->{command}->[1];
    }
  }
  for my $r (@{$general_edits->{Rules}}){
    if($r->{rule_code} eq "SeriesUid"){
      if(exists $general_edits->{ChangeUids}){
        return $this->SetErrorState(
          "ChangeUids not compatable with Split Series");
      }
      my $new_uid_base = Posda::UUID::GetUUID;
      my $inc = 1;
      my %mapping;
      file:
      for my $f (@{$r->{affected_files}}){
        my $dig = $dicom_info->{FilesToDigest}->{$f};
        my $f_info = $dicom_info->{FilesByDigest}->{$dig};
        unless($f =~/^(.*)\/([^\/]+)$/){
          print STDERR "Can't extract file to link from $f\n";
          next file;
        }
        my $dir = $1;
        my $file = $2;
        unless($dir eq $source_dir){
          print STDERR
            "Wrong Source dir:\n\t \"$dir\"\nvs\n\t\"$source_dir\"\n";
          next file;
        }
        my $dest_file = "$dest_dir/$file";
        my $desc = $f_info->{$r->{FullEle}};
        unless(exists $mapping{$desc}){
          $mapping{$desc} = $inc;
          $inc += 1;
        }
        my $uid = "$new_uid_base.$mapping{$desc}";
        unless(exists $Edits->{$f}->{from_file}){
          $Edits->{$f}->{from_file} = $f;
        }
        unless(exists $Edits->{$f}->{to_file}){
          $Edits->{$f}->{to_file} = $dest_file;
        }
        $Edits->{$f}->{full_ele_additions}->{"(0020,000e)"} = $uid;
      }
    } else {
      file:
      for my $f (@{$r->{affected_files}}){
        my $dig = $dicom_info->{FilesToDigest}->{$f};
        my $f_info = $dicom_info->{FilesByDigest}->{$dig};
        unless($f =~/^(.*)\/([^\/]+)$/){
          print STDERR "Can't extract file to link from $f\n";
          next file;
        }
        my $dir = $1;
        my $file = $2;
        unless($dir eq $source_dir){
          print STDERR
            "Wrong Source dir:\n\t \"$dir\"\nvs\n\t\"$source_dir\"\n";
          next file;
        }
        my $dest_file = "$dest_dir/$file";
        if($r->{rule_code} eq "ShortEle"){
          if($r->{rule_type} =~ /^Hash/){
            if(exists $general_edits->{ChangeUids}){
              return $this->SetErrorState(
                "ChangeUids not compatable with $r->{rule_type}");
            }
            unless(exists $Edits->{$f}->{from_file}){
              $Edits->{$f}->{from_file} = $f;
            }
            unless(exists $Edits->{$f}->{to_file}){
              $Edits->{$f}->{to_file} = $dest_file;
            }
            $Edits->{$f}->{hash_unhashed_uid}->{$r->{ShortEle}} = $r->{Value};
          } elsif($r->{rule_type} =~ /^Replace/){
            unless(exists $Edits->{$f}->{from_file}){
              $Edits->{$f}->{from_file} = $f;
            }
            unless(exists $Edits->{$f}->{to_file}){
              $Edits->{$f}->{to_file} = $dest_file;
            }
            $Edits->{$f}->{short_ele_replacements}->{$r->{ShortEle}} =
              $r->{Value};
          } elsif($r->{rule_type} eq "Delete Element Leaf"){
            unless(exists $Edits->{$f}->{from_file}){
              $Edits->{$f}->{from_file} = $f;
            }
            unless(exists $Edits->{$f}->{to_file}){
              $Edits->{$f}->{to_file} = $dest_file;
            }
            $Edits->{$f}->{leaf_delete}->{$r->{ShortEle}} = 1;
          } else {
            print STDERR "Invalid rule_code ($r->{rule_code}), " .
              "rule_type ($r->{rule_type}) combination\n";
          }
        } elsif ($r->{rule_code} eq "FullEle"){
          if($r->{rule_type} =~ /^Delete/){
            unless(exists $Edits->{$f}->{from_file}){
              $Edits->{$f}->{from_file} = $f;
            }
            unless(exists $Edits->{$f}->{to_file}){
              $Edits->{$f}->{to_file} = $dest_file;
            }
            $Edits->{$f}->{full_ele_deletes}
              ->{$r->{FullEle}} = $r->{Value};
          } elsif($r->{rule_type} =~ /^Insert/){
            unless(exists $Edits->{$f}->{from_file}){
              $Edits->{$f}->{from_file} = $f;
            }
            unless(exists $Edits->{$f}->{to_file}){
              $Edits->{$f}->{to_file} = $dest_file;
            }
            $Edits->{$f}->{full_ele_additions}->{$r->{FullEle}} = $r->{Value};
          } else {
            print STDERR "Invalid rule_code ($r->{rule_code}), " .
              "rule_type ($r->{rule_type}) combination\n";
          }
        }
      }
    }
  }
  $this->{PendingEdits} = $edit_instructions;
  $dyn->{for} = "Edit";
  $dyn->{subj} = $subj;
  $this->RequestLock($http, $dyn,
    $this->WhenEditLockComplete($http, $dyn, $edit_instructions));
}
sub RelinkSs{
  my($this, $http, $dyn) = @_;
  $this->HideErrors($http, $dyn);
  my $site = $dyn->{site};
  my $coll = $dyn->{collection};
  my $subj = $dyn->{subj};
  my $series_uid = $dyn->{series_uid};
  my $dir_info =
      $this->GetExtractionEditDirsAndFiles($dyn->{subj});
  unless(
    exists $dir_info->{dicom_info_file} && -f $dir_info->{dicom_info_file}
  ){
    $this->SetErrorState(
      "No Dicom Info File found for $coll $site $subj");
    return;
  }
  my $dicom_info = Storable::retrieve($dir_info->{dicom_info_file});
  my($files_to_link, $files_to_edit) =
    $this->MakeLinkEditLists($dicom_info,
      $this->CheckFilePresent($this->{DisplayInfoIn}->{CheckedSs}));
  my $edit_dir = "$this->{ExtractionRoot}/$coll/" .
    "$site/$subj/revisions";
  my $source_dir = "$edit_dir/$dir_info->{current_rev}/files";
  my $next_rev = $dir_info->{current_rev} + 1;
  my $dest_dir = "$edit_dir/$next_rev/files";
  my $edit_instructions = {
    operation => "EditAndAnalyze",
    files_to_link => {},
    cache_dir => "$this->{DicomInfoCache}/dicom_info",
    parallelism => 3,
    destination => $dest_dir,
    source => $source_dir,
    info_dir => "$edit_dir/$next_rev",
#      source_info_dir => "$edit_dir/$dir_info->{current_rev}",
    RelinkSS => {},
  };
  file_to_link:
  for my $f (keys %$files_to_link){
    unless($f =~/^(.*)\/([^\/]+)$/){
      print STDERR "Can't extract file to link from $f\n";
      next file_to_link;
    }
    my $dir = $1;
    my $file = $2;
    my $f_info = $files_to_link->{$f};
    unless($dir eq $source_dir) {
      print STDERR "Wrong Source dir:\n\t \"$dir\"\nvs\n\t\"$source_dir\"\n";
      next file_to_link;
    }
    $edit_instructions->{files_to_link}->{$file} = $f_info->{digest};
  }
  ss_to_relink:
  for my $from_file (keys %$files_to_edit){
    unless($from_file =~ /^(.*)\/([^\/]+)$/) {
      print STDERR "Can't extract name from $from_file\n";
      next ss_to_relink;
    }
    my $dir = $1;
    my $file = $2;
    unless($dir eq $source_dir) {
      print STDERR "Wrong Edit Source dir:\n" .
        "\t \"$dir\"\nvs\n\t\"$source_dir\"\n";
      next ss_to_relink;
    }
    unless(exists $this->{DisplayInfoIn}->{SelectedSsLinkSeries}->{$from_file}){
      print STDERR "Structure Set $from_file has no selected series\n";
      next ss_to_relink;
    }
    my $sel_series = $this->{DisplayInfoIn}->{SelectedSsLinkSeries}->{$from_file};
    my $st_hash = $this->{DisplayInfoIn}->{hierarchy_by_uid};
    study:
    for my $st (keys %$st_hash){
      my $ser_hash = $st_hash->{$st}->{series};
      if(exists $ser_hash->{$sel_series}){
        my $sel_ser_hash = $ser_hash->{$sel_series};
        my $relink_inst = {
          study_uid => $st,
          series_uid => $sel_series,
          for_uid => $sel_ser_hash->{FoR},
          files => [],
        };
        for my $ldf (keys %{$sel_ser_hash->{files}}){
          my $f_info = $sel_ser_hash->{files}->{$ldf};
          my @iop = split(/\\/, $f_info->{norm_iop});
          my @ipp = split(/\\/, $f_info->{"(0020,0032"});
          my @pix_sp = split(/\\/, $f_info->{pixel_sp});
          push(@{$relink_inst->{files}}, {
            sop_inst => $f_info->{sop_instance_uid},
            sop_class => $f_info->{sop_class},
            iop => \@iop,
            ipp => [$f_info->{norm_x}, $f_info->{norm_y},  $f_info->{norm_z}],
            rows => $f_info->{rows},
            cols => $f_info->{cols},
            pix_sp => \@pix_sp,
          });
        }
        $edit_instructions->{RelinkSS}->{$from_file} = {
          from_file => $from_file,
          to_file => "$dest_dir/$file",
          relink_ss => $relink_inst,
        };
      }
    }
  }
#  $this->{DisplayInfoIn}->{RelinkInstructions} = $edit_instructions;
  $dyn->{for} = "Edit";
  $this->RequestLock($http, $dyn,
    $this->WhenEditLockComplete($http, $dyn, $edit_instructions));
}
sub CheckFilePresent{
  my($this, $hash) = @_;
  my $sub = sub {
    my($f_info, $file) = @_;
    if(exists($hash->{$file}) && $hash->{$file} eq "true"){
      return 1;
    }
    return 0;
  };
  return $sub;
}

sub WhenSplitLockComplete{
  my($this, $http, $dyn, $edit_instructions) = @_;
  my $sub = sub {
    my($lines) = @_;
    my %args;
    for my $line (@$lines){
      if($line =~ /^(.*):\s*(.*)$/){
        my $k = $1; my $v = $2;
        $args{$k} = $v;
      }
    }
    if(exists($args{Locked}) && $args{Locked} eq "OK"){
      my $commands = $args{"Revision Dir"} . "/creation.pinfo";
      store($edit_instructions, $commands);
      my $user = $this->get_user;
      my $session = $this->{session};
      my $pid = $$;
      my $new_args = [ "ApplyEdits", "Id: $args{Id}",
        "Session: $session", "User: $user", "Pid: $pid" ,
        "Commands: $commands" ];
      $this->SimpleTransaction($this->{ExtractionManagerPort},
        $new_args,
        $this->WhenEditQueued($http, $dyn));
    } else {
      print STDERR "Split Lock Failed - probably double click\n";
    }
  };
  return $sub;
}
sub SetErrorState{
  my($this, $error_message) = @_;
  $this->{ClearErrorState} = $this->{CollectionMode};
  $this->{CollectionMode} = "ErrorState";
  $this->{ErrorMessage} = $error_message;
}
sub ErrorState{
  my($this, $http, $dyn) = @_;
  $http->queue("Error: $this->{ErrorMessage}<br/>");
  $http->queue($this->MakeHostLinkSync("clear", "ClearErrorState", {
  }, 1, "Update();"));
}
sub ClearErrorState{
  my($this, $http, $dyn) = @_;
  delete $this->{ErrorMessage};
  $this->{CollectionMode} = $this->{ClearErrorState};
  delete $this->{ClearErrorState};
}
####################################################
# Discard Extraction
sub DiscardExtractionOK{
  my($this, $http, $dyn) = @_;
  $this->{CollectionMode} = "PendingDiscard";
  $this->{PendingDiscardSite} = $dyn->{site};
  $this->{PendingDiscardCollection} = $dyn->{collection};
  $this->{PendingDiscardSubject} = $dyn->{subj};
}
sub PendingDiscard{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, qq{
    <h3>Are you sure you want to discard this extraction:</h3>
    <ul>
      <li>Collection: $this->{PendingDiscardCollection}</li>
      <li>Site: $this->{PendingDiscardSite}</li>
      <li>Subject: $this->{PendingDiscardSubject}</li>
    </ul>
    <div class="btn-group">
      <?dyn="NotSoSimpleButton" caption="Yes, Discard" subj="$this->{PendingDiscardSubject}" collection="$this->{PendingDiscardCollection}" site="$this->{PendingDiscardSite}" op="DiscardExtraction" sync="Update();"?>
      <?dyn="NotSoSimpleButton" caption="No, Don't Discard" op="DontDiscardExtraction" sync="Update();"?>
    </div>
  });
}
sub DontDiscardExtraction{
  my($this, $http, $dyn) = @_;
  $this->{CollectionMode} = "CollectionsSelection";
  delete $this->{PendingDiscardSite};
  delete $this->{PendingDiscardCollection};
  delete $this->{PendingDiscardSubject};
}
sub DiscardExtraction{
  my($this, $http, $dyn) = @_;
  $this->HideErrors;
  delete $this->{DirectoryLocks};
  my $user = $this->get_user;
  my $session = $this->{session};
  my $pid = $$;
  unless(defined $session){
    print STDERR "Session undefined in DiscardExtraction\n";
    $session = '<undef>';
  }
  unless(defined $user){
    print STDERR "$user undefined in DiscardExtraction\n";
    $user = '<undef>';
  }
  unless(defined $dyn->{collection}){
    print STDERR "collection undefined in DiscardExtraction\n";
    $dyn->{collection} = '<undef>';
  }
  unless(defined $dyn->{site}){
    print STDERR "site undefined in DiscardExtraction\n";
    $dyn->{site} = '<undef>';
  }
  my $new_args = [ "DiscardExtraction",
    "Session: $session", "User: $user", "Pid: $pid" ,
    "Collection: $dyn->{collection}",
    "Site: $dyn->{site}",
    "Subject: $dyn->{subj}",
    "For: Discard",
#    "Response: $this->{BaseExternalNotificationUrl}",
  ];
  if(
    $this->SimpleTransaction($this->{ExtractionManagerPort},
    $new_args,
    $this->WhenDiscardQueued($http, $dyn))
  ){
    return;
  } else {
    print STDERR "Discard failed: probably double click\n";
  }
}
sub WhenDiscardQueued{
  my($this, $http, $dyn) = @_;
  my $sub = sub {
    print STDERR "Discard Queued\n";
    # nothing to do here???
      my($lines) = @_;
  };
  return $sub;
}
sub DiscardLastRevision{
  my($this, $http, $dyn) = @_;
  $this->HideErrors;
  delete $this->{DirectoryLocks};
  my $user = $this->get_user;
  my $session = $this->{session};
  my $pid = $$;
  my $new_args = [ "DiscardLastRevision",
    "Session: $session", "User: $user", "Pid: $pid" ,
    "Collection: $this->{DisplayInfoIn}->{Collection}",
    "Site: $this->{DisplayInfoIn}->{Site}",
    "Subject: $this->{DisplayInfoIn}->{subj}",
    "For: RevisionDiscard",
#    "Response: $this->{BaseExternalNotificationUrl}",
  ];
  if(
    $this->SimpleTransaction($this->{ExtractionManagerPort},
    $new_args,
    $this->WhenDiscardQueued($http, $dyn))
  ){
    return;
  } else {
    print STDERR "Discard failed: probably double click\n";
  }
}
sub HideErrors{
  my($this, $http, $dyn) = @_;
  $this->{CollectionMode} = "CollectionsSelection";
}
############################################
##  ResolveDupSopInstances
#############################################
sub ResolveDupSopInstances{
  my($this, $http, $dyn) = @_;
  my $child_name = $this->child_path("ResolveDupSopInstances");
  my $child = $this->child("ResolveDupSopInstances");
  unless($child) {
    PosdaCuration::DuplicateSopResolution->new($this->{session}, $child_name,
      $this->{DisplayInfoIn},
      $this->{DupSopInstList});
  }
  $this->{CollectionMode} = "ResolveDupSopInstancesContent";
}
sub ResolveDupSopInstancesContent{
  my($this, $http, $dyn) = @_;
    my $child = $this->child("ResolveDupSopInstances");
    unless(defined $child){
      return $this->HideInfo;
    }
    if($child->can("Refresh")){
      $child->Refresh($http, $dyn);
    } else {
      $this->HideInfo;
    }
    return;
}
############################################
##  GeneralPurposeEditor
#############################################
sub GeneralPurposeEditor{
  my($this, $http, $dyn) = @_;
  my $child_name = $this->child_path("GeneralPurposeEditor");
  my $child = $this->child("GeneralPurposeEditor");
  unless($child) {
    PosdaCuration::GeneralPurposeEditor->new($this->{session}, $child_name,
      $this->{DisplayInfoIn});
  }
  $this->{CollectionMode} = "GeneralPurposeEditorContent";
}
sub GeneralPurposeEditorContent{
  my($this, $http, $dyn) = @_;
    my $child = $this->child("GeneralPurposeEditor");
    unless(defined $child){
      return $this->HideInfo;
    }
    if($child->can("Refresh")){
      $child->Refresh($http, $dyn);
    } else {
      $this->HideInfo;
    }
    return;
}
#############################################
sub GetExtractionEditDirsAndFiles{
  my($this, $subj) = @_;
  my $subj_dir = "$this->{ExtractionRoot}/$this->{SelectedCollection}" .
    "/$this->{SelectedSite}/$subj";
  my $lock_file = "$subj_dir/lock.txt";
  my $hist_file = "$subj_dir/history.pinfo";
  my $rev_dir = "$subj_dir/revisions";
  my $rev_hist_file = "$subj_dir/rev_hist.pinfo";
  my $current_rev = 0;
  if(-f $rev_hist_file){
    my $rev_hist;
    eval {$rev_hist = Storable::retrieve($rev_hist_file) };
    if($@){
      print STDERR "Can't retrieve from $rev_hist_file\n";
    }
    if(exists $rev_hist->{CurrentRev}) {
      $current_rev = $rev_hist->{CurrentRev}
    } else {
      print STDERR "No CurrentRev in $rev_hist_file\n";
    }
  } else {
    print STDERR "Rev hist: $rev_hist_file doesn't exist\n";
  }
  my $h = {
    current_rev => $current_rev,
    info_dir => "$rev_dir/$current_rev",
    file_dir => "$rev_dir/$current_rev/files",
  };
  my $hierarchy_file = "$rev_dir/$current_rev/hierarchy.pinfo";
  if(-f $hierarchy_file){
    my $hierarchy;
    eval {$hierarchy = Storable::retrieve($hierarchy_file) };
    if($@){
      print STDERR "Can't retrieve from $hierarchy_file\n";
    } else {
      $h->{hierarchy} = $hierarchy;
    }
  } else {
    print STDERR "Hierarchy: $hierarchy_file doesn't exist\n";
  }
  my $creation_file = "$rev_dir/$current_rev/creation.pinfo";
  my $consistency_file = "$rev_dir/$current_rev/consistency.pinfo";
  my $dicom_info_file = "$rev_dir/$current_rev/dicom.pinfo";
  my $link_info_file = "$rev_dir/$current_rev/link_info.pinfo";
  my $error_info_file = "$rev_dir/$current_rev/error.pinfo";
  my $ignored_error_info_file = "$rev_dir/$current_rev/ignored_error.pinfo";
  my $send_info_file = "$rev_dir/$current_rev/send_hist.pinfo";
  my $phi_file = "$rev_dir/$current_rev/phi.pinfo";
  if(-f $creation_file){ $h->{creation_file} = $creation_file }
  if(-f $consistency_file){ $h->{consistency_file} = $consistency_file }
  if(-f $hierarchy_file){ $h->{hierarchy_file} = $hierarchy_file }
  if(-f $dicom_info_file){ $h->{dicom_info_file} = $dicom_info_file }
  if(-f $link_info_file){ $h->{link_info_file} = $link_info_file }
  if(-f $error_info_file){ $h->{error_info_file} = $error_info_file }
  if(-f $ignored_error_info_file){
    $h->{ignored_error_info_file} = $ignored_error_info_file
  }
  if(-f $send_info_file){ $h->{send_info_file} = $send_info_file }
  if(-f $phi_file){ $h->{phi_file} = $phi_file }
  return $h;
}
sub WhenEditLockComplete{
  my($this, $http, $dyn, $edit_instructions) = @_;
  my $sub = sub {
    my($lines) = @_;
    my %args;
    for my $line (@$lines){
      if($line =~ /^(.*):\s*(.*)$/){
        my $k = $1; my $v = $2;
        $args{$k} = $v;
      }
    }
    if(exists($args{Locked}) && $args{Locked} eq "OK"){
$this->{DebugLastEditInstructions} = $edit_instructions;
      my $commands = $args{"Revision Dir"} . "/creation.pinfo";
      store($edit_instructions, $commands);
      my $user = $this->get_user;
      my $session = $this->{session};
      my $pid = $$;
      my $new_args = [ "ApplyEdits", "Id: $args{Id}",
        "Session: $session", "User: $user", "Pid: $pid" ,
        "Commands: $commands" ];
      $this->SimpleTransaction($this->{ExtractionManagerPort},
        $new_args,
        $this->WhenEditQueued($http, $dyn));
    } else {
      print STDERR "##################################\n";
      print STDERR "Edit Lock Failed - probably double click\n";
      for my $i (sort keys %args){
        print STDERR "$i: $args{$i}\n";
      }
      print STDERR "##################################\n";
    }
  };
  return $sub;
}
sub MakeLinkEditLists{
  my($this, $dicom_info, $edit_pred) = @_;
  my %files_to_link;
  my %files_to_edit;
  for my $file (keys %{$dicom_info->{FilesToDigest}}){
    my $dig = $dicom_info->{FilesToDigest}->{$file};
    my $f_info = $dicom_info->{FilesByDigest}->{$dig};
    if(&$edit_pred($f_info, $file)){
      $files_to_edit{$file} = $f_info;
    } else {
      $files_to_link{$file} = $f_info;
    }
  }
  return(\%files_to_link, \%files_to_edit);
}
################################
# ExtractAllUnextracted
sub ExtractAllUnextracted{
  my($this, $http, $dyn) = @_;
  $this->{CollectionMode} = "PendingExtractAll";
  $this->{PendingExtractAllSite} = $this->{SelectedSite};
  $this->{PendingExtractAllCollection} = $this->{SelectedCollection};
  my @extractions_to_perform; 
  for my $subj (sort keys %{$this->{DbResults}}){
    unless(exists $this->{ExtractionsHierarchies}->{$subj}) { next }
    unless(
      exists(
        $this->{ExtractionsHierarchies}
          ->{$subj}->{hierarchy}->{$subj}->{studies}
      )
    ){ push(@extractions_to_perform, $subj) }
  }
  $this->{PendingExtractAllList} = \@extractions_to_perform;
}
sub PendingExtractAll{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, qq{
    <h3>Are you sure you want to perform the following extractions:</h3>
    <ul>
      <li>Collection: $this->{PendingExtractAllCollection}</li>
      <li>Site: $this->{PendingExtractAllSite}</li>
      <li>
        Subjects:
        <ul>
  });
  for my $i (@{$this->{PendingExtractAllList}}){
    $http->queue("<li>$i</li>");
  }
  $this->RefreshEngine($http, $dyn, qq{
        </ul>
      </li>
    </ul>
    <div class="btn-group">
      <?dyn="NotSoSimpleButton" caption="Yes, Extract" op="ExtractAllYes" sync="Update();"?>
      <?dyn="NotSoSimpleButton" caption="No, Don't Extract" op="DontExtractAll" sync="Update();"?>
    </div>
  });
}
sub DontExtractAll{
  my($this, $http, $dyn) = @_;
  $this->{CollectionMode} = "CollectionsSelection";
  delete $this->{PendingExtractAllSite};
  delete $this->{PendingExtractAllCollection};
  delete $this->{PendingExtractAllList};
}
sub ExtractAllYes{
  my($this, $http, $dyn) = @_;
  my @list = @{$this->{PendingExtractAllList}};
  Dispatch::Select::Background->new($this->ExtractSubjects(
    $http, $dyn, \@list)
  )->queue;
  $this->{CollectionMode} = "PreparingExtractions";
  delete $this->{PendingExtractAllSite};
  delete $this->{PendingExtractAllCollection};
#  delete $this->{PendingExtractAllList};
  $this->{ProcessingExtractAllList} = \@list;
}
sub ExtractSubjects{
  my($this, $http, $dyn, $subjects) = @_;
  my $sub = sub {
    my($disp) = @_;
    if($#{$subjects} == -1){
      $this->{CollectionMode} = "CollectionsSelection";
      delete $this->{PendingExtractAllList};
      delete $this->{ProcessingExtractAllList};
      return;
    }
    my $next = shift @{$subjects};
    $this->ExtractNextSubject($next, $disp);
  };
  return $sub;
}
sub PreparingExtractions{
  my($this, $http, $dyn) = @_;
  my $total_to_extract = @{$this->{PendingExtractAllList}};
  my $waiting_to_extract = @{$this->{ProcessingExtractAllList}};
  $http->queue("<h2>Preparing Extractions</h2>" .
    "Total: $total_to_extract<br>" .
    "Waiting: $waiting_to_extract");
}
#sub ExtractSubject{
#  my($this, $http, $dyn) = @_;
#  my $cmd = "BuildExtractionCommands.pl " .
#    "\"$this->{Environment}->{database_name}\" " .
#    "\"$this->{SelectedCollection}\" " .
#    "\"$this->{SelectedSite}\" " .
#    "\"$dyn->{subj}\"";
#  my $struct = {};
#  Dispatch::LineReader->new_cmd($cmd,
#    $this->BuildExtractionLine($this->{SelectedCollection},
#      $this->{SelectedSite}, $dyn->{subj}, $struct),
#    $this->BuildExtractionEnd($http, $dyn,
#      $this->{SelectedCollection},
#      $this->{SelectedSite}, $dyn->{subj}, $struct)
#  );
#}
#sub BuildExtractionEnd{
#  my($this, $http, $dyn, $collection, $site, $subj, $struct) = @_;
#  my $sub = sub{
#    $this->LockForExtractSubject($http, $dyn, $subj, $struct);
#  };
#  return $sub;
#}
#sub LockForExtractSubject{
#  my($this, $http, $dyn, $subj, $struct) = @_;
#  $this->RequestLock($http, $dyn,
#    $this->WhenExtractionLockComplete($http, $dyn, $subj, $struct));
#}
#sub WhenExtractionLockComplete{
#  my($this, $http, $dyn, $subj, $struct) = @_;
#  my $sub = sub {
#    my($lines) = @_;
#    my %args;
#    for my $line (@$lines){
#      if($line =~ /^(.*):\s*(.*)$/){
#        my $k = $1; my $v = $2;
#        $args{$k} = $v;
#      }
#    }
#    if(exists($args{Locked}) && $args{Locked} eq "OK"){
#      my $extract_struct = {
#        operation => "ExtractAndAnalyze",
#        destination => $args{"Destination File Directory"},
#        info_dir => $args{"Revision Dir"},
#        cache_dir => "$this->{DicomInfoCache}/dicom_info",
#        parallelism => 5,
#        desc => {
#          patient_id => $subj,
#          studies => $struct,
#        },
#      };
#      $extract_struct->{desc}->{patient_id} = $subj;
#      my $commands = $args{"Revision Dir"} . "/creation.pinfo";
#      store($extract_struct, $commands);
#      my $session = $this->{session};
#      my $pid = $$;
#      my $user = $this->get_user;
#      my $new_args = [ "ApplyEdits", "Id: $args{Id}",
#        "Session: $session", "User: $user", "Pid: $pid" ,
#        "Commands: $commands" ];
#      $this->SimpleTransaction($this->{ExtractionManagerPort},
#        $new_args,
#        $this->WhenEditQueued($http, $dyn));
#    } else {
#      print STDERR "Extraction Lock Failed - probably double click\n";
#    }
#  };
#  return $sub;
#}
#sub WhenEditQueued{
#  my($this, $http, $dyn) = @_;
#  my $sub = sub {
#    # nothing to do here???
#    my($lines) = @_;
#  };
#  return $sub;
#}
sub ExtractNextSubject{
  my($this, $next, $disp) = @_;
  my $cmd = "BuildExtractionCommands.pl " .
    "\"$this->{Environment}->{database_name}\" " .
    "\"$this->{SelectedCollection}\" " .
    "\"$this->{SelectedSite}\" " .
    "\"$next\"";
  my $struct = {};
  Dispatch::LineReader->new_cmd($cmd,
    $this->BuildExtractionLine($this->{SelectedCollection},
      $this->{SelectedSite}, $next, $struct),
    $this->BuildNextExtractionEnd(
      $this->{SelectedCollection},
      $this->{SelectedSite}, $next, $struct, $disp)
  );
  $this->AutoRefresh;
}
sub BuildNextExtractionEnd{
  my($this, $collection, $site, $subj, $struct, $disp) = @_;
  my $sub = sub{
    $this->LockForNextExtractSubject($subj, $struct, $disp);
  };
  return $sub;
}
sub LockForNextExtractSubject{
  my($this, $subj, $struct, $disp) = @_;
  $this->NewRequestLockForEdit($subj,
    $this->WhenNextExtractionLockComplete($subj, $struct, $disp));
}
sub WhenNextExtractionLockComplete{
  my($this, $subj, $struct, $disp) = @_;
  my $sub = sub {
    my($lines) = @_;
    my %args;
    for my $line (@$lines){
      if($line =~ /^(.*):\s*(.*)$/){
        my $k = $1; my $v = $2;
        $args{$k} = $v;
      }
    }
    if(exists($args{Locked}) && $args{Locked} eq "OK"){
      my $extract_struct = {
        operation => "ExtractAndAnalyze",
        destination => $args{"Destination File Directory"},
        info_dir => $args{"Revision Dir"},
        cache_dir => "$this->{DicomInfoCache}/dicom_info",
        parallelism => 5,
        desc => {
          patient_id => $subj,
          studies => $struct,
        },
      };
      $extract_struct->{desc}->{patient_id} = $subj;
      my $commands = $args{"Revision Dir"} . "/creation.pinfo";
      store($extract_struct, $commands);
      my $session = $this->{session};
      my $pid = $$;
      my $user = $this->get_user;
      my $new_args = [ "ApplyEdits", "Id: $args{Id}",
        "Session: $session", "User: $user", "Pid: $pid" ,
        "Commands: $commands" ];
      $this->SimpleTransaction($this->{ExtractionManagerPort},
        $new_args,
        $this->WhenNextExtractQueued($disp));
    } else {
      print STDERR "Extraction Lock Failed - probably double click\n";
    }
  };
  return $sub;
}
sub WhenNextExtractQueued{
  my($this, $disp) = @_;
  my $sub = sub {
    my($lines) = @_;
print "In WhenNextExtractQueued($lines)\n";
    if(ref($lines) eq "ARRAY"){
      print "Response:\n";
      for my $line (@$lines){
        print "\t$line\n";
      }
    }
print "##########\n";
    $disp->queue;
  };
  return $sub;
}
################################
# Discard Incomplete Extractions
sub DiscardIncompleteExtractions{
  my($this, $http, $dyn) = @_;
  $this->{CollectionMode} = "PendingDiscardIE";
  $this->{PendingIEDiscardSite} = $this->{SelectedSite};
  $this->{PendingIEDiscardCollection} = $this->{SelectedCollection};
  my @extractions_to_discard; 
  for my $subj (sort keys %{$this->{DbResults}}){
    unless(exists $this->{ExtractionsHierarchies}->{$subj}) { next }
    unless(
      exists(
        $this->{ExtractionsHierarchies}
          ->{$subj}->{hierarchy}->{$subj}->{studies}
      )
    ){ next }
    my($db_studies, $db_series, $db_images) =
      $this->GetCountsDatabase($this->{DbResults}->{$subj}->{studies});
    my($ex_studies, $ex_series, $ex_images) =
      $this->GetCountsExtraction(
        $this->{ExtractionsHierarchies}
          ->{$subj}->{hierarchy}->{$subj}->{studies}
      )
    ;
    unless($db_images == $ex_images){
      push(@extractions_to_discard, $subj);
    }
  }
  $this->{PendingIEDiscardSubjectList} = \@extractions_to_discard;
}
sub PendingDiscardIE{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, qq{
    <h3>Are you the sure you want to discard the following extractions:</h3>
    <ul>
      <li>Collection: $this->{PendingIEDiscardCollection}</li>
      <li>Site: $this->{PendingIEDiscardSite}</li>
      <li>
        Subjects:
        <ul>
  });
  for my $i (@{$this->{PendingIEDiscardSubjectList}}){
    $http->queue("<li>$i</li>");
  }
  $this->RefreshEngine($http, $dyn, qq{
        </ul>
      </li>
    </ul>
    <div class="btn-group">
      <?dyn="NotSoSimpleButton" caption="Yes, Discard" op="DiscardIncompleteExtractionsYes" sync="Update();"?>
      <?dyn="NotSoSimpleButton" caption="No, Don't Discard" op="DontDiscardIncompleteExtraction" sync="Update();"?>
    </div>
  });
}
sub DontDiscardIncompleteExtraction{
  my($this, $http, $dyn) = @_;
  $this->{CollectionMode} = "CollectionsSelection";
  delete $this->{PendingIEDiscardSite};
  delete $this->{PendingIEDiscardCollection};
  delete $this->{PendingIEDiscardSubjectList};
}
sub DiscardIncompleteExtractionsYes{
  my($this, $http, $dyn) = @_;
  my @list = @{$this->{PendingIEDiscardSubjectList}};
  Dispatch::Select::Background->new($this->DiscardSubjects(
    $http, $dyn, \@list)
  )->queue;
  $this->{CollectionMode} = "CollectionsSelection";
  delete $this->{PendingIEDiscardSite};
  delete $this->{PendingIEDiscardCollection};
  delete $this->{PendingIEDiscardSubjectList};
}
sub DiscardSubjects{
  my($this, $http, $dyn, $subjects) = @_;
  my $sub = sub {
    my($disp) = @_;
    if($#{$subjects} == -1){
      return;
    }
    my $next = shift @{$subjects};
    $this->DiscardNextSubject($next, $disp);
  };
  return $sub;
}
sub DiscardNextSubject{
  my($this, $next, $disp) = @_;
  my $user = $this->get_user;
  my $session = $this->{session};
  my $pid = $$;
  my $collection;
  my $site;
  unless(defined $session){
    print STDERR "Session undefined in DiscardNextSubject\n";
    $session = '<undef>';
  }
  unless(defined $user){
    print STDERR "$user undefined in DiscardNextSubject\n";
    $user = '<undef>';
  }
  unless(defined $this->{SelectedCollection}){
    print STDERR "collection undefined in DiscardNextSubject\n";
    return;
  }
  unless(defined $this->{SelectedSite}){
    print STDERR "site undefined in DiscardNextSubject\n";
    return;
  }
  my $new_args = [ "DiscardExtraction",
    "Session: $session", "User: $user", "Pid: $pid" ,
    "Collection: $this->{SelectedCollection}",
    "Site: $this->{SelectedSite}",
    "Subject: $next",
    "For: Discard",
#    "Response: $this->{BaseExternalNotificationUrl}",
  ];
print "Invoking Discard:\n";
for my $line(@$new_args){
  print "\t$line\n";
}
print "###########\n";
  if(
    $this->SimpleTransaction($this->{ExtractionManagerPort},
    $new_args,
    $this->WhenNextDiscardQueued($disp))
  ){
    print "Discard succeeded\n";
    return;
  } else {
    print STDERR "Discard failed: probably double click\n";
  }
}
sub WhenNextDiscardQueued{
  my($this, $disp) = @_;
  my $sub = sub {
    my($lines) = @_;
print "In WhenNextDiscardQueued($lines)\n";
    if(ref($lines) eq "ARRAY"){
      print "Response:\n";
      for my $line (@$lines){
        print "\t$line\n";
      }
    }
print "##########\n";
    $disp->queue;
  };
  return $sub;
}
################################
sub GetCountsExtraction{
  my($this, $struct) = @_;
  my $num_studies = keys %{$struct};
  my $num_series = 0;
  my $num_images = 0;
  for my $std (keys %$struct){
    $num_series += keys %{$struct->{$std}->{series}};
    for my $ser ( keys %{$struct->{$std}->{series}}){
      $num_images += keys %{$struct->{$std}->{series}->{$ser}->{files}};
    }
  }
  return($num_studies, $num_series, $num_images);
}
sub GetCountsDatabase{
  my($this, $struct) = @_;
  my $num_studies = keys %{$struct};
  my $num_series = 0;
  my $num_images = 0;
  for my $std (keys %$struct){
    $num_series += keys %{$struct->{$std}->{series}};
    for my $ser ( keys %{$struct->{$std}->{series}}){
      $num_images += $struct->{$std}->{series}->{$ser}->{num_files};
    }
  }
  return($num_studies, $num_series, $num_images);
}
sub NewRequestLockForEdit{
  my($this, $subj, $at_end) = @_;
  my $collection = $this->{SelectedCollection};
  my $site = $this->{SelectedSite};
  my $user = $this->get_user;
  my $session = $this->{session};
  my $pid = $$;
#  my $url = $this->{BaseExternalNotificationUrl};
  $this->LockExtractionDirectory({
    Collection => $collection,
    Site => $site,
    Subject => $subj,
    Session => $session,
    User => $user,
    Pid => $pid,
    For => "Edit",
#    Response => $url,
   }, $at_end);
}
sub GetLatestRevDir{
  my($this, $coll, $site, $subj) = @_;
  my $base_dir = "$this->{ExtractionRoot}/$coll/$site/$subj";
  my $rev_hist = Storable::retrieve("$base_dir/rev_hist.pinfo");
  my $latest_rev = $rev_hist->{CurrentRev};
  return "$base_dir/revisions/$latest_rev";
}
################################
# Remove All Phi Scans
sub RemoveAllPhiScans{
  my($this, $http, $dyn) = @_;
  $this->{CollectionMode} = "RemovingPhiScans";
  $this->{PhiRemoveLines} = [];
  my $dir = $this->{ExtractionRoot} . "/$this->{SelectedCollection}" .
    "/$this->{SelectedSite}";
  my $cmd = "RemovePhiScans.pl \"$dir\"";
  Dispatch::LineReader->new_cmd($cmd,
    $this->RemovePhiScanLines,
    $this->RemovePhiScanLinesDone);
}
sub RemovingPhiScans{
  my($this, $http, $dyn) = @_;
  $http->queue("Removing PHI file:<br><pre>");
  for my $line (@{$this->{PhiRemoveLines}}){
    $http->queue("$line\n");
  }
  $http->queue("</pre>");
}
sub RemovePhiScanLines{
  my($this) = @_;
  my $sub = sub {
    my($line) = @_;
    push @{$this->{PhiRemoveLines}}, $line;
    $this->AutoRefresh;
  };
  return $sub;
}
sub RemovePhiScanLinesDone{
  my($this) = @_;
  my $sub = sub {
    $this->{CollectionMode} = "CollectionsSelection";
    delete $this->{PhiRemoveLines};
    $this->AutoRefresh;
  };
  return $sub;
}
################################
# PhiSearch Transaction
sub PhiSearch{
  my($this, $http, $dyn) = @_;
  $this->HideErrors;
  delete $this->{DirectoryLocks};
  my $user = $this->get_user;
  my $session = $this->{session};
  my $pid = $$;
  unless(defined $session){
    print STDERR "Session undefined in PhiSearch\n";
    $session = '<undef>';
  }
  unless(defined $user){
    print STDERR "$user undefined in PhiSearch\n";
    $user = '<undef>';
  }
  my $new_args = [ "CheckForPhi",
    "Session: $session", "User: $user", "Pid: $pid" ,
    "Collection: $this->{DisplayInfoIn}->{Collection}",
    "Site: $this->{DisplayInfoIn}->{Site}",
    "Subject: $this->{DisplayInfoIn}->{subj}",
    "For: PhiSearch",
#    "Response: $this->{BaseExternalNotificationUrl}",
  ];
  if(
    $this->SimpleTransaction($this->{ExtractionManagerPort},
    $new_args,
    $this->WhenPhiQueued($http, $dyn))
  ){
    return;
  } else {
    print STDERR "Phi failed: probably double click\n";
  }
}
sub WhenPhiQueued{
  my($this, $http, $dyn) = @_;
  my $sub = sub {
    print STDERR "PhiCalculation Queued\n";
    # nothing to do here???
    my($lines) = @_;
    for my $line (@$lines){
      print STDERR "\t$line\n";
    }
  };
  return $sub;
}
################################
# Scan for PHI if not already scanned
sub ScanAllForPhi{
  my($this, $http, $dyn) = @_;
  $this->{CollectionMode} = "PendingPhiScans";
  $this->{PendingPhiScanSite} = $this->{SelectedSite};
  $this->{PendingPhiScanCollection} = $this->{SelectedCollection};
  my @SubjsToScan; 
  my @SubjsScanned; 
  for my $subj (sort keys %{$this->{DbResults}}){
    # Currently ExtractionsHierarchies is created for every subject,
    # but will be empty for unextracted subjects.
    unless(keys %{$this->{ExtractionsHierarchies}->{$subj}}) { next }
    my $rev_dir = $this->GetLatestRevDir($this->{SelectedCollection},
      $this->{SelectedSite}, $subj);
    if(-f "$rev_dir/PhiCheck.info"){
      push @SubjsScanned, "$rev_dir/PhiCheck.info";
    } else {
      push @SubjsToScan, $subj;
    }
  }
  if(@SubjsToScan > 0){
    $this->{PendingPhiScanSubjectList} = \@SubjsToScan;
  } elsif(@SubjsScanned > 0){
    $this->{PendingPhiConsolidationList} = \@SubjsScanned;
    $this->{CollectionMode} = "AllSubjectsScanned";
  } else {
    $this->DontDoPhiScans;
  }
}
sub PendingPhiScans{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, qq{
    <h3>Are you sure you want to scan the following for PHI:</h3>
    <ul>
      <li>Collection: $this->{PendingPhiScanCollection}</li>
      <li>Site: $this->{PendingPhiScanSite}</li>
      <li>
        Subjects:
        <ul>
  });
  for my $i (@{$this->{PendingPhiScanSubjectList}}){
    $http->queue("<li>$i</li>");
  }
  $this->RefreshEngine($http, $dyn, qq{
        </ul>
      </li>
    </ul>
    <div class="btn-group">
      <?dyn="NotSoSimpleButton" caption="Yes, Scan" op="PhiScansYes" sync="Update();"?>
      <?dyn="NotSoSimpleButton" caption="No, Don't Scan" op="DontDoPhiScans" sync="Update();"?>
    </div>
  });
}
sub DontDoPhiScans{
  my($this, $http, $dyn) = @_;
  $this->{CollectionMode} = "CollectionsSelection";
  delete $this->{PendingPhiScanSite};
  delete $this->{PendingPhiScanCollection};
  delete $this->{PendingPhiScanSubjectList};
}
sub PhiScansYes{
  my($this, $http, $dyn) = @_;
  my @list = @{$this->{PendingPhiScanSubjectList}};
  Dispatch::Select::Background->new($this->PhiScanSubjects(
    $http, $dyn, \@list)
  )->queue;
  $this->{CollectionMode} = "CollectionsSelection";
  delete $this->{PendingPhiScanSite};
  delete $this->{PendingPhiScanCollection};
  delete $this->{PendingPhiScanSubjectList};
}
sub PhiScanSubjects{
  my($this, $http, $dyn, $subjects) = @_;
  my $sub = sub {
    my($disp) = @_;
    if($#{$subjects} == -1){
      return;
    }
    my $next = shift @{$subjects};
    $this->PhiScanNextSubject($next, $disp);
  };
  return $sub;
}
sub PhiScanNextSubject{
  my($this, $next, $disp) = @_;
  my $user = $this->get_user;
  my $session = $this->{session};
  my $pid = $$;
  my $collection;
  my $site;
  unless(defined $session){
    print STDERR "Session undefined in PhiScanNextSubject\n";
    $session = '<undef>';
  }
  unless(defined $user){
    print STDERR "$user undefined in PhiScanNextSubject\n";
    $user = '<undef>';
  }
  unless(defined $this->{SelectedCollection}){
    print STDERR "collection undefined in PhiScanNextSubject\n";
    return;
  }
  unless(defined $this->{SelectedSite}){
    print STDERR "site undefined in PhiScanNextSubject\n";
    return;
  }
#  my $new_args = [ "DiscardExtraction",
#    "Session: $session", "User: $user", "Pid: $pid" ,
#    "Collection: $this->{SelectedCollection}",
#    "Site: $this->{SelectedSite}",
#    "Subject: $next",
#    "For: Discard",
##    "Response: $this->{BaseExternalNotificationUrl}",
#  ];
  my $new_args = [ "CheckForPhi",
    "Session: $session", "User: $user", "Pid: $pid" ,
    "Collection: $this->{SelectedCollection}",
    "Site: $this->{SelectedSite}",
    "Subject: $next",
    "For: PhiSearch",
#    "Response: $this->{BaseExternalNotificationUrl}",
  ];
print "Invoking PhiScan:\n";
for my $line(@$new_args){
  print "\t$line\n";
}
print "###########\n";
  if(
    $this->SimpleTransaction($this->{ExtractionManagerPort},
    $new_args,
    $this->WhenNextPhiScanQueued($disp))
  ){
    print "PhiScan succeeded\n";
    return;
  } else {
    print STDERR "PhiScan failed: probably double click\n";
  }
}
sub WhenNextPhiScanQueued{
  my($this, $disp) = @_;
  my $sub = sub {
    my($lines) = @_;
print "In WhenNextPhiScanQueued($lines)\n";
    if(ref($lines) eq "ARRAY"){
      print "Response:\n";
      for my $line (@$lines){
        print "\t$line\n";
      }
    }
print "##########\n";
    $disp->queue;
  };
  return $sub;
}
sub AllSubjectsScanned{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, qq{
    <h3>All Subjects have already been scanned for PHI</h3>
    <ul>
      <li>Collection: $this->{PendingPhiScanCollection}</li>
      <li>Site: $this->{PendingPhiScanSite}</li>
    </ul>
    <div class="btn-group">
      <?dyn="NotSoSimpleButton" caption="Ok, (Go back)" op="DontConsolidate" sync="Update();"?>
      <?dyn="NotSoSimpleButton" caption="Consolidate Scans For Review" op="ConsolidatePhi" sync="Update();"?>
    </div>
  });
}
sub DontConsolidate{
  my($this, $http, $dyn) = @_;
  $this->{CollectionMode} = "CollectionsSelection";
  delete $this->{PendingPhiScanSite};
  delete $this->{PendingPhiScanCollection};
  delete $this->{PendingPhiConsolidationList};
}
sub ConsolidatePhi{
  my($this, $http, $dyn) = @_;
  my $phi_root = $this->{Environment}->{PhiAnalysisRoot} .
    "/$this->{SelectedCollection}";
  unless(-d $phi_root){
    unless(mkdir($phi_root) == 1){
      my $error = "Couldn't mkdir $phi_root ($!)";
      delete $this->{PendingPhiScanSite};
      delete $this->{PendingPhiScanCollection};
      delete $this->{PendingPhiConsolidationList};
      $this->SetCollectionError($error);
      return;
    }
  }
  $phi_root = "$phi_root/$this->{SelectedSite}";
  unless(-d $phi_root){
    unless(mkdir($phi_root) == 1){
      my $error = "Couldn't mkdir $phi_root ($!)";
      delete $this->{PendingPhiScanSite};
      delete $this->{PendingPhiScanCollection};
      delete $this->{PendingPhiConsolidationList};
      $this->SetCollectionError($error);
      return;
    }
  }
  my $dir;
  unless(opendir $dir, $phi_root){
    return $this->SetCollectionError("Can't opendir $phi_root");
  }
  my @rounds;
  while (my $d = readdir($dir)){
    if($d =~ /^\./) { next }
    unless($d =~ /^[\d]+$/) {
      print STDERR "bad format for round directory ($d) in $phi_root\n";
      next;
    }
    unless(-d "$phi_root/$d"){
      print STDERR "not a directory ($d) in $phi_root\n";
      next;
    }
    push @rounds, $d;
  }
  my $current_round;
  my $next_round;
  if(@rounds <= 0){
    $next_round = 0;
  } else {
    @rounds = sort {$a<=>$b} @rounds;
    $current_round = $rounds[$#rounds];
    $next_round = $current_round + 1;
  }
  if(defined $current_round){
    # Right here you could scan the data in the current round
    # and see if the files from which it is constructed are the
    # same as those in the current list, and just put up a message
    # saying that its already been done.
    # Alternatively, you could move this (and immediately 
    # preceeding/following) code to the sub-process ...
    #
  }
  unless(mkdir("$phi_root/$next_round") == 1){
    return $this->SetCollectionError("Can't mkdir $phi_root/$next_round ($!)");
  }
  my $report_file = "$phi_root/$next_round/consolidated.pinfo";
  my $bom_file = "$phi_root/$next_round/consolidation_bom.txt";
  my($sock, $pid) = $this->ReadWriteChild("SubProcessConsolidatePhiScans.pl " .
    "\"$bom_file\" \"$report_file\"");
  Dispatch::Select::Socket->new($this->FeedConsolidater, $sock)->Add("writer");
  Dispatch::Select::Socket->new(
    $this->ReadConsolidater($pid), $sock)->Add("reader");
  $this->{CollectionMode} = "PhiConsolidationInProgress";
}
sub FeedConsolidater{
  my($this) = @_;
  my $sub = sub {
    my($disp, $sock) = @_;
    if(my $file = shift (@{$this->{PendingPhiConsolidationList}})){
      print $sock "$file\n";
    } else {
      $disp->Remove("writer");
      shutdown($sock, 1);
    }
  };
  return $sub;
}
sub ReadConsolidater{
  my($this, $pid) = @_;
  my $buff = "";
  my $sub = sub {
    my($disp, $sock) = @_;
    my $ret = read($sock, $buff, 1024, length($buff));
    unless(defined($ret) && $ret < 0){
      $disp->Remove("reader");
      $this->HarvestPid($pid);
      $this->AutoRefresh;
      $this->{CollectionMode} = "PhiConsolidationComplete";
      $this->{PhiConsolidationStatus} = $buff;
    }
  };
  return $sub;
}
sub PhiConsolidationInProgress{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
    '<h3>Consolidation in Progress</h3>'
  );
}
sub PhiConsolidationComplete{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
    '<h3>Consolidation Complete</h3>' . $this->{PhiConsolidationStatus} .
    '<br/><?dyn="NotSoSimpleButton" caption="Got It" ' .
    'op="ClearConsolidation" sync="Update();"?>'
  );
}
sub ClearConsolidation{
  my($this, $http, $dyn) = @_;
  delete $this->{ConsolidationStatus};
  $this->{CollectionMode} = "CollectionsSelection";
}
################################
sub SetCollectionError{
  my($this, $message) = @_;
  $this->{CollectionMode} = "CollectionError";
  $this->{CollectionError} = $message;
}
sub CollectionError{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
    '<h3>An Error Occured:</h3>' . $this->{CollectionError} .
    '<br/><?dyn="NotSoSimpleButton" caption="Got It" ' .
    'op="ClearCollectionError" sync="Update();"?>'
  );
}
sub ClearCollectionError{
  my($this, $http, $dyn) = @_;
  delete $this->{CollectionError};
  $this->{CollectionMode} = "CollectionsSelection";
}
################################
# Fix Study Inconsistencies
sub FixStudyInconsistencies{
  my($this, $http, $dyn) = @_;
  $this->{CollectionMode} = "ScanningStudyInconsistencies";
  my $dir = $this->{ExtractionRoot} . "/$this->{SelectedCollection}" .
    "/$this->{SelectedSite}";
  my $cmd = "FindStudyConsistencyErrors.pl \"$dir\"";
  my $pid = open my $fh, "$cmd|" or die "Can't open $cmd|";
  Dispatch::Select::Socket->new(
    $this->ReadSerializedResponse($this->SaveStudyInconsistencies, $pid),
    $fh
  )->Add("reader");
}
sub SaveStudyInconsistencies{
  my($this) = @_;
  my $sub = sub {
    my($stat, $results) = @_;
    if($stat eq "Succeeded"){
      $this->{StudyInconsistencies} = $results;
      $this->{CollectionMode} = "ProposingStudyInconsistencyFixes";
      my @subjs = keys %$results;
      Dispatch::Select::Background->new(
        $this->ProposeStudyFixes(\@subjs))->queue;
    } else {
      my $error = "Status to Study Inconsistency Scan: $stat";
      $this->SetCollectionError($error);
    }
    $this->AutoRefresh;
  };
  return $sub;
}
sub ScanningStudyInconsistencies{
  my($this, $http, $dyn) = @_;
  $http->queue("Scanning for Study Inconsistencies");
}
sub ProposingStudyInconsistencyFixes{
  my($this, $http, $dyn) = @_;
  $http->queue("Proposing Study Inconsistency Fixes");
}
sub StudyInconsistenciesFound{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
    "Study Inconsistencies Found:" .
    '<?dyn="NotSoSimpleButton" op="CancelStudyFixes" caption="Cancel"' . 
    ' sync="Update();"?>' .
    '<?dyn="NotSoSimpleButton" op="ApplyStudyFixes" ' .
    'caption="Apply Selected Fixes"' . 
    ' sync="Update();"?>'
  );
  for my $subj (sort keys %{$this->{StudyInconsistencies}}){
    $http->queue("<hr>Subject: $subj<br>");
    for my $i (0 .. $#{$this->{StudyInconsistencies}->{$subj}}){
      my $err = $this->{StudyInconsistencies}->{$subj}->[$i];
      $this->DisplayProposedStudyFix(
        $http, $dyn, $subj, $i, $err->{ProposedFix});
    }
  }
}
sub CancelStudyFixes{
  my($this, $http, $dyn) = @_;
  delete $this->{StudyInconsistencies};
  $this->{CollectionMode} = "CollectionsSelection";
}
sub ProposeStudyFixes{
  my($this, $subjs) = @_;
  my $sub = sub{
    my($disp) = @_;
    if($#{$subjs} < 0){
      $this->{CollectionMode} = "StudyInconsistenciesFound";
      $this->AutoRefresh;
      return;
    }
    my $next = shift @$subjs;
    $disp->queue;
    my $err_subj = $this->{StudyInconsistencies}->{$next};
    for my $err_info (@$err_subj){
      my $dir_info = $this->GetExtractionEditDirsAndFiles($next);
      my $dicom_info = Storable::retrieve($dir_info->{dicom_info_file});
      my $hierarchy = Storable::retrieve($dir_info->{hierarchy_file});
      my %files_in_study;
      my $studies = $hierarchy->{$next}->{studies};
      for my $i (keys %{$studies}){
        if($studies->{$i}->{uid} eq $err_info->{study_uid}){
          for my $j (keys %{$studies->{$i}->{series}}){
            for my $f (
              keys %{$studies->{$i}->{series}->{$j}->{files}}
            ){
              my $digest = $dicom_info->{FilesToDigest}->{$f};
              $files_in_study{$f} = $dicom_info->{FilesByDigest}->{$digest};
            }
          }
        }
      }
      if(
        $err_info->{type} eq "study_consistency" &&
        $err_info->{sub_type} eq "multiple element values"
      ){
        my $ele = $err_info->{ele};
        my $ele_info = $this->{DD}->get_ele_by_sig($ele);
        my $ele_desc = $ele_info->{Name};
        my @fix_list;
        for my $v (@{$err_info->{values}}){
          my $fix = {};
          for my $f(keys %files_in_study){
            unless($files_in_study{$f}->{$ele} eq $v){
              $fix->{files}->{$f} = 1;
            }
            $fix->{ele} = $ele;
            $fix->{ele_desc} = $ele_desc;
            if($v eq "<undef>"){
              $fix->{op} = "delete";
            } else {
              $fix->{op} = "set";
              $fix->{value} = $v;
            }
          }
          $fix->{num_files} = keys %{$fix->{files}};
          push @fix_list, $fix;
        }
        $err_info->{ProposedFix} = [
          sort {$a->{num_files} <=> $b->{num_files}} @fix_list
        ];
        $err_info->{ProposedFix}->[0]->{selected} = 1;
      }
    }
  };
  return $sub;
}
sub DisplayProposedStudyFix{
  my($this, $http, $dyn, $subj, $i, $fix) = @_;
  $http->queue("<small><table border><tr>" .
    "<th>Element</th><th>Name</th><th>Number Files</th><th>Operation</th>" .
    "<th>Value</th><th>Sel</th></tr>");
  for my $j (0 .. $#{$fix}){
    my $f = $fix->[$j];
    my $value = "";
    if(exists $f->{value}) { $value = $f->{value} }
    $http->queue("<tr><td>$f->{ele}</td><td>$f->{ele_desc}</td>" .
      "<td>$f->{num_files}</td><td>$f->{op}</td><td>$value</td><td>");
    $http->queue($this->RadioButtonDelegate(
       $subj . "_$i", $j, exists($f->{selected}), {
          op => "SelectStudyFix",
          subj => $subj,
          fix => $i,
          index => $j,
          sync => "Update();",
        }
      )
    );
    $http->queue("</td></tr>");
  }
  $http->queue("</table></small>");
}
sub SelectStudyFix{
  my($this, $http, $dyn) = @_;
  my $subj = $dyn->{subj};
  my $fix = $dyn->{fix};
  my $index = $dyn->{index};
  for my $i (
    0 .. $#{$this->{StudyInconsistencies}->{$subj}->[$fix]->{ProposedFix}}
  ){
    delete $this->{StudyInconsistencies}->{$subj}->[$fix]->{ProposedFix}
      ->[$i]->{selected};
  }
  $this->{StudyInconsistencies}->{$subj}->[$fix]->{ProposedFix}->[$index]
    ->{selected} = 1;
}
sub ApplyStudyFixes{
  my($this, $http, $dyn) = @_;
  for my $subj (keys %{$this->{StudyInconsistencies}}){
    my $sub_array = $this->{StudyInconsistencies}->{$subj};
    for my $fix (@$sub_array){
      p_fix:
      for my $p_fix (@{$fix->{ProposedFix}}){
        unless($p_fix->{selected}) { next p_fix }
        for my $f (keys %{$p_fix->{files}}){
          if($p_fix->{op} eq "delete"){
            $this->{FixesToApply}->{$subj}->{FileEdits}->
              {$f}->{full_ele_deletes}->{$p_fix->{ele}} = 1;
          } elsif ($p_fix->{op} eq "set"){
            $this->{FixesToApply}->{$subj}->{FileEdits}->
              {$f}->{full_ele_additions}->{$p_fix->{ele}} = $p_fix->{value};
          }
        }
      }
    }
  }
  for my $k (keys %{$this->{FixesToApply}}){
    $this->{FixesToApplySave}->{$k} = $this->{FixesToApply}->{$k};
  }
  delete $this->{StudyInconsistencies};
  $this->{CollectionMode} = "ApplyFixes";
  my @fixes_to_apply = sort keys %{$this->{FixesToApply}};
  $this->{FixesApplied} = {};
  $this->{FixesFailed} = {};
  Dispatch::Select::Background->new(
   $this->ApplyNextFix(\@fixes_to_apply)
  )->queue;
}
################################
# ApplyFixes
#
sub ApplyFixes{
  my($this, $http, $dyn) = @_;
  $http->queue("ApplyingFixes<ul>");
  my $to_apply = keys %{$this->{FixesToApply}};
  my $applied = keys %{$this->{FixesApplied}};
  my $failed = keys %{$this->{FixesFailed}};
  $http->queue("<li>Remaining: $to_apply</li>");
  $http->queue("<li>Applied: $applied</li>");
  $http->queue("<li>Failed: $failed</li>");
  $http->queue("</ul>");
}
sub ApplyNextFix{
  my($this, $fixes_to_apply) = @_;
  my $sub = sub{
    my($disp) = @_;
    $this->AutoRefresh;
    if($#{$fixes_to_apply} < 0){
      $this->{CollectionMode} = "CollectionsSelection";
      delete $this->{FixesFailed};
      delete $this->{FixesApplied};
      delete $this->{FixesToApply};
      return;
    }
    my $next = shift @{$fixes_to_apply};
    my $next_fix = $this->{FixesToApply}->{$next}->{FileEdits};
    my $dir_info = $this->GetExtractionEditDirsAndFiles($next);
    my $dicom_info = Storable::retrieve($dir_info->{dicom_info_file});
    my $Fix = {
      FileEdits => $next_fix,
      cache_dir => "$this->{DicomInfoCache}/dicom_info",
      source => "$dir_info->{file_dir}",
      operation => "EditAndAnalyze",
      parallelism => 3,
    };
    for my $file (keys %{$dicom_info->{FilesToDigest}}){
      if(exists $next_fix->{$file}){
        if($file =~ /^(.*)\/([^\/]+)$/){
          my $path = $1; my $f = $2;
          $next_fix->{$file}->{file_only} = $f;
        } else {
          print STDERR "File to edit ($file) can't be split into path, file\n";
          $this->{FixesFailed}->{$next} = 1;
          $disp->queue;
          return;
        }
      } else {
        if($file =~ /^(.*)\/([^\/]+)$/){
          my $path = $1; my $f = $2;
          unless($path eq $Fix->{source}){
            print STDERR "File to link ($f) isn't in source dir\n" .
              "\t$Fix->{source}\n" .
              "\t$path\n";
            $this->{FixesFailed}->{$next} = 1;
            $disp->queue;
            return;
          }
          $Fix->{files_to_link}->{$f} = $dicom_info->{FilesToDigest}->{$file};
        } else {
          print STDERR "File to link ($file) can't be split into path, file\n";
          $this->{FixesFailed}->{$next} = 1;
          $disp->queue;
          return;
        }
      }
    }
    $this->NewRequestLockForEdit($next,
      $this->WhenApplyLockGranted($Fix, $disp, $next));
  };
  return $sub;
}
sub WhenApplyLockGranted{
  my($this, $fix, $disp, $subj) = @_;
  my $sub = sub {
    my($lines) = @_;
    my %args;
    for my $line (@$lines){
      if($line =~ /^(.*):\s*(.*)$/){
        my $k = $1; my $v = $2;
        $args{$k} = $v;
      }
    }
    if(exists($args{Locked}) && $args{Locked} eq "OK"){
      $fix->{info_dir} = $args{"Revision Dir"};
      $fix->{destination} = $args{"Destination File Directory"};
      for my $f (keys %{$fix->{FileEdits}}){
        $fix->{FileEdits}->{$f}->{from_file} = $f;
        $fix->{FileEdits}->{$f}->{to_file} = 
          "$fix->{destination}/$fix->{FileEdits}->{$f}->{file_only}";
        delete $fix->{FileEdits}->{$f}->{file_only};
      }
      my $commands = $args{"Revision Dir"} . "/creation.pinfo";
      store($fix, $commands);
      my $session = $this->{session};
      my $pid = $$;
      my $user = $this->get_user;
      my $new_args = [ "ApplyEdits", "Id: $args{Id}",
        "Session: $session", "User: $user", "Pid: $pid" ,
        "Commands: $commands" ];
      $this->{FixApplied}->{$subj} = 1;
      $this->SimpleTransaction($this->{ExtractionManagerPort},
        $new_args,
        $this->WhenApplyEditQueued($subj, $disp));
    } else {
      print STDERR "Extraction Lock Failed - probably double click\n";
    }
  };
  return $sub;
}
sub WhenApplyEditQueued{
  my($this, $subj, $disp) = @_;
  my $sub = sub {
    my($lines) = @_;
    $this->{FixesApplied}->{$subj} = 1;
    print STDERR "################\nApplyEditQueued\n";
    for my $l (@$lines){
      print STDERR "$l\n";
    }
    print STDERR "################\nApplyEditQueued\n";
    $disp->queue;
  };
  return $sub;
}

################################
# Fix Series Inconsistencies
sub FixSeriesInconsistencies{
  my($this, $http, $dyn) = @_;
  $this->{CollectionMode} = "ScanningSeriesInconsistencies";
  my $dir = $this->{ExtractionRoot} . "/$this->{SelectedCollection}" .
    "/$this->{SelectedSite}";
  my $cmd = "FindSeriesConsistencyErrors.pl \"$dir\"";
  my $pid = open my $fh, "$cmd|" or die "Can't open $cmd|";
  Dispatch::Select::Socket->new(
    $this->ReadSerializedResponse($this->SaveSeriesInconsistencies, $pid),
    $fh
  )->Add("reader");
}
sub SaveSeriesInconsistencies{
  my($this) = @_;
  my $sub = sub {
    my($stat, $results) = @_;
    if($stat eq "Succeeded"){
      $this->{SeriesInconsistencies} = $results;
      $this->{CollectionMode} = "ProposingSeriesInconsistencyFixes";
      my @subjs = keys %$results;
      Dispatch::Select::Background->new(
        $this->ProposeSeriesFixes(\@subjs))->queue;
    } else {
      my $error = "Status to Series Inconsistency Scan: $stat";
      $this->SetCollectionError($error);
    }
    $this->AutoRefresh;
  };
  return $sub;
}
sub ScanningSeriesInconsistencies{
  my($this, $http, $dyn) = @_;
  $http->queue("Scanning for Series Inconsistencies");
}
sub ProposingSeriesInconsistencyFixes{
  my($this, $http, $dyn) = @_;
  $http->queue("Proposing Series Inconsistency Fixes");
}
sub SeriesInconsistenciesFound{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
    "Series Inconsistencies Found:" .
    '<?dyn="NotSoSimpleButton" op="CancelSeriesFixes" caption="Cancel"' . 
    ' sync="Update();"?>' .
    '<?dyn="NotSoSimpleButton" op="ApplySeriesFixes" ' .
    'caption="Apply Selected Fixes"' . 
    ' sync="Update();"?>'
  );
  for my $subj (sort keys %{$this->{SeriesInconsistencies}}){
    $http->queue("<hr>Subject: $subj<br>");
    for my $i (0 .. $#{$this->{SeriesInconsistencies}->{$subj}}){
      my $err = $this->{SeriesInconsistencies}->{$subj}->[$i];
      $this->DisplayProposedSeriesFix(
        $http, $dyn, $subj, $i, $err->{ProposedFix});
    }
  }
}
sub CancelSeriesFixes{
  my($this, $http, $dyn) = @_;
  delete $this->{SeriesInconsistencies};
  $this->{CollectionMode} = "CollectionsSelection";
}
sub ProposeSeriesFixes{
  my($this, $subjs) = @_;
  my $sub = sub{
    my($disp) = @_;
    if($#{$subjs} < 0){
      $this->{CollectionMode} = "SeriesInconsistenciesFound";
      $this->AutoRefresh;
      return;
    }
    my $next = shift @$subjs;
    $disp->queue;
    my $err_subj = $this->{SeriesInconsistencies}->{$next};
    for my $err_info (@$err_subj){
      my $dir_info = $this->GetExtractionEditDirsAndFiles($next);
      my $dicom_info = Storable::retrieve($dir_info->{dicom_info_file});
      my $hierarchy = Storable::retrieve($dir_info->{hierarchy_file});
      my %files_in_series;
      my $studies = $hierarchy->{$next}->{studies};
      for my $i (keys %{$studies}){
        series:
        for my $j (keys %{$studies->{$i}->{series}}){
          my $series_uid = $studies->{$i}->{series}->{$j}->{uid};
          unless($series_uid eq $err_info->{series_uid}) {next series}
          for my $f (
            keys %{$studies->{$i}->{series}->{$j}->{files}}
          ){
            my $digest = $dicom_info->{FilesToDigest}->{$f};
            $files_in_series{$f} = $dicom_info->{FilesByDigest}->{$digest};
          }
        }
      }
      if(
        $err_info->{type} eq "series_consistency" &&
        $err_info->{sub_type} eq "multiple element values"
      ){
        my $ele = $err_info->{ele};
        my $ele_info = $this->{DD}->get_ele_by_sig($ele);
        my $ele_desc = $ele_info->{Name};
        my @fix_list;
        for my $v (@{$err_info->{values}}){
          my $fix = {};
          for my $f(keys %files_in_series){
            my $ev = $files_in_series{$f}->{$ele};
            unless($files_in_series{$f}->{$ele} eq $v){
              $fix->{files}->{$f} = 1;
            }
            $fix->{ele} = $ele;
            $fix->{ele_desc} = $ele_desc;
            if($v eq "<undef>"){
              $fix->{op} = "delete";
            } else {
              $fix->{op} = "set";
              $fix->{value} = $v;
            }
          }
          $fix->{num_files} = keys %{$fix->{files}};
          push @fix_list, $fix;
        }
        $err_info->{ProposedFix} = [
          sort {$a->{num_files} <=> $b->{num_files}} @fix_list
        ];
        $err_info->{ProposedFix}->[0]->{selected} = 1;
      }
    }
  };
  return $sub;
}
sub DisplayProposedSeriesFix{
  my($this, $http, $dyn, $subj, $i, $fix) = @_;
  $http->queue("<small><table border><tr>" .
    "<th>Element</th><th>Name</th><th>Number Files</th><th>Operation</th>" .
    "<th>Value</th><th>Sel</th></tr>");
  for my $j (0 .. $#{$fix}){
    my $f = $fix->[$j];
    my $value = "";
    if(exists $f->{value}) { $value = $f->{value} }
    $http->queue("<tr><td>$f->{ele}</td><td>$f->{ele_desc}</td>" .
      "<td>$f->{num_files}</td><td>$f->{op}</td><td>$value</td><td>");
    $http->queue($this->RadioButtonDelegate(
       $subj . "_$i", $j, exists($f->{selected}), {
          op => "SelectSeriesFix",
          subj => $subj,
          fix => $i,
          index => $j,
          sync => "Update();",
        }
      )
    );
    $http->queue("</td></tr>");
  }
  $http->queue("</table></small>");
}
sub SelectSeriesFix{
  my($this, $http, $dyn) = @_;
  my $subj = $dyn->{subj};
  my $fix = $dyn->{fix};
  my $index = $dyn->{index};
  for my $i (
    0 .. $#{$this->{SeriesInconsistencies}->{$subj}->[$fix]->{ProposedFix}}
  ){
    delete $this->{SeriesInconsistencies}->{$subj}->[$fix]->{ProposedFix}
      ->[$i]->{selected};
  }
  $this->{SeriesInconsistencies}->{$subj}->[$fix]->{ProposedFix}->[$index]
    ->{selected} = 1;
}
sub ApplySeriesFixes{
  my($this, $http, $dyn) = @_;
  for my $subj (keys %{$this->{SeriesInconsistencies}}){
    my $sub_array = $this->{SeriesInconsistencies}->{$subj};
    for my $fix (@$sub_array){
      p_fix:
      for my $p_fix (@{$fix->{ProposedFix}}){
        unless($p_fix->{selected}) { next p_fix }
        for my $f (keys %{$p_fix->{files}}){
          if($p_fix->{op} eq "delete"){
            $this->{FixesToApply}->{$subj}->{FileEdits}->
              {$f}->{full_ele_deletes}->{$p_fix->{ele}} = 1;
          } elsif ($p_fix->{op} eq "set"){
            $this->{FixesToApply}->{$subj}->{FileEdits}->
              {$f}->{full_ele_additions}->{$p_fix->{ele}} = $p_fix->{value};
          }
        }
      }
    }
  }
  delete $this->{SeriesInconsistencies};
  $this->{CollectionMode} = "ApplyFixes";
  my @fixes_to_apply = sort keys %{$this->{FixesToApply}};
  $this->{FixesApplied} = {};
  $this->{FixesFailed} = {};
  Dispatch::Select::Background->new(
   $this->ApplyNextFix(\@fixes_to_apply)
  )->queue;
}
################################
# Fix Patient Inconsistencies
sub FixPatientInconsistencies{
  my($this, $http, $dyn) = @_;
  $this->{CollectionMode} = "ScanningPatientInconsistencies";
  my $dir = $this->{ExtractionRoot} . "/$this->{SelectedCollection}" .
    "/$this->{SelectedSite}";
  my $cmd = "FindPatientConsistencyErrors.pl \"$dir\"";
  my $pid = open my $fh, "$cmd|" or die "Can't open $cmd|";
  Dispatch::Select::Socket->new(
    $this->ReadSerializedResponse($this->SavePatientInconsistencies, $pid),
    $fh
  )->Add("reader");
}
sub SavePatientInconsistencies{
  my($this) = @_;
  my $sub = sub {
    my($stat, $results) = @_;
    if($stat eq "Succeeded"){
      $this->{PatientInconsistencies} = $results;
      $this->{CollectionMode} = "ProposingPatientInconsistencyFixes";
      my @subjs = keys %$results;
      Dispatch::Select::Background->new(
        $this->ProposePatientFixes(\@subjs))->queue;
    } else {
      my $error = "Status to Patient Inconsistency Scan: $stat";
      $this->SetCollectionError($error);
    }
    $this->AutoRefresh;
  };
  return $sub;
}
sub ScanningPatientInconsistencies{
  my($this, $http, $dyn) = @_;
  $http->queue("Scanning for Patient Inconsistencies");
}
sub ProposingPatientInconsistencyFixes{
  my($this, $http, $dyn) = @_;
  $http->queue("Proposing Patient Inconsistency Fixes");
}
sub PatientInconsistenciesFound{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
    "Patient Inconsistencies Found:" .
    '<?dyn="NotSoSimpleButton" op="CancelPatientFixes" caption="Cancel"' . 
    ' sync="Update();"?>' .
    '<?dyn="NotSoSimpleButton" op="ApplyPatientFixes" ' .
    'caption="Apply Selected Fixes"' . 
    ' sync="Update();"?>'
  );
  for my $subj (sort keys %{$this->{PatientInconsistencies}}){
    $http->queue("<hr>Subject: $subj<br>");
    for my $i (0 .. $#{$this->{PatientInconsistencies}->{$subj}}){
      my $err = $this->{PatientInconsistencies}->{$subj}->[$i];
      $this->DisplayProposedPatientFix(
        $http, $dyn, $subj, $i, $err->{ProposedFix});
    }
  }
}
sub CancelPatientFixes{
  my($this, $http, $dyn) = @_;
  delete $this->{PatientInconsistencies};
  $this->{CollectionMode} = "CollectionsSelection";
}
sub ProposePatientFixes{
  my($this, $subjs) = @_;
  my $sub = sub{
    my($disp) = @_;
    if($#{$subjs} < 0){
      $this->{CollectionMode} = "PatientInconsistenciesFound";
      $this->AutoRefresh;
      return;
    }
    my $next = shift @$subjs;
    $disp->queue;
    my $err_subj = $this->{PatientInconsistencies}->{$next};
    for my $err_info (@$err_subj){
      my $dir_info = $this->GetExtractionEditDirsAndFiles($next);
      my $dicom_info = Storable::retrieve($dir_info->{dicom_info_file});
      my $hierarchy = Storable::retrieve($dir_info->{hierarchy_file});
      my %files_in_patient;
      my $studies = $hierarchy->{$next}->{studies};
      for my $i (keys %{$studies}){
        for my $j (keys %{$studies->{$i}->{series}}){
          for my $f (
            keys %{$studies->{$i}->{series}->{$j}->{files}}
          ){
            my $digest = $dicom_info->{FilesToDigest}->{$f};
            $files_in_patient{$f} = $dicom_info->{FilesByDigest}->{$digest};
          }
        }
      }
      if(
        $err_info->{type} eq "patient_consistency" &&
        $err_info->{sub_type} eq "multiple element values"
      ){
        my $ele = $err_info->{ele};
        my $ele_info = $this->{DD}->get_ele_by_sig($ele);
        my $ele_desc = $ele_info->{Name};
        my @fix_list;
        for my $v (@{$err_info->{values}}){
          my $fix = {};
          for my $f(keys %files_in_patient){
            my $ev = $files_in_patient{$f}->{$ele};
            unless($files_in_patient{$f}->{$ele} eq $v){
              $fix->{files}->{$f} = 1;
            }
            $fix->{ele} = $ele;
            $fix->{ele_desc} = $ele_desc;
            if($v eq "<undef>"){
              $fix->{op} = "delete";
            } else {
              $fix->{op} = "set";
              $fix->{value} = $v;
            }
          }
          $fix->{num_files} = keys %{$fix->{files}};
          push @fix_list, $fix;
        }
        $err_info->{ProposedFix} = [
          sort {$a->{num_files} <=> $b->{num_files}} @fix_list
        ];
        $err_info->{ProposedFix}->[0]->{selected} = 1;
      }
    }
  };
  return $sub;
}
sub DisplayProposedPatientFix{
  my($this, $http, $dyn, $subj, $i, $fix) = @_;
  $http->queue("<small><table border><tr>" .
    "<th>Element</th><th>Name</th><th>Number Files</th><th>Operation</th>" .
    "<th>Value</th><th>Sel</th></tr>");
  for my $j (0 .. $#{$fix}){
    my $f = $fix->[$j];
    my $value = "";
    if(exists $f->{value}) { $value = $f->{value} }
    $http->queue("<tr><td>$f->{ele}</td><td>$f->{ele_desc}</td>" .
      "<td>$f->{num_files}</td><td>$f->{op}</td><td>$value</td><td>");
    $http->queue($this->RadioButtonDelegate(
       $subj . "_$i", $j, exists($f->{selected}), {
          op => "SelectPatientFix",
          subj => $subj,
          fix => $i,
          index => $j,
          sync => "Update();",
        }
      )
    );
    $http->queue("</td></tr>");
  }
  $http->queue("</table></small>");
}
sub SelectPatientFix{
  my($this, $http, $dyn) = @_;
  my $subj = $dyn->{subj};
  my $fix = $dyn->{fix};
  my $index = $dyn->{index};
  for my $i (
    0 .. $#{$this->{PatientInconsistencies}->{$subj}->[$fix]->{ProposedFix}}
  ){
    delete $this->{PatientInconsistencies}->{$subj}->[$fix]->{ProposedFix}
      ->[$i]->{selected};
  }
  $this->{PatientInconsistencies}->{$subj}->[$fix]->{ProposedFix}->[$index]
    ->{selected} = 1;
}
sub ApplyPatientFixes{
  my($this, $http, $dyn) = @_;
  for my $subj (keys %{$this->{PatientInconsistencies}}){
    my $sub_array = $this->{PatientInconsistencies}->{$subj};
    for my $fix (@$sub_array){
      p_fix:
      for my $p_fix (@{$fix->{ProposedFix}}){
        unless($p_fix->{selected}) { next p_fix }
        for my $f (keys %{$p_fix->{files}}){
          if($p_fix->{op} eq "delete"){
            $this->{FixesToApply}->{$subj}->{FileEdits}->
              {$f}->{full_ele_deletes}->{$p_fix->{ele}} = 1;
          } elsif ($p_fix->{op} eq "set"){
            $this->{FixesToApply}->{$subj}->{FileEdits}->
              {$f}->{full_ele_additions}->{$p_fix->{ele}} = $p_fix->{value};
          }
        }
      }
    }
  }
  delete $this->{PatientInconsistencies};
  $this->{CollectionMode} = "ApplyFixes";
  my @fixes_to_apply = sort keys %{$this->{FixesToApply}};
  $this->{FixesApplied} = {};
  $this->{FixesFailed} = {};
  Dispatch::Select::Background->new(
   $this->ApplyNextFix(\@fixes_to_apply)
  )->queue;
}
1;
