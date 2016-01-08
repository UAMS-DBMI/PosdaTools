#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/ContourToBitMap3d.pl,v $
#$Date: 2011/10/14 20:09:02 $
#$Revision: 1.5 $
#
#Copyright 2011, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

# Streamed Pixel operations
# This program accepts contours on an fd and writes a bitmap
# on another fd of the points contained within the contours
# The fd's have been opened by the parent process...

# What to do is specified on the command line.
# All of the parameters on the command line are of the form:
#  <name>=<value> (no spaces)
# parameter order does not matter.
# Here are the possible parameters:
#  in=<number of first input fd>
#  out=<number of output fd>
#  status=<number of status fd>
#  rows=<number of rows in bitmap output>
#  cols=<number of cols in bitmap output>
#  slices=<number of slices in bitmap output>
#  ulx=<x coordinate of upper left point>
#  uly=<y coordinate of upper left point>
#  ulz=<z coordinate of upper left point>
#  rowdcosx=<x of row direction cosine>
#  rowdcosy=<y of row direction cosine>
#  rowdcosy=<z of row direction cosine>
#  coldcosx=<x of col direction cosine>
#  coldcosy=<y of col direction cosine>
#  coldcosz=<z of col direction cosine>
#  rowspc=<spacing between columns>
#  colspc=<spacing between rows>
#  slicespc=<spacing between slices>
#
# On the input socket, the format of the contours is the following:
# BEGIN CONTOUR at z        - marks the beginning of a contour at offset z
# x1,y1,z                   - first point in contour
# x2,y2,y2                  - next point
# ...                       - and so on
# xn,yn,zn                  - last point
# END CONTOUR
# ...                       - repeat for as many contours as you have
#
# This script uses ContourToBitMap.pl for each slice, passing it the
# contours on the nearest slice.  If the nearest slice has no contours
# you need to tell ContourToBitMap3d.pl by having a "BEGIN CONTOUR at z"
# followed immediately by an "END CONTOUR".  Otherwise, it will use the
# nearest slice it knows about (which might be far away)...
#
use strict;
use Posda::FlipRotate;
use VectorMath;
use Dispatch::Select;
use PipeChildren;
use Debug;
use Errno qw(EINTR EIO :POSIX);

