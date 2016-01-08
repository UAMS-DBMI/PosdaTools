#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/UIDServer.pl,v $
#$Date: 2008/04/30 19:17:34 $
#$Revision: 1.2 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use DBI;
use Socket;
use FileHandle;
use Fcntl;
$SIG{PIPE} = "IGNORE";
$SIG{CHLD} = "IGNORE";
my $db = DBI->connect("dbi:Pg:dbname=free_uids", "", "");

sub OpenServer{
  my $port = shift;
  my $server = new FileHandle;
  my $proto = getprotobyname( 'tcp' );
  if ( !(socket($server, PF_INET, SOCK_STREAM, $proto)) ) {
    return( "Unable to create socket" );
  }   
  setsockopt($server, SOL_SOCKET, SO_REUSEADDR, 1);
  if ( !(bind($server, sockaddr_in($port, INADDR_ANY))) ) {
    return( "Unable to bind socket" );
  }   
  listen($server, SOMAXCONN) or die "listen: $!";
  my $paddr;
  fcntl $server, &F_SETFD, 1;
  return $server
}

my $port = $ARGV[0];
my $server = OpenServer($port);
my $client = new FileHandle;
acceptance:
while (my $paddr = accept($client, $server)){
  unless($paddr){
    print "Error: $? to accept\n";
    next acceptance;
  }
  my ($port, $iaddr) = unpack_sockaddr_in($paddr);
  my $remote_addr = inet_ntoa($iaddr);
  my $command;
  my %parms;
  line:
  while(my $line = <$client>){
    chomp $line;
    $line =~ s/\r//g;
    if($line =~ /^\s*$/){
      last;
    }
    if($line =~ /^(\w+):\s*(.*)$/){
      my $key = $1;
      my $value = $2;
      $parms{$key} = $value;
    }
  }
  my $q1 = $db->prepare(
    "insert into assigned_uids(time_assigned, ip_addr) " .
    "values(now(), ?)"
  );
  $q1->execute($remote_addr);
  my $q2 = $db->prepare(
    "insert into uid_request_parms(id, key, value) " .
    "values (currval('assigned_uids_id_seq'), ?, ?)"
  );
  for my $i(keys %parms){
    $q2->execute($i, $parms{$i});
  }
  my $q3 = $db->prepare(
    "select root || '.' ||currval('assigned_uids_id_seq') as uid from uid_root"
  );
  $q3->execute();
  my $hash = $q3->fetchrow_hashref();
  $client->print("$hash->{uid}\n");
  $q3->finish();
  $client->close();
}
