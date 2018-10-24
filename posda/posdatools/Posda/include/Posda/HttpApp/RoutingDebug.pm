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
use Posda::HttpApp::GenericMfWindow;
my $content = <<EOF;
<table width=100%>
<tr><td align="right" valign="top">
<small>
<?dyn="iframe" height="0" width="0" style="visibility:hidden;display:none" child_path="Controller"?>
<?dyn="iframe" frameborder="0" height="85" width="90%" child_path="WindowButtons"?>
</small>
</td></tr>
<tr><td width="100%" align="left">
<?dyn="CheckBoxNs" name="Options" index="PrintStderr"?> Print to STDERR<br>
Track: 
<?dyn="CheckBoxNs" name="Options" index="Collection"?> Collections,
<?dyn="CheckBoxNs" name="Options" index="Invocation"?> Invocations,
<?dyn="CheckBoxNs" name="Options" index="Notification"?> Notifications<br>
Filter: <?dyn="InputChangeNoReload" param="filter" op="SetFilter"?>
<?dyn="CheckBoxNs" name="Options" index="FilterOnly"?> Show Matching<br>
</td></tr>
<tr><td width="100%" align="left">
<?dyn="iframe" frameborder="0" height="1000" child_path="Content"?>
</td></tr>

</table>
EOF
# <?dyn="Button" caption="Show Checked Objects Only"?>
{
  package Posda::HttpApp::RoutingDebug;
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
    Posda::HttpApp::RoutingDebugContent->new($this->{session},
      $this->child_path("Content"), $debug_obj);
    $this->{Options} = {
       Collection => "checked",
       Invocation => "checked",
       Notification => "checked",
       FilterOnly => "checked",
       PrintStderr => "not_checked",
    };
    $this->EnableRoutingDebug("$this->{path}");
    $this->{filter} = "";
    $this->ReOpenFile;
    return $this;
  }
  sub ProcessRoutingDebug{
    my($this, $path, $type, $method, $event) = @_;
    if($path =~ /^Debug/) { return }
    unless($this->{Options}->{$type} eq "checked"){ return }
    if($this->{filter}){
      my $filter = $this->{filter};
      if($this->{Options}->{FilterOnly} eq "checked"){
        unless($method =~ /$filter/) { return }
      } else {
        if($method =~ /$filter/) { return }
      }
    }
    if($this->{Options}->{PrintStderr} eq "checked"){
      print STDERR "$type:" . ":$method: $event, $path\n";
    }
    $this->child("Content")->QueueContent([$path, $type, $method, $event]);
  }
  sub SetFilter{
    my($this, $http, $dyn) = @_;
    $this->{filter} = $dyn->{value};
  }
  sub Initialize{
    my($this) = @_;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, $content);
  }
  sub ClearContent{
    my($this, $http, $dyn) = @_;
    $this->child("Content")->Clear($http, $dyn);
  }
}
{
  package Posda::HttpApp::RoutingDebugContent;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::StructToHtml" );
  sub new {
    my($class, $session, $path, $debug_obj) = @_;
    my $this = Posda::HttpApp::GenericIframe::new($class, $session, $path);
    $this->{Content} = [];
    return $this;
  }
  sub Clear{
    my($this, $http, $dyn) = @_;
    $this->{Content} = [];
  }
  sub QueueContent{
    my($this, $foo) = @_;
    push(@{$this->{Content}}, $foo);
    $this->AutoRefresh;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    while($#{$this->{Content}} > 64) { shift @{$this->{Content}} }
    $http->queue("<small><pre>");
    for my $i (@{$this->{Content}}){
      $http->queue("$i->[1]:" . ":$i->[2]: $i->[3], $i->[0]\n");
    }
    $http->queue("</pre></small>");
  }
}
1;
