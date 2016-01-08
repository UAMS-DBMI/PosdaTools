package Dispatch::DB::ChildIf;
#$Source: /home/bbennett/pass/archive/Posda/include/Dispatch/DB/ChildIf.pm,v $
#$Date: 2012/03/05 15:36:01 $
#$Revision: 1.2 $
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
  print STDERR "$message\n";
}

sub LogIfDebug {
  my($message) = @_;
  unless($ENV{DEBUG}){
    return;
  }
  Log($message)
}

sub LogList{
  my $i;
  for $i (@_){
    Log($i);
  }
}

sub LogDebug{
  my($name, $thing) = @_;
  Log("$name = ");
  Debug::GenPrint($dbg, $thing, 1);
  Log("\n");
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
      #Log("$query\n");
    }
    print $socket "\n";
      #Log("\n");
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
    my $start_execute = time;
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
    my $execute_time = time - $start_execute;
    Log("Query: $query took $execute_time seconds");
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
          return(&{$Dispatch->{$com}}(\*STDOUT, $param, \@Input));
        } else {
          Log("ERROR - $com is unknown");
          print STDOUT "ERROR\n";
          print STDOUT "Unknown command: $com\n\n";
          return 1;
        }
      } elsif($Command =~ /^(.*)$/){
        my $com = $1;
        my $param = undef;
        if(exists $Dispatch->{$com}){
          Log("$com");
          LogList(@Input);
          return(&{$Dispatch->{$com}}(\*STDOUT, $param, \@Input));
        } else {
          Log("ERROR - $com is unknown");
          print STDOUT "ERROR\n";
          print STDOUT "Unknown command: $com\n\n";
          return 1;
        }
      } else {
        Log("ERROR - $Command didn't match");
        print STDOUT "ERROR\n";
        print STDOUT "Unmatched command: $Command\n\n";
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
sub Loop{
  #Establish Database Connection
  my $connect_string = "dbi:Pg:dbname=$db;host=$host;user=$user";
  $Dbh = DBI->connect($connect_string, "", "");
  unless($Dbh){
    Log("Connect failed");
    exit;
  }
  $Dbh->{AutoCommit} = 0;

  my $status;
  my $StartTime = time;
  while(($status = Transaction(\*STDIN)) == 1){ }
  $Dbh->rollback;  # Roll back any uncommitted transactions
  Log("Roll back any uncommited transactions");
  my $TransTime = time - $StartTime;
  Log("Close after $TransTime Seconds");
  $Dbh->disconnect;
}
1;
