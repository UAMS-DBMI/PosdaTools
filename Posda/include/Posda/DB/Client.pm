#!/usr/bin/perl -w use strict;
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/DB/Client.pm,v $
#$Date: 2012/04/10 14:14:45 $
#$Revision: 1.9 $
#
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use IO::Socket;
use Errno qw(EINTR EIO :POSIX);
{
  package Posda::DB::Client;
  use IPC::Open3;
  use Symbol 'gensym';
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpObj" );
  sub new{
    my($class, $session, $path, $host, $db, $user) = @_;
    my $this = Posda::HttpObj->new($session, $path);
    $this->{host} = $host;
    $this->{db} = $db;
    $this->{user} = $user;
    $this->{resp_obj_name} = $this->parent->{path};
    $this->{State} = "NotConnected";
    bless $this, $class;
    return $this->StartHandlers;
  }
  sub set_resp_obj {
    my($this, $resp_obj_name) = @_;
    $this->{resp_obj_name} = $resp_obj_name;
  }
  sub clear_to_send{
    my($this) = @_;
    if($this->{State} eq "ClearToSend"){
      return 1;
    }
  }
  sub ctrl_c{
    my($this) = @_;
    if($this->{child_pid}){
      return kill 2, $this->{child_pid};
    }
    return undef;
  }
  sub StartHandlers{
    my($this) = @_;
    my $reader = sub {
      my($disp, $sock) = @_;
      unless($this->{State} eq "AwaitingResponse"){
        print STDERR "$this->{path}: " .
          "selecting true when not awaiting response\n";
        $this->Abort($sock, "selecting true when not awaiting response");
        return;
      }
      unless(defined $this->{buff}) { $this->{buff} = "" }
      my $bytes = $sock->sysread($this->{buff}, 1024, length($this->{buff}));
      if($bytes < 0){
        print STDERR "$this->{path}: Premature end of read ($!)\n";
        $this->Abort($sock, "premature end of read");
        return;
      }
      unless($bytes){
        unless(($! == &Errno::EAGAIN) || ($! == &Errno::EWOULDBLOCK)){
          print STDERR "$this->{path}: undefined or 0 with $!\n";
          $this->Abort($sock, "$!");
        }
        return;
      }
      if(length($this->{buff}) > 0){
        while($this->{buff} =~ /^([^\n]+)\n(.*)$/s){
          my $line = $1;
          my $remaining = $2;
          $this->HandleReceivedLine($line);
          $this->{buff} = $remaining;
        }
        if($this->{buff} eq "\n") {
          $this->{buff} = "";
          $this->ResponseComplete($sock);
        }
      }
    };
    my $writer = sub {
      my($disp, $sock) = @_;
      my $len_written;
      my $len_to_write;
      if($this->{State} eq "WaitingToSendMessage"){
        $len_to_write = length($this->{MessagePending});
        $len_written = $sock->syswrite($this->{MessagePending});
        $this->AwaitResponse();
      } else {
        print STDERR "$this->{path}: invalid state ($this->{State} in " .
          "write_handler\n";
        $this->Abort($sock, "invalid state ($this->{State} in write handler");
      }
      unless($len_written = $len_to_write){
        print STDERR "$this->{path}: Really ought to handle incomplete " .
          "writes - but it doesn't\n";
        $this->Abort($sock, "Lame implementation doesn't handle " .
          "incomplete writes");
      }
      $this->{write_disp}->Remove("writer");
    };
    my $log_buff = "";
    my $logger = sub {
      my($disp, $sock) = @_;
      my $count = $sock->sysread($log_buff, 1024, length($log_buff));
      if($count <= 0){
        print STDERR "Error ($!) ($count) reading Log\n";
        if($log_buff) { push @{$this->{Log}}, $log_buff }
        push(@{$this->{Log}}, "Error reading STDERR of child\n");
        $disp->Remove;
        print STDERR "Error reading STDERR of child\n";
        $this->Abort($sock, "EOF on log\n");
        return;
      }
      while($log_buff =~ /^([^\n]+)\n(.*)$/s){
        my $line = $1;
        $log_buff = $2;
        push(@{$this->{Log}}, $line);
      }
    };
#    my $fh = IO::Socket::INET->new(
#      PeerAddr => $this->{host},
#      PeerPort => $this->{port},
#      Prototol => 'tcp',
#      Blocking => 0,
#      Timeout => 10
#    );
#    unless($fh) { 
#      print STDERR "can't connect to $this->{host}, $this->{port}\n";
#      return undef;
#    }
    my($from, $to, $err);
    $err = gensym;  #  to compensate for bug in IPC::Open3
    my $cmd = "ChildIf.pl $this->{db} $this->{host} $this->{user}";
    my $pid =  open3($to, $from, $err, $cmd);
    $this->{child_pid} = $pid;
    $this->{read_disp} = Dispatch::Select::Socket->new($reader, $from);
    $this->{write_disp} = Dispatch::Select::Socket->new($writer, $to);
    $this->{err_disp} = Dispatch::Select::Socket->new($logger, $err);
    $this->{read_disp}->Add("reader");
    $this->{err_disp}->Add("reader");
    $this->SetClearToSend;
    return $this;
  }
  sub HandleReceivedLine{
    my($this, $line, $sock) = @_;
    unless($this->{State} eq "AwaitingResponse"){
      print STDERR "Received line when in $this->{State} state\n";
      $this->Abort($sock, "received line when in $this->{State} state");
    }
    if($this->{ResponseType} eq "simple"){
      $this->{ResponseLine} = $line;
      return;
    } elsif ($this->{ResponseType} eq "complex"){
      if($this->{MessagePending} =~ /^list_queries/){
        push(@{$this->{ReceivedLines}}, $line);
      }elsif($this->{MessagePending} =~ /^list_query/){
        push(@{$this->{ReceivedLines}}, $line);
      }elsif($this->{MessagePending} =~ /^select/){
        my $obj = $this->get_obj($this->{resp_obj_name});
        $obj->DB_selected_row($line);
      } else {
        print STDERR "unrecognized message pending $this->{MessagePending}" .
          " in HandleReceivedLine\n";
        $this->Abort($sock, "invalid response type $this->{ResponseType}" .
          " in HandleReceivedLine");
      }
    } else {
      print STDERR "invalid response type $this->{ResponseType}" .
        " in HandleReceiveLine\n";
      $this->Abort($sock, "invalid response type $this->{ResponseType}" .
        " in HandleReceiveLine");
    }
  }
  sub ResponseComplete{
    my($this, $sock) = @_;
    unless($this->{State} eq "AwaitingResponse"){
      print STDERR "Response Complete when in $this->{State} state\n";
      $this->Abort($sock, "response complete when in $this->{State} state");
    }
    my $obj = $this->get_obj($this->{resp_obj_name});
    if($this->{ResponseType} eq "simple"){
      if($this->{MessagePending} =~ /^commit/){
        $obj->DB_commit_response($this->{ResponseLine});
      }elsif($this->{MessagePending} =~ /^rollback/){
        $obj->DB_rollback_response($this->{ResponseLine});
      }elsif($this->{MessagePending} =~ /^ping/){
        $obj->DB_ping_response($this->{ResponseLine});
      }elsif($this->{MessagePending} =~ /^define_query/){
        my $query_name;
        unless($this->{ResponseLine} =~ /^defined query: (.*)$/){
          print STDERR "invalid response line $this->{ResponseLine}" .
            " in ResponseComplete for define_query\n";
          $this->Abort($sock, "invalid response line $this->{ResponseLine}" .
            " in ResponseComplete for define_query");
          return;
        }
        my $q_name = $1;
        delete $this->{ResponseLine};
        $obj->DB_query_defined($q_name);
      }else{
        print STDERR "unrecognized message pending $this->{MessagePending}" .
          " in ResponseComplete\n";
        $this->Abort($sock, "invalid response type $this->{ResponseType}" .
          " in ResponseComplete");
      }
    }elsif($this->{ResponseType} eq "complex"){
      if($this->{MessagePending} =~ /^select/){
        $obj->DB_select_complete();
      }elsif($this->{MessagePending} =~ /^list_queries/){
        $obj->DB_listed_queries($this->{ReceivedLines});
      }elsif($this->{MessagePending} =~ /^list_query\?(.*)$/){
        $obj->DB_listed_query($1, $this->{ReceivedLines});
      } else {
        print STDERR "unrecognized message pending $this->{MessagePending}" .
          " in ResponseComplete\n";
        $this->Abort($sock, "invalid response type $this->{ResponseType}" .
          " in ResponseComplete");
      }
    } else {
      print STDERR "invalid response type $this->{ResponseType}" .
        " in ResponseComplete\n";
      $this->Abort($sock, "invalid response type $this->{ResponseType}" .
        " in ResponseComplete");
    }
    $this->SetClearToSend();
  }
  sub AwaitResponse{
    my($this, $response_type) = @_;
    $this->{State} = "AwaitingResponse";
    $this->{ReceivedLines} = [];
  };
  sub SimpleMessage{
    my($this, $message) = @_;
    unless($this->{State} eq "ClearToSend"){
      print STDERR "Simple message called in state $this->{State}\n";
      return undef;
    }
    $this->{MessagePending} = $message;
    $this->{ResponseType} = "simple";
    $this->{State} = "WaitingToSendMessage";
    $this->{write_disp}->Add("writer");
    return 1;
  }
  sub ComplexMessage{
    my($this, $message) = @_;
    unless($this->{State} eq "ClearToSend"){ return undef }
    $this->{MessagePending} = $message;
    $this->{ResponseType} = "complex";
    $this->{State} = "WaitingToSendMessage";
    $this->{write_disp}->Add("writer");
    return 1;
  }
  sub commit{
    my($this) = @_;
    return $this->SimpleMessage("commit\n\n");
  }
  sub rollback{
    my($this) = @_;
    return $this->SimpleMessage("rollback\n\n");
  }
  sub ping{
    my($this) = @_;
    return $this->SimpleMessage("ping\n\n");
  }
  sub define_query{
    my($this, $q_name, $query) = @_;
    if($query =~ /\n/){
#      print STDERR "$this->{path}: query has imbedded nl:\n$query\n";
      $query =~ s/\n/ /gs;
    }
    if($q_name =~ /\n/){
      print STDERR "$this->{path}: query has imbedded nl:\n$query\n";
      $q_name =~ s/\n//gs;
    }
    my $cmd = "define_query?$q_name\n$query";
    return $this->SimpleMessage("$cmd\n\n");
  }
  sub list_queries{
    my($this) = @_;
    return $this->ComplexMessage("list_queries\n\n");
  }
  sub list_query{
    my($this, $q_name) = @_;
    return $this->ComplexMessage("list_query?$q_name\n\n");
  }
  sub select{
    my($this, $q_name, $args) = @_;
    unless($this->{State} eq "ClearToSend"){ return undef }
    my $cmd = "select?$q_name";
    unless(ref($args) eq "ARRAY"){
      $args = [$args];
    }
    for my $i (0 .. $#{$args}) {
      if($args->[$i] =~ /\n/){
        print STDERR "$this->{path}: $i'th arg to $q_name has embedded nl";
        $args->[$i] =~ s/\n/ /g;
      }
      $cmd .= "\n$args->[$i]";
    }
    return $this->ComplexMessage("$cmd\n\n");
  }
  sub DEBUG{
    my($this) = @_;
    unless($this->{State} eq "ClearToSend"){ return undef }
    ###########
    #not implemented
  }
  sub CLOSE{
    my($this) = @_;
    unless($this->{State} eq "ClearToSend"){ return undef }
    ###########
    #not implemented
  }
  sub SetClearToSend{
    my($this) = @_;
    my $obj = $this->get_obj($this->{resp_obj_name});
    unless(defined $obj) { print "Couldn't find $this->{resp_obj_name}\n"; }
    $this->{State} = "ClearToSend";
    if(defined $obj && $obj->can("DB_clear_to_send")){
      $obj->DB_clear_to_send();
    } else {
      my $class = ref($obj);
      print STDERR "$this->{resp_obj_name} ($class) can't DB_clear_to_send\n";
    }
  }
  sub CleanUp{
    my($this) = @_;
    if($this->{read_disp} && $this->{read_disp}->can("Remove")){
      $this->{read_disp}->Remove("reader");
    }
    if($this->{err_disp} && $this->{err_disp}->can("Remove")){
      $this->{err_disp}->Remove("reader");
    }
    if($this->{write_disp} && $this->{write_disp}->can("Remove")){
      $this->{write_disp}->Remove("writer");
    }
    delete $this->{read_disp};
    delete $this->{write_disp};
    delete $this->{err_disp};
    if($this->{child_pid}) {
      kill 9, $this->{child_pid};
      waitpid $this->{child_pid}, 0;
      delete $this->{child_pid};
    }
  }
  sub Abort{
    my($this, $socket, $message) = @_;
    $this->{read_disp}->Remove("reader");
    $this->{err_disp}->Remove("reader");
    $this->{write_disp}->Remove("writer");
    delete $this->{read_disp};
    delete $this->{err_disp};
    delete $this->{write_disp};
    $socket->close();
    waitpid $this->{child_pid}, 0;
    delete $this->{child_pid};
    my $not_obj = $this->get_obj($this->{resp_obj_name});
    if($this->{State} eq "AwaitingClose"){
      $not_obj->DB_CLOSED();
    } else {
      $not_obj->DB_disconnected($message);
    }
  }
  sub DESTROY{
    my($this) = @_;
    if($this->{child_pid}){
      print "$this->{path} in destructor with child process\n";
      kill 9, $this->{child_pid};
      waitpid $this->{child_pid}, 0;
    }
#    print "$this->{path}: DESTROY\n";
    Posda::HttpObj::DESTROY($this);
  }
}
1;
