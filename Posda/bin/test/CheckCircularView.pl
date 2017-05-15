#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
my $q = PosdaDB::Queries->GetQueryInstance("GetBasicImageGeometry");
my @List;
$q->RunQuery(sub {
  my($row) = @_;
  my($x, $y, $z) = split /\\/, $row->[1];
  push(@List, [$x, $y, $z]);
}, sub {}, $ARGV[0]);
for my $i (@List){
  my($x, $y, $z) = @$i;
  my $s = ($x * $x) + ($y * $y);
  print "$s, $z\n";
}
