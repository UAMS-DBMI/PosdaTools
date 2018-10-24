#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
my $usage = <<EOF;
FindAndCompareFiles.pl <root> <collection> <site>
EOF
unless($#ARGV == 2) { die $usage }
my $q_inst = PosdaDB::Queries->GetQueryInstance(
  "PatientStudySeriesFileHierarchyByCollectionSite");
$q_inst->RunQuery(sub{
  my($row) = @_;
  my $patient_id = $row->[0];
  my $study_instance_uid = $row->[1];
  my $series_instance_uid = $row->[2];
  my $sop_instance_uid = $row->[3];
  my $modality = $row->[4];
  my $file_name = "$ARGV[0]/$patient_id/$study_instance_uid/" .
    "$series_instance_uid/${modality}_$sop_instance_uid.dcm";
  unless(-f $file_name) {
    print "$patient_id&$study_instance_uid&$series_instance_uid\n";
  }
}, sub {}, $ARGV[1], $ARGV[2]);
