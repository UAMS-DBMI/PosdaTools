#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
my $usage = "usage: HideSeriesWithStatus.pl <patient_id> <user> <reason>\n";
unless($#ARGV == 2) { die $usage }
my $get_file = PosdaDB::Queries->GetQueryInstance(
  'GetFileIdVisibilityByPatientId');
my @rows;
open SUBP, "|HideFilesWithStatus.pl $ARGV[1] \"$ARGV[2]\""
  or die "can't open subprocess ($!)";
$get_file->RunQuery(
  sub {
    my($row) = @_;
    my($file_id, $old_visibility) = @$row;
    unless(defined $old_visibility) { $old_visibility = '<undef>' }
    print SUBP "$file_id&$old_visibility\n";
  },
  sub {
  },
  $ARGV[0]
);