my $dbg = sub {print @_};
my($in, $out, $status, $rows, $cols, $slices, $ulx, $uly, $ulz,
  $rowdcosx, $rowdcosy, $rowdcosz,
  $coldcosx, $coldcosy, $coldcosz,
  $rowspc, $colspc, $slicespc
);
my $debug;
for my $i (@ARGV){
  unless($i =~ /^([^=]+)=([^=]+)$/) {
    die "$0: can't parse parameter $i";
  }
  my $key = $1;
  my $value = $2;
  if($key eq "in") { $in = $value }
  elsif ($key eq "out") { $out = $value }
  elsif ($key eq "status") { $status = $value }
  elsif ($key eq "rows") { $rows = $value }
  elsif ($key eq "cols") { $cols = $value }
  elsif ($key eq "slices") { $slices = $value }
  elsif ($key eq "ulx") { $ulx = $value }
  elsif ($key eq "uly") { $uly = $value }
  elsif ($key eq "ulz") { $ulz = $value }
  elsif ($key eq "rowdcosx") { $rowdcosx = $value }
  elsif ($key eq "rowdcosy") { $rowdcosy = $value }
  elsif ($key eq "rowdcosz") { $rowdcosz = $value }
  elsif ($key eq "coldcosx") { $coldcosx = $value }
  elsif ($key eq "coldcosy") { $coldcosy = $value }
  elsif ($key eq "coldcosz") { $coldcosz = $value }
  elsif ($key eq "rowspc") { $rowspc = $value }
  elsif ($key eq "colspc") { $colspc = $value }
  elsif ($key eq "slicespc") { $slicespc = $value }
  elsif ($key eq "debug") { $debug = $value }
  else { die "$0: unknown parameter: $key" }
}
unless(defined $in) { die "$0: in is not defined" }
unless(defined $out) { die "$0: out is not defined" }
unless(defined $rows) { die "$0: rows is not defined" }
unless(defined $cols) { die "$0: cols is not defined" }
unless(defined $slices) { die "$0: slices is not defined" }
unless(defined $ulx) { die "$0: ulx is not defined" }
unless(defined $uly) { die "$0: uly is not defined" }
unless(defined $ulz) { die "$0: ulz is not defined" }
unless(defined $rowdcosx) { die "$0: rowdcosx is not defined" }
unless(defined $rowdcosy) { die "$0: rowdcosy is not defined" }
unless(defined $rowdcosz) { die "$0: rowdcosz is not defined" }
unless(defined $coldcosx) { die "$0: coldcosx is not defined" }
unless(defined $coldcosy) { die "$0: coldcosy is not defined" }
unless(defined $coldcosz) { die "$0: coldcosz is not defined" }
unless(defined $rowspc) { die "$0: rowspc is not defined" }
unless(defined $colspc) { die "$0: colspc is not defined" }
unless(defined $slicespc) { die "$0: slicespc is not defined" }
if($debug){
  print "$0: DEBUG\n";
  print "\trows: $rows\n";
  print "\tcols: $cols\n";
  print "\tslices: $slices\n";
  print "\tulx: $ulx\n";
  print "\tuly: $uly\n";
  print "\tulz: $ulz\n";
}
open(INPUT, "<&", $in) or die "$0: Can't open in = $in ($!)";
open(OUTPUT, ">&", $out) or die "$0: Can't open out = $out ($!)";
my $normal = VectorMath::cross([$rowdcosx, $rowdcosy, $rowdcosz],
  [$coldcosx, $coldcosy, $coldcosz]);

