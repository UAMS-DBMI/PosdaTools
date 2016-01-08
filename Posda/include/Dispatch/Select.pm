#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Dispatch/Select.pm,v $
#$Date: 2015/05/20 20:08:13 $
#$Revision: 1.23 $

use strict;
use FileHandle;
use IO::Select;
use Time::HiRes;
use B;
sub coderef2where {
  my $val;
  eval {
    my $obj = B::svref_2object( shift() );
    $val = $obj->GV->FILE . " line " . $obj->GV->LINE;
  };
  if($@) { return "error $@" }
  return $val;
}
package Dispatch::Select;

my $MaxBackgrounds = 100;
my $readers = {};
my $writers = {};
my $excepts = {};
my $background = [];
my $background_info = [];
my $timer = {};
my $timer_info = {};

sub GetTypeArray{
  my($type) = @_;
  if($type eq "reader"){
    return $readers;
  } elsif($type eq "writer"){
    return $writers;
  } elsif($type eq "except"){
    return $excepts;
  } else {
    die "unknown type: $type";
  }
}
sub BackgroundCount{
  my($class) = @_;
  my $background_count = @$background;
  my $time_count = keys %$timer;
  return($background_count, $time_count);
}

{
  package Dispatch::DebugHandler;
  use Time::HiRes qw( time );
  sub DebugMsg{
    my($this, $mess) = @_;
    unless(defined $this->{debug}) { return }
    my $now = time;
    my $class = ref($this);
    my @foo = caller(0);
    my @fie = caller(1);
    my $immed_sub = $fie[3];
    my $immed_line = $foo[2];
    my $immed_file = $foo[1];
    unless(defined $immed_sub) { $immed_sub = "Unknown" }
    my $name_space = $this->{where}->[0];
    my $file = $this->{where}->[1];
    my $line_no = $this->{where}->[2];
    my $sub = $this->{where}->[3];
    print "Debug: $immed_sub ($this->{debug})\n";
    print "\tnow: $now";
    if(defined $mess){
      print "\t$mess\n";
    }
    print "\t$file at $line_no\n";
    print "\t$immed_file at $immed_line\n";
    print "\tin $sub\n";
  }
  sub Debug{
    my($this, $mess) = @_;
    $this->{debug} = $mess;
    $this->{where} = [caller(2)];
    $this->{wherefore} = [caller(3)];
  }
}

