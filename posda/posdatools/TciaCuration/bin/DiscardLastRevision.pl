#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use File::Path 'remove_tree';
use Storable;
use Debug;
$| = 1;
my $dbg = sub { print STDERR @_ };
my $help = <<EOF;
Usage: DiscardLastRevision.pl <directory>
or
       DiscardLastRevision.pl -h
EOF
my $start = time;
if($#ARGV == 0 && ($ARGV[0] eq "-h")){
  print $help;
  exit;
}
unless($#ARGV == 0) { die $help }
my $dir = $ARGV[0];
unless($dir && -d $dir){
  print "Status=Failed&directory=$dir&error=doesn't exist\n";
  die "$dir doesn't exist";
}
my $rev_hist = Storable::retrieve("$dir/rev_hist.pinfo");
my $latest_rev = $rev_hist->{CurrentRev};
if($latest_rev == 0){
  print "Status=Error&message=Can't delete Rev 0\n";
  exit;
} else {
  delete $rev_hist->{Revisions}->{$latest_rev};
  $rev_hist->{CurrentRev} = [ sort {$b <=> $a} keys %{$rev_hist->{Revisions}} ]
    ->[0];
  print "Status=Running&directory=$dir&rev_to_delete=" .
    "$dir/revisions/$latest_rev&new_latest=$rev_hist->{CurrentRev}" .
    "&start_time=$start\n";
  remove_tree "$dir/revisions/$latest_rev";
  store $rev_hist, "$dir/rev_hist.pinfo";
}
my $end = time;
my $elapsed = $end - $start;
print "Status=OK&directory=$dir&rev_deleted=$latest_rev" .
  "&new_latest=$rev_hist->{CurrentRev}" .
  "&start_time=$start&end_time=$end&elapsed=$elapsed\n";
