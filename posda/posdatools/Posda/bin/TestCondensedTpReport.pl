#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::ActivityInfo;
use Debug;
my $dbg = sub { print @_ };

my $usage = <<EOF;
Usage:
TestCondensedTpReport.pl  <activity_id> <act_tp_id> <mode>
  or
TestCondensedTpReport.pl -h

Expects nothing STDIN 

Generates a Condensed Timepoint Report on STDOUT
<mode> = "struct" for a perl structure dump
       = "csv" for a csv file
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }
unless($#ARGV == 2) { print $usage; exit }
my($act_id, $tp_id, $mode) = @ARGV;
#########Generate Old Tp Reports#######################
my $ActInfo = Posda::ActivityInfo->new($act_id);
my $TpFileInfo = $ActInfo->GetFileInfoForTp($tp_id);
my $hier = $ActInfo->MakeCondensedHierarchyFromInfo(
  $TpFileInfo);
if($mode eq "struct"){
  print "Condensed activity report structure:\n";
  Debug::GenPrint($dbg, $hier, 1);
  print "\n";
} else {
  $ActInfo->PrintCondensedHierarchyReport(*STDOUT, $hier);
}
