#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/TestSslUpload.pl,v $
#$Date: 2010/12/21 12:53:38 $
#$Revision: 1.4 $
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
use FileHandle;
use Digest::MD5;

# TestSslUpload.pl <host> <port> <uri> <file>

sub MakeHeaderWriter{
  my($s, $ssl, $c, $f) = @_;
  my $foo = sub {
    my($d, $sock) = @_;
    my $len_to_write = length($c);
    my $wrote = $ssl->write($c);
    if($wrote < 0) { return }
    if($wrote == $len_to_write){
      my $cc = MakeCloserStarter($s, $ssl);
      my $cb = Dispatch::Select::Background->new($cc);
      my($fr, $fw) = MakeFileCopierComponents($s, $ssl, $f, $cb);
      my $nd = Dispatch::Select::Socket->new($fw, $s);
      my $ne = Dispatch::Select::Background->new($fr);
      $nd->Add("writer");
      $ne->queue();
    }
  };
  return $foo;
}
sub MakeFileCopierComponents{
  my($s, $ssl, $f, $rd) = @_;
  my $fh = FileHandle->new("<$f");
  unless($fh) { die "couldn't open $f" }
  my @queue;
  my $r_block;
  my $w_block;
  my $cur_buff;
  my $cur_count;
  my $write_error;
  my $write_finished;
  my $fr = sub {
    my($b) = @_;
    if($write_error){
      print STDERR "Stopping reading because of write error\n";
      $r_block = undef;
      return;
    }
    if($#queue > 2){
      $r_block = $b;
      return;
    }
    my $buff;
    my $count = $fh->read($buff, 16384);
    if($count <= 0){
      $r_block = undef;
      $fh->close();
      $write_finished = 1;
      return;
    }
    push(@queue, $buff);
    if($w_block){
      $w_block->Add("writer");
      $w_block = undef;
    }
    if($#queue > 2) {
      $r_block = $b;
      return;
    }
    $b->queue();
  };
  my $fw = sub {
    my($d, $sock) = @_;
    unless(defined $cur_buff){
      unless($#queue >= 0){
        if($write_finished){
          $rd->queue();
        } else {
          $w_block = $d;
        }
        $d->Remove("writer");
        return;
      }
      $cur_buff = shift @queue;
      if($#queue < 2){
        if($r_block) {
          $r_block->queue();
          $r_block = undef;
        }
      }
      $cur_count = 0;
    }
    my $written = $ssl->write(substr($cur_buff, $cur_count));
    if($written <= 0){
      unless($! eq "Resource temporarily unavailable"){
        $write_error = 1;
        print STDERR "Error: \"$!\" on ssl write\n";
        $d->Remove("writer");
      }
      return;
    }
    $cur_count += $written;
    if($cur_count == length($cur_buff)){
      $cur_count = 0;
      $cur_buff = undef;
    }
  };
  return ($fr, $fw);
}
sub MakeCloserStarter{
  my($s, $ssl) = @_;
  my $foo = sub {
    my($b) = @_;
    my $r = MakeCloser($s, $ssl);
    my $rb = Dispatch::Select::Socket->new($r, $s);
    $rb->Add("writer");
  };
  return $foo;
}
sub MakeCloser{
  my($s, $ssl) = @_;
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
  my($s, $ssl, $c, $f) = @_;
  my $foo = sub {
    my ($d, $sock) = @_;
    unless($ssl->connect($s)) { return }
    $d->Remove("writer");
    $d->Remove("reader");
    my $writer = MakeHeaderWriter($s, $ssl, $c, $f);
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
{ unless($#ARGV == 3){ die 
    "usage $0 <host> <port> <uri> <file>" }
  my $host = $ARGV[0];
  my $port = $ARGV[1];
  my $uri = $ARGV[2];
  my $file = $ARGV[3];
  unless(-r $file) { die "$file is not readable" }
  my $method = "POST";
  my $content_type = "application/octet-stream";
  open FILE, "<$file" or die "can't open $file";
  my $ctx = Digest::MD5->new();
  $ctx->addfile(*FILE);
  my $digest = $ctx->hexdigest();
  print "computed digest of file: $digest\n";
  seek FILE, 0, 2;
  my $content_length = tell FILE;
  close FILE;
  my $command_string = 
  "POST $uri HTTPS/1.0\n" .
  "HOST: $host\n" .
  "ACCEPT: */*\n" .
  "CONTENT-TYPE: $content_type\n" .
  "CONTENT-LENGTH: $content_length\n\n";

  my $socket = IO::Socket::INET->new(
    PeerAddr => $host,
    PeerPort => 'https(443)',
    AutoFlush => 1,
    Blocking => 0,
    Proto => 'tcp' ) or die "can't connect to https server at wustl";

  my $ssl = Dispatch::SSLClient->new();
  my $ssler = MakeSSLer($socket, $ssl, $command_string, $file);
  my $write_selector = Dispatch::Select::Socket->new($ssler, $socket);
  $write_selector->Add("writer");
  $write_selector->Add("reader");
  Dispatch::Select::Dispatch();
}

