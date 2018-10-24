#!/usr/bin/perl -w
#
#Copyright 2011, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Socket;
use FileHandle;
use Fcntl;
$SIG{PIPE} = "IGNORE";
$SIG{CHLD} = "IGNORE";

my $usage = "usage: $0 <port> <root> <seq_file>";
unless($#ARGV == 2) { die $usage }

my $port = $ARGV[0];
my $root = $ARGV[1];
my $seq_file = $ARGV[2];
unless(-f $seq_file) {
  open FILE, ">$seq_file" or die "can't open seq_file: $seq_file";
  print FILE "1\n";
  close FILE;
}

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

my $server = OpenServer($port);
my $client = new FileHandle;
acceptance:
while (my $paddr = accept($client, $server)){
  unless($paddr){
    print "Error: $? to accept\n";
    next acceptance;
  }
  open FILE, "<$seq_file" or die "can't open seq file: $seq_file\n";
  my $seq = <FILE>;
  close FILE;
  chomp $seq;
  $seq += 1;
  open FILE, ">$seq_file" or die "can't open seq file: $seq_file\n";
  print FILE "$seq\n";
  close FILE;
  $client->print("$root.$seq");
  $client->close();
}
