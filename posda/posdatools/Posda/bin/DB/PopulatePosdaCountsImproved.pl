#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use DBI;
use Posda::DB::PosdaFilesQueries;
unless($#ARGV == 1) { die "usage: $0 <posda_files_db> <posda_counts_db>" }
my $dbf = DBI->connect("dbi:Pg:dbname=$ARGV[0]",
  "", "");
my $dbc = DBI->connect("dbi:Pg:dbname=$ARGV[1]",
  "", "");
my $get_counts = PosdaDB::Queries->GetQueryInstance("PosdaTotals");
$get_counts->Prepare($dbf);
my $insert_counts = PosdaDB::Queries->GetQueryInstance("UpdateCountsDb");
$insert_counts->Prepare($dbc);
my $insert_rpt = $dbc->prepare("insert into count_report(at) values (now())");
$insert_rpt->execute;
$get_counts->execute;
$get_counts->Rows(sub{
  my($h) = @_;
  $insert_counts->Execute($h->{project_name}, $h->{site_name},
    $h->{num_subjects}, $h->{num_studies}, $h->{num_series}, $h->{total_files});
});
