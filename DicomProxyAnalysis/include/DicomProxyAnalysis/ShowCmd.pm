#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/DicomProxyAnalysis/include/DicomProxyAnalysis/ShowCmd.pm,v $
#$Date: 2014/02/19 15:22:58 $
#$Revision: 1.3 $
#
use strict;
use Posda::HttpApp::GenericMfWindow;
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::SubController;
use Posda::HttpApp::WindowButtons;
use Posda::Command;
use Dispatch::LineReader;
#use Dispatch::Acceptor;
my $header = <<EOF;
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
</table><hr>
<?dyn="iframe" height="350" child_path="Content"?>
<hr>
EOF
{
  package DicomProxyAnalysis::ShowCmd;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericMfWindow" );
  sub new {
    my($class, $sess, $path, $message, $title) = @_;
    my $this = Posda::HttpApp::GenericMfWindow->new($sess, $path);
    $this->{title} = $title;
    bless $this, $class;
    $this->{w} = 1024;
    $this->{h} = 700;
    Posda::HttpApp::SubController->new($this->{session}, 
      $this->child_path("Controller"));
    Posda::HttpApp::WindowButtons->new($this->{session},
      $this->child_path("WindowButtons"));
    DicomProxyAnalysis::ShowCmd::Content->new(
        $this->{session}, $this->child_path("Content"), $message);
    Posda::HttpApp::DebugWindow->new($sess, "Debug");
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
  sub CleanUp{
    my($this) = @_;
    $this->delete_descendants;
  }
  sub DESTROY{
    my($this) = @_;
  }
}
{
  package DicomProxyAnalysis::ShowCmd::Content;
  use Time::HiRes qw( gettimeofday tv_interval );
  use File::Path qw (remove_tree);
  use Posda::HttpApp::GenericIframe;
  use Storable qw( fd_retrieve );
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericIframe" );
  sub new{
    my($class, $sess, $path, $message) = @_;
    my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
    $this->{message} = $message;
    if($this->{message}->can("DumpLines")){
      $this->{lines} = $this->{message}->DumpLines;
    }
    if($this->{message}->can("BasicCommandInfo")){
      $this->{basic_info} = [ $this->{message}->BasicCommandInfo ];
    }
    bless $this, $class;
    return $this;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn,
      'Command: <?dyn="Command"?><br>' .
      '<table><tr>' .
      '<th>(grp,ele)</th><th>Name</th><th>VR</th><th>Value</th>' .
      '</tr><?dyn="cmd_rows"?>' .
      '</table>'
    );
  }
  sub cmd_rows{
    my($this, $http, $dyn) = @_;
    for my $r (@{$this->{lines}}){
      $http->queue("<tr><td>$r->[0]</td><td>$r->[1]</td>". 
        "<td>$r->[2]</td><td align=\"right\">");
      if($r->[3] eq "ushort"){
        $http->queue(sprintf("0x%04x", $r->[4]));
      } else {
        $http->queue($r->[4]);
      }
      $http->queue("</td></tr>");
    }
  }
  sub Command{
    my($this, $http, $dyn) = @_;
    my $command = $this->{basic_info}->[0];
    if($this->{basic_info}->[2]){
      $http->queue($command . "_RESP");
    } else {
      $http->queue($command);
    }
  }
}
1;
