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
package Posda::HttpApp::DebugObjs;
use Posda::HttpApp::StructToHtml;
my $content = <<EOF;
<?dyn="CheckBoxNs" name="Options" index="AutoRefresh"?>AutoRefresh<br />
<pre>
<?dyn="GenDebug"?>
</pre>
EOF
use vars qw( @ISA );
@ISA = ( "Posda::HttpApp::StructToHtml" );
sub new {
  my($class, $session, $path) = @_;
  my $this = Posda::HttpApp::GenericIframe->new($session, $path);
  bless $this, $class;
  # $this->MakeTimer;
  $this->{Options}->{AutoRefresh} = "not_checked";
  return $this;
}
sub Content{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, $content);
}
sub CleanUp{
  my($this) = @_;
  $this->{CleanedUp} = 1;
}
sub SetCheckBoxValue{
  my($this, $http, $dyn) = @_;
  Posda::HttpObj::SetCheckBoxValue($this, $http, $dyn);
  if($dyn->{name} eq "Options" && $dyn->{index} eq "AutoRefresh"){
    if ($this->{Options}->{AutoRefresh} eq "checked") 
      { $this->MakeTimer; }
  }
}
sub MakeTimer{
  my($this) = @_;
  my $foo = sub {
    my($self) = @_;
    if ($this->{CleanedUp}) { return; }
    if ($this->{Options}->{AutoRefresh} ne "checked") { return; }
    $this->AutoRefresh;
    $self->timer(2);
  };
  my $timer = Dispatch::Select::Background->new($foo);
  $timer->queue;
}
sub GenDebug{
  my($this, $http, $dyn) = @_;
  my $root = $main::HTTP_APP_SINGLETON->GetSession($this->{session})->{root};
  my $dw = $this->parent;
  obj:
  for my $i (sort keys %$root){
    unless(exists $dw->{ObjCheckboxes}->{$i}){
      $dw->{ObjCheckboxes}->{$i} = "not_checked";
    }
    unless(
      $dw->{ObjCheckboxes}->{$i} eq "checked"
    ){ next obj }
    unless(defined $this->{selected_path}->{$i}){
      $this->{selected_path}->{$i} = [];
    }
    $this->DumpHtml($http, $i, $root->{$i}, 
                    $this->{selected_path}->{$i});
  }
}

1;
