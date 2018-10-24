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
my $usage = "usage: $0 <file> <modality>";
my $file = $ARGV[0];
unless($file =~ /^\//) {$file = getcwd."/$file"}
sub handle {
  my($path, $df, $ds, $size, $xfr_stx, $errors) = @_;
  my $Modality = $ds->ExtractElementBySig("(0008,0060)");
  if($Modality eq $ARGV[1]){
    print "$path\n";
  }
}
Posda::Find::SearchDir($file, \&handle);
