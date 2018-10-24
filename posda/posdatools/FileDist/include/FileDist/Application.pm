#!/usr/bin/perl -w
#
use strict;
use Posda::HttpApp::GenericMfWindow;
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::SubController;
use Posda::HttpApp::WindowButtons;
use Dispatch::NamedFileInfoManager;
use FileDist::Anonymizer;
use FileDist::CombineAssociations;
use FileDist::CompareDirectories;
use FileDist::DicomSender;
use FileDist::DicomEdit;
use FileDist::DicomQuery;
use FileDist::ViewDirectory;
my $header = <<EOF;
<table style="width:100%" summary="window header">
  <tr>
    <td valign="top" align="left" width="160">
      <?dyn="Logo"?>
    </td>
    <td valign="top">
      <table>
      <tr><td colspan="2"><h2>File Distribution Application</h2></td>
      <tr><td colspan="2"><h3><?dyn="title"?></h3></td></tr>
      <tr><td>
      <small>Select operation: <?dyn="SelectNsByValue" op="SelectOperation"?>
      <?dyn="OperationDropDown"?></select></td><td>
      <?dyn="iframe" height="35" width="100%" child_path="Alert"?></td></tr>
      </table>
      </td>
    <td valign="top" align="right" width="180" height="120">
<?dyn="iframe" height="0" width="0" style="visibility:hidden;display:none" child_path="Controller"?>
<?dyn="iframe" frameborder="0" height="100%" child_path="WindowButtons"?>
    </td>
  </tr>
</table>
<?dyn="iframe" height="768" child_path="Content"?>
EOF
my $bad_config = <<EOF;
<table style="width:100%" summary="window header">
  <tr>
    <td valign="top" align="left" width="160">
      <?dyn="Logo"?>
    </td>
    <td valign="top">
      <h2>File Distribution Application</h2>
      <h3><?dyn="title"?></h3>
      <small>Select operation: <?dyn="SelectNsByValue" op="SelectOperation"?>
      <?dyn="OperationDropDown"?></select>
      </td>
    <td valign="top" align="right" width="180" height="120">
<?dyn="iframe" height="0" width="0" style="visibility:hidden;display:none" child_path="Controller"?>
<?dyn="iframe" frameborder="0" height="100%" child_path="WindowButtons"?>
    </td>
  </tr>
