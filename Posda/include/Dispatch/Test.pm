#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Dispatch/Test.pm,v $
#$Date: 2009/05/28 17:24:11 $
#$Revision: 1.5 $

use strict;
package Dispatch::Test;
sub CreateDeleter{
  my($name, $obj_list) = @_;
  my $foo = sub {
    print "Deleteing $name\n";
    delete $obj_list->{$name};
  }
}
sub CreateNotifier{
  my($out, $list) = @_;
  my $foo = sub {
    for my $i (@$list){
      print $out "$i ";
    }
    print $out "\n";
  };
  return $foo;
}
sub CreateCounter{
  my($out, $name, $count, $rm) = @_;
  my $foo = sub {
    my $disp = shift;
    print $out "Counter: $name $count\n";
    $count -= 1;
    if($count > 0){
      $disp->queue();
    } else {
      &$rm;
    }
  };
  return $foo;
}
sub CreateTimer {
  my($out, $name, $rm) = @_;
  my $now = Time::HiRes::time;
  my $foo = sub {
    my $then = Time::HiRes::time;
    my $elapsed = $then - $now;
    print $out "Timer: $name timed out after $elapsed\n";
    &$rm;
  };
};
my $sock_id = 0;
sub CreateSockReader{
  my($out, $name) = @_;
  my $sock_name = "$name" . "_$sock_id";
  my $foo = sub {
    my($this, $socket) = @_;
    my $mess;
    my $count = read($socket, $mess, 1024);
    unless(defined $count){
      $this->Remove('reader');
      if($ENV{POSDA_DEBUG}){
        print "disconnected socket $sock_name\n";
      }
      print $out "disconnected socket $sock_name\n";
      return;
    }
    print $out "read from $sock_name: \"$mess\"\n";
  };
  $sock_id += 1;
  if($ENV{POSDA_DEBUG}){
    print "accepted new socket: $sock_name\n";
  }
  print $out "accepted new socket: $sock_name\n";
  return $foo;
}
sub CreateSockAcceptor{
  my($out, $name) = @_;
  my $foo = sub {
    my($this, $socket) = @_;
    my $reader = CreateSockReader($out, $name);
    my $rh = Dispatch::Select::Socket->new($reader, $socket);
    $rh->Add("reader");
  };
  return $foo;
}
my $seq = 1;
sub CreateObjAdder{
  my($name, $objs) = @_;
  my $foo = sub {
     my($obj) = @_;
     my $new = $name . "_" . $seq;
     $seq += 1;
     $objs->{$new} = $obj;
     if($obj->can("SetDisconnectCallback")){
       $obj->SetDisconnectCallback(CreateObjDeleter($new, $objs));
     }
  };
  return $foo;
}
sub CreateObjDeleter{
  my($name, $objs) = @_;
  my $foo = sub {
     my($obj) = @_;
     if(exists $objs->{$name}){
       delete $objs->{$name};
     }
  };
  return $foo;
}
sub CreateEchoResponse{
  my($out) = @_;
  my $foo = sub {
    my($resp) = @_;
    print $out "response to echo\n";
  };
  return $foo;
}
1;
