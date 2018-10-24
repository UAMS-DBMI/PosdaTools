#!/usr/bin/perl -w
use strict;
use Text::CSV;
use DBI;
my $dbh = DBI->connect("DBI:Pg:dbname=posda_files", "", "");
my $rq = <<EOF;
select                                      
  patient_id,
  count(distinct file_id) as total_files,
  min(import_time) min_time, max(import_time) as max_time,
  count(distinct study_instance_uid) as num_studies,
  count(distinct series_instance_uid) as num_series
from
  ctp_file natural join file natural join 
  file_import natural join import_event natural join
  file_study natural join file_series natural join file_patient
where
  project_name = ? and site_name = ? and visibility is null
group by patient_id
EOF
my $cq = <<EOF;
select
  sum(size) as total_bytes
from file
where file_id in (
  select
    distinct file_id
  from
    ctp_file natural join file_patient natural join file_series
  where
    project_name = ? and site_name = ? and
    patient_id = ? and
    visibility is null
)
EOF
my $mq = <<EOF;
select
  distinct modality
from
  file_series
where file_id in (
  select
    distinct file_id
  from
    ctp_file natural join file_patient
  where
    project_name = ? and site_name = ? and
    patient_id = ? and
    visibility is null
)
EOF
unless($#ARGV == 1) { 
  die "usage: PosdaStatusQuery.pl <collection> <site>"
}
my $q = $dbh->prepare($rq);
my $q1 = $dbh->prepare($cq);
my $q2 = $dbh->prepare($mq);
$q->execute($ARGV[0], $ARGV[1]);
my @headers = ( "patient_id", "num_studies", "num_series", "total_files",
    "total_bytes", "modality", "min_time", "max_time");
for my $i (0 .. $#headers){
  print $headers[$i];
  if($i == $#headers) { print "\n" } else { print ","}
}
while(my $h = $q->fetchrow_hashref){
  $q1->execute($ARGV[0], $ARGV[1], $h->{patient_id});
  my $h1 = $q1->fetchrow_hashref;
  $q1->finish;
  $h->{total_bytes} = $h1->{total_bytes};
  $q2->execute($ARGV[0], $ARGV[1], $h->{patient_id});
  my $modalities = "";
  while (my $h2 = $q2->fetchrow_hashref){
    if($modalities){
      $modalities .= ", ";
    }
    $modalities .= $h2->{modality};
  }
  $h->{modality} = $modalities;
  for my $i (0 .. $#headers){
    print "\"$h->{$headers[$i]}\"";
    if($i == $#headers) { print "\n" } else { print ","}
  }
}
