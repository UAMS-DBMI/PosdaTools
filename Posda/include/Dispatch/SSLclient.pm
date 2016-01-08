#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Dispatch/SSLclient.pm,v $
#$Date: 2010/12/14 17:12:28 $
#$Revision: 1.3 $
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Errno;
use Fcntl;
use IO::Socket;
use Net::SSLeay qw(die_now die_if_ssl_error );
Net::SSLeay::load_error_strings();
eval 'no warnings "redefine";
      sub Net::SSLeay::load_error_strings () {}
     '; die $@ if $@;
Net::SSLeay::SSLeay_add_ssl_algorithms();
eval 'no warnings "redefine"; 
      sub Net::SSLeay::SSLeay_add_ssl_algorithms () {}
     '; die $@ if $@;
Net::SSLeay::ENGINE_load_builtin_engines();
eval 'no warnings "redefine";
      sub Net::SSLeay::ENGINE_load_builtin_engines () {}
     '; die $@ if $@;
Net::SSLeay::ENGINE_register_all_complete();
eval 'no warnings "redefine";
      sub Net::SSLeay::ENGINE_register_all_complete () {}
     '; die $@ if $@;
Net::SSLeay::randomize();
eval 'no warnings "redefine";
      sub Net::SSLeay::randomize (;$$) {}
     '; die $@ if $@;
package Dispatch::SSLClient;
sub ssl_get_error {
  my $errors = "";
  my $errnos = [];
  while(my $errno = Net::SSLeay::ERR_get_error()) {
    push @$errnos, $errno;
    $errors .= Net::SSLeay::ERR_error_string($errno) . "\n";
  }
  return $errors, $errnos if wantarray;
  return $errors;
}
sub ssl_check_die {
  my ($message) = @_;
  my ($errors, $errnos) = ssl_get_error();
  die "${message}: ${errors}" if @$errnos;
  return;
}

sub new{
  my($class) = @_;
  my $ctx = Net::SSLeay::CTX_new() or die("Failed to create SSL_CTX $!");
  Net::SSLeay::CTX_set_options($ctx, &Net::SSLeay::OP_ALL)
    and ssl_check_die("ssl ctx set options");
  my $ssl = Net::SSLeay::new($ctx) or die_now("Failed to create SSL $!");
  my $this = {
    ctx => $ctx,
    ssl => $ssl,
  };
  return bless $this, $class;
}
sub connect{
  my($this, $s) = @_;
  Net::SSLeay::set_fd($this->{ssl}, fileno($s));   # Must use fileno
  my $res = Net::SSLeay::connect($this->{ssl}) and Net::SSLeay::die_if_ssl_error("ssl connect");
  if($res < 0){ return undef}
  $this->{socket} = $s;
  return 1;
}
sub write{
  my($this, $string) = @_;
  return Net::SSLeay::write($this->{ssl}, $string);
}
sub close_write{
  my($this, $string) = @_;
  my $res = CORE::shutdown $this->{socket}, 1;
}
sub read{
  my($this) = @_;
  my $buff = "";
  my $rb = Net::SSLeay::read($this->{ssl}, 16384);
  ssl_check_die("SSL read");
  unless(
    (defined $rb && length($rb) > 0) or 
    $! eq "resource temporarily unavailable" or
    $!{EAGAIN} or 
    $!{EINTR} or 
    $!{EWOULDBLOCK} or 
    $!{ENOBUFS}
  ){
    die "Done";
  }
  if(defined $rb && length($rb) > 0) { 
    $buff .= $rb;
  }
  return $buff;
}
sub close{
  my($this, $string) = @_;
  if(defined $this->{ssl}){
    Net::SSLeay::free ($this->{ssl});
    delete $this->{ssl};
  }
  if(defined $this->{ctx}){
    Net::SSLeay::CTX_free ($this->{ctx});
    delete $this->{ctx};
  }
  if(defined $this->{socket}){
    delete $this->{socket};
  }
}
sub DESTROY{
  my($this) = @_;
  if($ENV{POSDA_DEBUG}){
    print STDERR "Destroying $this\n";
  }
  $this->close();
}
1;
