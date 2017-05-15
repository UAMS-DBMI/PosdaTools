#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
my $usage = <<EOF;
UpdateBacklogPriorities.pl
  Updates Priorities of Collections in posda_backlog database
Expects lines on STDIN:
  <collection>&<priority>
EOF
if($#ARGV >= 0){
  print STDERR $usage;
  exit -1;
}
my $upd = PosdaDB::Queries->GetQueryInstance("UpdateCollectionBacklogPrio");
while(my $line = <STDIN>){
  chomp $line;
  my($collection, $prio) = split(/&/, $line);
  $collection =~ s/^\s*//;
  $prio =~ s/^\s*//;
  $collection =~ s/\s*$//;
  $prio =~ s/^\s*$//;
print "updating collection $collection to priority $prio\n";
  $upd->RunQuery(sub{}, sub {}, $prio, $collection);
}
