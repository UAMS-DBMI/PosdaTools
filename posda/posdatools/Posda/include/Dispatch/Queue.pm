#!/usr/bin/perl -w
use strict;
package Dispatch::Queue;
use Errno qw(EINTR EIO :POSIX);
use vars qw( $Next );
$Next = 0;
use vars qw( @ISA );
@ISA = ( "Dispatch::DebugHandler" );
sub new{
  my($class, $high, $low, $debug) = @_;
  my $this = {
    high => $high,
    low => $low,
    queue => [],
    label => $Next,
    finished => 0,
  };
  $Next++;
  bless $this, $class;
  if($ENV{POSDA_DEBUG}){
    print "NEW: $this\n";
  }
  if(defined $debug) { $this->Debug($debug) }
  return $this;
}
sub set_identifier{
   my($this, $id) = @_;
   $this->{identifier} = $id;
}
sub ready_out {
   my($this) = @_;
   if($this->{finished}){
     $this->DebugMsg("read_out returning 0");
     return 0;
   }
   my $in_queue = @{$this->{queue}};
   $this->DebugMsg("checking water_marks $in_queue vs $this->{high}");
   my $ret = ((scalar @{$this->{queue}}) <= $this->{high});
   $this->DebugMsg("returning $ret");
   return ($ret);
}
sub post_output{
  my($this) = @_;
  if(
    defined($this->{output_event})
  ){
    $this->{output_event}->post_and_clear();
    $this->DebugMsg("post_output with event");
    delete $this->{output_event};
  } else {
    $this->DebugMsg("post_output no event");
  }
}
sub queue {
  my($this, $string) = @_;
  $this->DebugMsg("in queue");
  unless (defined $string) { 
    return;  # Quiet - empty strings queued all the time
    print STDERR "Dispatch::Queue::queue string is undefined.\n";
    my($package, $filename, $line, $subroutine, $hasargs,
        $wantarray, $evaltext, $is_require, $hints, $bit_mask);
    for my $i (1 .. 6){
      ($package, $filename, $line, $subroutine, $hasargs,
        $wantarray, $evaltext, $is_require, $hints, $bit_mask) = caller($i);
      print STDERR "\tfrom:$filename, $line\n";
    }
    return;
   
  }
  my $str_len = length($string);
  # don't queue an empty string (you'll regret it later)
  if($str_len == 0){
    return;
  }
  $this->DebugMsg("queueing $str_len bytes");
  if(utf8::is_utf8($string)){ utf8::encode($string) }
  push(@{$this->{queue}}, $string);
  if(defined $this->{input_event}){
    $this->{input_event}->post_and_clear();
    delete $this->{input_event};
    $this->DebugMsg("posted input_event");
  }
}
sub dequeue{
  my($this) = @_;
  $this->DebugMsg("in dequeue");
  if(scalar(@{$this->{queue}}) < 1){
    $this->DebugMsg("returning undef from dequeue");
    return undef;
  }
  my $string = shift @{$this->{queue}};
  my $in_queue = @{$this->{queue}};
  $this->DebugMsg("remaining in queue: $in_queue (low: $this->{low})");
  if(
    defined($this->{output_event}) &&
    (scalar @{$this->{queue}}) < $this->{low}
  ){
    $this->DebugMsg("posting output event in dequeue");
    $this->{output_event}->post_and_clear();
    delete $this->{output_event};
  }
  my $len = length($string);
  $this->DebugMsg("removing $len bytes from queue (in dequeue)");
  return $string;
}
sub wait_output{
  my($this, $event) = @_;
  $this->DebugMsg("wait_output");
  $this->{output_event} = $event;
}
sub wait_input {
  my($this, $event) = @_;
  $this->DebugMsg("wait_input");
  $this->{input_event} = $event;
}
sub finish{
  my($this) = @_;
  $this->DebugMsg("finish");
  #print "In finished\n";
  $this->{finished} = 1;
  if(defined $this->{input_event}){
    $this->DebugMsg("finish posting input");
    $this->{input_event}->post_and_clear();
    delete $this->{input_event};
  }
  if(
    defined($this->{output_event})
  ){
    $this->DebugMsg("finish posting output");
    $this->{output_event}->post_and_clear();
    delete $this->{output_event};
  }
}
sub SocketWriter{
  my($queue) = @_;
  my $foo = sub {
    my($this, $sock) = @_;
    $queue->DebugMsg("In SocketWriter");
    dequeue:
    while($#{$queue->{queue}} >= 0){
      my $string = $queue->{queue}->[0];
      my $str_len = length($string);
      if($str_len == 0){
         die "string of zero length on queue";
      }
      unless(defined $queue->{current_offset}) {$queue->{current_offset} = 0 }
      $queue->DebugMsg("working string of length $str_len at offset" .
        " $queue->{current_offset}");
      my $len = 
        syswrite $sock, $string, length($string), $queue->{current_offset};
      if(defined $len){
        $queue->DebugMsg("wrote $len bytes of ($str_len) at " .
          "$queue->{current_offset}");
      }
      unless(defined($len)){
        if($! == &Errno::EPIPE){
          if(defined $queue->{identifier}){
#            print STDERR "EPIPE on write($queue->{identifier})\n";
          } else {
#            print STDERR "EPIPE on write\n";
          }
          $this->{finished} = 1;
          delete $queue->{current_offset};
          $this->{queue} = [];
          $this->Remove("writer");
          return;
        } elsif($! == &Errno::EAGAIN){
#          print "EAGAIN on write\n";
          return
        } elsif($! == &Errno::EWOULDBLOCK){
#          print "EWOULDBLOCK on write\n";
          return
        } else {
          print STDERR "Wrote 0 (had selected true) err = $!\n";
          $this->{finished} = 1;
          delete $queue->{current_offset};
          $this->{queue} = [];
          $this->Remove("writer");
          return;
        }
        return; # just in case
      }
      if($len >= 0){
        $queue->{current_offset} += $len;
      } elsif ($len < 0){
        die "error writing socket: $!";
      }
      if($len == 0){
        print STDERR "Wrote 0 (had selected true) err = $!\n";
        return;
      }
      if($queue->{current_offset} == length($string)){
        $queue->DebugMsg("finished current string (dequeue to remove it)");
        $queue->dequeue();
        delete $queue->{current_offset};
      } else {
#        print "Current offset: $queue->{current_offset} of $str_len ($len)\n";
      }
    }
    $this->Remove("writer");
    if($queue->{finished}) {
       return;
    }
    $queue->wait_input($queue->CreateQueueEmptierEvent($sock));
  };
  $queue->DebugMsg("Created SocketWriter");
  return $foo;
}
sub CreateQueueEmptierEvent{
  my($this, $sock) = @_;
  my $foo = sub {
    my($back) = @_;
    if(defined $sock->fileno()){
      my $handler = Dispatch::Select::Socket->new($this->SocketWriter(), $sock);
      $handler->Add("writer");
    } else {
      if($#{$this->{queue}} >= 0){
        $this->DebugMsg("Socket found closed when creating emptier");
      }
    }
  };
  $this->DebugMsg("CreateQueueEmptierEvent");
  $this->{input_event} = Dispatch::Select::Event->new(
    Dispatch::Select::Background->new($foo), (exists($this->{debug})?"queue emptier event":undef)
  );
}
sub SocketReader{
  my($queue, $sock) = @_;
  my $foo = sub {
    my($disp, $sock) = @_;
    my $string;
    if($queue->ready_out()){
      my $len = sysread($sock, $string, 32 * 1024);
#      my $len = sysread($sock, $string, 1024);
      if($len <= 0){
        $queue->finish();
        $disp->Remove("reader");
        return;
      } else {
        $queue->queue($string);
      }
    }
    unless($queue->ready_out()){
      $disp->Remove("reader");
      $queue->wait_output($queue->CreateQueueFillerEvent($sock));
    }
  };
}
sub CreateQueueFillerEvent{
  my($this, $sock) = @_;
  my $foo = sub {
    my($back) = @_;
    my $handler = Dispatch::Select::Socket->new($this->SocketReader(), $sock);
    $handler->Add("reader");
  };
  $this->DebugMsg("CreateQueueFillerEvent");
  $this->{output_event} = Dispatch::Select::Event->new(
    Dispatch::Select::Background->new($foo), "queue filler event"
  );
}
sub DESTROY{
  my($this) = @_;
  if($ENV{POSDA_DEBUG}){
    print "DESTROY: $this\n";
  }
}
1;
