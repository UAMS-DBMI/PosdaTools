#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use DBI;
use FileHandle;
use Socket;
use Fcntl;
use Term::ReadKey;
use Dispatch::DB::Server;

unless($#ARGV == 5){
  die "usage: $0 <dir> <db> <host> <user> <port> <num_servers>"
}
unless(-d $ARGV[0]){ die "$ARGV[0] is not a directory" }

$Dispatch::DB::Server::dir = $ARGV[0];
$Dispatch::DB::Server::db = $ARGV[1];
$Dispatch::DB::Server::host = $ARGV[2];
$Dispatch::DB::Server::user = $ARGV[3];
my $port = $ARGV[4];
my $num_servers = $ARGV[5];

#my $db_pass = DBI->connect(
#  "dbi:Pg:dbname=$Dispatch::DB::Server::db;" .
#  "host=$Dispatch::DB::Server::host;" .
#  "user=$Dispatch::DB::Server::user", "", "");
#unless($db_pass) { die "couldn't connect to DB: $Dispatch::DB::Server::db " .
#  "$Dispatch::DB::Server::host " .
#  "$Dispatch::DB::Server::user" }
#$db_pass->disconnect;
$Dispatch::DB::Server::server = FileHandle->new;
$Dispatch::DB::Server::client = FileHandle->new;

fork and exit;
my $proto = getprotobyname( 'tcp' );

#Child sets up and binds sockets .....
if ( !(socket($Dispatch::DB::Server::server, PF_INET, SOCK_STREAM, $proto)) ) {
  print STDERR "Unable to create socket\n" ;
  exit;
}
setsockopt($Dispatch::DB::Server::server, SOL_SOCKET, SO_REUSEADDR, 1);
unless(-d $Dispatch::DB::Server::dir){
  print STDERR "Directory $Dispatch::DB::Server::dir doesn't exist\n";
  exit;
}
unless ( 
  bind($Dispatch::DB::Server::server, sockaddr_in($port, INADDR_ANY))
){
  print STDERR "Unable to Bind Socket $!\n";
  exit;
}
# so socket survives fork
fcntl $Dispatch::DB::Server::server, &F_SETFD, 0;
#fcntl $Dispatch::DB::Server::log, &F_SETFD, 0;

# pass it off to kids
my $i;
for $i (0 .. $num_servers){
  my $child;
  unless($child = fork){
    Dispatch::DB::Server::ChildLoop($port);
    exit;
  }
}
