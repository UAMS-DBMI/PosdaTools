#!/usr/bin/perl -w
#
use strict;
use DBI;
my $dbh = DBI->connect("DBI:Pg:database=$ARGV[0]", "", "");
my $q1 = <<EOF;
select
  sop_instance_uid
from (
  select
    distinct sop_instance_uid, count(*)
  from
    file_sop_common natural join ctp_file
  where visibility is null
  group by sop_instance_uid) as foo 
where count > 1
EOF
my $q2 = <<EOF;
select
  project_name, site_name, patient_id, root_path || '/' || rel_path as path
from
  ctp_file natural join file_storage_root natural join file_location
  natural join file_patient
  where file_id in (
    select file_id from file_sop_common where sop_instance_uid = ?
    and patient_id = ?
  )
EOF
my $qh1 = $dbh->prepare($q1);
my $qh2 = $dbh->prepare($q2);
$qh1->execute;
while(my $h1 = $qh1->fetchrow_hashref){
  my $header_printed = 0;
  $qh2->execute($h1->{sop_instance_uid}, $ARGV[1]);
  while (my $h2 = $qh2->fetchrow_hashref){
    unless($header_printed) {
      print "Duplicate Sop Instance:$h1->{sop_instance_uid}\n";
      $header_printed = 1;
    }
    print "$h2->{project_name}|$h2->{site_name}|$h2->{patient_id}" .
      "|$h2->{path}\n";
  }
  if($header_printed){
    print "#################\n";
  }
}
