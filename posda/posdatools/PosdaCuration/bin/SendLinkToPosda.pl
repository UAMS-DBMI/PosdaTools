#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use DBI;
use IO::Socket;
unless($#ARGV == 7){
  die "usage: $0 <host> <port> <rel_path> <digest> <collection> <site> <subj> <rcv_timestamp>";
}

my $host = $ARGV[0];
my $port = $ARGV[1];
my $rel_path = $ARGV[2];
my $digest = $ARGV[3];
my $collection = $ARGV[4];
my $site = $ARGV[5];
my $subj = $ARGV[6];
my $rcv_ts = $ARGV[7];

#fork and exit;
my $server = IO::Socket::INET->new(
  PeerAddr => $host,
  PeerPort => $port,
  Proto => 'tcp',
  Blocking => 1,
  Timeout => 1,
);
unless ($server){
  die "Unable to Bind Connect $!";
}
print $server "command: import_file\nrelativepath: $rel_path\n" .
  "digest: $digest\ncollection: $collection\n" .
  "site: $site\nsubject: $subj\nreceive_date: $rcv_ts\n\n";
my %rsp;
while(my $line = <$server>){
  chomp $line;
  if($line =~ /^([^:]+):\s*(.*)$/){
    my $k = $1; my $v = $2;
    $rsp{$k} = $v;
  }
}
unless(exists $rsp{status}) {
  die "no status in response";
}
unless($rsp{status} eq "OK"){
  unless(defined $rsp{message}){
    die "Status: $rsp{status}";
  }
  die "Error: $rsp{message}";
}
print "Sent OK\n";
