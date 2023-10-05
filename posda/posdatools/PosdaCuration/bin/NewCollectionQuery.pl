#!/usr/bin/perl -w

use strict;
use DBI;

if ($#ARGV < 2) {
  die("Usage: NewCollectionQuery.pl " .
      "<database_name> <collection name> <site name>\n");
}

my $dbh = DBI->connect("DBI:Pg:database=$ARGV[0]", "", "");

my $query = qq{
  select
    distinct modality,
    body_part_examined,
    series_description,
    series_date,
    patient_name,
    patient_id,
    sex,
    series_instance_uid,
    study_instance_uid,
    study_date,
    study_description,
    accession_number,
    study_id,
    count(distinct file_id)
  from
    ctp_file 
    natural join file_patient 
    natural join file_series 
    natural join file_study
  where
    file_id in (
      select file_id
      from ctp_file
      where project_name = ? and site_name = ?
    )
  group by
    modality,
    body_part_examined,
    series_description,
    series_date,
    patient_name,
    patient_id,
    sex,
    series_instance_uid,
    study_instance_uid,
    study_date,
    study_description,
    accession_number,
    study_id
  order by
    study_instance_uid, series_instance_uid
};

my $statement = $dbh->prepare($query) or die "$!";
$statement->execute($ARGV[1], $ARGV[2]) or die $!;

my $undef = "<undef>";

while(my $i = $statement->fetchrow_hashref){
  # print as pipe-delimited lines
  print join('|', @{[
    $i->{patient_id},
    ($i->{patient_name}         or $undef),
    ($i->{study_instance_uid}   or $undef),
    ($i->{study_date}           or $undef),
    ($i->{study_description}    or $undef),
    ($i->{series_instance_uid}  or $undef),
    ($i->{series_date}          or $undef),
    ($i->{series_description}   or $undef),
    ($i->{modality}             or $undef),
    ($i->{sex}                  or $undef),
    ($i->{accession_number}     or $undef),
    ($i->{study_id}             or $undef),
    ($i->{body_part_examined}   or $undef),
    ($i->{count}                or $undef),
  ]}) . "\n";
}
