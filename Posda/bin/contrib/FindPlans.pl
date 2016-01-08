#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/FindPlans.pl,v $
#$Date: 2011/06/23 15:31:26 $
#$Revision: 1.2 $
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
my $usage = sub {
	print "usage: $0 <directory>";
	exit -1;
};
unless($#ARGV == 0) { &$usage() }
sub handle {
  my($path, $df, $ds, $size, $xfr_stx, $errors) = @_;
  my $modality = $ds->Get("(0008,0060)");
  if($modality eq "RTPLAN"){
    print "$path\n";
  }
}
Posda::Find::SearchDir($ARGV[0], \&handle);
