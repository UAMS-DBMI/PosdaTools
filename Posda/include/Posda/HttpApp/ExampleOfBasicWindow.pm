#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/HttpApp/ExampleOfBasicWindow.pm,v $
#$Date: 2013/08/16 19:03:37 $
#$Revision: 1.2 $
#
use strict;
use Posda::HttpApp::GenericMfWindow;
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::SubController;
use NewItcTools::WindowButtons;
my $header = <<EOF;
<table style="width:100%" summary="window header">
  <tr>
    <td valign="top" align="left" width="160">
      <?dyn="Logo"?>
    </td>
    <td valign="top">
      <h2>####Title#####<br>####more title####</h2>
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
  package Posda::HttpApp::<NewType>;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericMfWindow" );
  sub new {
    my($class, $sess, $path, <new args>) = @_;
    my $this = Posda::HttpApp::GenericMfWindow->new($sess, $path);
    $this->{title} = "<new title>";
    bless $this, $class;
    <handle args>
    $this->{w} = 1024;
    $this->{h} = 700;
    ### Make this a Controller if this is top level app
    Posda::HttpApp::SubController->new($this->{session}, 
      $this->child_path("Controller"));
    ###
    Posda::HttpApp::WindowButtons->new($this->{session},
      $this->child_path("WindowButtons"));
    Posda::HttpApp::<NewType>::Content->new(
        $this->{session}, $this->child_path("Content"));
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
  package Posda::HttpApp::<NewType>::Content;
  use Posda::HttpApp::GenericIframe;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericIframe" );
  sub new{
    my($class, $sess, $path) = @_;
    my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
    <new stuff>
    bless $this, $class;
    return $this;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, '<html><head></head><body>' .
      'content goes here</body></html>');
  }
}
}
1;