</table>
<table border="1"><hr><th colspan="2">Bad Configuration Files</th></tr>
<?dyn="BadConfigReport"?>
</table>
EOF
{
  package FileDist::Application;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericMfWindow" );
  sub new {
    my($class, $sess, $path) = @_;
    my $this = Posda::HttpApp::GenericMfWindow->new($sess, $path);
    $this->{title} = "File Distribution Application";
    bless $this, $class;
    $this->{w} = 1024;
    $this->{h} = 700;
    $this->{RoutesBelow}->{SetOperation} = 1;
    $this->{RoutesBelow}->{ExpertModeChanged} = 1;
    $this->{RoutesBelow}->{ShowAlert} = 1;
    $this->{ImportsFromAbove}->{SetOperation} = 1;
    Dispatch::NamedFileInfoManager->new($sess, "FileManager",
      ( -x "/usr/bin/speedy" ) ?
        "SpeedyDicomInfoAnalyzer.pl" : "DicomInfoAnalyzer.pl",
      $main::HTTP_APP_CONFIG->{config}->{Environment}->{CacheDir},
      10);
    Posda::HttpApp::Controller->new($this->{session}, 
      $this->child_path("Controller"));
    Posda::HttpApp::WindowButtons->new($this->{session},
      $this->child_path("WindowButtons"));
    FileDist::Application::Content->new(
        $this->{session}, $this->child_path("Content"));
    FileDist::Application::Alert->new(
        $this->{session}, $this->child_path("Alert"));
    Posda::HttpApp::DebugWindow->new($sess, "Debug");
    $this->SetInitialExpertAndDebug;
    $this->{Operation} = "Select Operation";
    $this->ReOpenFile();
    if(exists $main::HTTP_APP_CONFIG->{BadJson}){
      $this->{BadConfigFiles} = $main::HTTP_APP_CONFIG->{BadJson};
    }
    return $this;
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
    $http->queue("<img src=\"$image\" height=\"$height\" width=\"$width\" " ,
      "alt=\"$alt\">");
  }
  sub OperationDropDown{
    my($this, $http, $dyn) = @_;
    for my $i (
      "Select Operation", "Anonymize", "Compare Directories",
      "Send Dicom Data", "Query Dicom Ae", "Edit Dicom Data", "View Directory",
    ){
      $http->queue("<option value=\"$i\"");
      if($i eq $this->{Operation}){ $http->queue(" selected") }
      $http->queue(">$i</option>\n");
    }
  }
  sub SelectOperation{
    my($this, $http, $dyn) = @_;
    $this->{Operation} = $dyn->{value};
    $this->NotifyUp("SetOperation", $dyn->{value});
  }
  sub Content {
    my($this, $http, $dyn) = @_;
    if($this->{BadConfigFiles}){
      return $this->RefreshEngine($http, $dyn, $bad_config);
    }
    $this->RefreshEngine($http, $dyn, $header);
  }
  sub DESTROY{
    my($this) = @_;
    $this->delete_descendants();
  }
}
{
  package FileDist::Application::Content;
  use File::Path qw (remove_tree);
  use Posda::HttpApp::GenericIframe;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericIframe" );
  my $op_map = {
    "Anonymize" => {
      "name" => "Anonymizer",
      "obj_class" => "FileDist::Anonymizer",
    },
    "Create Results Directory" => {
      "name" => "AssocCombiner",
      "obj_class" => "FileDist::CombineAssociations",
    },
    "Compare Directories" => {
      "name" => "DirCompare",
      "obj_class" => "FileDist::CompareDirectories",
    },
    "Send Dicom Data" => {
      "name" => "DicomSender",
      "obj_class" => "FileDist::DicomSender",
    },
    "Query Dicom Ae" => {
      "name" => "DicomQuery",
      "obj_class" => "FileDist::DicomQuery",
    },
    "Edit Dicom Data" => {
      "name" => "DicomEditor",
      "obj_class" => "FileDist::DicomEdit",
    },
    "View Directory" => {
      "name" => "DirectoryViewer",
      "obj_class" => "FileDist::ViewDirectory",
    },
  };
  sub new{
    my($class, $sess, $path) = @_;
    my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
    bless $this, $class;
    $this->{Operation} = "Select Operation";
    $this->{Exports}->{SetOperation} = 1;
    $this->{RoutesBelow}->{TempDir} = 1;
    $this->{Exports}->{TempDir} = 1;
    my $dir = $main::HTTP_APP_CONFIG->{config}->{Environment}->{CacheDir};
    unless(-d $dir) { die "$dir doesn't exist" }
    my $count = mkdir "$dir/$sess";
    unless($count == 1) {die "Can't mkdir $dir/$sess" }
    $this->{TempDir} = "$dir/$sess";
    $this->AutoRefresh;
    return $this;
  }
  sub TempDir{
    my($this) = @_;
    return $this->{TempDir};
  }
  sub SetOperation{
    my($this, $operation) = @_;
    $this->{Operation} = $operation;
    $this->AutoRefresh;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    unless(defined $op_map->{$this->{Operation}}){
      $http->queue("No operation selected");
      return;
    }
    my $obj_class = $op_map->{$this->{Operation}}->{obj_class};
    my $name = $op_map->{$this->{Operation}}->{name};
    my $hand = $this->child($name);
    unless(defined $hand) {
      $hand = $obj_class->new($this->{session}, $this->child_path($name));
    }
    $hand->Content($http, $dyn);
  }
  sub DESTROY{
    my($this) = @_;
    print STDERR "remove_tree($this->{TempDir}\n";
    remove_tree($this->{TempDir});
  }
}
{
  package FileDist::Application::Alert;
  use Posda::HttpApp::GenericIframe;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericIframe" );
  sub new{
    my($class, $sess, $path) = @_;
    my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
    bless $this, $class;
    $this->{Exports}->{ShowAlert} = 1;
    $this->AutoRefresh;
    return $this;
  }
  sub ShowAlert{
    my($this, $mess) = @_;
    if(exists $this->{Alert}) { return $this->QueueAlert($mess) }
    $this->{Alert} = $mess;
    $this->AutoRefresh;
    $this->StartTimer;
  };
  sub QueueAlert{
    my($this, $mess) = @_;
    unless(exists $this->{AlertQueue}) { $this->{AlertQueue} = [] }
    push(@{$this->{AlertQueue}}, $mess);
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    if(exists $this->{Alert}) { $http->queue("<small>$this->{Alert}</small>") }
    $http->queue("&nbsp;");
  }
  sub StartTimer{
    my($this) = @_;
    my $sub = sub {
      my($disp) = @_;
      delete $this->{Alert};
      if(
        exists $this->{AlertQueue} &&
        ref $this->{AlertQueue} eq "ARRAY" &&
        $#{$this->{AlertQueue}} >= 0
      ){
        my $alert = shift(@{$this->{AlertQueue}});
        $this->{Alert} = $alert;
        $disp->timer(2);
      } else {
        delete $this->{AlertQueue};
      }
      $this->AutoRefresh;
    };
    Dispatch::Select::Background->new($sub)->timer(2);
  }
}
1;
