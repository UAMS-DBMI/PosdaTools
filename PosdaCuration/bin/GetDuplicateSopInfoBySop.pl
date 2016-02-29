#!/usr/bin/perl -w
#
use strict;
use DBI;
my $dbh = DBI->connect("DBI:Pg:database=$ARGV[0]", "", "");
my $q = <<EOF;
select
  project_name, site_name, patient_id, root_path || '/' || rel_path as path,
  import_time, file_id
from
  ctp_file natural join file_storage_root natural join file_location
  natural join file_patient natural join file_import natural join import_event
  where file_id in (
    select file_id from file_sop_common where sop_instance_uid = ?
  )
EOF
my %Files;
my $qh = $dbh->prepare($q);
$qh->execute($ARGV[1]);
while(my $h = $qh->fetchrow_hashref){
  $Files{$h->{path}}->{project_name} = $h->{project_name};
  $Files{$h->{path}}->{site_name} = $h->{site_name};
  $Files{$h->{path}}->{patient_id} = $h->{patient_id};
  $Files{$h->{path}}->{import_time}->{$h->{import_time}} = 1;
}
print "Sop Instance UID: $ARGV[1]\n";
for my $f (keys %Files){
  print "File: $f\n";
  print "\tCollection: $Files{$f}->{project_name}\n";
  print "\tSite: $Files{$f}->{site_name}\n";
  print "\tSubject: $Files{$f}->{patient_id}\n";
  print "\tImport times:\n";
  for my $i (keys %{$Files{$f}->{import_time}}){
    print "\t\t$i\n";
  }
}
