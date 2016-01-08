#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/ContourExtractor.pl,v $
#$Date: 2012/04/20 20:55:43 $
#$Revision: 1.4 $
#
use strict;
use Dispatch::Select;
use PipeChildren;
use Debug;
my $dbg = sub {print STDERR @_};
#
##############################################
#
# The fd's have been opened by the parent process...
#
# What to do is specified on the command line.
# All of the parameters on the command line are of the form:
#  <name>=<value> (no spaces)
#
#  out=<number of output fd>,<bits>,<scaling>,<units>
#
#
# my $out_scale;
# my $out_units;
# my $out_bits;
my $args = { };
my $SliceNeeded = { };
for my $i (@ARGV){
  # print STDERR "$0: ARGV value: $i\n";
  unless($i =~ /^([^=]+)=([^=]+)$/) {
    die "$0: can't parse parameter $i";
  }
  my $key = $1;
  my $value = $2;
  # if($key eq "in"){
  #   my($fd) = split(/,/, $value);
  #   $args->{in} = open(my $foo, "<&", $fd);
  if ($key eq "slices_needed") {
    my @slices = split(/,/, $value);
    for $i (@slices) { $SliceNeeded->{$i} = 1; }
  } else {
    $args->{$key} = $value;
  }
}
unless (exists ($args->{x})  &&
        exists ($args->{y})  &&
        exists ($args->{rows})  &&
        exists ($args->{cols})  &&
        exists ($args->{interval})  &&
        exists ($args->{base_file})  ) {
  die "$0: Missing required argument.";
}
unless(defined $args->{status}) { die "$0: status is undefined" }
open(STATUS, ">&", $args->{status}) 
  or die "$0: Can't open status = $args->{status} ($!)";
STATUS->autoflush(1);
my $ContourExtractionCounts = { };
my $CEXT_SliceSize;
my $CEXT_queue = [ ];
my $SliceMapping = { };
ExtractContours();
die "$0: Should not have returned from ExtractContours";
sub DumpContourExtractionCounts{
  print "(";
  for my $i ("processed", "num_kids", "ignored_blank",
    "ignored_to_far", "completed", "queued", "reading_bitmap", "errors"
  ){
    my $foo = "-";
    if(defined $ContourExtractionCounts->{$i}){
      $foo = $ContourExtractionCounts->{$i};
    }
    print "$foo";
    unless($i eq "errors"){ print " " }
  }
  print ")\n";
}

