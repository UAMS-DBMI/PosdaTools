#!/usr/bin/perl -w
use strict;
my $usage = <<EOF;
UpdatePatStat.pl <who> <why>
  expects "<patient_id>, <old_status>, <new_status>" on STDIN
EOF
unless($#ARGV == 1) {die $usage};
my($who, $why) = @ARGV;
use Posda::DB::PosdaFilesQueries;
#my $get = PosdaDB::Queries->GetQueryInstance("GetPatientStatus");
my $upd = PosdaDB::Queries->GetQueryInstance("UpdatePatientImportStatus");
my $rec = PosdaDB::Queries->GetQueryInstance("RecordPatientStatusChange");
my $nop = sub { };
while(my $line = <STDIN>){
  chomp $line;
  my($pat_id, $old_status, $new_status) = split(/\s*,\s*/, $line);
#  my $old_stat;
#  $get->RunQuery(sub {
#    my($row) = @_;
#    $old_stat = $row->[0];
#  }, $nop, $pat_id);
  $upd->RunQuery($nop, $nop, $new_status, $pat_id);
  $rec->RunQuery($nop, $nop, $pat_id, $who, $why, $old_status, $new_status);
  print "$pat_id status changed from $old_status to $new_status by $who for $why\n";
}
