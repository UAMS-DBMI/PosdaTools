#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/TciaCuration/bin/ExtractAllCollectionSubj.pl,v $
#$Date: 2015/01/06 20:44:57 $
#$Revision: 1.1 $
#
use strict;
use DBI;
my $dbh = DBI->connect("DBI:mysql:database=ncia;host=$ARGV[0]", "nciauser", "nciA#112");
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
  tdp.dp_site_name = ? and
  p.patient_id = ?;
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
my $p = $dbh->prepare($q) or die "$!";
$p->execute($ARGV[1], $ARGV[2], $ARGV[3]) or die $!;
my @list;
while(my $h = $p->fetchrow_hashref){
  push(@list, $h);
}
for my $i (@list) {
  my $body_part = "<undef>";
  if(defined $i->{body_part_examined}) {$body_part = $i->{body_part_examined}}
  my $desc = "<undef>";
  my $t_desc = "<undef>";
  if(defined $i->{series_desc}) {$desc = $i->{series_desc}}
  if(defined $i->{study_desc}) {$t_desc = $i->{study_desc}}
#  print "series: $i->{modality}, " .
#    "$i->{general_series_pk_id}, $i->{visibility}, $desc\n" .
#    "study: $i->{study_pk_id}, body_part: $body_part\n";
  my $p1 = $dbh->prepare($q1) or die "$!";
  $p1->execute($i->{general_series_pk_id});
  while(my $h = $p1->fetchrow_hashref){
    my $uri = $h->{dicom_file_uri};
    my $md5 = $h->{md5_digest};
    my $tim = $h->{curation_timestamp};
    unless(defined $tim) { $tim = "" }
    my $size = $h->{dicom_size};
    my $image_pk_id = $h->{image_pk_id};
    if($uri =~ /(storage\/.*)$/){
      $uri = "/mnt/erlbluearc/systems/cipa1-v01/data/$1";
    }
    print 
      "$i->{modality}|" .
      "$i->{general_series_pk_id}|" .
      "$i->{series_instance_uid}|" .
      "$desc|" .
      "$i->{visibility}|" .
      "$i->{study_pk_id}|" .
      "$i->{study_instance_uid}|" .
      "$t_desc|" .
      "$body_part|" .
      "$uri|$md5|$tim|$size|$image_pk_id|$i->{PID}|" .
      "$h->{sop_instance_uid}\n";
  }
}

