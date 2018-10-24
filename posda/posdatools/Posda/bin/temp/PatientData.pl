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
my $Results;
my $usage = sub {
	print "usage: $0 <file>";
	exit -1;
};
unless(
	$#ARGV == 0
) {
	&$usage();
}
my($file) = $ARGV[0]; shift @ARGV;
unless(
	$file =~ /^\//
) {
	$file = getcwd."/$file";
}
sub handle {
  my($path, $df, $ds, $size, $xfr_stx, $errors) = @_;
  my $patient_name = $ds->Get("(0010,0010)");
  my $patient_id = $ds->Get("(0010,0020)");
  $Results->{$patient_id}->{$patient_name} = 1;
}
Posda::Find::SearchDir($file, \&handle);
for my $id (keys %$Results){
  for my $name (keys %{$Results->{$id}}){
    print "Id: $id, name: $name\n";
  }
}