sub ExtractContours{
  # print STDERR "$0: Args: \n";
  # Debug::GenPrint($dbg, $args, 1);
  # print STDERR "\n";
  $CEXT_SliceSize = ($args->{rows} * $args->{cols});
  $ContourExtractionCounts->{processed} = 0;
  $ContourExtractionCounts->{num_kids} = 0;
  $ContourExtractionCounts->{ignored_blank} = 0;
  $ContourExtractionCounts->{ignored_to_far} = 0;
  $ContourExtractionCounts->{completed} = 0;
  $ContourExtractionCounts->{queued} = 0;
  $ContourExtractionCounts->{errors} = 0;
  $ContourExtractionCounts->{reading_bitmap} = 1;
  my $in_fd = open(my $foo, "<&", $args->{in});
  Dispatch::Select::Socket->new(CEXT_ReadBitmap(),
     $foo)->Add("reader");
  Dispatch::Select::Dispatch();
  print STDERR "ContourExtractor::ExtractContours: " .
    "ERROR: Returned from Dispatch\n";
}
sub SendStatus{
  print STATUS 
    "Status: " .
    $ContourExtractionCounts->{processed} . " " .
    $ContourExtractionCounts->{num_kids} . " " .
    $ContourExtractionCounts->{ignored_blank} . " " .
    $ContourExtractionCounts->{ignored_to_far} . " " .
    $ContourExtractionCounts->{completed} . " " .
    $ContourExtractionCounts->{queued} . " " .
    $ContourExtractionCounts->{errors} . "\n";
}
sub CEXT_ReadBitmap{
  my $file_pos = 0;
  my $slice_no = 0;
  my $build_bit_map = [];
  my $cur_size = 0;
  my $cur_polarity = 0;
  my $cur_count;
  my $byte;
  my $tot_bytes = 0;
  my $foo = sub {
    my($disp, $sock) = @_;
    my $bb;
    my $count = sysread($sock, $bb, 1);
    # print STDERR "CEXT_ReadBitmap: sysread count: $count.\n";
    $tot_bytes += $count;
    unless($count == 1){
      if($#{$build_bit_map} >= 0){
        print STDERR "ERROR: stuff left in build_bit_map at EOF\n";
      }
      $disp->Remove();
      $ContourExtractionCounts->{reading_bitmap} = 0;
      CEXT_StartKids();
      return;
    }
    my $byte;
    {
      no warnings;
      $byte = unpack("c", $bb);
    }
    my $pol = ($byte & 0x80) >> 7;
    $count = $byte & 0x7f;
    if($cur_count && ($pol != $cur_polarity)){
      if(($cur_count + $cur_size) >= $CEXT_SliceSize){
        my $remain = $CEXT_SliceSize - $cur_size;
        push(@$build_bit_map, [$cur_polarity, $remain]);
        $cur_count -= $remain;
        CEXT_ProcessSlice($build_bit_map, $slice_no);
        $slice_no += 1;
        $build_bit_map = [];
        $cur_size = 0;
      }
      if($cur_count > 0){
        push(@$build_bit_map, [$cur_polarity, $cur_count]);
        $cur_size += $cur_count;
      }
      $cur_polarity = $pol;
      $cur_count = $count;
    } else {
      $cur_count += $count;
      if(($cur_count + $cur_size) >= $CEXT_SliceSize){
        my $remain = $CEXT_SliceSize - $cur_size;
        push(@$build_bit_map, [$cur_polarity, $remain]);
        $cur_count -= $remain;
        CEXT_ProcessSlice($build_bit_map, $slice_no);
        $slice_no += 1;
        $build_bit_map = [];
        $cur_size = 0;
      }
    }
  };
  return $foo;
}
sub CEXT_DoneReadingBitMap{
  # print STDERR "Finished reading bitmap\n";
  print STATUS "OK\n";
  close STATUS;
  exit 0;
}
sub CEXT_ProcessSlice{
  my($compressed_bm, $slice_no) = @_;
  my $ones = 0;
  my $zeros = 0;
  my $entries = 0;
  $ContourExtractionCounts->{processed} += 1;
  for my $i (@$compressed_bm){
    $entries += 1;
    if($i->[0] == 0){
      $zeros += $i->[1];
    } else {
      $ones += $i->[1];
    }
  }
  my $tot = $ones + $zeros;
  if($ones == 0){
    $ContourExtractionCounts->{ignored_blank} += 1;
    SendStatus;
    return;
  }
  unless(exists $SliceNeeded->{$slice_no}){
    $ContourExtractionCounts->{ignored_to_far} += 1;
    SendStatus;
    return;
  }
  QueueSlice($compressed_bm, $slice_no);
  SendStatus;
}
sub QueueSlice{
  my($compressed_bm, $slice_no) = @_;
  $ContourExtractionCounts->{queued} += 1;
#print "Queueing Slice $slice_no";
#DumpContourExtractionCounts();
  my @bm;
  for my $i (@$compressed_bm){
    if($i->[0] == 0){
      while($i->[1] > 0){
        if($i->[1] > 0x7f){
          push(@bm, 0x7f);
          $i->[1] -= 0x7f;
        } else {
          push(@bm, $i->[1]);
          $i->[1] = 0;
        }
      }
    } else {
      while($i->[1] > 0){
        if($i->[1] > 0x7f){
          push(@bm, 0xff);
          $i->[1] -= 0x7f;
        } else {
          push(@bm, 0x80 | $i->[1]);
          $i->[1] = 0;
        }
      }
    }
  }
  my $bm_str;
  {
    no warnings;
    $bm_str = pack("c*", @bm);
  }
  my $len = length($bm_str);
  my $queue_entry = {
    bm_str => $bm_str,
    slice_no => $slice_no,
  };
  push(@{$CEXT_queue}, $queue_entry);
  CEXT_StartKids();
}
sub CEXT_StartKids{
  if($ContourExtractionCounts->{num_kids} > 5){
    return;
  }
  my $next_kid = shift @{$CEXT_queue};
  if($next_kid){
    $ContourExtractionCounts->{queued} -= 1;
    CEXT_StartAKid($next_kid);
  } else {
    if($ContourExtractionCounts->{num_kids} == 0){
      unless($ContourExtractionCounts->{reading_bitmap}){
        CEXT_DoneReadingBitMap();
      }
    }
  }
}
sub CEXT_StartAKid{
  my($kid) = @_;
  my $contour_file = $args->{base_file} . "_$kid->{slice_no}";
  my $to_file;
  unless(open($to_file, ">", $contour_file)){
    die "Couldn't open contour file $contour_file";
  }
  $kid->{file_name} = $contour_file;
  my $data_p = PipeChildren::GetSocketPair(my $d_p_f, my $d_p_t);
  my $stat_p = PipeChildren::GetSocketPair(my $s_p_f, my $s_p_t);
  my $fds = {
    in => $data_p->{from},
    out => $to_file,
    status => $stat_p->{to},
  };
  my $child_args = {
    x => $args->{x},
    y => $args->{y},
    x_spc => $args->{interval},
    y_spc => $args->{interval},
    rows => $args->{rows},
    cols => $args->{cols},
    slice_index => $kid->{slice_no},
  };
  my $pid = PipeChildren::Spawn(
    "CompressedPixBitMapToContour.pl", $fds, $child_args);
  my @bm;
  my $sock_num = fileno($stat_p->{from});
  Dispatch::Select::Socket->new(CEXT_StatusReader($pid, $kid),
    $stat_p->{from})->Add("reader");
  $ContourExtractionCounts->{num_kids} += 1;
  my $to_h = $data_p->{to};
  print $to_h $kid->{bm_str};
  delete $kid->{bm_str};
}
sub CEXT_StatusReader{
  my($pid, $kid) = @_;
  my $reply = "";
  my $foo = sub {
    my($disp, $sock) = @_;
    my $sock_num = fileno($sock);
    my $count = sysread($sock, $reply, 1024, length($reply));
    unless($count){
      $disp->Remove;
      waitpid $pid, 0;
      if($reply =~ /^OK/){
        $ContourExtractionCounts->{completed} += 1;
        print STATUS
          "ExtractContourFile: " .
          $kid->{slice_no} . " \"" .
          $kid->{file_name} . "\"\n";
      } else {
        $ContourExtractionCounts->{errors} += 1;
      }
#      $this->{ContourExtractionCounts}->{queued} -= 1;
      $ContourExtractionCounts->{num_kids} -= 1;
      CEXT_StartKids;
    }
  };
}
######################################################################
1;
