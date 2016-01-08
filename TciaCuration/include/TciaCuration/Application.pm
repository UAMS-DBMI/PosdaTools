#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/TciaCuration/include/TciaCuration/Application.pm,v $
#$Date: 2015/06/21 19:33:52 $
#$Revision: 1.50 $
#
use strict;
package TciaCuration::Application;
use Posda::HttpApp::JsController;
use TciaCuration::GeneralPurposeEditor;
use TciaCuration::InfoExpander;
use TciaCuration::CheckDbFiles;
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
@ISA = ( "Posda::HttpApp::JsController", "Posda::HttpApp::Authenticator", 
  "TciaCuration::InfoExpander" );
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
#$this->{AppSingleton} = $main::HTTP_APP_SINGLETON;
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
  $this->{mode} = "Collections";
  $this->{expander} = $expander;
  $this->{title} = "TCIA Curation Tools";
  bless $this, $class;
  $this->{BaseExternalNotificationUrl} =
    $main::HTTP_APP_SINGLETON->{base_url} . "/$sess/ExternalNotification?" .
    "obj_path=$path";
  if(exists $main::HTTP_APP_CONFIG->{BadJson}){
    $this->{BadConfigFiles} = $main::HTTP_APP_CONFIG->{BadJson};
  }
  $this->{Identity} = $main::HTTP_APP_CONFIG->{config}->{Identity};
  $this->{Environment} = $main::HTTP_APP_CONFIG->{config}->{Environment};
  $this->{LoginTempDir} = "$this->{Environment}->{LoginTemp}/$this->{session}";
  unless(mkdir $this->{LoginTempDir}) {
    die "can't mkdir $this->{LoginTempDir}"
  }
  my $width = $this->{Identity}->{width};
  my $height = $this->{Identity}->{height};
  $this->{QuarantineRoot} = 
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{QuarantineRoot};
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
#  Dispatch::NamedFileInfoManager->new($sess, "FileManager",
#    ( -x "/usr/bin/speedy" ) ?
#      "SpeedyDicomInfoAnalyzer.pl" : "DicomInfoAnalyzer.pl",
#    $main::HTTP_APP_CONFIG->{config}->{Environment}->{DicomInfoCache},
#    10);
  $this->{DicomInfoCache} = 
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{DicomInfoCache};
  $this->{ExtractionRoot} = 
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{ExtractionRoot};
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
#Mode: <?dyn="SelectByValue" op="ChangeMode"?><?dyn="ModeMenu"?></select>
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
#<div id="content" style="overflow:auto;background-color:#F8F8F8;height:<?dyn="height"?>px;width:<?dyn="content_width"?>px;float:left;">
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
sub MenuResponse{
  my($this, $http, $dyn) = @_;
  if($this->{mode} eq "Quarantines"){
    $this->QuarantinesMenu($http, $dyn);
  } elsif($this->{mode} eq "Collections"){
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
  } elsif($this->{mode} eq "Quarantines"){
    return $this->Quarantines($http, $dyn);
  }
  $http->queue("No handler yet for \"$this->{mode}\"");
}
sub ModeMenu{
  my($this, $http, $dyn) = @_;
  unless(defined $this->{mode}) { $this->{mode} = "--- select mode ---" }
  for my $i (
    "--- select mode ----", "Collections", "Quarantines"
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
sub QuarantinesMenu{
  my($this, $http, $dyn) = @_;
  $http->queue("<small>none</small>");
}
sub SetCollectionMode{
  my($this, $http, $dyn) = @_;
  print STDERR "############\n";
  print STDERR "#SetCollectionMode\n";
  print STDERR "############\n";
  $this->{CollectionMode} = $dyn->{mode};
  $this->AutoRefresh;
}
#################################
# New Collections Display being written here
#   Stand Back
#   
sub CollectionsMenu{
  my($this, $http, $dyn) = @_;
  $this->MakeMenu($http, $dyn,
    [
      { type => "host_link_sync",
        condition => 1,
        style => "small",
        caption => "refresh DB",
        method => "RefreshDbData",
        sync => "Update();",
      },
      { type => "host_link_sync",
        condition => 1,
        style => "small",
        caption => "refresh dir",
        method => "RefreshDirData",
        sync => "Update();",
      },
    ]);
}
sub Collections{
  my($this, $http, $dyn) = @_;
  if(
    exists($this->{DbQueryInProgress}) ||
    exists $this->{ExtractionSearchInProgress} ||
    exists $this->{QuarantineSearchInProgress}
  ){
    return $this->RefreshEngine($http, $dyn, 
      '<?dyn="StatusOfDbQuery"?><hr>' .
      '<?dyn="StatusOfExtractionSearch"?><hr>' .
      '<?dyn="StatusOfQuarantineSearch"?>');
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
    return $this->DbCollectionsAndExtractions($http, $dyn);
  } elsif($this->{CollectionMode} eq "PendingDiscard"){
    return $this->PendingDiscard($http, $dyn);
  } elsif($this->{CollectionMode} eq "InfoDisplay"){
    return $this->NewDisplayInfo($http, $dyn);
  } elsif($this->{CollectionMode} eq "MergeOpenDirectories"){
    return $this->MergeContent($http, $dyn);
  } elsif($this->{CollectionMode} eq "GeneralPurposeEditor"){
    return $this->GeneralPurposeEditorContent($http, $dyn);
  } else {
    die "Unknown CollectionMode: $this->{CollectionMode}";
  }
}
sub CollectionSelection{
  # present form for selection of Collection and Site
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, 
    '<br>Collection: <?dyn="EntryBox" default="'. $this->{SelectingCollection} .
    '" op="EnterCollection" name="collection"?>&nbsp;&nbsp;' .
    'Site: <?dyn="EntryBox" default="' . $this->{SelectingSite} .
    '" op="EnterSite" name="site"?>' .
    '<?dyn="SimpleButton" op="SetCollectionAndSite" parm="foo"' .
    ' sync="Update();"' .
    ' caption="Query Database"?><?dyn="QueryHistory"?>');
}
sub EnterCollection{
  # update collection as being entered
  my($this, $http, $dyn) = @_;
  $this->{SelectingCollection} = $dyn->{value};
}
sub EnterSite{
  # update site as being entered
  my($this, $http, $dyn) = @_;
  $this->{SelectingSite} = $dyn->{value};
}
sub SetCollectionAndSite{
  # set selected collection and site
  my($this, $http, $dyn) = @_;
  $this->{SelectedCollection} = $this->{SelectingCollection};
  $this->{SelectedSite} = $this->{SelectingSite};
  my $query_id = "$this->{SelectedCollection}//$this->{SelectedSite}";
  my $query_time = time;
  $this->{UserHistory}->{Queries}->{$query_id} = $query_time;
  $this->SaveUserHistory;
  delete $this->{DbResults};
  delete $this->{ExtractionsHierarchies};
  delete $this->{QuarantineHierarchies};
  $this->{DbQueryInProgress} = 1;
  $this->{ExtractionSearchInProgress} = 1;
  $this->{QuarantineSearchInProgress} = 1;
  $this->StartDbQuery;
  $this->StartExtractionSearch;
  $this->StartQuarantineSearch;
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
sub RefreshDirData{
  my($this, $http, $dyn) = @_;
  $this->{ExtractionSearchInProgress} = 1;
  $this->StartExtractionSearch;
}
sub StatusOfDbQuery{
  # present status of Db Query
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
          for my $f (keys %{$p->{files}}){
            $num_files += 1;
          }
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
sub StatusOfExtractionSearch{
  # present status of Extraction Search 
  my($this, $http, $dyn) = @_;
  if(exists $this->{ExtractionSearchInProgress}){
    $http->queue("Directory Search In Progress");
  } else {
    $http->queue("Directory Search Finished");
  }
}
sub StartDbQuery{
  # Start query
  my($this) = @_;
  delete $this->{DbResults};
  $this->{QueryReader} = Dispatch::LineReader->new_cmd(
    "ExtractAllCollection.pl \"" .
    "$this->{SelectedCollection}\" " .
    "\"$this->{SelectedSite}\" " .
    "\"$this->{database_host}\"",
    $this->NewHandleQueryLine($this->{SelectedCollection}, $this->{SelectedSite}),
    $this->NewEndOfQuery);
}
sub NewHandleQueryLine{
  # process lines from ExtractAllCollections.pl
  my($this, $collection, $site) = @_;
  my $sub = sub {
    my($line) = @_;
    my($modality, $series_pk, $series_uid, $series_desc, $visibility,
      $study_pk, $study_uid, $study_desc, $body_part, $file, $md5, $ts,
      $sz, $image_pk_id, $pid, $sop_inst) = 
    split(/\|/, $line);
    $this->{DbResults}->{$pid}->{studies}->{$study_pk}->{uid} = $study_uid;
    $this->{DbResults}->{$pid}->{studies}->{$study_pk}->{pid} = $pid;
    my $studies = $this->{DbResults}->{$pid}->{studies};
    $studies->{$study_pk}->{desc} = $study_desc;
    $studies->{$study_pk}->{series}->{$series_pk}->{uid} = $series_uid;
    my $series = $studies->{$study_pk}->{series}->{$series_pk};
    $series->{body_part} = $body_part;
    $series->{modality} = $modality;
    $series->{desc} = $series_desc;
    $series->{files}->{$image_pk_id} = {
      file => $file,
      visibility => $visibility,
      md5 => $md5,
      curation_timestamp => $ts,
      file_size => $sz,
      sop_instance_uid => $sop_inst,
    };
  };
  return $sub;
}
sub NewEndOfQuery{
  # invoked when query complete
  my($this) = @_;
  my $sub = sub {
    delete $this->{QueryReader};
    delete $this->{DbQueryInProgress};
    $this->AutoRefresh;
  };
  return $sub;
}
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
    $this->{ExtractionsHierarchies}->{$subj}->{rev_hist} = $rev_hist;
    $this->{ExtractionsHierarchies}->{$subj}->{hierarchy} = $hierarchy;
    $this->{ExtractionsHierarchies}->{$subj}->{errors} = $errors;
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
sub DbCollectionsAndExtractions{
  my($this, $http, $dyn) = @_;
  $this->GetExtractionLocks($this->ContinueDbCollectionsAndExtractions(
    $http, $dyn));
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
    $this->RefreshEngine($http, $dyn,
      '<?dyn="SimpleButton" op="NewNewQuery" caption="New Query" ' . 
      'sync="Update();"?>' .
      "<hr><h3>Collection: $this->{SelectedCollection}</h3>" .
      "<h3> Site: $this->{SelectedSite}</h3>" .
      '<small><table border="1" width="100%">' .
      '<tr><th width="10%">Subject</th><th width="45%">DB Info</th>' .
      '<th width="45%">Extraction Info</th></tr>' .
      '<?dyn="ExpandNewRows"?></table></small>'
    );
  };
  return $sub;
};
sub ExpandNewRows{
  my($this, $http, $dyn) = @_;
  my $col = $this->{SelectedCollection};
  my $site = $this->{SelectedSite};
  for my $subj (sort {$a cmp $b} keys %{$this->{CollectionRows}}){
    $http->queue("<tr><td valign=\"top\">$subj<br>");
    $dyn->{subj} = $subj;
    if($this->{InfoSel}->{$col}->{$site}->{$subj}){
      $this->NotSoSimpleButton($http, { 
         op => "CloseSubjInfo",
         subject => $subj,
         caption => "close",
         sync => "Update();"
      });
    } else {
      $this->NotSoSimpleButton($http, { 
         op => "OpenSubjInfo",
         subject => $subj,
         caption => "open",
         sync => "Update();"
      });
    }
    $http->queue('</td><td valign="top" align="left">');
    $http->queue('<table width="100%"><tr>');
    $http->queue('<td valign="top" align="left">');
    $this->NewExpandDbInfo($http, $dyn);
    $http->queue('</td><td valign="top" align="right"><small>');
    $this->DelegateButton($http, {
      caption => "check",
      op => "CheckDbSubj",
      subj => $dyn->{subj},
      sync => "Update();",
    });
    $http->queue('</small></td>');
    $http->queue('</tr></table></td><td valign="top">');
    $this->NewNewExpandExtraction($http, $dyn);
    $http->queue("</td></tr></td></tr>");
  }
}
sub CheckDbSubj{
  my($this, $http, $dyn) = @_;
  my $subj = $dyn->{subj};
  my $child_path = $this->child_path("Check_$subj");
  my $child_obj = $this->get_obj($child_path);
  unless(defined $child_obj){
    unless(exists $this->{NickNames}) {
      $this->{NickNames} = Posda::Nicknames->new;
    }
    $child_obj = TciaCuration::CheckDbFiles->new($this->{session},
      $child_path, $this->{SelectedCollection},
      $this->{SelectedSite}, $subj,
      $this->{DbResults}->{$subj}->{studies});
    if($child_obj){
       $this->InvokeAbove("StartChildDisplayer", $child_obj);
    } else {
        print STDERR 'TciaCuration::FileView->new failed!!!' . "\n";
    }
  }
}
sub NewNewQuery{
  my($this) = @_;
  delete $this->{SelectedCollection};
  delete $this->{SelectedSite};
}
sub NewExpandDbInfo{
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
    $this->NewExpandSelectedDbInfo($http, $dyn);
  } else {
    $this->NewExpandUnSelectedDbInfo($http, $dyn);
  }
}
sub NewExpandSelectedDbInfo{
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
sub NewExpandUnSelectedDbInfo{
  my($this, $http, $dyn) = @_;
  my $col = $this->{SelectedCollection};
  my $site = $this->{SelectedSite};
  my $subj = $dyn->{subj};
  $this->ExpandStudyCounts($http, $dyn, $this->{DbResults}->{$subj}->{studies});
#  my($num_studies, $num_series, $num_images) = 
#    $this->NewCountStudiesSeriesImages($this->{DbResults}->{$subj}->{studies});
#  $http->queue("Studies: $num_studies<br/>Series: $num_series<br/>" .
#    "Images: $num_images");
}
sub NewCountStudiesSeriesImages{
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
sub NewNewExpandExtraction{
  my($this, $http, $dyn) = @_;
  my $col = $this->{SelectedCollection};
  my $site = $this->{SelectedSite};
  my $subj = $dyn->{subj};
  if(exists $this->{DirectoryLocks}->{$col}->{$site}->{$subj}){
    my $lock_status = $this->{DirectoryLocks}->{$col}->{$site}->{$subj};
    my $reason = "edit";
    if($lock_status->{NextRev} eq "0"){
      $reason = "extraction";
    } elsif($lock_status->{NextRev} eq "discard"){
      $reason = "discard";
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
      $http->queue($this->MakeHostLinkSync("extract", "NewExtractSubject", {
        subj => $dyn->{subj},
        for => "Extraction",
      }, 1, "Update();"));
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
    $http->queue('<table width=100%"><tr><td valign="top" align="left">');
    $this->NewExpandExtractionStudyInfo($http, $dyn);
    $http->queue('</td><td valign="top" align="right">');
    $this->NewExpandExtractionInfo($http, $dyn);
    $http->queue('</td></tr></table>');
  };
}
sub NewExpandExtractionStudyInfo{
  my($this, $http, $dyn) = @_;
  my $col = $this->{SelectedCollection};
  my $site = $this->{SelectedSite};
  my $subj = $dyn->{subj};
  unless(exists $this->{InfoSel}->{$col}->{$site}->{$subj}){
    $this->{InfoSel}->{$col}->{$site}->{$subj} = 0;
  }
  if($this->{InfoSel}->{$col}->{$site}->{$subj}){
    $this->ExpandStudyHierarchy($http, $dyn,
      $dyn->{hierarchy}->{$dyn->{subj}}->{studies});
  } else {
    my $col = $this->{SelectedCollection};
    my $site = $this->{SelectedSite};
    my $subj = $dyn->{subj};
    $this->ExpandStudyCounts($http, $dyn, 
      $dyn->{hierarchy}->{$subj}->{studies});
#    my($num_studies, $num_series, $num_images) = 
#      $this->NewCountStudiesSeriesImages($dyn->{hierarchy}->{$subj}->{studies});
#    $http->queue("Studies: $num_studies<br/>Series: $num_series<br/>" .
#      "Images: $num_images");
  }
}
sub NewExpandExtractionInfo{
  my($this, $http, $dyn) = @_;
  my $status = "Extracted";
  if($dyn->{rev_hist}->{CurrentRev} ne "0"){
    $status = "Current Rev: $dyn->{rev_hist}->{CurrentRev}";
  }
  if(defined $dyn->{errors}){
    $status .= "<br>with errors";
  }
  my $link = $this->MakeHostLinkSync("info", "ShowInfo", {
    subj => $dyn->{subj}
  }, 1, "Update();");
  $http->queue("$status<br>$link");
}
sub NewExtractSubject{
  my($this, $http, $dyn) = @_;
  $this->RequestLock($http, $dyn, 
    $this->WhenExtractionLockComplete($http, $dyn, $dyn->{subj}));
}
sub WhenExtractionLockComplete{
  my($this, $http, $dyn, $subj) = @_;
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
        desc => $this->{DbResults}->{$subj},
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
      print STDERR "Lock Failed - probably double click";
    }
  };
  return $sub;
}
sub ShowInfo{
  my($this, $http, $dyn) = @_;
  my $subj = $dyn->{subj};
  $this->{CollectionMode} = "InfoDisplay";
  unless(exists $this->{NickNames}) {
    $this->{NickNames} = Posda::Nicknames->new;
  }
#  $this->{DisplayInfoIn}->{subj} = $subj;
#  $this->{DisplayInfoIn}->{Collection} = $this->{SelectedCollection};
#  $this->{DisplayInfoIn}->{Site} = $this->{SelectedSite};
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
}
sub HideInfo{
  my($this, $http, $dyn) = @_;
  $this->{CollectionMode} = "CollectionsSelection";
}
sub RestoreInfo{
  my($this, $http, $dyn) = @_;
  $this->{CollectionMode} = "InfoDisplay";
}
sub NewDisplayInfo{
  my($this, $http, $dyn) = @_;
  my $info = $this->{DisplayInfoIn};
  $http->queue("<h3>Info for Collection: $info->{Collection}, " .
    "Site: $info->{Site}, Subject: $info->{subj}:</h3>");
  $this->RefreshEngine($http, $dyn,
    '<table width="100%">' .
    '<tr><td align="left" valign="top" width="50%">' .
    '<?dyn="NotSoSimpleButton" caption="Go Back" ' .
    'op="HideInfo" sync="Update();"?>' .
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
#    '<hr>' .
    '<?dyn="DupSops"?>' .
    '<?dyn="RenderEditMenu"?>' .
    '<?dyn="SendMenu"?><hr>'.
    '<?dyn="PhiMenu"?>')
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
  $this->RefreshEngine($http, $dyn,
    '<?dyn="NotSoSimpleButton" caption="Search For PHI" ' .
    'op="PhiSearch" sync="Update();"?>');
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
  my $url = $this->{BaseExternalNotificationUrl};

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
    "Response: $this->{BaseExternalNotificationUrl}"
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
    # nothing to do here???
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
  my $hierarchy = $this->{ExtractionsHierarchies}->{$dyn->{subj}}->{hierarchy}
    ->{$dyn->{subj}};
  return $this->ErrorReportCommon($http, $dyn, $error_info, $hierarchy);
}
sub RenderEditMenu{
  my($this, $http, $dyn) = @_;
  $this->RenderSplitBySeriesDescMenu($http, $dyn);
  $this->RenderRehashSsMenu($http, $dyn);
  $this->RenderRelinkSsMenu($http, $dyn);
  $this->RefreshEngine($http, $dyn,
    '<?dyn="NotSoSimpleButton" caption="General Edits" ' .
    'op="GeneralPurposeEditor" sync="Update();"?>');
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
#      print STDERR "Series need splitting or normalization on element " .
#        "other than series description\n";
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
        $this->LinkageSeriesSelection($this, $http, $dyn, $file);
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
##################################
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
  my $h = { current_rev => $current_rev };
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
  my $phi_file = "$rev_dir/$current_rev/phi.pinfo";
  if(-f $creation_file){ $h->{creation_file} = $creation_file }
  if(-f $consistency_file){ $h->{consistency_file} = $consistency_file }
  if(-f $hierarchy_file){ $h->{hierarchy_file} = $hierarchy_file }
  if(-f $dicom_info_file){ $h->{dicom_info_file} = $dicom_info_file }
  if(-f $link_info_file){ $h->{link_info_file} = $link_info_file }
  if(-f $error_info_file){ $h->{error_info_file} = $error_info_file }
  if(-f $phi_file){ $h->{phi_file} = $phi_file }
  return $h;
}
sub GetExtractionStatus{
  my($this, $subj) = @_;
  if(
    exists( $this->{DirectoryLocks}->{$this->{SelectedCollection}}
        ->{$this->{SelectedSite}}->{$subj})
  ){
    return "locked";
  } else {
    my $dir = "$this->{ExtractionRoot}/$this->{SelectedCollection}" .
      "/$this->{SelectedSite}/$subj";
    my $lock = "$dir/lock.txt";
    if(-d $dir) {
      if(-f $lock){
        return "stale_lock";
      } else {
        my $revision_0 = "$dir/revisions/0";
        if(-d $revision_0){
          return "present_unlocked";
        } else {
          return "not_present";
        }
      }
    } else {
      return "not_present";
    }
  }
}
sub CountStudiesSeriesImagesForSubj{
  my($this, $subj) = @_;
  my $num_studies = keys %{$this->{BySubject}->{$subj}->{studies}};
  my $num_series = 0;
  my $num_images = 0;
  my $studies = $this->{BySubject}->{$subj}->{studies};
  for my $std (keys %$studies){
    $num_series += keys %{$studies->{$std}->{series}};
    for my $ser ( keys %{$studies->{$std}->{series}}){
      $num_images += keys %{$studies->{$std}->{series}->{$ser}->{files}};
    }
  }
  return($num_studies, $num_series, $num_images);
}
sub CountStudiesSeriesImagesForExtraction{
  my($this, $studies) = @_;
  my $num_studies = keys %{$studies};
  my $num_series = 0;
  my $num_images = 0;
  for my $std (keys %$studies){
    $num_series += keys %{$studies->{$std}->{series}};
    for my $ser ( keys %{$studies->{$std}->{series}}){
      $num_images += keys %{$studies->{$std}->{series}->{$ser}->{files}};
    }
  }
  return($num_studies, $num_series, $num_images);
}
sub ExtractSubject{
  my($this, $http, $dyn) = @_;
  $dyn->{For} = "Extraction";
  $this->RequestLock($http, $dyn, 
    $this->WhenLockComplete($http, $dyn, $dyn->{subj}));
}
sub WhenLockComplete{
  my($this, $http, $dyn, $subj) = @_;
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
        desc => $this->{BySubject}->{$subj},
      };
      $extract_struct->{desc}->{patient_id} = $subj;
      my $commands = $args{"Revision Dir"} . "/creation.pinfo";
      store($extract_struct, $commands);
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
      print STDERR "Lock Failed - probably double click";
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
sub HideErrors{
  my($this, $http, $dyn) = @_;
  $this->{CollectionMode} = "CollectionsSelection";
}
########################################################
sub DisplayErrors{
  my($this, $http, $dyn) = @_;
  my $link_back = $this->MakeHostLinkSync("go back", "HideErrors", {
  }, 1, "Update();");
  my $error_info = $this->{DisplayErrorsIn};
  $http->queue("Extraction Errors for Collection: $error_info->{Collection}, " .
    "Site: $error_info->{Site}, Subject: $error_info->{subj}: (");
  $http->queue($link_back);
  $http->queue(")<hr>");
  $this->EditMenu($http, $dyn);
  $http->queue("<hr>");
  $dyn->{subj} = $error_info->{subj};
  $this->RenderErrors($http, $dyn);
}
sub EditMenu{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
    '<table><tr><td valign="top">' .
    '<?dyn="NotSoSimpleButton" caption="Go Back" ' .
    'op="HideErrors" sync="Update();"?><br>' .
    '<?dyn="NotSoSimpleButton" caption="Discard This Extraction" ' .
    'subj="' . $this->{DisplayErrorsIn}->{subj} . '" ' .
    'collection="' . $this->{DisplayErrorsIn}->{Collection} . '" ' .
    'site="' . $this->{DisplayErrorsIn}->{Site} . '" ' .
    'op="DiscardExtractionOK" sync="Update();"?></td><td><small>'
  );
  my $subj = $this->{DisplayErrorsIn}->{subj};
  my $extraction_info =
    $this->GetExtractionEditDirsAndFiles($subj);
  $this->ExpandStudyHierarchy($http, $dyn,
    $extraction_info->{hierarchy}->{$subj}->{studies});
  $this->RefreshEngine($http, $dyn, "</small></td><td>" .
    '<?dyn="SendExtraction"?>' .
    "</td></tr></table>");
}
sub DiscardExtractionOK{
  my($this, $http, $dyn) = @_;
  $this->{CollectionMode} = "PendingDiscard";
  $this->{PendingDiscardSite} = $dyn->{site};
  $this->{PendingDiscardCollection} = $dyn->{collection};
  $this->{PendingDiscardSubject} = $dyn->{subj};
}
sub PendingDiscard{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn,
    '<h3>Are you sure you want to discard this extraction:</h3>' .
    "<ul><li>Collection: $this->{PendingDiscardCollection}</li>" .
    "<li>Site: $this->{PendingDiscardSite}</li>" .
    "<li>Subject: $this->{PendingDiscardSubject}</li></ul>" .
    '<?dyn="NotSoSimpleButton" caption="Yes, Discard" ' .
    "subj=\"$this->{PendingDiscardSubject}\" " .
    "collection=\"$this->{PendingDiscardCollection}\" " .
    "site=\"$this->{PendingDiscardSite}\" " .
    'op="DiscardExtraction" sync="Update();"?></td><td>' .
    '<?dyn="NotSoSimpleButton" caption="No, Don' . "'" . 't Discard" ' .
    'op="DontDiscardExtraction" sync="Update();"?></td><td>'
  );
}
#DiscardExtraction
#params:
#Collection: <collection>
#Site: <site>
#Subject: <subject>
#Session: <session_id>
#User: <user>
#Pid: <pid>
#[Response: <url>]
#
#Returns:
#Aborted: <id>
#or
#Error: <text>
#
sub DontDiscardExtraction{
  my($this, $http, $dyn) = @_;
  $this->{CollectionMode} = "CollectionsSelection";
  delete $this->{PendingDiscardSite};
  delete $this->{PendingDiscardCollection};
  delete $this->{PendingDiscardSubject};
}
sub SendExtraction{
  my($this, $http, $dyn) = @_;
  $http->queue("Send button (etc) goes here");
}
sub DiscardExtraction{
  my($this, $http, $dyn) = @_;
  $this->HideErrors;
  delete $this->{DirectoryLocks};
  my $user = $this->get_user;
  my $session = $this->{session};
  my $pid = $$;
  my $new_args = [ "DiscardExtraction", 
    "Session: $session", "User: $user", "Pid: $pid" ,
    "Collection: $dyn->{collection}",
    "Site: $dyn->{site}", 
    "Subject: $dyn->{subj}",
    "For: Discard",
    "Response: $this->{BaseExternalNotificationUrl}",
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
    "Response: $this->{BaseExternalNotificationUrl}",
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
sub RenderErrors{
  my($this, $http, $dyn) = @_;
  my $dir_info = $this->GetExtractionEditDirsAndFiles($dyn->{subj});
#  $this->{dir_info} = $dir_info;
  my $error_file = $dir_info->{error_info_file};
  my $consistency_file = $dir_info->{consistency_file};
  unless(exists $this->{NickNames}) {
    $this->{NickNames} = Posda::Nicknames->new;
  }
  unless(-f $error_file) { 
    return $http->queue("error file (" .  "$error_file) not found");
  }
  unless(-f $error_file) { 
    return $http->queue("consistency file (" .  "$consistency_file) not found");
  }
  my $consistency_info = Storable::retrieve($consistency_file);
  my $error_info = Storable::retrieve($error_file);
  $http->queue("<small>Errors: <ul>");
  for my $err(@{$error_info}){
    $http->queue("<li>$err->{message}");
    my $link;
    if($err->{type} eq "image_number_check"){
      $link = $this->MakeHostLinkSync("fix", "FixImageNumbers", {
        site => $this->{DisplayErrorsIn}->{Site},
        collection => $this->{DisplayErrorsIn}->{Collection},
        subj => $this->{DisplayErrorsIn}->{subj},
        series_uid => $err->{series_uid},
      }, 1, "Update();");
    } elsif($err->{type} eq "series_consistency"){
      my $series_uid = $err->{series_uid};
      my $studies = $dir_info->{hierarchy}->{$dyn->{subj}}->{studies};
      search:
      for my $st_i (keys %$studies){
        for my $se_i (keys %{$studies->{$st_i}->{series}}){
          my $info = $studies->{$st_i}->{series}->{$se_i};
        }
      }
    }
    if(defined $link){
      $http->queue(" ($link this error)");
    }
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
#        } elsif($i eq "sop_inst"){
#          my $nn =  
#            $this->{NickNames}->GetEntityNicknameByEntityId("FILE",
#              $err->{$i});
#          $http->queue(" ($nn)");
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
sub FixImageNumbers{
  my($this, $http, $dyn) = @_;
  $this->HideErrors($http, $dyn);
  my $site = $dyn->{site};
  my $collection = $dyn->{collection};
  my $subj = $dyn->{subj};
  my $series_uid = $dyn->{series_uid};
  my $dir_info = $this->GetExtractionEditDirsAndFiles($subj);
  my $dicom_info_file;
  if(exists $dir_info->{dicom_info_file} && -f $dir_info->{dicom_info_file}){
    my $dicom_info = Storable::retrieve($dir_info->{dicom_info_file});
    my($files_to_link, $files_to_edit) =
      $this->MakeLinkEditLists(
        $dicom_info, $this->SeriesEqualCheck($series_uid));
    my $edit_dir = "$this->{ExtractionRoot}/$collection/" .
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
      unless($f =~ /^(.*)\/([^\/]+)$/){
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
    my $new_instance_number = 0;
    file_to_edit:
    for my $f (
      sort
      {
        $files_to_edit->{$a}->{norm_z}
        <=>
        $files_to_edit->{$b}->{norm_z}
      } 
      keys %$files_to_edit
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
      $new_instance_number += 1;
      $edit_instructions->{FileEdits}->{$file} = {
        from_file => $f,
        to_file => "$dest_dir/$file",
        full_ele_additions => {
          "(0020,0013)" => $new_instance_number,
        },
      };
    }
    $this->{PendingEdits} = $edit_instructions;
    ####  Here is where we request a lock for edit and
    ####  when granted, store pending edits into creation_info
    ####  and invoke edit transaction
    $dyn->{for} = "Edit";
    $this->RequestLock($http, $dyn, 
      $this->WhenEditLockComplete($http, $dyn, $edit_instructions));
  } else {
    $this->SetErrorState(
      "No Dicom Info File found for $collection $site $subj");
  }
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
      print STDERR "Lock Failed - probably double click";
    }
  };
  return $sub;
}
sub SeriesEqualCheck{
  my($this, $series_uid) = @_;
  my $sub = sub {
    my($f_info, $file) = @_;
    if($f_info->{series_uid} eq $series_uid) { return 1 }
    return 0;
  };
  return $sub;
}
sub SeriesSelectedCheck{
  my($this) = @_;
  my $sub = sub {
    my($f_info, $file) = @_;
    my $series = $f_info->{series_uid};
    unless(defined $this->{DisplayInfoIn}->{CheckedSeriesToSplit}->{$series}){
      $this->{DisplayInfoIn}->{CheckedSeriesToSplit}->{$series} = "false";
    }
    my $checked = $this->{DisplayInfoIn}->{CheckedSeriesToSplit}->{$series};
    if($checked eq "true") { return 1 }
    return 0;
  };
  return $sub;
}
sub SplitSeriesByDesc{
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
    $this->MakeLinkEditLists($dicom_info, $this->SeriesEqualCheck($series_uid));
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
#  $this->{TestEditInstructions} = $edit_instructions;
  $dyn->{for} = "Edit";
  $this->RequestLock($http, $dyn, 
    $this->WhenEditLockComplete($http, $dyn, $edit_instructions));
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
      print STDERR "Lock Failed - probably double click";
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
  my $url = $this->{BaseExternalNotificationUrl};
  $this->LockExtractionDirectory({
    Collection => $collection,
    Site => $site,
    Subject => $subj,
    Session => $session,
    User => $user,
    Pid => $pid,
    For => $dyn->{for},
    Response => $url,
   }, $at_end);
}
sub LockExtractionDirectory{
  my($this, $args, $when_done) = @_;
  delete $this->{DirectoryLocks};
  my @lines;
  push(@lines, "LockForEdit");
  for my $k (keys %$args){
    push(@lines, "$k: $args->{$k}");
  }
  if($this->SimpleTransaction($this->{ExtractionManagerPort},
    [@lines],
    $when_done)
  ){
    return;
  }
}
#################################################
# Quarantines
#################################################
sub Quarantines{
  my($this, $http, $dyn) = @_;
  print STDERR "In Quarantines\n";
  if(
    exists($this->{DbQueryInProgress}) ||
    exists $this->{ExtractionSearchInProgress}||
    exists $this->{QuarantineSearchInProgress}
  ){
    return $this->RefreshEngine($http, $dyn, 
      '<?dyn="StatusOfDbQuery"?><hr>' .
      '<?dyn="StatusOfExtractionSearch"?><hr>' .
      '<?dyn="StatusOfQuarantineSearch"?>');
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
    return $this->QuarantinesAndExtractions($http, $dyn);
  } elsif($this->{CollectionMode} eq "InfoDisplay"){
    return $this->QuarantineDisplayInfo($http, $dyn);
  } elsif($this->{CollectionMode} eq "MergeOpenDirectories"){
    return $this->MergeContent($http, $dyn);
  } elsif($this->{CollectionMode} eq "GeneralPurposeEditor"){
    return $this->GeneralPurposeEditorContent($http, $dyn);
  } else {
    die "Unknown CollectionMode: $this->{CollectionMode}";
  }
}
sub QuarantineDisplayInfo{
  my($this, $http, $dyn) = @_;
  $this->NewDisplayInfo($http, $dyn);
}
sub QuarantinesAndExtractions{
  my($this, $http, $dyn) = @_;
  $this->GetExtractionLocks($this->ContinueQuarantinesAndExtractions(
    $http, $dyn));
}
sub ContinueQuarantinesAndExtractions{
  my($this, $http, $dyn) = @_;
  my $sub = sub {
    $this->{QuarantineRows} = {};
    for my $subj (keys %{$this->{QuarantineHierarchy}}){
      $this->{CollectionRows}->{$subj} = 1;
    }
    for my $subj (keys %{$this->{ExtractionsHierarchies}}){
      $this->{CollectionRows}->{$subj} = 1;
    }
    $this->RefreshEngine($http, $dyn,
      '<?dyn="SimpleButton" op="NewNewQuery" caption="New Query" ' . 
      'sync="Update();"?>' .
      '<?dyn="MergeMenu"?>' .
      '<hr>' .
      '<small><table border="1" width="100%">' .
      '<tr><th width="10%">Subject</th><th width="45%">Quarantine Info</th>' .
      '<th width="45%">Extraction Info</th></tr>' .
      '<?dyn="ExpandQuarantineRows"?></table></small>'
    );
  };
  return $sub;
};
sub MergeMenu{
  my($this, $http, $dyn) = @_;
  my %open_dirs;
  my $num_open_dirs;
  for my $col (keys %{$this->{InfoSel}}){
    for my $site (keys %{$this->{InfoSel}->{$col}}){
      for my $subj (keys %{$this->{InfoSel}->{$col}->{$site}}){
        if($this->{InfoSel}->{$col}->{$site}->{$subj}){
          $num_open_dirs += 1;
          $open_dirs{$col}->{$site}->{$subj} = 1;
        }
      }
    }
  }
  if($num_open_dirs <= 1) { return }
  $this->{PotentialMerges} = \%open_dirs;
  $this->RefreshEngine($http, $dyn,
      '<?dyn="SimpleButton" op="MergeOpenDirectories" ' .
      'caption="Merge Directories" ' . 
      'sync="Update();"?>');
};
sub ExpandQuarantineRows{
  my($this, $http, $dyn) = @_;
  my $col = $this->{SelectedCollection};
  my $site = $this->{SelectedSite};
  for my $subj (sort {$a cmp $b} keys %{$this->{CollectionRows}}){
    $http->queue("<tr><td valign=\"top\">$subj<br>");
    $dyn->{subj} = $subj;
    if($this->{InfoSel}->{$col}->{$site}->{$subj}){
      $this->NotSoSimpleButton($http, { 
         op => "CloseSubjInfo",
         subject => $subj,
         caption => "close",
         sync => "Update();"
      });
    } else {
      $this->NotSoSimpleButton($http, { 
         op => "OpenSubjInfo",
         subject => $subj,
         caption => "open",
         sync => "Update();"
      });
    }
    $http->queue('</td><td valign="top" align="left">');
    $http->queue('<table width="100%"><tr>');
    $http->queue('<td valign="top" align="left">');
    $this->ExpandQuarantineInfo($http, $dyn);
    $this->RefreshEngine($http, $dyn,
      '</td><td valign="top" align="right"><small>' . 
      '<?dyn="ExpandQuarantineErrors"?>' .
      '</small></td>');
    $http->queue('</tr></table></td><td valign="top">');
    $this->NewNewExpandExtraction($http, $dyn);
    $http->queue("</td></tr></td></tr>");
  }
};
sub ExpandQuarantineInfo{
  my($this, $http, $dyn) = @_;
  if(exists $this->{QuarantineHierarchy}->{$dyn->{subj}}){
    $dyn->{hierarchy} = 
      $this->{QuarantineHierarchy}->{$dyn->{subj}}->{hierarchy_info};
    $this->NewExpandExtractionStudyInfo($http, $dyn);
  } else {$http->queue("--")}
}
sub ExpandQuarantineErrors{
  my($this, $http, $dyn) = @_;
  $http->queue("foo");
}
sub StatusOfQuarantineSearch{
  # present status of Extraction Search 
  my($this, $http, $dyn) = @_;
  if(exists $this->{QuarantineSearchInProgress}){
    $http->queue("Quarantine Search In Progress");
  } else {
    $http->queue("Quarantine Search Finished");
  }
}
sub StartQuarantineSearch{
  my($this, $http, $dyn) = @_;
  delete $this->{QuarantineHierarchy};
  my $dir_to_search = $this->{QuarantineRoot} .
    "/$this->{SelectedCollection}/$this->{SelectedSite}";
  my $cmd = "/bin/ls \"$dir_to_search\"";
  $this->{QuarantineDirSearcher} = Dispatch::LineReader->new_cmd($cmd,
    $this->ProcessQuarantineDirectoryLine(
      $this->{SelectedCollection}, $this->{SelectedSite},
      $dir_to_search),
    $this->QuarantineDirectorySearched($http, $dyn));
}
sub ProcessQuarantineDirectoryLine{
  my($this, $coll, $site, $root) = @_;
  my $sub = sub {
    my($line) = @_;
    if($line =~ /^\./) { return }
    my $subj = $line;
    unless(-d "$root/$subj"){ return }
    my $dicom_info;
    my $f = "$root/$subj/bom.pinfo";
    if(-f $f){
      eval {
        $dicom_info = Storable::retrieve($f);
      };
      if($@) { print STDERR "Error in retrieve of $f: $@" }
      else {
        $this->{QuarantineHierarchy}->{$subj}->{dicom_info} = $dicom_info;
      }
    }
    my $error_info;
    $f = "$root/$subj/error.pinfo";
    if(-f $f){
      eval {
        $error_info = Storable::retrieve($f);
      };
      if($@) { print STDERR "Error in retrieve of $f: $@" }
      else {
        $this->{QuarantineHierarchy}->{$subj}->{error_info} = $error_info;
      }
    }
    my $consistency_info;
    $f = "$root/$subj/consistency.pinfo";
    if(-f $f){
      eval {
        $consistency_info = Storable::retrieve($f);
      };
      if($@) { print STDERR "Error in retrieve of $f: $@" }
      else {
        $this->{QuarantineHierarchy}->{$subj}->{consistency_info} =
          $consistency_info;
      }
    }
    my $hierarchy_info;
    $f = "$root/$subj/hierarchy.pinfo";
    if(-f $f){
      eval {
        $hierarchy_info = Storable::retrieve($f);
      };
      if($@) { print STDERR "Error in retrieve of $f: $@" }
      else {
        $this->{QuarantineHierarchy}->{$subj}->{hierarchy_info} =
          $hierarchy_info;
      }
    }
  };
  return $sub;
}
sub QuarantineDirectorySearched{
  my($this, $http, $dyn) = @_;
  my $sub = sub {
    delete $this->{QuarantineDirSearcher};
    delete $this->{QuarantineSearchInProgress};
    $this->AutoRefresh;
  };
  return $sub;
}
sub PhiSearch{
  my($this, $http, $dyn) = @_;
  my $Collection = $dyn->{col};
  my $Site = $dyn->{site};
  my $Subject = $dyn->{subj};
  print STDERR "##########################\n";
  print STDERR "In PhiSearch($Collection, $Site, $Subject)\n";
  print STDERR "Not yet implemented\n";
  print STDERR "##########################\n";
}
############################################
#  GeneralPurposeEditor
############################################
sub GeneralPurposeEditor{
  my($this, $http, $dyn) = @_;
  my $child_name = $this->child_path("GeneralPurposeEditor");
  my $child = $this->child("GeneralPurposeEditor");
  unless($child) {
    TciaCuration::GeneralPurposeEditor->new($this->{session}, $child_name,
      $this->{DisplayInfoIn});
  }
  $this->{CollectionMode} = "GeneralPurposeEditor";
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
############################################
#  Merge Directories
############################################
sub MergeOpenDirectories{
  my($this, $http, $dyn) = @_;
  $this->{CollectionMode} = "MergeOpenDirectories";
}
sub MergeContent{
  my($this, $http, $dyn) = @_;
  for my $coll (keys %{$this->{InfoSel}}){
    unless($coll eq $this->{SelectedCollection}) { next }
    for my $site (keys %{$this->{InfoSel}->{$coll}}){
      unless($site eq $this->{SelectedSite}) { next }
      for my $subj (keys %{$this->{InfoSel}->{$coll}->{$site}}){
## here's where you look for quarantine and extraction directories
      }
    }
  }
  $this->RefreshEngine($http, $dyn,
    '<?dyn="NotSoSimpleButton" caption="Go Back" ' .
    'op="HideInfo" sync="Update();"?><hr>' .
    'Merge menu goes here');
}
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
1;