{
  package Dispatch::Select::Background;
  sub new{
    my($class, $closure) = @_;
    # closure($this);
    #print "Creating Dispatch::Select::Background\n";
    bless $closure, $class;
    if($ENV{POSDA_DEBUG}){
      print STDERR "NEW: $closure\n";
    }
    return $closure;
  }
  sub queue{
    my($this) = @_;
    #print "Queueing Dispatch::Select::Background\n";
    push @$background, $this;
    push @$background_info, [ caller(1) ];
  }
  sub timer{
    my($this, $seconds) = @_;
    my $now = Time::HiRes::time;
    my $then = $now + $seconds;
    if(defined $timer->{$then}){
      # Watch out for collision!!!
      unless(ref($timer->{$then}) eq "ARRAY"){
        $timer->{$then} = [$timer->{$then}];
        $timer_info->{$then} = [$timer_info->{$then}];
      }
      push(@{$timer->{$then}}, $this);
      push(@{$timer_info->{$then}}, [ caller(0) ]);
    } else {
      $timer->{$then} = $this;
      $timer_info->{$then} = [ caller(0) ];
    }
  }
  sub clear{
    my($this) = @_;
    for my $k (keys %$timer){
      if($timer->{$k} eq $this){
        delete $timer->{$k};
        delete $timer_info->{$k};
      }
    }
    my $new_back = [];
    my $new_back_info = [];
    while (my $b = shift(@$background)){
      my $bi = shift(@$background_info);
      unless($b eq $this){
        push(@$new_back, $b);
        push(@$new_back_info, $bi);
      }
    }
    $background = $new_back;
    $background_info = $new_back_info;
  }
  sub clear_all_timers{
    for my $i (keys %$timer){
      delete $timer->{$i};
      delete $timer_info->{$i};
    }
  }
  sub DESTROY{
    my($this) = @_;
    if($ENV{POSDA_DEBUG}){
      print STDERR "DESTROY: $this\n";
    }
  }
}
{
  package Dispatch::Select::Socket;
  use vars qw( @ISA );
  @ISA = ( "Dispatch::DebugHandler" );
  sub new {
    my($class, $closure, $socket, $debug) = @_;
    my $this = {
      socket => $socket,
      closure => $closure,
      where => [ [caller(0)], [caller(1)], [caller(2)] ],
    };
    bless $this, $class;
    if($debug) { $this->Debug($debug); }
    if($ENV{POSDA_DEBUG}){
      print STDERR "NEW: $this\n";
    }
    return $this;
  }
  sub Add {
    my($this, $type) = @_;  # type is reader, writer, or except
    my $h = Dispatch::Select::GetTypeArray($type);
    unless(defined $this->{socket}){
      print STDERR "Dispatch::Select::Socket->Add - No associated socket\n";
      return;
    }
    my $fn = eval { fileno($this->{socket}) };
    if($@){
      print STDERR "ERROR: ($@)\n";
      my $i = 0;
      while(caller($i)){
        my @foo = caller($i);
        $i++;
        my $file = $foo[1];
        my $line = $foo[2];
        print STDERR "\tline $line of $file\n";
      }
    }
    if(defined $fn){
      $h->{$fn} = $this;
    } else {
      print STDERR "Dispatch::Select::Socket->Add - socket has no fileno\n";
    }
  }
  sub Remove {
    my($this, $type) = @_;  # type is reader, writer, or except
    if(defined $type){
      my $h = Dispatch::Select::GetTypeArray($type);
      unless(defined $this->{socket}){
        print STDERR 
          "Dispatch::Select::Socket->Remove - No associated socket\n";
        return;
      }
      my $fn = fileno($this->{socket});
      if (defined $fn) { delete $h->{fileno($this->{socket})}; }
    } else {
      $this->Remove("reader");
      $this->Remove("writer");
      $this->Remove("except");
    }
  }
  sub DESTROY{
    my($this) = @_;
    if($ENV{POSDA_DEBUG}){
      print STDERR "DESTROY: $this\n";
    }
  }
}
{
  package Dispatch::Select::Event;
  use vars qw( @ISA );
  @ISA = ( "Dispatch::DebugHandler" );
  sub new {
    my($class, $background, $debug) = @_;
    my $this = {
      background => $background,
    };
    #print "Creating Dispatch::Select::Event\n";
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print STDERR "NEW: $this\n";
    }
    if(defined $debug){ $this->Debug($debug) }
    return $this;
  }
  sub post{
    my($this) = @_;
    $this->DebugMsg();
    if(exists($this->{background})){
       push(@$background, $this->{background});
       push(@$background_info, [caller(1)]);
    } else {
      die "Posting a cleared event";
    }
  }
  sub post_and_clear{
    my($this) = @_;
    # $this->DebugMsg();
    unless(exists $this->{background}){
      die "Posting (and clearing) a cleared event";
    }
    my $bk = $this->{background};
    delete $this->{background};
    push(@$background, $bk);
    push(@$background_info, [caller(1)]);
  }
  sub DESTROY{
    my($this) = @_;
    if($ENV{POSDA_DEBUG}){
      print STDERR "DESTROY: $this\n";
    }
  }
}

sub fh_list {
  my($type) = @_;
  my @list;
  my $count = 0;
  my $h = GetTypeArray($type);
  for my $i (keys %$h){
    push(@list, $h->{$i}->{socket});
    $count += 1;
  }
  return $count, \@list;
}

