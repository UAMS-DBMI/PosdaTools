#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/HelloWorld/Hello.pm,v $
#$Date: 2013/04/09 15:47:37 $
#$Revision: 1.7 $
#
use strict;
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::GenericMfWindow;
use Posda::HttpApp::Controller;
use Posda::HttpApp::WindowButtons;
use Dispatch::NamedFileInfoManager;
use Dispatch::NamedDirectoryManager;
package HelloWorld::Hello;
use vars qw( @ISA );
@ISA = ("Posda::HttpApp::GenericMfWindow");
##################################################################
# From here down, A GenericMfWindow
#   except has controller, not sub-controller (no parent)
#
my $base_content = <<EOF;
<table style="width:100%" summary="window header">
  <tr>
    <td valign="top" align="left" width="160">
    Hello World! (Whatever)
    </td>
    <td valign="top" align="right" width="180" height="120">
<?dyn="iframe" height="0" width="0" style="visibility:hidden;display:none" child_path="Controller"?>
<?dyn="iframe" frameborder="0" height="100%" child_path="WindowButtons"?>
    </td>
    <tr>
</table>
<?dyn="Whatever"?>
EOF
sub new{
  my($class, $sess, $path_name) = @_;
  my $this = Posda::HttpApp::GenericMfWindow->new($sess, $path_name);
  $this->{title} = "Hello World";
  bless $this, $class;
  my $user = $this->get_user;
  my($capabilities, $privs);
  if(defined $user){
    $capabilities = $main::HTTP_APP_CONFIG->{config}->{Capabilities}->{$user};
    $privs = {
      capability => $capabilities
    };
    $this->SetPrivs($privs);
  }
  my $cache_dir = $main::HTTP_APP_CONFIG->{config}->{Environment}->{PosdaCache};
  my $test_dir = 
    $main::HTTP_APP_CONFIG->{config}->{Environment}->{TestDirectory};
  Posda::HttpApp::Controller->new($sess, $this->child_path("Controller"));
  Posda::HttpApp::WindowButtons->new($sess, 
    $this->child_path("WindowButtons"), "done", 1);
  Dispatch::NamedFileInfoManager->new($sess, "FileManager", 
    (-x "/usr/bin/speedy") ? 
      "SpeedyDicomInfoAnalyzer.pl" : "DicomInfoAnalyzer.pl",
    $cache_dir, 10);
  Dispatch::NamedDirectoryManager->new($sess, "DirManager", 
    $test_dir, "FileManager");
  if($capabilities->{CanDebug}){
    Posda::HttpApp::DebugWindow->new($sess, "Debug");
  }
  return $this;
}
sub Content{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, $base_content);
}
sub Whatever{
  my($this, $http, $dyn) = @_;
  $http->queue("Whatever");
}
1;
