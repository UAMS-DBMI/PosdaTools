package Dispatch::DB::Server;
#$Source: /home/bbennett/pass/archive/Posda/include/Dispatch/DB/Server.pm,v $
#$Date: 2012/01/18 18:29:16 $
#$Revision: 1.7 $
use strict;
use FileHandle;
use Socket;
use Fcntl;
use DBI;
use Debug;

my $dbg = sub {
  my($text) = @_;
  print STDERR $text;
};
my $Dbh;

use vars qw( $client $dir $log $login $host $user $db $server $ConId %Queries);

sub Log {
  my($message) = @_;
  flock($log, 2);
  $log->print("$$|$ConId|$message\n");
  flock($log, 8);
}

sub LogIfDebug {
  my($message) = @_;
  unless($ENV{DEBUG}){
    return;
  }
  flock($log, 2);
  $log->print("$$|$ConId|$message\n");
  flock($log, 8);
}

sub LogList{
  flock($log, 2);
  my $i;
  for $i (@_){
    $log->print("$$|$ConId|$i\n");
  }
  flock($log, 8);
}

sub LogDebug{
  my($name, $thing) = @_;
  flock($log, 2);
  $log->print("$name = ");
  Debug::GenPrint($log, $thing, 1);
  $log->print("\n");
  flock($log, 8);
}


