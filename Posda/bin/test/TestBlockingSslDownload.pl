#!/usr/bin/perl -w
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use strict;
use Dispatch::Select;
use IO::Socket::INET;
use Digest::MD5;

# TestNewSslDownload.pl <host> <port> <uri> <avg_line_size> <num_lines>

unless($#ARGV >= 2){ die 
    "usage $0 <host> <port> <uri> <avg_line_size> <num_lines>" }

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
  Blocking => 1,
  Proto => 'tcp' ) or die "can't connect to https server at wustl";

my $ctx = Net::SSLeay::CTX_new() or die("Failed to create SSL_CTX $!");
Net::SSLeay::CTX_set_options($ctx, &Net::SSLeay::OP_ALL)
  and ssl_check_die("ssl ctx set options");
my $ssl = Net::SSLeay::new($ctx) or die_now("Failed to create SSL $!");

Net::SSLeay::set_fd($ssl, fileno($socket));
my $res = Net::SSLeay::connect($ssl) 
  and Net::SSLeay::die_if_ssl_error("ssl connect");

my $written = 0;
my $len = length($command_string);
while($written < length($command_string)){
print "writing substr(\$command_string, $written)\n";
  my $writ = Net::SSLeay::write($ssl, substr($command_string, $written));
  if($writ <= 0) {
    my $len = length($command_string);
    die "premature write failure: $! ($written of $len)";
  }
  $written += $writ;
}
$res = CORE::shutdown $socket, 1;
while(my $rd = Net::SSLeay::read($ssl, 16384)){
  print "$rd";
}
Net::SSLeay::free($ssl);
Net::SSLeay::CTX_free($ctx);
$socket->close();
