#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use strict;
my $usage =  "usage: IheSendMultiDirs.pl <called_addr> " .
  "<called_port> <called_ae> <calling_ae> <dir> [ <dir> ]";
unless($#ARGV >= 4) { die $usage }
my $cwd = getcwd;
my $called_addr = shift @ARGV;
my $called_port = shift @ARGV;
my $called_ae = shift @ARGV;
my $calling_ae = shift @ARGV;
while (my $dir = shift @ARGV){
  unless($dir =~ /^\//){ $dir = "$cwd/$dir" }
  unless(-d $dir) {
    print STDERR "$dir is not a directory\n";
    next;
  }
  print "storescu -v +sd -aet $calling_ae +sd -aec $called_ae $called_addr " .
    "$called_port \"$dir\"\n";
}
