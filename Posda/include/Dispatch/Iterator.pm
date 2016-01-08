#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Dispatch/Iterator.pm,v $
#$Date: 2011/05/10 18:52:42 $
#$Revision: 1.3 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package Dispatch::Iterator;
use Dispatch::Select;

sub MakeNotifier {
  my($session, $obj_name, $method, $parm) = @_;
  my $foo = sub {
    my($disp) = @_;
    my $obj = $main::HTTP_APP_SINGLETON->{Inventory}->{$session}->{root}->
      {$obj_name};
    $obj->$method($parm);
  };
  my $disp = Dispatch::Select::Background->new($foo);
  return $disp;
}
sub MakeIterator{
  my($this, $iterate, $end_test, $finalize) = @_;
  my $foo = sub {
    my $disp = shift;
    if($this->$end_test($disp)){
      $this->$finalize();
      return;
    }
    $this->$iterate($disp);
    if(exists $this->{PauseIteration}) { return }
    $disp->queue();
  };
  return $foo;
}

sub Iterate{
  my($this, $init, $iterate, $end_test, $finalize) = @_;
  $this->$init();
  my $loop = Dispatch::Select::Background->new(
    MakeIterator($this, $iterate, $end_test, $finalize));
  $loop->queue();
}
1;
