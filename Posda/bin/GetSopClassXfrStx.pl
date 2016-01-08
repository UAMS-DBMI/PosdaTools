#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/GetSopClassXfrStx.pl,v $
#$Date: 2011/06/23 15:31:25 $
#$Revision: 1.4 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use Posda::Parser;
use Posda::Dataset;

my $usage = "usage: $0 <file>";
unless($#ARGV == 0) {die $usage}

my $infile = $ARGV[0];
unless($infile =~ /^\//) {$infile = getcwd."/$infile"}

Posda::Dataset::InitDD();
open FILE, "<$infile";
my $mh = Posda::Parser::ReadMetaHeader(\*FILE);
close FILE;
if($mh){
  my $sop_cl = $mh->{metaheader}->{"(0002,0002)"};
  my $sop_inst = $mh->{metaheader}->{"(0002,0003)"};
  my $xfr_stx = $mh->{xfrstx};
  print "Sop Class: $sop_cl Xfr Stx: $xfr_stx Sop Inst: $sop_inst\n";
} else {
  my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($ARGV[0]);
  if($ds){
    my $sop_class = $ds->ExtractElementBySig("(0008,0016)");
    my $sop_inst = $ds->ExtractElementBySig("(0008,0018)");
    print "Sop Class: $sop_class Xfr Stx: $xfr_stx Sop Inst: $sop_inst\n";
  } else {
    print "Error\n";
  }
}
