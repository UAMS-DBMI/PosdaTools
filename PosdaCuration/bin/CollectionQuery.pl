#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/PosdaCuration/bin/CollectionQuery.pl,v $ #$Date: 2015/12/15 14:10:27 $
#$Revision: 1.2 $
#
use strict;
use DBI;
my $dbh = DBI->connect("DBI:Pg:database=$ARGV[0]", "", "");
my $q = <<EOF;
select
  distinct modality, body_part_examined, series_description,
  series_date, patient_name, patient_id, sex, series_instance_uid,
  study_instance_uid, study_date, study_description, accession_number,
  study_id,
  count(*)
from
  ctp_file natural join file_patient natural join
  file_series natural join file_study
where
  project_name = ? and site_name = ? and visibility is null
group by
  modality, body_part_examined, series_description,
  series_date, patient_name, patient_id, sex, series_instance_uid,
  study_instance_uid, study_date, study_description, accession_number,
  study_id
order by
  study_instance_uid, series_instance_uid
EOF
my $p = $dbh->prepare($q) or die "$!";
$p->execute($ARGV[1], $ARGV[2]) or die $!;
my @list;
while(my $h = $p->fetchrow_hashref){
  push(@list, $h);
}
for my $i (@list) {
  my $body_part = "<undef>";
  if(defined $i->{body_part_examined}) {$body_part = $i->{body_part_examined}}
  my $desc = "<undef>";
  my $t_desc = "<undef>";
  my $pname = "<undef>";
  my $acces = "<undef>";
  my $ser_date = "<undef>";
  my $st_date = "<undef>";
  my $st_id = "<undef>";
  my $sex = "<undef>";
  if(defined $i->{series_description}) {$desc = $i->{series_description}}
  if(defined $i->{study_description}) {$t_desc = $i->{study_description}}
  if(defined $i->{patient_name}) {$pname = $i->{patient_name}}
  if(defined $i->{sex}) {$sex = $i->{sex}}
  if(defined $i->{accession_number}) {$acces = $i->{accession_number}}
  if(defined $i->{series_date}) {$ser_date = $i->{series_date}}
  if(defined $i->{study_date}) {$st_date = $i->{study_date}}
  if(defined $i->{study_id}) {$st_id = $i->{study_id}}
  print("$i->{patient_id}|$pname|$i->{study_instance_uid}|$st_date|$t_desc|" .
    "$i->{series_instance_uid}|$ser_date|$desc|$i->{modality}|$sex|$acces|" .
    "$st_id|$body_part|$i->{count}\n");
}

#my($pat_id, $pname, $st_inst, $st_date, $st_desc,
#   $ser_inst, $ser_date, $ser_desc, $modality, $sex,
#   $access, $st_id, $body_p, $count) = split(/\|/, $line);

