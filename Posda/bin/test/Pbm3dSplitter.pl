#!/usr/bin/perl -w
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
open INPUT, "<$file" or die "can't open $file";
my $slice_size = ($rows * $cols) / 8;
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
#  my $pid = PipeChildren::Spawn("ToPbm.pl", $fd_map, $parms);
  my $pid = PipeChildren::Spawn("ToPbm", $fd_map, $parms);
  my $to = $to_pbm->{to};
  my $stat = $stat_pbm->{from};
  print $to $buff;
  close $to;
  my $resp;
  read($stat, $resp, 1024);
  print "Response from writing $pbm_file: $resp\n";
}
