#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/PbmDoseSplitter.pl,v $
#$Date: 2011/10/06 16:12:39 $
#$Revision: 1.1 $
#
#Copyright 2011, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use strict;
use PipeChildren;
my $file = $ARGV[0];
my $rows = $ARGV[1];
my $cols = $ARGV[2];
my $slices = $ARGV[3];
my $bytes = $ARGV[4];
my $level = $ARGV[5];
open INPUT, "<$file" or die "can't open $file";
my $slice_size = $rows * $cols * $bytes;
my $buff;
for my $i (0 .. $slices - 1){
  my $len = read(INPUT, $buff, $slice_size);
  unless($len == $slice_size) { die "read $len vs $slice_size" }
  if($file =~ /(.*)\.dat$/){
    $file = $1;
  }
  my $pbm_file = $file . "_$i.pbm";
  open my $fw, ">", $pbm_file;
  my $to_pbm = PipeChildren::GetSocketPair(my $tpbm_child, my $tpbm_parent);
  my $stat_pbm = PipeChildren::GetSocketPair(my $spbm_child, my $spbm_parent);
  my $fd_map = {
    in => $to_pbm->{from},
    status => $stat_pbm->{to},
    out => $fw,
  };
  my $parms = {
    rows => $rows,
    cols => $cols,
  };
  my $pid = PipeChildren::Spawn("ToPbm.pl", $fd_map, $parms);
  my $to = $to_pbm->{to};
  my $stat = $stat_pbm->{from};
  my @pixels = ($bytes == 2) ? unpack("v*", $buff) : unpack("V*", $buff);
  my $byte = 0;
  my $mask = 0x80;
  my @bytes;
  for my $i (@pixels){
print "$i: $level\n";
    if($i > $level){
      $byte |= $mask;
    }
    $mask >>= 1;
    if($mask == 0){
      push(@bytes, $byte);
      $byte = 0;
      $mask = 0x80;
    }
  }
  my $bitmap;
  {
    no warnings;
    $bitmap = pack("c*", @bytes);
  }
  print $to $bitmap;
  close $to;
  my $resp;
  read($stat, $resp, 1024);
  print "Response from writing $pbm_file: $resp\n";
}
