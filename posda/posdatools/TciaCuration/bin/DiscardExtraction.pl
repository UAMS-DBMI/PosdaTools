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
use Debug;
$| = 1;
my $dbg = sub { print STDERR @_ };
my $help = <<EOF;
Usage: DiscardExtraction.pl <directory>
or
       DiscardExtraction.pl -h
EOF
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
print "Status=Running&directory=$dir\n";
#print STDERR "remove_tree $dir (commented out)\n";
remove_tree $dir;
print "Status=OK&directory=$dir\n";
