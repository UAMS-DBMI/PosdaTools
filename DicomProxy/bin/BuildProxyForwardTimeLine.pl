#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/DicomProxy/bin/BuildProxyForwardTimeLine.pl,v $
#$Date: 2014/10/27 12:37:50 $
#$Revision: 1.4 $
#
use strict;
use Storable qw( store_fd );
my $usage = <<EOF;
BuildProxyForwardTimeLine.pl <dir>
 or
BuildProxyForwardTimeLine.pl -h

Builds time line of events on <from> and <to> queues as captured in a 
trace_index file.
Events:
  Read = {
    at => <time_offset>,
    buffered => <cum bytes read but not forwarded>,
    bytes => <bytes read>
    event => "Read",
    queue => "left" | "right",
    read => <cum bytes read>
  };
  Forward = {
    at => <time_offset>,
    buffered => <cum bytes read but not forwarded>,
    bytes => <bytes forwarded>
    event => "Forwarded",
    queue => "left" | "right",
    read => <cum bytes forwarded>
  };
  Paused = {
    at => <time_offset>,
    event => "Paused",
    queue => "left" | "right",
  };
  Throttled = {
    at => <time_offset>,
    buffered => <cum bytes read but not forwarded>,
    event => "Throttled",
    queue => "left" | "right",
  };
  UnThrottled = {
    at => <time_offset>,
    buffered => <cum bytes read but not forwarded>,
    event => "Unthrottled",
    queue => "left" | "right",
  };
  ShutdownDetect = {
    at => <time_offset>,
    event => "ShutdownDetect",
    queue => "left" | "right",
  };
  ShutdownForward {
    at => <time_offset>,
    event => "ShutdownForward",
    queue => "left" | "right",
  };

Time line data structure:
\$time_line = {
  <time_offset> => [
    <event>,
    ...
  ],
  ...
};
EOF
if($ARGV[0] eq "-h"){
  print $usage;
  exit;
}
my $dir = $ARGV[0];
my $from_file = "$dir/trace_index";
my $to_file = "$dir/time_line";
my $result = {};
sub Done{
  my $fh;
  unless(defined $to_file){
    print "No to_file specified\n";
    exit;
  }
  unless(open $fh, ">$to_file"){
    print "Unable to open $to_file\n";
    exit;
  }
  store_fd $result, $fh;
  close $fh;
  print "OK\n";
  exit;
}
unless(open FROM, "<$from_file") {
  print "Unable to open $from_file\n";
  exit;
}
my @events;
my $from_bytes_read = 0;
my $from_bytes_forwarded = 0;
my $from_buffered_bytes = 0;
my $to_bytes_read = 0;
my $to_bytes_forwarded = 0;
my $to_buffered_bytes = 0;
line:
while(my $line = <FROM>){
  chomp $line;
  if($line eq "Trace Started") { next line }
  if($line =~ /^(.*): Read (\d+) bytes at (.*)$/){
    my $event = "Read";
    my $queue = $1;
    my $bytes = $2;
    my $at = $3;
    my($read, $buffered);
    if($queue eq "left"){
      $from_bytes_read += $bytes;
      $from_buffered_bytes += $bytes;
      $buffered = $from_buffered_bytes;
      $read = $from_bytes_read;
    } else {
      $to_bytes_read += $bytes;
      $to_buffered_bytes += $bytes;
      $buffered = $to_buffered_bytes;
      $read = $to_bytes_read;
    }
    push(@events, { 
      queue => $queue,
      at => $at, event => $event, bytes => $bytes,
      buffered => $buffered,
      read => $read,
    } );
  } elsif($line =~ /^(.*): Forwarded (\d+) bytes at (.*)$/){
    my $event = "Forwarded";
    my $queue = $1;
    my $bytes = $2;
    my $at = $3;
    my($buffered, $forwarded);
    if($queue eq "left"){
      $from_bytes_forwarded += $bytes;
      $from_buffered_bytes -= $bytes;
      $buffered = $from_buffered_bytes;
      $forwarded = $from_bytes_forwarded;
    } else {
      $to_bytes_forwarded += $bytes;
      $to_buffered_bytes -= $bytes;
      $buffered = $to_buffered_bytes;
      $forwarded = $to_bytes_forwarded;
    }
    push(@events, { 
      queue => $queue,
      at => $at, event => $event, bytes => $bytes,
      buffered => $buffered,
      forwarded => $forwarded,
    } );
  } elsif($line =~ /^(.*): Forwarding paused at (.*)$/){
    my $event = "Paused";
    my $queue = $1;
    my $at = $2;
    push(@events, {
      queue => $queue,
      at => $at, event => $event,
    });
  } elsif($line =~ /^(.*): Throttling (\d+) bytes at (.*)$/){
    my $event = "Throttled";
    my $queue = $1;
    my $bytes = $2;
    my $at = $3;
    push(@events, {
    queue => $queue,
      at => $at, event => $event, buffered => $bytes,
    });
  } elsif($line =~ /^(.*): Unthrottling (\d+) bytes at (.*)$/){
    my $event = "Unthrottled";
    my $queue = $1;
    my $bytes = $2;
    my $at = $3;
    push(@events, {
      queue => $queue,
      at => $at, event => $event, buffered => $bytes,
    });
  } elsif($line =~ /^(.*): Detected shutdown at (.*)$/){
    my $event = "ShutdownDetect";
    my $queue = $1;
    my $at = $2;
    push(@events, {
      queue => $queue,
      at => $at, event => $event,
    });
  } elsif($line =~ /^(.*): Forwarding shutdown at (.*)$/){
    my $event = "ShutdownForward";
    my $queue = $1;
    my $at = $2;
    push(@events, {
      queue => $queue,
      at => $at, event => $event,
    });
  } else {
    print STDERR "Unrecognized line ($line)\n";
  }
}
for my $i (@events){
  my $at = $i->{at};
  unless(exists $result->{$at}){
    $result->{$at} = [];
  }
  push(@{$result->{$at}}, $i);
}
for my $i (keys %$result){
  if($#{$result->{$i}} > 0){
    print STDERR "Multiple events at $i\n";
  }
}
Done();
