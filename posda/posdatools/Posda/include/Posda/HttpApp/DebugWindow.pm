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
package Posda::HttpApp::DebugWindow;
use Posda::HttpApp::GenericMfWindow;
use Posda::HttpApp::DebugObjs;
use Posda::HttpApp::DebugObjWindow;
use Posda::HttpApp::RoutingReport;
use Posda::HttpApp::RoutingDebug;
use Posda::HttpApp::Controller;
use Posda::HttpApp::WindowButtons;
use Debug;
my $dbg = sub {print STDERR @_ };
my $content = <<EOF;
<table width=100%><tr><td width="100%" align="right">
<?dyn="Button" caption="Show HTTP_APP_SINGLETON" op="DumpAppSingleton"?><br>
<?dyn="Button" caption="Show Routing" op="ShowRouting"?><br>
<?dyn="Button" caption="Routing Debug" op="RoutingDebug"?><br>
</td></tr></table>
<table width=100%><tr><td align="left">
</td>
<td align="right" valign="top">
<small>
<?dyn="iframe" height="0" width="0" style="visibility:hidden;display:none" child_path="Controller"?>
</small>
</td></tr>
<tr><td><table border="1">
<tr><th>Open</th><th>Path</th><th>Obj Class</th>
</tr>
<?dyn="GenerateObjList"?>
</table>
</td></tr>
<td>
<?dyn="DispatchDebug"?>
</td></tr>
</table>
EOF
#<th>R Debug</th>
#<th>Routes Below</th>
#<th>Imports From Above</th>
# <?dyn="iframe" frameborder="0" height="85" child_path="WindowButtons"?>
use vars qw( @ISA );
@ISA = ( "Posda::HttpApp::GenericMfWindow" );
sub new {
  my($class, $session, $path) = @_;
  my $this = Posda::HttpApp::GenericMfWindow->new($session, $path);
  bless $this, $class;
  $this->{title} = "Debug Window";
  $this->{w} = 1024;
  $this->{h} = 1600;
  Posda::HttpApp::Controller->new($this->{session},
    $this->child_path("Controller"));
  my $root = 
       $main::HTTP_APP_SINGLETON->GetSession($this->{session})->{root};
  Posda::HttpApp::DebugObjs->new($this->{session},
    $this->child_path("DebugObjs"));
  $this->ReOpenFile;
  return $this;
}
sub Initialize{
  my($this) = @_;
}
sub Content{
  my($this, $http, $dyn) = @_;
  $this->OpenSubwindows;
  $this->RefreshEngine($http, $dyn, $content);
}
sub DumpAppSingleton{
  my($this, $path) = @_;
  print STDERR "AppSingleton: ";
  Debug::GenPrint($dbg, $main::HTTP_APP_SINGLETON, 1, 3);
  print STDERR "\n";
}
sub ShowRouting{
  my($this, $path) = @_;
  my $child_path = "$this->{path}/RoutingReport";
  my $obj = $this->get_obj($child_path);
  if (defined $obj) { 
    # print "DebugObj RE- opening debug window for obj: $debug_obj.\n";
    $obj->ReOpenFile();
  } else {
      Posda::HttpApp::RoutingReport->new($this->{session}, 
        $child_path);
  }
}
sub RoutingDebug{
  my($this, $path) = @_;
  my $child_path = "$this->{path}/RoutingDebug";
  my $obj = $this->get_obj($child_path);
  if (defined $obj) { 
    # print "DebugObj RE- opening debug window for obj: $debug_obj.\n";
    $obj->ReOpenFile();
  } else {
      Posda::HttpApp::RoutingDebug->new($this->{session}, 
        $child_path);
  }
}
sub GetRef{
  my($this, $path) = @_;
  my $root = 
       $main::HTTP_APP_SINGLETON->GetSession($this->{session})->{root};
  return ref($root->{$path});
}
sub GenerateObjList{
  my($this, $q, $dyn) = @_;
  my $root = 
       $main::HTTP_APP_SINGLETON->GetSession($this->{session})->{root};
  my $tree = {};
  for my $obj_name (sort keys %$root){
    my @path = split(/\//, $obj_name);
    my $obj_tree = $tree;
    for my $i (@path){
      unless(exists $obj_tree->{$i}){
        $obj_tree->{$i} = {};
      }
      $obj_tree = $obj_tree->{$i};
    }
  }
  $this->GenList($q, $dyn, "", $tree, "");
}
sub GenList{
  my($this, $http, $dyn, $path, $root, $indent) = @_;
  if($path eq ""){
    for my $p (sort keys %$root){
      $this->GenList($http, $dyn, $p, $root->{$p}, $indent . $indent);
    }
    return;
  }
  $http->queue("<tr><td>");
  if($this->HasKids($path)){
    unless(exists $this->{OpenYesNo}->{$path}){
      $this->{OpenYesNo}->{$path} = "not_checked";
    }
    $this->CheckBoxNs($http, {
      name => "OpenYesNo",
      "index" => $path,
    });
  }
  $http->queue("</td><td align=\"left\">");
  $this->RefreshEngine($http, $dyn,
    "$indent<?dyn=\"Button\" op=\"DebugObj\" " .
    "caption=\"$path\" param=\"$path\"?>");
  $http->queue("</td><td align=\"left\">");
  $http->queue("  " . $this->GetRef($path));
  my $that_obj = $this->get_obj($path);
  $this->{RoutingDebugYesNo}->{$path} = 
    $that_obj->{RoutingDebug} ? "checked" : "not_checked";
  if(
    !defined $this->{OpenYesNo}->{$path} ||
    $this->{OpenYesNo}->{$path} eq "checked"
  ){
    $http->queue("</td></tr>\n");
    for my $p (sort keys %$root){
      $this->GenList($http, $dyn, "$path/$p", 
        $root->{$p}, $indent . ("&nbsp;" x 5));
    }
  } elsif($this->HasOpenKids($path)){
    $http->queue("</td></tr>\n");
    for my $p (sort keys %$root){
      if($this->HasOpenKids("$path/$p")){
        $this->GenList($http, $dyn, "$path/$p", 
          $root->{$p}, $indent . ("&nbsp;" x 5));
      }
    }
  }
}
sub SetCheckBoxValue{
  my($this, $http, $dyn) = @_;
  if($dyn->{name} eq "RoutingDebugYesNo"){
    print STDERR "\tgetting $dyn->{index}\n";
    my $obj = $this->get_obj($dyn->{index});
    if($obj){
      $obj->{RoutingDebug} = $dyn->{value} eq "checked";
    }
  }
  Posda::HttpObj::SetCheckBoxValue($this, $http, $dyn);
  $this->AutoRefresh;
}
sub DebugObj{
  my($this, $http, $dyn) = @_;
  my $debug_obj = $dyn->{param};
  my $debug_obj_child_name = $debug_obj;
  $debug_obj_child_name =~ s/\//_/g;
  unless (defined $this->get_obj($debug_obj)) {
    $this->AutoRefresh;
    return;
  }
  my $child_path = "$this->{path}/$debug_obj_child_name";
  my $obj = $this->get_obj($child_path);
  if (defined $obj) { 
    # print "DebugObj RE- opening debug window for obj: $debug_obj.\n";
    $obj->ReOpenFile();
  } else {
      Posda::HttpApp::DebugObjWindow->new($this->{session}, 
        $child_path, $debug_obj);
  }
  $this->AutoRefresh;
}
sub DispatchDebug{
  my($this, $http, $env) = @_;
  $http->queue("<pre>");
  Dispatch::Select::QDump($http);
  $http->queue("</pre>");
}
sub HasOpenKids{
  my($this, $name) = @_;
  unless(exists $this->{OpenYesNo}->{$name}){
    $this->{OpenYesNo}->{$name} = "not_checked"
  }
  if($this->{OpenYesNo}->{$name} eq "checked") { return 1 }
  if($this->CheckedDescendants($name)) { return 1 }
  if(exists($this->{OpenSubwindows}->{$name})) { return 1 }
  my $obj = $this->get_obj($name);
  my @kids;
  if($obj) {
    @kids = $obj->children_names;
  } else {
    @kids = $this->children_names_of_path($name);
  }
  for my $n (@kids){
    if($this->HasOpenKids($n)) { return 1 }
  }
  return 0;
}
sub CheckedDescendants{
  my($this, $name) = @_;
  my @kids = $this->children_names_of_path($name);
  for my $k (@kids) {  
    unless(exists $this->{OpenYesNo}->{$k}){
      $this->{OpenYesNo}->{$k} = "not_checked"
    }
    if($this->{OpenYesNo}->{$k} eq "checked") { return 1 }
    if($this->CheckedDescendants($k)) { return 1 }
  }
  return 0;
}
sub HasKids{
  my($this, $name) = @_;
  my @kids = $this->children_names_of_path($name);
  if($#kids >= 0){ return 1 }
  return 0;
}
sub OpenSubwindows{
  my($this) = @_;
  $this->{OpenSubwindows} = {};
  for my $w (@{$this->children}){
    if(ref($w) eq "Posda::HttpApp::DebugObjWindow"){
      $this->{OpenSubwindows}->{$w->{debug_obj}} = 1;
    }
  }
}
1;
