#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Dispatch/Acceptor.pm,v $
#$Date: 2010/11/03 14:35:39 $
#$Revision: 1.5 $
use strict;
use FileHandle;
package Dispatch::Acceptor;

sub new {
  my($class, $closure) = @_;
  my $foo = sub {
    my($this, $socket) = @_;
    my $new_sock = $socket->accept();
    if(defined $new_sock){
      if($new_sock->can("autoflush")){
        $new_sock->autoflush();
      }
      &$closure($this, $new_sock);
    }
  };
  bless $foo, $class;
  if($ENV{POSDA_DEBUG}){
    print "NEW: $foo\n";
  }
  return $foo;
}
sub port_server{
  my($this, $port) = @_;
  my $sock = IO::Socket::INET->new(
    Listen => 1024,
    LocalPort => $port,
    Proto => 'tcp',
    Blocking => 0,
    ReuseAddr => 1,
  );
unless($sock) { die "couldn't open listener on port $port: $!" }
  my $port_server = Dispatch::Select::Socket->new($this, $sock);
  return $port_server;
}
sub DESTROY {
  my($this) = @_;
  if($ENV{POSDA_DEBUG}){
    print "DESTROY $this\n";
  }
}
1;
