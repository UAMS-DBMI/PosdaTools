#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/DicomProxy/include/DicomProxy/Proxy.pm,v $
#$Date: 2014/10/27 13:03:10 $
#$Revision: 1.17 $
#
use strict;
use Dispatch::Select;
use DicomProxy::Forwarder;
package DicomProxy::Proxy;
use Time::HiRes qw( gettimeofday tv_interval time );
sub new_tracer {
  my($class, $id, $server, $from_sock, $to_sock, 
    $proxy_dir, $chunk_size, $max_queued, $callback) = @_;
  if(-d $proxy_dir) {
    die "!!!!!!!!! proxy dir $proxy_dir pre exists !!!!!!!!!!!";
  } else {
    unless(mkdir $proxy_dir){ die "couldn't mkdir $proxy_dir ($!)" }
  }
  my @time = gettimeofday;
  if($time[1] > 1000000){
    $time[0] += 1;
    $time[1] -= 100000
  }
  my($sec, $min, $hr, $mday, $mon, $yr, $wday, $yday, $isdst) =
    localtime($time[0]);
  $sec = $sec + ($time[1] / 1000000);
  my $this = {
    id => $id,
    dir => $proxy_dir,
#    from_sock => $from_sock,
#    to_sock => $to_sock,
    connection_time => \@time,
    connection_time_text =>
      sprintf("%04d-%02d-%02d %02d:%02d:%07.4f", $yr+1900, $mon + 1,
        $mday, $hr, $min, $sec),
    from_addr => $from_sock->peerhost,
    trace_queue => [],
    status => "Active",
    chunk_size => $chunk_size,
    max_queued => $max_queued,
    callback => $callback,
    destination_host => $server->{destination_host},
    destination_name => $server->{destination_name},
    destination_port => $server->{destination_port},
    server_port => $server->{port},
  };
  bless $this, $class;
  my $log_file = "$proxy_dir/trace_index";
  my $from_trace_file = "$proxy_dir/trace_from_data";
  my $to_trace_file = "$proxy_dir/trace_to_data";
  my $trace_fh;
  open $trace_fh, "|cat >$log_file";
  unless($trace_fh) { die "can't open pipe to $log_file" }
  $this->{trace_handler} = Dispatch::Select::Socket->new(
    $this->TraceHandler, $trace_fh);
  my $from_trace_fh;
  open $from_trace_fh, "|cat >$from_trace_file";
  unless($from_trace_fh) { die "can't open pipe to $from_trace_file" }
  my $to_trace_fh;
  open $to_trace_fh, "|cat >$to_trace_file";
  unless($to_trace_fh) { die "can't open pipe to $to_trace_file" }
  $this->{left} = DicomProxy::Forwarder->new(
    $from_sock, $to_sock, $from_trace_fh,
    $this->{chunk_size}, $this->{max_queued},
    $this->{connection_time},
    $this->LogAnEvent("left"),
    $this->ForwarderClosed("left")
  );
  $this->{right} = DicomProxy::Forwarder->new(
    $to_sock, $from_sock, $to_trace_fh,
    $this->{chunk_size}, $this->{max_queued},
    $this->{connection_time},
    $this->LogAnEvent("right"),
    $this->ForwarderClosed("right")
  );
  return $this;
}
sub LogAnEvent{
  my($this, $direction) = @_;
  my $sub = sub {
    my($e) = @_;
    push(@{$this->{trace_queue}}, "$direction: $e");
    $this->{trace_handler}->Add("writer");
    &{$this->{callback}}($this->{id});
  };
  return $sub;
}
sub ForwarderClosed{
  my($this, $direction) = @_;
  my $sub = sub {
    my($num_read, $num_written, $elapsed) = @_;
    $this->{bytes_read}->{$direction} = $num_read;
    $this->{bytes_written}->{$direction} = $num_written;
    $this->{elapsed}->{$direction} = $elapsed;
    delete $this->{$direction};
    $this->CheckRemainingForwarders;
    &{$this->{callback}}($this->{id});
  };
  return $sub;
}
sub CheckRemainingForwarders{
  my($this) = @_;
  unless(exists($this->{left}) || exists($this->{right})){
    $this->{status} = "Finished";
    my $elapsed = tv_interval($this->{connection_time});
    $this->{elapsed}->{proxy} = $elapsed;
    if(exists $this->{trace_handler}) { $this->{trace_handler}->Add("writer") }
    open my $fh, ">$this->{dir}/ProxySession.info";
    print $fh "connection_time_text: $this->{connection_time_text}\n";
    print $fh "status: $this->{status}\n";
    print $fh "connection_time: $this->{connection_time}->[0]," .
     "$this->{connection_time}->[1]\n";
    print $fh "elapsed: $this->{elapsed}->{proxy}\n";
    print $fh "destination_host: $this->{destination_host}\n";
    print $fh "destination_name: $this->{destination_name}\n";
    print $fh "destination_port: $this->{destination_port}\n";
    print $fh "from: $this->{from_addr}\n";
    print $fh "server_port: $this->{server_port}\n";
    print $fh "from_received: $this->{bytes_read}->{left}\n";
    print $fh "from_forwarded: $this->{bytes_written}->{left}\n";
    print $fh "to_received: $this->{bytes_read}->{right}\n";
    print $fh "to_forwarded: $this->{bytes_written}->{right}\n";
    print $fh "chunk_size: $this->{chunk_size}\n";
    print $fh "max_queued: $this->{max_queued}\n";
    close $fh;
  }
}
sub TraceHandler{
  my($this) = @_;
  my $write_offset = 0;
  my $sub = sub {
    my($disp, $sock) = @_;
    unless(scalar @{$this->{trace_queue}} > 0){
      $disp->Remove("writer");
      if($this->{status} eq "Finished"){ delete $this->{trace_handler} }
      delete $this->{trace_queue};
      return;
    }
    my $len = length $this->{trace_queue}->[0];
    if($write_offset > $len) { die "write_offset ($write_offset) > len ($len)" }
    my $num_written = syswrite($sock, $this->{trace_queue}->[0],
      $len - $write_offset, $write_offset);
    if($num_written <= 0){
      die "Error ($!) writing event";
    }
    $write_offset += $num_written;
    if($write_offset >= $len){
       $write_offset = 0;
       shift @{$this->{trace_queue}};
    }
  };
  return $sub;
}
sub DESTROY{
  my($this) = @_;
  # print STDERR "Destroying $this\n";
}
1;
