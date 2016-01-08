#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/AppController/DetachedChild.pm,v $
#$Date: 2015/05/20 20:03:13 $
#$Revision: 1.3 $
#

use strict;
package AppController::DetachedChild;
use vars qw( @ISA );

sub Transform{
  my($class, $old_obj) = @_;
  my $old_class = ref($old_obj);
  unless($old_class eq "AppController::JsChildProcess"){
    die "Can only transform AppController::JsChildProcess instances";
  }
  bless $old_obj, $class;
  $old_obj->{PortServed} = $old_obj->{TryingSocket};
  for my $i (
    "ChildRunning", "ImportsFromAbove", "State", "content_width",
    "expander", "h", "left", "login_width", "menu_width", 
    "socket_list", "timer_count", "title", "top", "w", "path",
  ) { delete $old_obj->{$i} }
  $old_obj->{stderr_reader}->replace_handlers(
    $old_obj->Stderr_line, $old_obj->Stderr_end);
  $old_obj->{stdout_reader}->replace_handlers(
    $old_obj->Stdout_line, $old_obj->Stdout_end);
  return $old_obj;
}
sub Stderr_line{
  my($this) = @_;
  my $sub = sub {
    my($line) = @_;
    print STDERR "E:$this->{child_pid}:$this->{TryingSocket}:$line\n";
  };
  return $sub;
}
sub Stderr_end{
  my($this) = @_;
  my $sub = sub {
    delete $this->{stderr_reader};
    $this->CheckDone;
  };
  return $sub;
}
sub Stdout_line{
  my($this) = @_;
  my $sub = sub {
    my($line) = @_;
    print STDERR "O:$this->{child_pid}:$this->{TryingSocket}:$line\n";
    my $state_change = 0;
    if($line =~ /^Application Terminated Normally$/){
      $state_change = 1;
      $this->{Status} = "Application Terminated Normally";
    } elsif($line =~ /^Logged in\s*([^\s]+)\s*([^\s]+)\s*$/){
      $state_change = 1;
      $this->{AuthUser} = $1;
      $this->{RealUser} = $2;
      $this->{Status} = "Logged In";
    } elsif($line =~ /^Logged in\s*([^\s]+)\s*$/){
      $state_change = 1;
      $this->{AuthUser} = $1;
      $this->{RealUser} = $this->{AuthUser};
      $this->{Status} = "Logged In";
    } elsif($line =~ /^Time Out:/){
      $state_change = 1;
      $this->{Status} = "Timed Out";
    }
    if($state_change){
      print STDERR "Notifying session heads of state change of detached obj\n";
      Dispatch::NamedObject->NotifySessionHeads("AutoRefresh");
    }
  };
  return $sub;
}
sub Stdout_end{
  my($this) = @_;
  my $sub = sub {
    delete $this->{stdout_reader};
    $this->CheckDone;
  };
  return $sub;
}
sub CheckDone{
  my($this) = @_;
  if(exists $this->{stdout_reader}) { return }
  if(exists $this->{stderr_reader}) { return }
  my $port = $this->{PortServed};
  my $pid = $this->{child_pid};
  Dispatch::EventHandler->HarvestPid($pid);
  delete $AppController::RunningApps{$port};
  Dispatch::NamedObject->NotifySessionHeads("AutoRefresh");
}
sub DESTROY{
  my($this) = @_;
#  print STDERR "Destroying detached child\n";
}
1;
