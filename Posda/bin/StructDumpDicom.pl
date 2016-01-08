#!/usr/bin/perl -w 
#$Source: /home/bbennett/pass/archive/Posda/bin/StructDumpDicom.pl,v $
#$Date: 2011/09/12 13:45:12 $
#$Revision: 1.3 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Posda::Parser;
use Posda::Dataset;
use Debug;
my $dbg = sub {print @_};

my $infile = $ARGV[0];
my $depth = $ARGV[1];
my $path = $ARGV[2];

Posda::Dataset::InitDD();
my $dd = $Posda::Dataset::DD;

my($df, $ds, $size, $xfr_stx, $errors)  = Posda::Dataset::Try($ARGV[0]);

if($ds){
  if($df){
    print "DF:";
    Debug::GenPrint($dbg, $df, 1, $depth);
    print "\n";
  }
  print "DS:";
#  $ds->MapToConvertPvt();
  if(defined $path){
    Debug::GenPrint($dbg, $ds->{$path}, 1, $depth);
  } else {
    Debug::GenPrint($dbg, $ds, 1, $depth);
  }
  print "\n";
} else {
  for my $i(@$errors){
     print "$i\n";
  }
}
