#!/usr/bin/perl -w 
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Posda::Try;
unless($#ARGV == 1) { die "usage: $0 <from> <to>" }
use Cwd;
my $dir = getcwd;
my $from = $ARGV[0];
my $to = $ARGV[1];
unless($from =~ /^\//) { $from = "$dir/$from" }
unless($to =~ /^\//) { $to = "$dir/$to" }
my $try = Posda::Try->new($from);
unless(exists $try->{dataset}) {die "$from didn't parse as a DICOM dataset" }
$try->{dataset}->MapPvt(sub {
  my($ele, $sig) = @_;
  if($sig =~ /\"/){ $try->{dataset}->Delete($sig); }
});
$try->{dataset}->WritePart10($to, $try->{xfr_stx}, "POSDA", undef, undef);
