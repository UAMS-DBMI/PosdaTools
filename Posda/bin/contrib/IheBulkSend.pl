#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/IheBulkSend.pl,v $
#$Date: 2013/05/08 09:16:37 $
#$Revision: 1.1 $
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use strict;
my $usage =  "usage: IheBulkSend.pl <dir_of_dirs> <called_addr> " .
  "<called_port> <called_ae> <calling_ae>";
unless($#ARGV == 4) { die $usage }
my $cwd = getcwd;
my $dir_of_dirs = $ARGV[0];
my $called_addr = $ARGV[1];
my $called_port = $ARGV[2];
my $called_ae = $ARGV[3];
my $calling_ae = $ARGV[4];
unless($dir_of_dirs =~ /^\//) { $dir_of_dirs = "$cwd/$dir_of_dirs" }
unless(-d $dir_of_dirs) { die "$dir_of_dirs is not a directory " }
opendir DIR, $dir_of_dirs or die "can't opendir $dir_of_dirs";
while(my $dir = readdir(DIR)){
  if($dir =~ /^\./) { next }
  unless(-d "$dir_of_dirs/$dir") { next }
  print "storescu -v +sd -aet $calling_ae +sd -aec $called_ae $called_addr " .
    "$called_port \"$dir_of_dirs/$dir\"\n";
}
