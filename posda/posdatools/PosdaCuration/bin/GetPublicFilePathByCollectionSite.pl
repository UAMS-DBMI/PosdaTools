#!/usr/bin/perl -w
#
use strict;
use DBI;
my $dbh = DBI->connect("DBI:mysql:database=ncia;host=144.30.1.74", "nciauser",
                       "nciA#112");
my $q = <<EOF;
select
  p.patient_id as PID,
  t.study_instance_uid,
  t.study_desc,
  s.series_instance_uid,
  s.general_series_pk_id,
  s.series_desc,
  s.body_part_examined,
  p.patient_name,
  s.patient_id,
  s.visibility,
  t.study_pk_id,
  t.study_date,
  t.study_desc,
  s.modality
from
  general_series s,
  study t,
  patient p,
  trial_data_provenance tdp
where
  s.study_pk_id = t.study_pk_id and
  t.patient_pk_id = p.patient_pk_id and
  p.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ? and
  tdp.dp_site_name = ?;
EOF
my $q1 = <<EOF;
select 
  dicom_file_uri, md5_digest, curation_timestamp, dicom_size, image_pk_id,
  sop_instance_uid
from
  general_image
where
  general_series_pk_id = ?;
EOF
my $p = $dbh->prepare($q);
$p->execute($ARGV[0], $ARGV[1]);
my @list;
while(my $h = $p->fetchrow_hashref){
  push(@list, $h);
}
my $count = @list;
print "$count series in $ARGV[0]/$ARGV[1]\n";
for my $i (@list){
  my $p1 = $dbh->prepare($q1) or die $!;
  $p1->execute($i->{general_series_pk_id});
  my @images;
  while(my $h = $p1->fetchrow_hashref){
    push @images, $h;
  }
  my $ser_count = @images;
  print "$ser_count images in $i->{series_desc}\n";
  my $num_present = 0;
  my $num_absent = 0;
  for my $j (@images){
    my $file = $j->{dicom_file_uri};
    my $db_root = "/mnt/sdd1/tcia/storage";
    my $fs_root = "/mnt/intake1-data/tcia/storage";
    $file =~ s/$db_root/$fs_root/o;
    if (-f $file) {
      $num_present += 1;
#      print "\t present: $j->{dicom_file_uri}\n";
    } else {
      $num_absent += 1;
#      print "\t  absent: $j->{dicom_file_uri}\n";
    }
  }
  print "Series $i->{series_instance_uid} has $num_present present and " .
    "$num_absent absent files"; 
  if($num_absent > 0) {print "<<<<<<"}
  print "\n";
}
