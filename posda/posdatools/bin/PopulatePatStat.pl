#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
my $ins = PosdaDB::Queries->GetQueryInstance("InsertInitialPatientStatus");
my $nop = sub { };
while(my $line = <STDIN>){
  chomp $line;
  my($pat_id, $status) = split(/\s*,\s*/, $line);
  $ins->RunQuery($nop, $nop, $pat_id, $status);
  print "set status of $pat_id to '$status'\n";
}
