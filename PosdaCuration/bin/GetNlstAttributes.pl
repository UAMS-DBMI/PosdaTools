#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/PosdaCuration/bin/GetNlstAttributes.pl,v $ #$Date: 2015/12/15 14:12:42 $
#$Revision: 1.1 $
#
use strict;
use DBI;
my $usage = "GetNlstAttributes.pl <db_host> <sop_instance_uid>\n";
unless($#ARGV == 1) { die $usage }
my $dbhost = $ARGV[0];
my $sop_inst = $ARGV[1];
my $dbh = DBI->connect("DBI:mysql:database=ncia;host=$dbhost",
  "nciauser", "nciA#112");
unless($dbh) { die "connect failed" }
my $q = <<EOF;
select
  d.instance_number, d.content_date, d.content_time, d.image_type,
  d.acquisition_date, d.acquisition_time, d.acquisition_number,
  d.lossy_image_compression, d.pixel_spacing, d.image_orientation_patient,
  d.image_position_patient, d.slice_thickness, d.slice_location, d.i_rows,
  d.i_columns, d.contrast_bolus_agent, d.contrast_bolus_route,
  s.body_part_examined, s.frame_of_reference_uid, s.series_laterality,
  s.modality, s.protocol_name, s.series_date, s.series_desc,
  s.series_instance_uid, s.series_number, s.sync_frame_of_ref_uid,
  t.study_instance_uid, t.additional_patient_history, t.study_date,
  t.study_desc, t.admitting_diagnoses_desc, t.admitting_diagnoses_code_seq,
  t.occupation, t.patient_age, t.patient_size, t.study_id, t.study_time,
  t.trial_time_point_id, t.trial_time_point_desc,
  p.patient_id, p.patient_name, p.patient_birth_date, p.patient_sex,
  p.ethnic_group, p.trial_subject_id, p.trial_subject_reading_id
from
  dicom_image d, dicom_series s, dicom_study t, patient p
where
  d.patient_pk_id = p.patient_pk_id and
  d.study_pk_id = t.study_pk_id and
  d.general_series_pk_id = s.general_series_pk_id and
  d.sop_instance_uid = ?
EOF
my $p = $dbh->prepare($q) or die "$!";
$p->execute($sop_inst) or die $!;
my @list;
while(my $h = $p->fetchrow_hashref){
  push(@list, $h);
}
for my $i (@list) {
  for my $k (sort keys %{$i}){
    my $v = $i->{$k};
    unless(defined $v) { $v = "<undef>" }
    print "$k: $v\n";
  }
}

