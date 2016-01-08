#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/TciaCuration/include/TciaCuration/DbFileProcessor.pm,v $
#$Date: 2015/10/28 14:19:25 $
#$Revision: 1.1 $
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
package TciaCuration::DbFileProcessor;
use strict;
use Dispatch::EventHandler;
use Dispatch::Select;
use IO::Socket::INET;
use FileHandle;
use File::Path qw(make_path remove_tree);
use Storable;

use vars qw(@ISA);
@ISA = qw( Dispatch::EventHandler );
sub new{
  my($class, $config) = @_;
  my $this = {};
  for my $k (keys %$config){
    $this->{$k} = $config->{$k};
  }
  bless $this, $class;
  $this->KeepAlive(10);
  $this->{process_seq} = 1;
  return $this;
}
sub KeepAlive{
  my($this, $delay) = @_;
  my $foo = sub{
    my($self) = @_;
    my $now = time;
    for my $k (keys %{$this->{CompletedSubProcesses}}){
      if($now - $this->{CompletedSubProcesses}->{$k}->{end_time} > 20){
        delete $this->{CompletedSubProcesses}->{$k}
      }
    }
    unless($this->{KillTimer}){
      $this->Crank;
      $self->timer($delay);
    }
  };
  my $timer = Dispatch::Select::Background->new($foo);
  $timer->timer($delay);
}
sub Crank{
  my($this) = @_;
  unless($this->{SubProcess}) {
    $this->StartSubProcess;
  }
}  
sub StartSubProcess{
  my($this) = @_;
  my $cmd = 
    "$this->{sub_process_program} $this->{database} $this->{chunk_size}";
  $this->{SubProcess} = $this->{process_seq};
  $this->{ProcessOutput}->{$this->{process_seq}} = {
    start_time => time,
    lines => [],
  };
  Dispatch::LineReader->new_cmd($cmd,
    $this->LineH($this->{process_seq}), 
    $this->EndH($this->{process_seq})
  );
  $this->{process_seq} += 1;
}
sub LineH{
  my($this, $index) = @_;
  my $sub = sub {
    my($line) = @_;
    push(@{$this->{ProcessOutput}->{$index}->{lines}}, $line);
  };
  return $sub;
}
sub EndH{
  my($this, $index) = @_;
  my $sub = sub {
    $this->{ProcessOutput}->{$index}->{end_time} = time;
    my $info = $this->{ProcessOutput}->{$index};
    $this->{CompletedSubProcesses}->{$index} = $info;
    delete $this->{ProcessOutput}->{$index};
    delete $this->{SubProcess};
    my $nth = $#{$info->{lines}};
    my $last_line = $info->{lines}->[$nth];
    if($last_line =~ /^remaining: (.*)$/){
      if($1 > 0){ $this->StartSubProcess }
    }
  };
  return $sub;
}
1;
