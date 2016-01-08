#!/usr/bin/perl -w 
#$Source: /home/bbennett/pass/archive/Posda/bin/ae/MakeFileList.pl,v $
#$Date: 2011/06/23 15:31:26 $
#$Revision: 1.4 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use Posda::Find;
Posda::Dataset::InitDD();

sub usage {
	print "usage: $0 <file> <file> ...";
	exit -1;
}
unless($#ARGV >0){&usage();}	# This is a file list we need ATLEAST 2 files.
my @FileList;

my $map = sub {
  my($path, $df, $ds, $size, $xfr_stx, $errors) = @_;
  my $sop_class = $ds->ExtractElementBySig("(0008,0016)");
  my $sop_instance = $ds->ExtractElementBySig("(0008,0018)");
  print "file|$sop_class|$sop_instance|$xfr_stx|$path\n";
};
for my $i (@ARGV){
  unless($i=~/^\//){$i=getcwd."/$i"}
  Posda::Find::SearchDir($i, $map);
}
