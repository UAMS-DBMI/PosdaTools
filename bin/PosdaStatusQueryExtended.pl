#!/usr/bin/perl -w
use strict;
use DBI;
use Debug;
my $dbg = sub {print @_ };
my $dbh = DBI->connect("DBI:Pg:dbname=N_posda_files", "", "");
my $rq = <<EOF;
select                                      
  patient_id, patient_import_status,
  count(distinct file_id) as total_files,
  min(import_time) min_time, max(import_time) as max_time,
  count(distinct study_instance_uid) as num_studies,
  count(distinct series_instance_uid) as num_series
from
  ctp_file natural join file natural join 
  file_import natural join import_event natural join
  file_study natural join file_series natural join file_patient
  natural join patient_import_status
where
  project_name = ? and site_name = ? and visibility is null
group by patient_id, patient_import_status
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
  die "usage: PosdaStatusQueryExtended.pl <collection> <site>"
}
my $q = $dbh->prepare($rq);
my $q1 = $dbh->prepare($cq);
my $q2 = $dbh->prepare($mq);
my %Results;
$q->execute($ARGV[0], $ARGV[1]);
while(my $h = $q->fetchrow_hashref){
  my $status = $h->{patient_import_status};
  unless(exists $Results{$status}){
    $Results{$status} = $h;
    $Results{$status}->{num_subjects} = 1;
    my $pat_id = $h->{patient_id};
    $Results{$status}->{patient_id_hash} = {};
    $Results{$status}->{patient_id_hash}->{$pat_id} = 1;
    $h->{total_bytes} = 0;
  } else {
    $Results{$status}->{patient_id_hash}->{$h->{patient_id}} = 1;
    $Results{$status}->{num_subjects} += 1;
    $Results{$status}->{num_studies} += $h->{num_studies};
    $Results{$status}->{num_series} += $h->{num_series};
    $Results{$status}->{total_files} += $h->{total_files};
    if($h->{min_time} lt $Results{$status}->{min_time}){
      $Results{$status}->{min_time} = $h->{min_time};
    }
    if($h->{max_time} gt $Results{$status}->{max_time}){
      $Results{$status}->{max_time} = $h->{max_time};
    }
  }
  $q1->execute($ARGV[0], $ARGV[1], $h->{patient_id});
  my $h1 = $q1->fetchrow_hashref;
  $q1->finish;
  $Results{$status}->{total_bytes} += $h1->{total_bytes};
  $q2->execute($ARGV[0], $ARGV[1], $h->{patient_id});
  while (my $h2 = $q2->fetchrow_hashref){
    $Results{$status}->{modalities}->{$h2->{modality}} = 1;
  }
}
my @headers = (
  "project", "site", "status", "num_subjects", "num_studies",
  "num_series", "total_files", "total_bytes", "modalities",
  "min_time", "max_time"
);
for my $i (0 .. $#headers){
  print "\"$headers[$i]\"";
  if($i == $#headers){ print "\n" } else { print "," }
}
for my $r (sort keys %Results){
  for my $i(0 .. $#headers){
    my $h = $headers[$i];
    if($h eq "project") {
      print "\"$ARGV[0]\"";
    } elsif($h eq "site"){
      print "\"$ARGV[1]\"";
    } elsif($h eq "status"){
      print "\"$Results{$r}->{patient_import_status}\"";
    } elsif($h eq "modalities"){
      my $modalities = "";
      my @mod_list = sort keys %{$Results{$r}->{modalities}};
      for my $m (0 .. $#mod_list){
        $modalities .= $mod_list[$m];
        if($m != $#mod_list){ $modalities .= ", " }
      }
      print "\"$modalities\"";
    } else {
      print "\"$Results{$r}->{$h}\"";
    }
    if($i == $#headers){ print "\n" } else { print "," }
  }
}
