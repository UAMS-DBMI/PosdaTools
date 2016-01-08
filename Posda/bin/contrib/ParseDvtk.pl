#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/ParseDvtk.pl,v $
#$Date: 2008/10/13 16:01:21 $
#$Revision: 1.1 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Dvtk;
my $files_ok = 0;
my $files_bad = 0;
for my $f (@ARGV){
  my $dvt;
print "$f:\n";
  eval { $dvt = Posda::Dvtk->new($f) };
  if($@){
    print "Error processing $f: $@\n";
#    print "bad: $f\n";
    $files_bad += 1;
  } else {
    $files_ok += 1;
  }
}
print "$files_bad \tfiles with errors\n$files_ok\t files ok\n";
