#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/FileDist/include/DicomLookup/Application.pm,v $
#$Date: 2013/10/16 20:03:49 $
#$Revision: 1.1 $
#
use strict;
use Posda::HttpApp::GenericMfWindow;
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::SubController;
use Posda::HttpApp::WindowButtons;
use Dispatch::LineReader;
my $header = <<EOF;
<table style="width:100%" summary="window header">
  <tr>
    <td valign="top" align="left" width="160">
      <?dyn="Logo"?>
    </td>
    <td valign="top">
      <h2><?dyn="title"?></h2>
      Enter search value:
      <?dyn="InputChangeNoReload" op="SetSearchString" field="SearchString"?>
      </td>
    <td valign="top" align="right" width="180" height="120">
<?dyn="iframe" height="0" width="0" style="visibility:hidden;display:none" child_path="Controller"?>
<?dyn="iframe" frameborder="0" height="100%" child_path="WindowButtons"?>
    </td>
  </tr>
</table><hr>
<?dyn="iframe" height="350" child_path="Content"?>
<hr>
EOF
my $bad_config = <<EOF;
<table style="width:100%" summary="window header">
  <tr>
    <td valign="top" align="left" width="160">
      <?dyn="Logo"?>
    </td>
    <td valign="top">
      <h2><?dyn="title"?></h2>
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
  package DicomLookup::Application;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericMfWindow" );
  sub new {
    my($class, $sess, $path) = @_;
    my $this = Posda::HttpApp::GenericMfWindow->new($sess, $path);
    $this->{title} = "Dicom Element Lookup Application";
    bless $this, $class;
    $this->{w} = 800;
    $this->{h} = 500;
    $this->{RoutesBelow}->{ExpertModeChanged} = 1;
    Posda::HttpApp::Controller->new($this->{session}, 
      $this->child_path("Controller"));
    Posda::HttpApp::WindowButtons->new($this->{session},
      $this->child_path("WindowButtons"));
    DicomLookup::Application::Content->new(
        $this->{session}, $this->child_path("Content"));
    Posda::HttpApp::DebugWindow->new($sess, "Debug");
    $this->SetInitialExpertAndDebug;
    $this->ReOpenFile();
    if(exists $main::HTTP_APP_CONFIG->{BadJson}){
      $this->{BadConfigFiles} = $main::HTTP_APP_CONFIG->{BadJson};
    }
    my $session = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
    $session->{Privileges}->{capability}->{CanDebug} = 1;
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
  sub Content {
    my($this, $http, $dyn) = @_;
    if($this->{BadConfigFiles}){
      return $this->RefreshEngine($http, $dyn, $bad_config);
    }
    $this->RefreshEngine($http, $dyn, $header);
  }
  sub SetSearchString{
    my($this, $http, $dyn) = @_;
    $this->{SearchString} = $dyn->{value};
    $this->SearchText;
  }
  sub SearchText{
    my($this, $http, $dyn) = @_;
    my $obj = $this->child("Content");
    $obj->SearchText($this->{SearchString});
  }
  sub CleanUp{
    my($this) = @_;
    $this->delete_descendants;
  }
  sub DESTROY{
    my($this) = @_;
  }
}
{
  package DicomLookup::Application::Content;
  use File::Path qw (remove_tree);
  use Posda::HttpApp::GenericIframe;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericIframe" );
  sub new{
    my($class, $sess, $path) = @_;
    my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
    bless $this, $class;
    $this->{SearchesInProgress} = 0;
    $this->{Operation} = "Idle";
    $this->AutoRefresh;
    return $this;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    if($this->{Operation} eq "SearchString"){
      $this->RefreshEngine($http, $dyn,
        "<small>Search for elements matching: \"$this->{SearchString}\"<br>" .
        '<pre><?dyn="SearchStringResults"?><pre></small>');
    } else {
      $http->queue("Enter Search Above");
    }
  }
  sub SearchText{
    my($this, $text_string) = @_;
    $this->{SearchString} = $text_string;
    $this->{Operation} = "SearchString";
    $this->StartTextSearch;
    $this->AutoRefresh;
  }
  sub SearchStringResults{
    my($this, $http, $dyn) = @_;
    for my $l (@{$this->{SearchResults}}){ $http->queue("$l\n") }
  }
  sub StartTextSearch{
    my($this) = @_;
    my $str = $this->{SearchString};
    $str =~ s/\"/\\\"/g;
    my $cmd = "SearchElementsByName.pl \"$str\"";
    $this->{SearchResults} = [];
    if($this->{SearchesInProgress} > 0){
      push(@{$this->{SearchResults}}, 
        "Attempting to start new search when one in progress");
      return;
    }
    $this->{SearchesInProgress} += 1;
    Dispatch::LineReader->new_cmd($cmd, 
      $this->SearchLine, $this->EndSearch);
  }
  sub SearchLine{
    my($this) = @_;
    my $sub = sub {
      my($line) = @_;
      push(@{$this->{SearchResults}}, $line);
    };
    return $sub;
  }
  sub EndSearch{
    my($this, $line) = @_;
    my $sub = sub {
      $this->{SearchesInProgress} -= 1;
      $this->AutoRefresh;
    };
    return $sub;
  }
}
1;
