#!/usr/bin/perl -w
#
#Copyright 2012, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Try;
my $file = shift @ARGV;
my $try = Posda::Try->new($file);
unless(exists $try->{dataset}) { die "$file isn't a DICOM file" }
for my $sig (@ARGV){
  my $v = $try->{dataset}->Get($sig);
  my $d = $try->{dataset}->GetEle($sig);
  unless(defined $d) {
    print STDERR "$sig doesn't occur in dataset\n";
    next;
  }
  unless(defined $v) {
    print STDERR "$sig occurs but is undefined\n";
  }
  print "$sig = $v\n";
  my $digest = $try->{dataset}->ValueDigest($sig, $v);
  print "digest = $digest\n";
}
