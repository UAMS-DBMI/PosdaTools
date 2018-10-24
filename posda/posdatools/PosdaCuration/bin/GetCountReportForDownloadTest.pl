#!/usr/bin/perl -w
#
use strict;
use DBI;
my $usage = "GetCountsReportForDwnload.pl <db> <collection> <site>\n";
my $dbh = DBI->connect("DBI:Pg:database=$ARGV[0]", "", "");
my $q = <<EOF;
select
  distinct 
    patient_id, image_type, modality, study_date, study_description,
    series_description, study_instance_uid, series_instance_uid, 
    manufacturer, manuf_model_name, software_versions,
    count(*) as num_files
from
  ctp_file join file_patient using(file_id) 
  join file_series using(file_id)
  join file_study using(file_id)
  join file_equipment using(file_id)
  left join file_image using(file_id)
  join image using (image_id)
where 
  project_name = ? and site_name = ? and visibility is null
group by
  patient_id, image_type, modality, study_date, study_description,
  series_description, study_instance_uid, series_instance_uid, 
  manufacturer, manuf_model_name, software_versions
order by
  patient_id, study_instance_uid, series_instance_uid, image_type, 
  modality, study_date, study_description,
  series_description,
  manufacturer, manuf_model_name, software_versions
EOF
my %Series;
my $current_study;
my $in_current_study = 0;
my $qh = $dbh->prepare($q);
$qh->execute($ARGV[1], $ARGV[2]);
while(my $h = $qh->fetchrow_hashref){
  unless(defined $current_study) { $current_study = $h->{study_instance_uid} }
  unless($current_study eq $h->{study_instance_uid}){
    print "\"Study Total:\",,,\"$in_current_study\"\n";
    $current_study = $h->{study_instance_uid};
    $in_current_study = 0;
  }
  $in_current_study += $h->{num_files};
  my @foo = split(/\\/, $h->{image_type});
  my $image_type = $foo[0];
  print 
    "\"$h->{patient_id}\"," .
    "\"$image_type\"," .
    "\"$h->{modality}\"," .
    "\"$h->{num_files}\"," .
    "\"$h->{study_date}\"," .
    "\"$h->{study_description}\"," .
    "\"$h->{series_description}\"," .
    "\"$h->{study_instance_uid}\"," .
    "\"$h->{series_instance_uid}\"," .
    "\"$h->{manufacturer}\"," .
    "\"$h->{manuf_model_name}\"," .
    "\"$h->{software_versions}\"\n";
}
