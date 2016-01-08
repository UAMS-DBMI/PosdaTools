#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/IheSortPatId.pl,v $
#$Date: 2013/05/13 12:40:25 $
#$Revision: 1.1 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use strict;
use Posda::Parser;
use Posda::Dataset;
use Posda::Find;
use Posda::Try;

my $usage = "usage:IheRoFixPatientOrientation.pl  <dir>";
unless($#ARGV == 0) {die $usage}
my $dir = $ARGV[0];
Posda::Dataset::InitDD();
unless($dir =~ /^\//) {$dir = getcwd."/$dir"}
unless(-d $dir) { die "$dir is not a directory" }

sub MakeFinder {
  my $sub = sub {
    my($try) = @_;
    unless(exists $try->{dataset}) { return };
    my $pat_id = $try->{dataset}->Get("(0010,0020)");
    unless($pat_id){ return }
    unless(-d "$dir/$pat_id") { mkdir "$dir/$pat_id" };
    `mv \"$try->{filename}\" \"$dir/$pat_id\"`;
  };
  return $sub;
}
Posda::Find::FastDicomOnly($dir, MakeFinder());
