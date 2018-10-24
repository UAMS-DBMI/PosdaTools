#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Debug;
my $dbg = sub {print STDERR @_};
my $usage = <<EOF;
CreateSeriesEquivalenceClasses.pl <collection>
EOF
unless($#ARGV == 0){ die $usage }
if($ARGV[0] eq "-h"){ print STDERR "$usage\n"; exit }
my $q_inst = PosdaDB::Queries->GetQueryInstance(
  "SeriesFileByCollectionWithNoEquivalenceClass");
$q_inst->RunQuery(sub{
   my($row) = @_;
   print "$row->[0]\n";
 },
 sub {},
 $ARGV[0]
);
