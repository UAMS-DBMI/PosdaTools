#!/usr/bin/perl -w
#
use strict;
use DBI;
my $usage = 
  "GetIntakeImagesForCollectionSite.pl <db_host> <collection> <site>\n";
unless($#ARGV == 2) { die $usage }
my $db_host = $ARGV[0];
my $collection = $ARGV[1];
my $site = $ARGV[2];
my $qt = <<EOF;
select
        p.patient_id as PID,
        i.image_type as ImageType,
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
EOF
my $dbh = DBI->connect("DBI:mysql:database=ncia;host=$db_host",
  "nciauser", "nciA#112");
unless($dbh) { die "connect failed" }
my $q = $dbh->prepare($qt);
$q->execute($collection, $site);
while(my $h = $q->fetchrow_hashref){
  print "$h->{PID}|$h->{SopInstance}|$h->{StudyInstanceUID}|" .
        "$h->{SeriesInstanceUID}\n";
}