sub Dispatch{
  dispatch_loop:
  while(1){
    my($read_count, $read_handles) = fh_list("reader");
    my($write_count, $write_handles) = fh_list("writer");
    my($except_count, $except_handles) = fh_list("except");
    my $bk_count = @$background;
    my $timer_count = keys %$timer;
    my $timer_increment;
    if($timer_count > 0){
      $timer_increment = 
        ([sort { $a <=> $b } keys %$timer]->[0]) - Time::HiRes::time;
    }
    if(
      $read_count == 0 &&
      $write_count == 0 &&
      $except_count == 0 &&
      $timer_count == 0 &&
      $bk_count == 0
    ){
      return;
    }
    if($timer_count > 0 && defined $timer_increment){
      if($timer_increment <= 0){
        DispatchTimers();
        next dispatch_loop;
      }
    }
    if($bk_count > 0){
      $timer_increment = 0;
    }
    my $reader = IO::Select->new(@$read_handles);
    my $writer = IO::Select->new(@$write_handles);
    my $except = IO::Select->new(@$except_handles);
    my($r_dispatch, $w_dispatch, $e_dispatch);
    if(defined($timer_increment)){
      ($r_dispatch, $w_dispatch, $e_dispatch) =
        IO::Select->select($reader, $writer, $except, $timer_increment);
      if(
        !defined($r_dispatch) &&
        !defined($w_dispatch) &&
        !defined($e_dispatch)
      ){
        unless($timer_increment == 0){
#          print STDERR "select returned with timer ($timer_increment) and" .
#            " nothing ready for anything. ($!)\n";
        }
      }
    } else {
      ($r_dispatch, $w_dispatch, $e_dispatch) =
        IO::Select->select($reader, $writer, $except);
      if(
        !defined($r_dispatch) &&
        !defined($w_dispatch) &&
        !defined($e_dispatch)
      ){
#        print STDERR "select returned with no timer and" .
#          " nothing ready for anything. ($!)\n";
      }
    }
    DispatchFhHandlers($r_dispatch, "reader");
    DispatchFhHandlers($w_dispatch, "writer");
    DispatchFhHandlers($e_dispatch, "except");
    DispatchCurrentDefaults();
  }
}

sub Dump{
  my($out) = @_;
  print $out "Readers:\n";
  for my $i (keys %$readers){
    print $out "\t$i: $readers->{$i}\n";
    my $at = main::coderef2where($readers->{$i}->{closure});
    print $out "\t\tcoderef at $at\n";
    print $out "\t\t$readers->{$i}->{socket}";
    my $file_no = $readers->{$i}->{socket}->fileno();
    print $out " ($file_no)\n";
  }
  print $out "Writers:\n";
  for my $i (keys %$writers){
    print $out "\t$i: $writers->{$i}\n";
    my $at = main::coderef2where($writers->{$i}->{closure});
    print $out "\t\tcoderef at $at\n";
    print $out "\t\t$writers->{$i}->{socket}";
    my $file_no = $writers->{$i}->{socket}->fileno();
    print $out " ($file_no)\n";
  }
  print $out "Excepts:\n";
  for my $i (keys %$excepts){
    print $out "\t$i: $excepts->{$i}\n";
    my $at = main::coderef2where($excepts->{$i}->{closure});
    print $out "\t\tcoderef at $at\n";
    print $out "\t\t$excepts->{$i}->{socket}";
    my $file_no = $excepts->{$i}->{socket}->fileno();
    print $out " ($file_no)\n";
  }
  print $out "Backgrounds:\n";
  for my $i (@$background){
    print $out "\t$i\n";
  }
  print $out "Timers:\n";
  my $now = Time::HiRes::time;
  for my $i (keys %$timer){
    my $wait = $i - $now;
    my $count = 1;
    if(ref($timer->{$i}) eq "ARRAY") {
      $count = @{$timer->{$i}};
    }
    print $out "\t$wait: $count event(s)\n";
  }
};
sub QDump{
  my($q) = @_;
  $q->queue("Readers:\n");
  for my $i (keys %$readers){
    $q->queue( "\t$i: $readers->{$i}\n");
    my $at = main::coderef2where($readers->{$i}->{closure});
    $q->queue( "\t\t$readers->{$i}->{closure} at $at\n");
    $q->queue( "\t\t$readers->{$i}->{socket}");
    my $file_no = $readers->{$i}->{socket}->fileno();
    $q->queue( " ($file_no)\n");
    $q->queue( "\t\t$readers->{$i}->{where}->[0]->[1]," .
      " line $readers->{$i}->{where}->[0]->[2]\n");
    $q->queue( "\t\t$readers->{$i}->{where}->[1]->[1]," .
      " line $readers->{$i}->{where}->[1]->[2]\n");
    $q->queue( "\t\t$readers->{$i}->{where}->[2]->[1]," .
      " line $readers->{$i}->{where}->[2]->[2]\n");
  }
  $q->queue( "Writers:\n");
  for my $i (keys %$writers){
    $q->queue( "\t$i: $writers->{$i}\n");
    my $at = main::coderef2where($writers->{$i}->{closure});
    $q->queue( "\t\t$writers->{$i}->{closure} at $at\n");
    $q->queue( "\t\t$writers->{$i}->{socket}");
    my $file_no = $writers->{$i}->{socket}->fileno();
    $q->queue( " ($file_no)\n");
    $q->queue( "\t\t$writers->{$i}->{where}->[0]->[1]," .
      " line $writers->{$i}->{where}->[0]->[2]\n");
    $q->queue( "\t\t$writers->{$i}->{where}->[1]->[1]," .
      " line $writers->{$i}->{where}->[1]->[2]\n");
    $q->queue( "\t\t$writers->{$i}->{where}->[2]->[1]," .
      " line $writers->{$i}->{where}->[2]->[2]\n");
  }
  $q->queue( "Excepts:\n");
  for my $i (keys %$excepts){
    $q->queue( "\t$i: $excepts->{$i}\n");
    my $at = main::coderef2where($excepts->{$i}->{closure});
    $q->queue( "\t\t$excepts->{$i}->{closure} at $at\n");
    $q->queue( "\t\t$excepts->{$i}->{socket}");
    my $file_no = $excepts->{$i}->{socket}->fileno();
    $q->queue( " ($file_no)\n");
    $q->queue( "\t\t$excepts->{$i}->{where}->[0]->[1]," .
      " line $excepts->{$i}->{where}->[0]->[2]\n");
    $q->queue( "\t\t$excepts->{$i}->{where}->[1]->[1]," .
      " line $excepts->{$i}->{where}->[1]->[2]\n");
    $q->queue( "\t\t$excepts->{$i}->{where}->[2]->[1]," .
      " line $excepts->{$i}->{where}->[2]->[2]\n");
  }
  $q->queue( "Backgrounds:\n");
  for my $i (0 .. $#{$background}){
    my $bkgrnd = $background->[$i];
    my $at = main::coderef2where($bkgrnd);
    my $bi = $background_info->[$i];
    $q->queue( "\t$bkgrnd at $at\n\t\t$bi->[1] line $bi->[2]\n");
  }
  $q->queue( "Timers:\n");
  my $now = Time::HiRes::time;
  for my $i (keys %$timer){
    my $wait = $i - $now;
    my $t_info = $timer_info->{$i};
    if(ref($timer->{$i}) eq "ARRAY"){
      for my $ti (0 .. $#{$timer->{$i}}){
        my $at = main::coderef2where($timer->{$i}->[$ti]);
        $q->queue(
          "\t$wait: $timer->{$i}->[$ti] at $at\n\t\t($t_info->[$ti]->[1], " .
          "line $t_info->[$ti]->[2])\n");
      }
    } else {
      my $at = main::coderef2where($timer->{$i});
      $q->queue("\t$wait: $timer->{$i} at $at\n\t\t" .
        "($t_info->[1], line $t_info->[2])\n");
    }
  }
};

