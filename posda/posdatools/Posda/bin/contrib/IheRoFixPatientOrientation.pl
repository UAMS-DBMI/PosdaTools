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
    my $sop_class = $try->{dataset}->Get("(0008,0016)");
    unless($sop_class eq "1.2.840.10008.5.1.4.1.1.2"){ return }
    my $old_file = $try->{filename};
    my $new_file = "$try->{filename}.new";
#    print "fix_file:\n\told: $old_file\n\tnew: $new_file\n";
#    print "\t$try->{xfr_stx}\n";
    $try->{dataset}->Insert("(0020,0020)", 'L\P');
    $try->{dataset}->WritePart10(
        $new_file, $try->{xfr_stx}, "POSDA_FIX", undef, undef);
    unlink $old_file;
    link $new_file, $old_file;
    unlink $new_file;
  };
  return $sub;
}
Posda::Find::DicomOnly($dir, MakeFinder());
