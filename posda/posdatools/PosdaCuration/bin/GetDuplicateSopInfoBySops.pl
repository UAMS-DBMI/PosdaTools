#!/usr/bin/perl -w
#
use strict;
use DBI;
use Storable;
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
my %SopInfo;
my $qh = $dbh->prepare($q);
my @Sops;
while (my $line = <STDIN>) {
  chomp $line;
print STDERR "Read $line\n";
  push @Sops, $line;
}
for my $sop (@Sops){
  $qh->execute($sop);
  while(my $h = $qh->fetchrow_hashref){
    $SopInfo{$sop}->{$h->{path}}->{file_id} = $h->{file_id};
    $SopInfo{$sop}->{$h->{path}}->{project_name} = $h->{project_name};
    $SopInfo{$sop}->{$h->{path}}->{site_name} = $h->{site_name};
    $SopInfo{$sop}->{$h->{path}}->{patient_id} = $h->{patient_id};
    $SopInfo{$sop}->{$h->{path}}->{import_time}->{$h->{import_time}} = 1;
  }
}
Storable::store_fd \%SopInfo, \*STDOUT;
