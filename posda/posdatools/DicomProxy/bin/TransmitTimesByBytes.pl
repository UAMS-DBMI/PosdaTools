#!/usr/bin/perl -w
#
use strict;
use Storable qw( store_fd fd_retrieve);
my $usage = <<EOF;
TransmitTimesByBytes.pl <dir>
 or
TransmitTimesByBytes.pl -h

Reads a serialized perl data structure from time_line as produced by 
BuildProxyForwardTimeLine.pl from <dir>,
serializes an index of time line to <dir>/time_line_index.

Index Format:
\$Index = [
  [
    <byte_offset>,
    <time_read>,
    <time_forwarded>,
  ],
  ...
];

Output Structure Format:
\$Output = {
  left => <from_index>,
  right => <to_index>
};
EOF
if($ARGV[0] eq "-h"){
  print $usage;
  exit;
}
my $dir = $ARGV[0];
my $from_file = "$dir/time_line";
my $to_file = "$dir/time_line_index";
my $result;
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
my $rfh;
unless(open $rfh, "<$from_file") {
  print "Unable to open $from_file\n";
  exit;
}
my $ref = fd_retrieve($rfh);
my $index = {};
for my $i (keys %$ref){
  for my $event (@{$ref->{$i}}){
    if($event->{event} eq "Read"){
      $index->{$event->{queue}}->{$event->{read}}->{read} = $event->{at};
    } elsif($event->{event} eq "Forwarded"){
      $index->{$event->{queue}}->{$event->{forwarded}}->{forwarded} = 
        $event->{at};
    }
  }
}
for my $q ("left", "right"){
  my @queue;
  for my $k (sort { $a <=> $b } keys %{$index->{$q}}){
    my $event = $index->{$q}->{$k};
    push(@queue, [$k, $event->{read}, $event->{forwarded}]);
  }
  $result->{$q} = \@queue;
}
Done();
