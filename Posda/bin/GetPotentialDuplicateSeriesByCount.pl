#!/usr/bin/perl -w
use strict;
use DBI;
use Debug;
my $usage = <<EOF;
GetPotentialDuplicateSeriesByCount.pl <db> <nn_db> <num_dups> 
EOF
unless($#ARGV == 2) { die $usage }
my $dbh = DBI->connect("DBI:Pg:dbname=$ARGV[0]", "", "");
my $nn_dbh = DBI->connect("DBI:Pg:dbname=$ARGV[1]", "", "");
my $q = <<EOF;
select 
  distinct project_name, site_name, patient_id, series_instance_uid, count(*)
from 
  ctp_file natural join file_patient natural join file_series 
where 
  file_id in (
    select 
      distinct file_id
    from
      file_image natural join image natural join unique_pixel_data
    where digest in (
      select
        distinct pixel_digest
      from (
        select
          distinct pixel_digest, count(*)
        from (
          select 
            distinct unique_pixel_data_id, pixel_digest, project_name,
            site_name, patient_id, count(*) 
          from (
            select
              distinct unique_pixel_data_id, file_id, project_name,
              site_name, patient_id, 
              unique_pixel_data.digest as pixel_digest 
            from
              image natural join file_image natural join 
              ctp_file natural join file_patient fq
              join unique_pixel_data using(unique_pixel_data_id)
            where visibility is null
          ) as foo 
          group by 
            unique_pixel_data_id, project_name, pixel_digest,
            site_name, patient_id
        ) as foo 
        group by pixel_digest
      ) as foo
      where count = ?
    )
  ) 
  and visibility is null
group by project_name, site_name, patient_id, series_instance_uid
order by count desc;
EOF
my $nq = "select * from series_nickname where series_instance_uid = ?";
my $gh = $dbh->prepare($q);
my $gnn = $nn_dbh->prepare($nq);
$gh->execute($ARGV[2]);
while(my $h = $gh->fetchrow_hashref){
  my @nicknames;
  $gnn->execute($h->{series_instance_uid});
  while (my $n = $gnn->fetchrow_hashref){
    push(@nicknames, $n);
  }
  if(@nicknames < 1){
    print STDERR "nickname not found for $h->{series_instance_uid}\n";
  } elsif (@nicknames > 1){
    my $nn_count = @nicknames;
    print STDERR "$nn_count nicknames found for $h->{series_instance_uid}\n";
  }
  my $series_nn = $nicknames[0]->{series_nickname};
  print "$h->{project_name}\t $h->{site_name}\t$h->{patient_id}\t$series_nn\t$h->{count}\n";
}
