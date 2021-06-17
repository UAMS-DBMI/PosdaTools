#!/usr/bin/perl -w 
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Posda::Try;
use Debug;
use Time::HiRes qw( time );
my $dbg = sub {print @_};
unless($#ARGV == 0) { die "usage: $0 <file>" }
use Cwd;
my $dir = getcwd;
my $from = $ARGV[0];
unless($from =~ /^\//) { $from = "$dir/$from" }
my $try = Posda::Try->new($from);
unless(exists $try->{dataset}) {
  print "Try: ";
  Debug::GenPrint($dbg, $try, 1);
  print "\n";
  die "$from didn't parse as a DICOM dataset"
}
if(
  exists($try->{parser_warnings}) && ref($try->{parser_warnings}) eq "ARRAY" &&
  $#{$try->{parser_warnings}} >= 0
){
  for my $i (@{$try->{parser_warnings}}){
    print "$i\n";
  }
}

