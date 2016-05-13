#!/usr/bin/perl -w
#
use strict;
package PosdaCuration::ExtractionManagerIf;
use Storable;
use IO::Socket::INET;
use Dispatch::Select;

sub new{
  my($class, $port, $user, $session, $pid, $async) = @_;
  my $this = {
    port => $port,
    user => $user,
    session => $session,
    pid => $pid,
    async => $async,
  };
  return bless $this, $class;
}
my $check_async = sub {
  my($this, $resp_hand) = @_;
  if($this->{async}){
    unless(defined($resp_hand) && ref($resp_hand) eq "CODE"){
      die "no response handler in async mode";
    }
  } elsif(defined $resp_hand) {
    print STDERR "Response handler defined in sync mode - ???\n";
  }
};
my $do_trans = sub{
  my($this, $lines, $resp_hand) = @_;
  if($this->{async}){
    $this->SimpleAsyncTransaction($this->{port}, $lines, $resp_hand);
  } else {
    return $this->SimpleSyncTransaction($this->{port}, $lines);
  }
};
sub LockForEdit{
  my($this, $col, $site, $subj, $for, $resp_hand) = @_;
  &$check_async($this, $resp_hand);
  my @lines;
  push @lines, "LockForEdit";
  push @lines, "Collection: $col";
  push @lines, "Site: $site";
  push @lines, "Subject: $subj";
  push @lines, "Session: $this->{session}";
  push @lines, "User: $this->{user}";
  push @lines, "Pid: $this->{pid}";
  push @lines, "For: $for";
  return &$do_trans($this, \@lines, $resp_hand);
}
sub ReleaseLockWithNoEdit{
  my($this, $id, $resp_hand) = @_;
  &$check_async($this, $resp_hand);
  my @lines;
  push @lines, "ReleaseLockWithNoEdit";
  push @lines, "Id: $id";
  push @lines, "Session: $this->{session}";
  push @lines, "User: $this->{user}";
  push @lines, "Pid: $this->{pid}";
  return  &$do_trans($this, \@lines, $resp_hand);
}
sub ApplyEdits{
  my($this, $id, $caption, $cmd_file, $resp_hand) = @_;
  &$check_async($this, $resp_hand);
  my @lines;
  push @lines, "ApplyEdits";
  push @lines, "Id: $id";
  push @lines, "Caption: $caption";
  push @lines, "Commands: $cmd_file";
  push @lines, "Session: $this->{session}";
  push @lines, "User: $this->{user}";
  push @lines, "Pid: $this->{pid}";
  return &$do_trans($this, \@lines, $resp_hand);
}
sub SendExtraction{
  my($this, $col, $site, $subj, $host, $port, $calling, $called, $caption,
    $resp_hand) = @_;
  &$check_async($this, $resp_hand);
  my @lines;
  push @lines, "SendAllFiles";
  push @lines, "Collection: $col";
  push @lines, "Site: $site";
  push @lines, "Subject: $subj";
  push @lines, "Host: $host";
  push @lines, "Port: $port";
  push @lines, "CallingAeTitle: $calling";
  push @lines, "CalledAeTitle: $called";
  push @lines, "Session: $this->{session}";
  push @lines, "User: $this->{user}";
  push @lines, "Pid: $this->{pid}";
  push @lines, "For: $caption";
  return &$do_trans($this, \@lines, $resp_hand);
}
##########################
# Sync communications
sub SimpleSyncTransaction{
  my($this, $port, $lines, $response) = @_;
  my $sock;
  unless(
    $sock = IO::Socket::INET->new(
      PeerAddr => "localhost",
      PeerPort => $port,
      Proto => 'tcp',
      Timeout => 1,
      Blocking => 1,
    )
  ){
    return [
      "Error ($!): Couldn't contact Transaction Manager",
    ];
  }
  my $text = join("\n", @$lines) . "\n\n";
  print $sock $text;
  my @lines;
  while(my $line = <$sock>){
    chomp $line;
    push @lines, $line;
  }
  close $sock;
  return \@lines;
}
##########################
# Async communications
sub SimpleAsyncTransaction{
  my($this, $port, $lines, $response) = @_;

  my $sock;
  unless(
    $sock = IO::Socket::INET->new(
     PeerAddr => "localhost",
     PeerPort => $port,
     Proto => 'tcp',
     Timeout => 1,
     Blocking => 0,
    )
  ){
    print "-> Aborting, socket could not be opened!\n";
    return 0;
  }
  my $text = join("\n", @$lines) . "\n\n";
  Dispatch::Select::Socket->new($this->WriteTransactionParms($text, $response),
    $sock)->Add("writer");
}
sub WriteTransactionParms{
  my($this, $text, $response) = @_;
  my $offset = 0;
  my $sub = sub {
    my($disp, $sock) = @_;
    my $length = length($text);
    if($offset == length($text)){
      $disp->Remove;
      Dispatch::Select::Socket->new($this->ReadTransactionResponse($response),
        $sock)->Add("reader");
    } else {
      my $len = syswrite($sock, $text, length($text) - $offset, $offset);
      if($len <= 0) {
        print STDERR "Wrote $len bytes ($!)\n";
        $offset = length($text);
      } else { $offset += $len }
    }
  };
  return $sub;
}
sub ReadTransactionResponse{
  my($this, $response) = @_;
  my $text = "";
  my @lines;
  my $sub = sub {
    my($disp, $sock) = @_;
    my $len = sysread($sock, $text, 65536, length($text));
    if($len <= 0){
      if($text) { push @lines, $text }
      $disp->Remove;
      &$response(\@lines);
    } else {
      while($text =~/^([^\n]*)\n(.*)$/s){
        my $line = $1;
        $text = $2;
        push(@lines, $line);
      }
    }
  };
  return $sub;
}
1;