my %ContoursByZ;
my $current_z;
my $contour;
my $mode = "scan";
while(my $line = <INPUT>){
  chomp $line;
  if($mode eq "scan" && !($line =~ /^BEGIN CONTOUR at\s*(\S*)\s*$/)){ next }
  if($mode eq "scan"){
    if($line =~ /BEGIN CONTOUR at\s*(\S*)\s*$/){
      $mode = "in contour";
      $current_z = $1;
      $contour = undef;
      next;
    } else {
      print STDERR"Unrecognized line in scan mode\n";
    }
  }
  if($line eq "END CONTOUR"){
    if($#{$contour} >= 0){
      my $first = $contour->[0];
      my $last = $contour->[$#{$contour}];
      unless(
        $first->[0] eq $last->[0] &&
        $first->[1] eq $last->[1] &&
        $first->[2] eq $last->[2]
      ){
        push(@{$contour}, $first);
      }
    }
    unless(defined $ContoursByZ{$current_z}) { $ContoursByZ{$current_z} = [] }
    if(defined $contour && ref($contour) eq "ARRAY" && $#{$contour} >= 0){
      push @{$ContoursByZ{$current_z}}, $contour;
    }
    $contour = undef;
    $current_z = undef;
    $mode = "scan";
    next;
  }
  my @numbers = split(/\\/, $line);
  my $num_numbers = @numbers;
  unless($num_numbers % 3 == 0){
    die "$0: Number of numbers ($num_numbers) isn't divisible by 3";
  }
  my $num_points = $num_numbers / 3;
  for my $i (0 .. $num_points - 1){
    my $point = [$numbers[$i*3], $numbers[($i*3)+ 1], $numbers[($i*3) + 2]];
    push(@{$contour}, $point);
  }
}
unless($mode eq "scan") { die "$0: end of input in $mode mode" }
my $slice_size = ($rows * $cols) / 8;
my $empty_slice = "\0" x $slice_size;
##################################
# The following stuff pertains to the dispatch environment

use vars qw( $output_queue  $current_queue_item
             $num_running_children);

$output_queue = [];
$num_running_children = 0;
$current_queue_item = undef;

# This routine is the "output writer".  It is called when output
# selects true.
# If the current queue item is an unfinished child, it will suspend
# writing (the child will restart it when the data is available).
#
# If the queue is empty, we're done, remove the writer, and you
# should exit the Dispatcher.
#
my $output_handler = sub {
  my($disp, $sock) = @_;
  unless(defined $current_queue_item){
    if($#{$output_queue} >= 0){
      $current_queue_item = shift @$output_queue;
    } else {
      $disp->Remove;
      return;
      # We're done
    }
  }
  if(
    defined($current_queue_item) &&
    ref($current_queue_item) eq "HASH" &&
    defined($current_queue_item->{type}) &&
    $current_queue_item->{type} eq "slice_data"
   ){
    unless(defined $current_queue_item->{bytes_written}){
      $current_queue_item->{bytes_written} = 0;
    }
    my $bytes_written = syswrite($sock,
      $current_queue_item->{slice_data},
      length($current_queue_item->{slice_data}) - 
        $current_queue_item->{bytes_written},
      $current_queue_item->{bytes_written}
    );
    if($bytes_written <= 0){
      if(
        $! == &Errno::EAGAIN ||
        $! == &Errno::EWOULDBLOCK
      ){
        return;
      }
      my $to_read = length(
        $current_queue_item->{slice_data} - 
        $current_queue_item->{bytes_written}
      );
      unless(defined $bytes_written){ $bytes_written = "<undef>" }
      die "$0: read $bytes_written of $to_read ($!)";
    }
    $current_queue_item->{bytes_written} += $bytes_written;
    if(
      $current_queue_item->{bytes_written} >= 
      length($current_queue_item->{slice_data})
    ){
      $current_queue_item = undef;
    }
  } else {
    $current_queue_item->{suspended_writer} = $disp;
    $disp->Remove;
  }
};

# This routine handles input from a child 2d contourer
# It merely reads the input and copies it to the output queue
# If the output queue is over the limit, it removes the output
# and suspends the read.
# if output is suspended, it restarts the writer.
# If the input is finished, it dismisses the read and removes the
# reader.
sub MakeInputReader{
  my($item) = @_;
  my $input_reader = sub{
    my($disp, $sock) = @_;
    unless(exists $item->{slice_data}) { $item->{slice_data} = "" }
    my $len = sysread($sock, $item->{slice_data}, 16384, 
      length($item->{slice_data}));
    if($len == 0){
      waitpid($item->{pid}, 0);
      $disp->Remove;
      $item->{type} = "slice_data";
      if(exists $item->{suspended_writer}){
        $item->{suspended_writer}->Add("writer");
        delete $item->{suspended_writer};
      }
    }
  };
  return $input_reader;
}

sub StartChildHandler{
  my($item) = @_;
  my $to_child = PipeChildren::GetSocketPair();
  my $from_child = PipeChildren::GetSocketPair();
  my $status_child = PipeChildren::GetSocketPair();
  my $child_fd_map = {
    in => $to_child->{from},
    out => $from_child->{to},
    status => $status_child->{to},
  };
  my $ul = VectorMath::Add([$ulx, $uly, $ulz],
    VectorMath::Scale($item->{at}, $normal));
  my $child_args = {
    rows => $rows,
    cols => $cols,
    ulx => $ul->[0],
    uly => $ul->[1],
    ulz => $ul->[2],
    rowdcosx => $rowdcosx,
    rowdcosy => $rowdcosy,
    rowdcosz => $rowdcosz,
    coldcosx => $coldcosx,
    coldcosy => $coldcosy,
    coldcosz => $coldcosz,
    rowspc => $rowspc,
    colspc => $rowspc,
    ztol => 10,
  };
  my $child_pid = PipeChildren::Spawn("ContourToBitMap.pl", 
    $child_fd_map, $child_args);
  $item->{pid} = $child_pid;
  Dispatch::Select::Socket->new(MakeInputReader($item), 
    $from_child->{from})->Add("reader");
  Dispatch::Select::Socket->new(MakeStatusReader($item), 
    $status_child->{from})->Add("reader");
  my $to = $to_child->{to};
  for my $i (@{$item->{contours}}){
    print $to "BEGIN CONTOUR\n";
    for my $pi (0 .. $#{$i}){
      my $p = $i->[$pi];
      print $to "$p->[0]\\$p->[1]\\$p->[2]";
      if($pi == $#{$i}) {
        print $to "\n";
      } else {
        print $to "\\";
      }
    }
    print $to "END CONTOUR\n";
  }
  close $to_child->{to};
}

sub StartMoreChildren{
  if(
    defined($current_queue_item) &&
    ref($current_queue_item) eq "HASH" &&
    defined($current_queue_item->{type}) &&
    $current_queue_item->{type} eq "2dContouringChild" &&
    !defined($current_queue_item->{pid})
  ){
    StartChildHandler($current_queue_item);
    $num_running_children++;
    if($num_running_children > 1){
      return;
    }
  }
  for my $i (@$output_queue){
    if(
      $i->{type} eq "2dContouringChild" &&	
      !defined($i->{pid})
    ){
      StartChildHandler($i);
      $num_running_children++;
      if($num_running_children > 1){
        return;
      }
    }
  }
}
# This routine handles reading the status from a child 2d contourer, and
# harvesting its pid when its done.
sub MakeStatusReader{
  my($pid, $name) = @_;
  my $reply = "";
  my $harvester = sub {
    my($disp, $sock) = @_;
    my $count = sysread($sock, $reply, 1024, length($reply));
    unless($count){
      $disp->Remove;
      unless($reply =~ /^OK/){
        print STDERR "Child $name ($pid) returned status: $reply\n";
      }
      waitpid $pid, 0;
      $num_running_children--;
      StartMoreChildren();
    }
  };
  return $harvester;
}

#  This routine is the "master" dispatch routine.
my $handler = sub {
  my($disp) = @_;
  my @offsets = sort {$a <=> $b} keys %ContoursByZ;
  my $lower = $offsets[0];
  my $higher = $offsets[1];
  my $next = 2;
  for my $i (0 .. $slices - 1){
    my $nearest;
    if($i < $offsets[0]) {
      $nearest = $offsets[0];
    } elsif($i > $offsets[$#offsets]){
      $nearest = $offsets[0];
    } else {
      while($i > $higher) {
        $lower = $higher;
        $higher = $offsets[$next];
        $next += 1;
      }
      unless($i >= $lower && $i <= $higher){
        die "$i < lower($lower) or $i > higher($higher) ???";
      }
      if(($higher - $i) > ($i - $lower)){
        $nearest = $lower;
      } else {
        $nearest = $higher;
      }
    }
    my $contours = $ContoursByZ{$nearest};
    my $item;
    if($#{$contours} < 0){
      $item = {
        type => "slice_data",
        slice_data => $empty_slice,
        name => "Empty Contours at $i ($nearest)",
      };
    } else {
      $item = {
        type => "2dContouringChild",
        name => "Contourer at $i ($nearest)",
        at => $i,
        contours => $ContoursByZ{$nearest},
        ztol => 2 * abs($i - $nearest),
      };
    }
    push(@$output_queue, $item);
  }
  Dispatch::Select::Socket->new($output_handler, \*OUTPUT)->Add("writer");
  StartMoreChildren();
};
Dispatch::Select::Background->new($handler)->queue;
Dispatch::Select::Dispatch();
##################################
# back from dispatch environment
# write the status
#
if(defined $status){
  open(STATUS, ">&", $status) or die "$0: Can't open status = $status ($!)";
  print STATUS "OK\n";
  close STATUS;
}

