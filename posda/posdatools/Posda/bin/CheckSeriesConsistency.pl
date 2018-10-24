#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use DBI;
use Posda::DB::PosdaFilesQueries;
use Debug;
my $dbg = sub { print STDERR @_ };
my $help = <<EOF;
Usage: 
  CheckSeriesConsistency.pl  <series>
or
  CheckSeriesConsistency.pl -h
EOF

if($#ARGV != 0 || ($ARGV[0] eq "-h")){
  print $help;
  exit;
}
my $q_inst = PosdaDB::Queries->GetQueryInstance("SeriesConsistency");
my $db_name = $q_inst->GetSchema;
my $dbh = DBI->connect("dbi:Pg:dbname=$db_name");
unless($dbh) { die "Can't connect to $db_name" }
my @Rows;
my $add_row = sub {
  my($row) = @_;
  push @Rows, $row;
};
$q_inst->Prepare($dbh);
$q_inst->Execute($ARGV[0]);
$q_inst->Rows($add_row);
if(@Rows == 1){
#  print "series $ARGV[0] is consistent\n";
  exit;
} elsif (@Rows <= 0){
#  print "series $ARGV[0] is not in DB\n";
  exit;
}
my %ValueCounts;
my $total_count = 0;
for my $row (@Rows){
  my $count = $row->{count};
  $total_count += $count;
  for my $key (keys %$row){
    my $value = $row->{$key};
    unless(defined $value) { $value = "<undef>" }
    if($value eq "") { $value = "<blank>" }
    unless(exists $ValueCounts{$key}->{$value}){
      $ValueCounts{$key}->{$value} = 0;
    }
    $ValueCounts{$key}->{$value} += $count;
  }
}
print "series $ARGV[0] has inconsistencies:\n" .
      "\tof $total_count\n";
for my $key (keys %ValueCounts){
  if($key eq "count") { next }
  if(keys %{$ValueCounts{$key}} == 1) { next }
  for my $v (keys %{$ValueCounts{$key}}){
    my $c = $ValueCounts{$key}->{$v};
    print "\t\t$key has $c occurances of value $v\n";
  }
}
