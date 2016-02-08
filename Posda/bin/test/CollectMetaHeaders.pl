#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use strict;
use Posda::Dataset;
use Posda::Find;
use Debug;
my $dbg = sub {print @_};
Posda::Dataset::InitDD();
my $usage = sub {
	print "usage: $0 <source directory> ";
	exit -1;
};
unless(
	$#ARGV >= 0
) {
	&$usage();
}
my $dir = $ARGV[0];
my $cwd = getcwd;
unless($dir =~ /^\//) { $dir = "$cwd/$dir" }
unless(-d $dir) { die "$dir is not a directory" }
my $list = Posda::Find::CollectMetaHeaders($dir);
for my $i (@$list){
  print "File: $i->{file}\n";
  print "offset: $i->{offset}\n";
  print "length: $i->{length}\n";
  print "sop_class: $i->{sop_class}\n";
  print "sop_inst: $i->{sop_inst}\n";
  print "xfr_stx: $i->{xfr_stx}\n";
  print "##############\n";
}