sub DispatchTimers{
  my $now = Time::HiRes::time;
  for my $i (keys %$timer){
    if($i < $now){
      my $back = $timer->{$i};
      delete $timer->{$i};
      delete $timer_info->{$i};
      if(ref($back) eq "ARRAY"){
        for my $bi (0 .. $#{$back}){
          push @$background, $back->[$bi];
          push @$background_info, [caller(0)];
        }
      } else {
        push @$background, $back;
        push @$background_info, [caller(0)];
      }
    }
  }
}

sub DispatchFhHandlers{
  my $list = shift;
  my $type = shift;
  my $h = GetTypeArray($type);
  handle:
  for my $i (@$list){
    my $file_no = fileno($i);
    unless(defined $file_no) { next handle };
    unless(exists $h->{$file_no}) { next handle; }
    my $handler = $h->{$file_no};
    if($handler->{debug}){ 
      $handler->DebugMsg($type);
    }
    &{$handler->{closure}}($handler, $i);
  }
}

sub DispatchCurrentDefaults{
  my($num_to_disp) = @_;
  unless(defined $num_to_disp && $num_to_disp >= 1) { $num_to_disp = 1 };
  my $count = @$background;
  unless($count) { return }
  if($count > $MaxBackgrounds) { $count = $MaxBackgrounds }
  while($count > 0){
    $count -= 1;
    my $backgrnd = shift(@$background);
    my $foo = shift(@$background_info);
    &{$backgrnd}($backgrnd);
  }
}


1;
