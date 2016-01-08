#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/IheStripGroup3.pl,v $
#$Date: 2013/05/09 14:19:40 $
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

my $usage = "usage:IheStripGroup3.pl <from_dir> <to_dir>";
unless($#ARGV == 1) {die $usage}
my $from_dir = $ARGV[0];
my $to_dir = $ARGV[1];
Posda::Dataset::InitDD();
unless($from_dir =~ /^\//) {$from_dir = getcwd."/$from_dir"}
unless($to_dir =~ /^\//) {$to_dir = getcwd."/$to_dir"}
unless(-d $from_dir) { die "$from_dir is not a directory" }
unless(-d $to_dir) { die "$to_dir is not a directory" }

sub MakeFinder {
  my($from, $to) = @_;
  my $sub = sub {
    my($try) = @_;
    unless(exists $try->{dataset}) { return };
    my $sop_class = $try->{dataset}->Get("(0008,0016)");
    unless($sop_class eq "1.2.840.10008.5.1.4.1.1.2"){ return }
    my $old_file = $try->{filename};
    unless($old_file =~ /^$from\/(.*)$/) {
       print STDERR "$old_file is not in $from\n";
       return;
    }
    my $new_file = "$to/$1";
#    print "fix_file:\n\told: $old_file\n\tnew: $new_file\n";
#    print "\t$try->{xfr_stx}\n";
    delete $try->{dataset}->{3};
#    $try->{dataset}->Insert("(0020,0020)", 'L\P');
    $try->{dataset}->WritePart10(
        $new_file, $try->{xfr_stx}, "POSDA_FIX", undef, undef);
  };
  return $sub;
}
Posda::Find::DicomOnly($from_dir, MakeFinder($from_dir, $to_dir));
