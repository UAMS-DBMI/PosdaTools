#!/usr/bin/perl -w
use strict;
use IO::Socket;
my $usage = <<'EOF';
UnlockDirectory.pl <host> <port> <id> <session> <user> <pid>
EOF
unless($#ARGV == 5) { die $usage };
my $host = $ARGV[0];
my $port = $ARGV[1];
my $id = $ARGV[2];
my $session = $ARGV[3];
my $user = $ARGV[4];
my $pid = $ARGV[5];
my $sock;
unless(
  $sock = IO::Socket::INET->new(
    PeerAddr => "localhost",
    PeerPort => $port,
    Proto => 'tcp',
    Timeout => 1,
    Blocking => 1,
  )
){ die "Couldn't connect to $host:$port" }
print $sock "ReleaseLockWithNoEdit\n";
print $sock "Id: $id\n";
print $sock "Session: $session\n";
print $sock "User: $user\n";
print $sock "Pid: $pid\n\n";
print "Response:\n";
while(my $line = <$sock>){
  print $line;
}
