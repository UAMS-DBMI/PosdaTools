#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/TciaCuration/bin/ExtractVisibleCollection.pl,v $
#$Date: 2014/11/14 21:48:10 $
#$Revision: 1.2 $
#
use strict;
use DBI;
my $dbh = DBI->connect("DBI:mysql:database=ncia;host=$ARGV[2]", "nciauser", "nciA#112");
my $q = <<EOF;
select
  p.patient_id as PID,
  t.study_instance_uid,
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
  tdp.dp_site_name = ?
  and s.visibility;
EOF
my $q1 = <<EOF;
select 
  dicom_file_uri
from
  general_image
where
  general_series_pk_id = ?;
EOF
my $p = $dbh->prepare($q) or die "$!";
$p->execute($ARGV[0], $ARGV[1]) or die $!;
my @list;
while(my $h = $p->fetchrow_hashref){
  push(@list, $h);
}
for my $i (@list) {
  my $body_part = "<undef>";
  if(defined $i->{body_part_examined}) {$body_part = $i->{body_part_examined}}
  my $desc = "<undef>";
  if(defined $i->{series_desc}) {$desc = $i->{series_desc}}
  print "series: $i->{modality}, " .
    "$i->{general_series_pk_id}, $i->{visibility}, $desc\n" .
    "study: $i->{study_pk_id}, body_part: $body_part\n";
  my $p1 = $dbh->prepare($q1) or die "$!";
  $p1->execute($i->{general_series_pk_id});
  while(my $h = $p1->fetchrow_hashref){
    print "\t$h->{dicom_file_uri}\n";
  }
}

