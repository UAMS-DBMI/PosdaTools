#!/usr/bin/perl -w
#
use strict;
use AppController::Start;
use Posda::HttpApp::ReceiverStatusControl;
use Debug;
my $dbg = sub {print @_};
{
  package Posda::HttpApp::PosdaApplication;
  use vars qw( @ISA );
  @ISA = ("AppController::Start");
my $base_content = <<EOF;
  <table style="width:100%" summary="window header">
    <tr>
      <td valign="top" height="82">
      <?dyn="Logo"?>
      </td>
      <td valign="top" align="left">
      <h2><?dyn="MainTitle"?></h2>
      <?dyn="iframe" height="35" width="100%" child_path="DateTime"?>
      </td>
      <td valign="top" align="right">
  <?dyn="iframe" height="0" width="0" style="visibility:hidden;display:none" child_path="Controller"?>
  <?dyn="iframe" frameborder="0" child_path="WindowButtons"?>
      </td>
      <tr>
  </table>
  <?dyn="iframe" height="1024" width="100%" child_path="Content"?>
  <hr>
EOF
  sub new{
    my($class, $sess, $path_name) = @_;
    my $this = AppController::Start::new($class,$sess, $path_name);
    Posda::HttpApp::PosdaApplication::Content->new(
      $this->{session},$this->child_path("Content"));
    $this->{base_content} = $base_content;
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
  sub MainTitle{
    my($this, $http, $dyn) = @_;
    my $main_title = "Posda Dicom Tools";
    if(defined $main::HTTP_APP_CONFIG->{config}->{Identity}->{Title}){
      $main_title = $main::HTTP_APP_CONFIG->{config}->{Identity}->{Title};
    }
    $http->queue($main_title);
  }
}
{
  package Posda::HttpApp::PosdaApplication::Content;
  use vars qw( @ISA );
  @ISA = ("AppController::Start::Content");
  sub new{
    my($class, $sess, $path) = @_;
    my $this = AppController::Start::Content::new($class, $sess, $path);
    $this->{Exports}->{GetSocketList} = 1;
    return $this;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    if($this->get_user) {
      $this->RefreshEngine($http, $dyn,
      '<?dyn="Button" op="Password" caption="Password Maintenance"?>'.
      '<?dyn="Button" op="ServerControl" caption="Server Status/Control"?>'
      );
    }
    if($this->IsExpert){
      $this->RefreshEngine($http, $dyn,
      '<?dyn="Button" op="CheckBOM" caption="Check Bill of Materials"?>' .
      '<?dyn="CacheCheck"?>'
      );
    }
    $this->RefreshEngine($http, $dyn,
      '<hr>Applications Available:<table>' .
      '<tr><th>Name</th><th>Description</th><th>Login</th>' .
      '<?dyn="AvailableApps"?>' .
      '</table>' .
      '<hr>Applications Pending:<ul><?dyn="PendingApps"?></ul>' .
      '<hr>Applications Running:<ul><?dyn="RunningApps"?></ul>' .
      '<hr>Applications Harvested:<ul><?dyn="HarvestedApps"?></ul>' .
      '<?dyn="Zombies"?>');
  }
  sub ServerControl{
    my($this, $http, $dyn) = @_;
    my $child_name = $this->child_path("ReceiverStatus");
    my $child_obj = $this->get_obj($child_name);
    unless($child_obj){
      $child_obj = Posda::HttpApp::ReceiverStatusControl->new(
        $this->{session}, $child_name);
    }
    $child_obj->ReOpenFile;
  }
}
1;
