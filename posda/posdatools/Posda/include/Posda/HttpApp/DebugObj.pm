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
package Posda::HttpApp::DebugObj;
use Posda::HttpApp::StructToHtml;
my $content = <<EOF;
<?dyn="CheckBoxNs" name="Options" index="AutoRefresh"?>AutoRefresh&nbsp;&nbsp;
<?dyn="CheckBoxNs" name="Options" index="AutoRefreshHard"?>AutoRefresh as fast as possible<br />
<pre>
<?dyn="GenDebug"?>
</pre>
EOF
use vars qw( @ISA );
@ISA = ( "Posda::HttpApp::StructToHtml" );
sub new {
  my($class, $session, $path, $debug_obj) = @_;
  my $this = Posda::HttpApp::GenericIframe->new($session, $path);
  bless $this, $class;
  $this->{debug_obj} = $debug_obj;
  # $this->MakeTimer;
  $this->{Options}->{AutoRefresh} = "not_checked";
  $this->{Options}->{AutoRefreshHard} = "not_checked";
  return $this;
}
sub Content{
  my($this, $http, $dyn) = @_;
  if ($this->{CleanedUp}) { return; } 
  $this->RefreshEngine($http, $dyn, $content);
  if ($this->{Options}->{AutoRefreshHard} eq "checked")
    { $this->AutoRefresh; }
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
  if($dyn->{name} eq "Options" && $dyn->{index} eq "AutoRefreshHard"){
    $this->AutoRefresh;
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
  my $root = 
       $main::HTTP_APP_SINGLETON->GetSession($this->{session})->{root};
  unless(defined $this->{selected_path}->{$this->{debug_obj}}){
    $this->{selected_path}->{$this->{debug_obj}} = [];
  }
  $this->DumpHtml($http, $this->{debug_obj}, $root->{$this->{debug_obj}}, 
                  $this->{selected_path}->{$this->{debug_obj}});
}

1;
