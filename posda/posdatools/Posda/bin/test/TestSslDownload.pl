#!/usr/bin/perl -w
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use strict;
use Dispatch::SSLCLient;
use Dispatch::Select;
use IO::Socket::INET;
use Digest::MD5;

# TestSslDownload.pl <host> <port> <uri> <avg_line_size> <num_lines>

sub MakeWriter{
  my($s, $ssl, $c) = @_;
  my $foo = sub {
    my($d, $sock) = @_;
    my $len_to_write = length($c);
    my $wrote = $ssl->write($c);
    if($wrote < 0) { return }
    if($wrote == $len_to_write){
      my $closer = MakeCloser($s, $ssl);
      my $nd = Dispatch::Select::Socket->new($closer, $s);
      $nd->Add("writer");
    }
  };
  return $foo;
}
$Net::SSLeay::slowly = 1;
sub MakeCloser{
  my($s, $ssl, $c) = @_;
  my $foo = sub {
    my($d, $sock) = @_;
    $ssl->close_write();
    $d->Remove("writer");
    my $reader = MakeReader($sock, $ssl);
    my $read_selector = Dispatch::Select::Socket->new($reader, $sock);
    $read_selector->Add("reader");
  };
  return $foo;
}
sub MakeSSLer{
  my($s, $ssl, $c) = @_;
  my $foo = sub {
    my ($d, $sock) = @_;
    unless($ssl->connect($s)) { return }
    $d->Remove("writer");
    $d->Remove("reader");
    my $writer = MakeWriter($s, $ssl, $c);
    my $nd = Dispatch::Select::Socket->new($writer, $s);
    $nd->Add("writer");
  };
  return $foo;
}
sub MakeReader{
  my($s, $ssl) = @_;
  my $foo = sub {
    my($d, $sock) = @_;
    my $buff;
    my $string;
    eval { $string = $ssl->read() };
    if ($@){
      $d->Remove("reader");
      $ssl->close();
      return;
    }
    print $string;
  };
  return $foo;
}
{ unless($#ARGV >= 2){ die 
    "usage $0 <host> <port> <uri> <avg_line_size> <num_lines>" }
  my $host = $ARGV[0];
  my $port = $ARGV[1];
  my $url = $ARGV[2];
  my $avg_line_size = $ARGV[3];
  my $num_lines = $ARGV[4];
  unless(defined $avg_line_size) { $avg_line_size = 100 }
  unless(defined $num_lines) { $num_lines = 100 }
  my $method = "POST";
  my $content = "len=$avg_line_size&num_lines=$num_lines&";
  my $content_length = length($content);
  my $content_type = "application/x-www-form-urlencoded";
  my $command_string = 
  "POST $url HTTPS/1.0\n" .
  "HOST: $host\n" .
  "ACCEPT: */*\n" .
  "CONTENT-TYPE: $content_type\n" .
  "CONTENT-LENGTH: $content_length\n\n" .
  $content;

  my $socket = IO::Socket::INET->new(
    PeerAddr => $host,
    PeerPort => $port,
    AutoFlush => 1,
    Blocking => 0,
    Proto => 'tcp' ) or die "can't connect to https server at wustl";

  my $ssl = Dispatch::SSLClient->new();
  my $ssler = MakeSSLer($socket, $ssl, $command_string);
  my $write_selector = Dispatch::Select::Socket->new($ssler, $socket);
  $write_selector->Add("writer");
  $write_selector->Add("reader");
  Dispatch::Select::Dispatch();
}

