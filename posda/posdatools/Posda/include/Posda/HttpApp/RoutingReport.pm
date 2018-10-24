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
<?dyn="iframe" frameborder="0" height="1000" child_path="RoutingReportContent"?>
</td></tr>

</table>
EOF
# <?dyn="Button" caption="Show Checked Objects Only"?>
{
  package Posda::HttpApp::RoutingReport;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericMfWindow" );
  sub new {
    my($class, $session, $path, $debug_obj) = @_;
    my $this = Posda::HttpApp::GenericMfWindow->new($session, $path);
    bless $this, $class;
    $this->{title} = "Routing Report Window: $debug_obj";
    $this->{w} = 2000;
    $this->{h} = 1200;
    $this->{debug_obj} = $debug_obj;
    Posda::HttpApp::Controller->new($this->{session},
      $this->child_path("Controller"));
    Posda::HttpApp::WindowButtons->new($this->{session},
      $this->child_path("WindowButtons"), "Close", 0);
    Posda::HttpApp::RoutingReportContent->new($this->{session},
      $this->child_path("RoutingReportContent"), $debug_obj);
    $this->ReOpenFile;
    return $this;
  }
  sub Initialize{
    my($this) = @_;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, $content);
  }
}
{
  package Posda::HttpApp::RoutingReportContent;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::StructToHtml", "Posda::HttpApp::GenericIframe" );
  sub new {
    my($class, $session, $path, $debug_obj) = @_;
    my $this = Posda::HttpApp::GenericIframe::new($class, $session, $path);
    return $this;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn,
    '<table border="1" width="100%"><tr>' .
    '<th>Object Name</th><th>Object Class</th>' .
    '<th>Routes</th><th>Imports From Above</th>' .
    '<th>Imports From Below</th>' .
    '<th>Exports</th>' .
    '</tr>' .
    '<?dyn="TableContent"?>' .
    '</table');
  }
  sub TableContent{
    my($this, $http, $dyn) = @_;
    my $root = $main::HTTP_APP_SINGLETON->GetSession($this->{session})->{root};
    key:
    for my $key (sort keys %$root){
      my $obj = $this->get_obj($key);
      unless($obj) { next key }
      my $class = ref($obj);
      my $routes_text = "";
      if(
        exists($obj->{RoutesBelow}) && ref($obj->{RoutesBelow}) eq "HASH"
      ){
        my @routes = sort keys %{$obj->{RoutesBelow}};
        for my $i (0 .. $#routes){
          $routes_text .= $routes[$i];
          unless($i == $#routes) { $routes_text .= "<br>" }
        }
      }
      my $import_above_text = "";
      if(
        exists($obj->{ImportsFromAbove}) &&
        ref($obj->{ImportsFromAbove}) eq "HASH"
      ){
        my @imports = sort keys %{$obj->{ImportsFromAbove}};
        for my $i (0 .. $#imports){
          $import_above_text .= $imports[$i];
          unless($i == $#imports) { $import_above_text .= "<br>" }
        }
      }
      my $import_below_text = "";
      if(
        exists($obj->{ImportsFromBelow}) &&
        ref($obj->{ImportsFromBelow}) eq "HASH"
      ){
        my @imports = sort keys %{$obj->{ImportsFromBelow}};
        for my $i (0 .. $#imports){
          $import_below_text .= $imports[$i];
          unless($i == $#imports) { $import_below_text .= "<br>" }
        }
      }
      my $export_text = "";
      if(
        exists($obj->{Exports}) &&
        ref($obj->{Exports}) eq "HASH"
      ){
        my @exports = sort keys %{$obj->{Exports}};
        for my $i (0 .. $#exports){
          $export_text .= $exports[$i];
          unless($i == $#exports) { $export_text .= "<br>" }
        }
      }
      $dyn->{key} = $key;
      $dyn->{obj} = $obj;
      $this->RefreshEngine($http, $dyn, 
      '<tr>' .
      "<td>$key</td>" .
      "<td>$class</td>" .
      "<td>$routes_text</td>" .
      "<td>$import_above_text</td>" .
      "<td>$import_below_text</td>" .
      "<td>$export_text</td>" .
      '</tr>');
    }
  }
}
1;
