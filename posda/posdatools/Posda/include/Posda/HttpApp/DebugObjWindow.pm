#!/usr/bin/perl -w
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
#####################
use strict;
package Posda::HttpApp::DebugObjWindow;
use Posda::HttpApp::GenericMfWindow;
use Posda::HttpApp::DebugObj;
my $content = <<EOF;
<table width=100%>
<tr><td align="right" valign="top">
<small>
<?dyn="iframe" height="0" width="0" style="visibility:hidden;display:none" child_path="Controller"?>
<?dyn="iframe" frameborder="0" height="85" width="90%" child_path="WindowButtons"?>
</small>
</td></tr>

<tr><td width="100%" align="left">
<?dyn="iframe" frameborder="0" height="1000" child_path="DebugObj"?>
</td></tr>

</table>
EOF
# <?dyn="Button" caption="Show Checked Objects Only"?>
use vars qw( @ISA );
@ISA = ( "Posda::HttpApp::GenericMfWindow" );
sub new {
  my($class, $session, $path, $debug_obj) = @_;
  my $this = Posda::HttpApp::GenericMfWindow->new($session, $path);
  bless $this, $class;
  $this->{title} = "Debug Window: $debug_obj";
  $this->{w} = 1024;
  $this->{h} = 1200;
  $this->{debug_obj} = $debug_obj;
  # print "DebugObjWindow: opening debug obj window for obj: $debug_obj/\n";
  Posda::HttpApp::Controller->new($this->{session},
    $this->child_path("Controller"));
  Posda::HttpApp::WindowButtons->new($this->{session},
    $this->child_path("WindowButtons"), "Close", 0);
  Posda::HttpApp::DebugObj->new($this->{session},
    $this->child_path("DebugObj"), $debug_obj);
  $this->ReOpenFile;
  return $this;
}
sub Initialize{
  my($this) = @_;
}
sub Content{
  my($this, $http, $dyn) = @_;
  unless (defined $this->get_obj($this->{debug_obj})) {
    $this->CloseWindow;
    return;
  }
  $this->RefreshEngine($http, $dyn, $content);
}

1;
