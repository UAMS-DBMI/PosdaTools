#!/usr/bin/perl -w
use strict;
use IO::Socket;
my $usage = <<'EOF';
ListLocks.pl <host> <port>
EOF
unless($#ARGV == 1) { die $usage };
my $host = $ARGV[0];
my $port = $ARGV[1];
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
print $sock "ListLocks\n\n";
print "Response:\n";
my @records;
while(my $line = <$sock>){
  chomp $line;
  my @fields = split(/\|/, $line);
  my $hash;
  for my $i (@fields) {
    if($i =~ /^(.*)=(.*)$/){
      my $k = $1; my $v = $2;
      $hash->{$k} = $v;
    }
  }
  push(@records, $hash);
}
for my $r (@records){
  print $r->{"Lock: Id"} . " $r->{Session} $r->{User}\n";
}