my $Dispatch = {
  commit => sub {
    my($socket, $query, $Input) = @_;
    $Dbh->commit;
    Log("commit");
    $socket->print("committed\n\n");
    Log(">committed");
    return 1;
  },
  rollback => sub {
    my($socket, $query, $Input) = @_;
    $Dbh->rollback;
    Log("rollback");
    $socket->print("rollback complete\n\n");
    Log(">rolledback");
    return 1;
  },
  ping => sub {
    my($socket, $query, $Input) = @_;
    if($Dbh){
      my $res = $Dbh->ping;
      $socket->print("ping: $res\n\n");
      unless($res){
        return -1;
      }
      return 1;
    } else {
      $socket->print("ping: 0\n\n");
      return -1;
    }
  },
  Reset => sub {
    return -1;
  },
  define_query => sub {
    my($socket, $query, $Input) = @_;
    if($query eq "") {
    print $socket "ERROR: Null named query defined\n\n";
    return 1;
    }
    $Queries{$query} = join("\n", @$Input);
    print $socket "defined query: $query\n\n";
    return 1;
  },
  list_queries => sub {
    my($socket, $query, $Input) = @_;
    my $count = 0;
    for my $query (keys %Queries){
      $count += 1;
      print $socket "$query\n";
      Log("$query\n");
    }
    print $socket "\n";
      Log("\n");
    return 1;
  },
  list_query => sub {
    my($socket, $query, $Input) = @_;
    unless(exists $Queries{$query}){
      print $socket "Query $query doesn't exist\n\n";
      return 1;
    }
    print $socket "$Queries{$query}\n\n";
  },
  select => sub {
    my($socket, $query, $Input) = @_;
    unless(exists $Queries{$query}){
      print $socket "ERROR: $query is unknown\n\n";
      return 1;
    }
    my $query_text = $Queries{$query};
    my $q = $Dbh->prepare($query_text);
    unless(defined $q){
      my $error = $Dbh->errstr();
      unless($error){
        $error = "prepare failed with on errstr";
      }
      $error =~ s/([^\w])/"%" . unpack("H2", $1)/eg;
      print $socket "ERROR: $error\n\n";
      return 1;
    }
    for my $i (@$Input) {
      $i =~ s/%{..}/pack("c",hex($1))/ge;
    };
    my $res = $q->execute(@$Input);
    unless($res){
      my $error = $Dbh->errstr();
      $error =~ s/([^\w])/"%" . unpack("H2", $1)/eg;
      print $socket "ERROR: $error\n\n";
      return 1;
    }
    while(my $h = $q->fetchrow_hashref()){
      for my $key (keys %$h){
        my $value = $h->{$key};
        $key =~ s/([^\w])/"%" . unpack("H2", $1)/eg;
        unless(defined $value) { $value = "" }
        print $socket "$key=$value|";
      }
      print $socket "\n";
    }
    print $socket "\n";
    return 1;
  },
  DEBUG => sub {
    my($socket, $query, $Input) = @_;
    if($Dbh->{AutoCommit}){
      $socket->print("AutoCommit\n");
    } else {
      $socket->print("No AutoCommit\n");
    }
    if($Dbh->{RaiseError}){
      $socket->print("RaiseError\n");
    } else {
      $socket->print("No RaiseError\n");
    }
    $socket->print("\n");
    return 1;
  },
  EXIT => sub {
    exit();
  },
  CLOSE => sub {
    return 0;
  },
};
#
#  Transaction Subroutine
#
sub Transaction {
  my($socket) = @_;
  $socket->autoflush;
  my @Input;
  my $line;
  socket_loop:
  while (defined($line = $socket->getline)){
    chomp $line;
    $line =~ s/\r//;
    #Log("Line:\"$line\"\n");
    if(($line eq "") && ($#Input >= 0)){
      #Log("*****************************************");
      my $Command = shift @Input;
      #Log("Processing New Command: $Command");
      #my $foo;
      #for $foo (@Input){
        #Log("$foo");
      #}
      #Log("*****************************************");
      if($Command =~ /^([^?]+)\?(.*)/){
        my $com = $1;
        my $param = $2;
        if(exists $Dispatch->{$com}){
          Log("$com?$param");
          LogList(@Input);
          return(&{$Dispatch->{$com}}($socket, $param, \@Input));
        } else {
          Log("ERROR - $com is unknown");
          $socket->print("ERROR\n");
          $socket->print("Unknown command: $com\n\n");
          return 1;
        }
      } elsif($Command =~ /^(.*)$/){
        my $com = $1;
        my $param = undef;
        if(exists $Dispatch->{$com}){
          Log("$com");
          LogList(@Input);
          return(&{$Dispatch->{$com}}($socket, $param, \@Input));
        } else {
          Log("ERROR - $com is unknown");
          $socket->print("ERROR\n");
          $socket->print("Unknown command: $com\n\n");
          return 1;
        }
      } else {
        Log("ERROR - $Command didn't match");
        $socket->print("ERROR\n");
        $socket->print("Unmatched command: $Command\n\n");
        return 1;
      }
    } elsif ($line ne "") {
      push (@Input, $line);
    } else {
      #error
    }
  }
  return 0;
}

#
# The loop in the (grand)child
#
sub ChildLoop{
  my($port) = @_;
  #listen on the server socket
  listen($server, SOMAXCONN) or die "listen: $!";
  unless(-d "$dir"){
    mkdir $dir, 0755;
  }
  unless(-d "$dir"){
    print STDERR "Unable to make directory $dir\n";
    exit;
  }
  unless(-f "$dir/lock_$port"){
    open LOCK, ">$dir/lock_$port";
    binmode LOCK;
    print LOCK "Lock\n";
    close LOCK;
  }
  unless(-f "$dir/lock_$port"){
    print STDERR "Unable to create lock file $dir/lock_$port\n";
    exit;
  }
  $log = FileHandle->new(">>$dir/Log");
  $log->binmode();
  
  # Recovery Loop Starts HERE
  recover:
  while(1){
    #Establish Database Connection
    $Dbh = DBI->connect("dbi:Pg:dbname=$db;host=$host;user=$user", "", "");
    unless($Dbh){
      Log("Connect failed");
      sleep 25;
      next recover;
    }
    $Dbh->{AutoCommit} = 0;

    #  The real loop starts here
    acceptance:
    while(1){
      my $i;
      unless(open LOCK, ">>$dir/lock_$port"){
        print STDERR "Unable to open lock file $dir/lock_$port\n";
        exit;
      }
      binmode LOCK;
      flock(LOCK, 2);
      my $paddr = accept($client, $server);
      flock(LOCK, 8);
      close LOCK;
      if(!$paddr){
        print STDERR "$$" . "Error $? to accept\n";
        next acceptance;
      }
      $log = FileHandle->new(">>$dir/Log");
      fcntl $client, &F_SETFD, 1;
      my $iaddr;
      my $rport;
      my $raddr;
      ($rport, $iaddr) = unpack_sockaddr_in($paddr);
      $raddr = inet_ntoa($iaddr);
      my $StartTime;
      if($raddr eq "127.0.0.1"){
        $ConId = "";
        Log("Accept from port $rport on $raddr");
        $StartTime = time();
      } else {
        Log("Accept from port $rport on $raddr rejected");
        close $client;
        next acceptance;
      }
      my $status;
      my $querystart = $StartTime;
      while(($status = Transaction($client)) == 1){
        my $Now = time();
        my $QueryTime = $Now - $querystart;
        Log("Query time: $QueryTime Seconds");
        $querystart = $Now;
      }
      my $Now = time();
      my $QueryTime = $Now - $querystart;
#      Log(" took $QueryTime Seconds");
      $Dbh->rollback;  # Roll back any uncommitted transactions
      Log("Roll back any uncommited transactions");
      $Now = time();
      my $TransTime = $Now - $StartTime;
      Log("Socket Close after $TransTime Seconds ($Now)");
      $ConId = "";
      if( $status == -1){
        last acceptance;
      }
      Log("Closing client connection");
      close $client;
    }
    Log("Disconnect and Retry");
    # Here if we have exited the inner loop - do recovery
    # Means database connection is lost
    $Dbh->disconnect();
    close $client;
  }
}
1;
