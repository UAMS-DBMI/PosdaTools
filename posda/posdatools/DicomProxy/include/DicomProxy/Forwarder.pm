#!/usr/bin/perl -w
#
use strict;
use Dispatch::Select;
package DicomProxy::Forwarder;
use Time::HiRes qw( gettimeofday tv_interval time );
sub new {
  my($class, $from_sock, $to_sock, $tr_sock, $chunk_size, $queue_l,
    $start_time, $event_callback, $complete_callback) = @_;
  my $this = {};
  bless $this, $class;
  $this->{queue} = [];
  $this->{tr_queue} = [];
  $this->{chunk_size} = $chunk_size;
  $this->{queue_l} = $queue_l;
  $this->{start_time} = $start_time;
  $this->{event} = $event_callback;
  $this->{complete} = $complete_callback;
  $this->{bytes_read} = 0;
  $this->{bytes_written} = 0;
  $this->{read_shutdown} = 0;
  $this->{write_shutdown} = 0;
  my($read_handler, $write_handler) = $this->CreateReadWriteHandler(
    $from_sock, $to_sock);
  $this->{from_read_handler} = Dispatch::Select::Socket->new(
    $read_handler, $from_sock);
  $this->{to_write_handler} = Dispatch::Select::Socket->new(
    $write_handler, $to_sock);
  $this->{trace_write_handler} = Dispatch::Select::Socket->new(
    $this->CreateTraceHandler, $tr_sock);
  $this->{from_read_handler}->Add("reader");
  return $this;
}
sub CreateReadWriteHandler{
  my($this, $from_sock, $to_sock) = @_;
  my $write_offset = 0;
  my $read_sub = sub {
    my($disp, $sock) = @_;
    my $buff;
    my $elapsed = tv_interval($this->{start_time});
    if($this->{write_shutdown}){
      $sock->shutdown(0);
      $this->{from_read_handler}->Remove("reader");
      delete $this->{from_read_handler};
      $this->{read_shutdown} = 1;
      &{$this->{event}}("Shutdown read in response to " .
        "write shutdown");
      $this->{trace_write_handler}->Add("writer");
      return;
    }
    my $count = sysread($sock, $buff, $this->{chunk_size});
    unless(defined $count){
      if(
        $! == &Errno::EAGAIN ||
        $! == &Errno::EWOULDBLOCK
      ){ return }
      # handle broken pipe on read exactly as shutdown
      $count = 0;
    }
    if($count <= 0){
      $this->{read_shutdown} = 1;
      $this->{to_write_handler}->Add("writer");
      $disp->Remove("reader");
      delete $this->{from_read_handler};
      &{$this->{event}}(sprintf(
        "Detected read shutdown at $elapsed\n"));
      return;
    }
    my $length = length($buff);
    $this->{bytes_read} += $length;
    &{$this->{event}}(
      sprintf("Read $length bytes at $elapsed\n"));
    push(@{$this->{queue}}, $buff);
    $this->{to_write_handler}->Add("writer");
    my $bytes = $this->BytesInQueue - $write_offset;
    if($bytes > $this->{queue_l}) {
      unless($this->{throttled}){
        my $elapsed_th = tv_interval($this->{start_time});
        &{$this->{event}}(
          sprintf("Throttling $bytes bytes at $elapsed\n"));
      }
      $this->{throttled} = 1;
      $disp->Remove("reader");
    }
    push(@{$this->{tr_queue}}, $buff);
    $this->{trace_write_handler}->Add("writer");
  };
  my $write_sub = sub {
    my($disp, $sock) = @_;
    my $elapsed = tv_interval($this->{start_time});
    unless(scalar(@{$this->{queue}}) > 0) {
      if($write_offset) {
        die "write_offset ($write_offset) with nothing in queue";
      }
      $disp->Remove("writer");
      if($this->{read_shutdown}){
        $sock->shutdown(1);
        $this->{write_shutdown} = 1;
        &{$this->{event}}(
          sprintf("Forwarding shutdown at $elapsed\n"));
        delete $this->{to_write_handler};
        $this->{trace_write_handler}->Add("writer");
      } else {
        &{$this->{event}}(
          sprintf("Forwarding paused at $elapsed\n"));
      }
      return;
    }
    my $len = length($this->{queue}->[0]);
    if($write_offset > $len){
      die "write_offset ($write_offset) > length ($len)";
    }
    my $len_attempt = $len - $write_offset;
    my $num_written = syswrite($sock, $this->{queue}->[0], 
      $len_attempt, $write_offset);
    unless(defined $num_written){
      if(
        $! == &Errno::EAGAIN ||
        $! == &Errno::EWOULDBLOCK
      ){ return }
      # broken pipe on output
      $this->{write_shutdown} = 1;
      $this->{to_write_handler}->Remove("writer");
      delete $this->{to_write_handler};
      $this->{queue} = [];
      if(
        defined $this->{from_read_handler} &&
        $this->{from_read_handler}->can("Add")
      ){
        $this->{from_read_handler}->Add("reader");
      }
      &{$this->{event}}(
        sprintf("Error ($!) writing $len_attempt bytes" .
          "at $elapsed (write_shutdown)\n"));
      return;
    }
    if($num_written <= 0){
      die "Count defined, but <= 0";
    }
    my $tot_buf_written = $write_offset + $num_written;
    if($tot_buf_written >= $len) {
      shift(@{$this->{queue}});
      $write_offset = 0;
    } else {
      $write_offset += $num_written;
    }
    $this->{bytes_written} += $num_written;
    my $bytes = $this->BytesInQueue($this->{queue}) - $write_offset;
    &{$this->{event}}(
      sprintf("Forwarded $num_written bytes at $elapsed\n"));
    if($bytes <= $this->{queue_l}) {
      if($this->{throttled}){
        $this->{throttled} = 0;
        my $elapsed_th = tv_interval($this->{connection_time});
        &{$this->{event}}(
          sprintf("Unthrottling $bytes bytes at $elapsed_th\n"));
      }
      if(
        defined($this->{from_read_handler}) &&
        $this->{from_read_handler}->can("Add")
      ){
        $this->{from_read_handler}->Add("reader");
      }
    }
  };
  return $read_sub, $write_sub;
}
sub CreateTraceHandler{
  my($this) = @_;
  my $write_offset = 0;
  my $sub = sub {
    my($disp, $sock) = @_;
    unless(scalar(@{$this->{tr_queue}}) > 0){
      $disp->Remove("writer");
      if($this->{read_shutdown} && $this->{write_shutdown}){
        $this->{trace_shutdown} = 1;
        $this->{trace_write_handler}->Remove("writer");
        delete $this->{trace_write_handler};
        $this->TearDown;
      }
      return;
    }
    my $len = length $this->{tr_queue}->[0];
    if($write_offset > $len) {
      die "write_offset ($write_offset) > len ($len)";
    }
    my $num_written = syswrite($sock, $this->{tr_queue}->[0], 
      $len - $write_offset, $write_offset);
    if($num_written < 0){
      die "Error ($!) writing";
    }
    $write_offset += $num_written;
    if($write_offset >= $len) {
      $write_offset = 0;
      shift @{$this->{tr_queue}};
    }
  };
  return $sub;
}
sub BytesInQueue{
  my($this) = @_;
  my $tot = 0;
  for my $i (@{$this->{queue}}) { $tot += length($i) }
  return $tot;
}
sub TearDown{
  my($this) = @_;
  # tear down all data structures
  my $elapsed = tv_interval($this->{start_time});
  my $complete = $this->{complete};
  my $bytes_read = $this->{bytes_read};
  my $bytes_written = $this->{bytes_written};
  for my $i (keys %$this){ delete $this->{$i} }
  &{$complete}($bytes_read, $bytes_written, $elapsed);
}
sub DESTROY{
  my($this) = @_;
  # print STDERR "Destroying $this\n";
}
1;
