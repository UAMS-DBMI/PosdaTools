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
unless($#ARGV == 1) { die "usage: $0 <file> <fast>" }
use Cwd;
my $dir = getcwd;
my $from = $ARGV[0];
my $fast = $ARGV[1];
unless($from =~ /^\//) { $from = "$dir/$from" }
my $start = time;
my $try = Posda::Try->new($from, $fast);
unless(exists $try->{dataset}) {
  print "Try: ";
  Debug::GenPrint($dbg, $try, 1);
  print "\n";
  die "$from didn't parse as a DICOM dataset"
}
my $interval = time - $start;
print "Time: $interval\n";
$try->{dataset}->DumpStyle0(\*STDOUT, 64, 300);
#print "Dataset: ";
#Debug::GenPrint($dbg, $try->{dataset}, 1);
#print "\n";

