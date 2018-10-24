#!/usr/bin/perl -w

use strict;
use DBI;

use constant DB_USER => 'nciauser';
use constant DB_PASS => 'nciA#112';

unless($#ARGV == 2) { 
  die "GetIntakeImagesForCollectionSite.pl <db_host> <collection> <site>\n";
}

my $db_host = $ARGV[0];
my $collection = $ARGV[1];
my $site = $ARGV[2];

my $dbh = DBI->connect(
  "DBI:mysql:database=ncia;host=$db_host", DB_USER, DB_PASS);

unless($dbh) {
  die "connect failed";
}

my $query = qq{
  select
    p.patient_id as PID,
    i.image_type as ImageType,
    i.dicom_file_uri as FilePath,
    s.modality as Modality,
    i.sop_instance_uid as SopInstance,
    t.study_date as StudyDate,
    t.study_desc as StudyDescription,
    s.series_desc as SeriesDescription,
    s.series_number as SeriesNumber,
    t.study_instance_uid as StudyInstanceUID,
    s.series_instance_uid as SeriesInstanceUID,
    q.manufacturer as Mfr,
    q.manufacturer_model_name as Model,
    q.software_versions

  from
    general_image i,
    general_series s,
    study t,
    patient p,
    trial_data_provenance tdp,
    general_equipment q

  where
    i.general_series_pk_id = s.general_series_pk_id and
    s.study_pk_id = t.study_pk_id and
    s.general_equipment_pk_id = q.general_equipment_pk_id and
    t.patient_pk_id = p.patient_pk_id and
    p.trial_dp_pk_id = tdp.trial_dp_pk_id and
    tdp.project = ? and
    tdp.dp_site_name = ?
};

my $statement = $dbh->prepare($query);
$statement->execute($collection, $site);

while(my $h = $statement->fetchrow_hashref){
  # print as pipe-delimited lines
  $h->{FilePath} =~ s/sdd1/intake1-data/;
  print join('|', @{[
    $h->{PID},
    $h->{SopInstance},
    $h->{FilePath},
  ]}) . "\n";
}
