#!/usr/bin/perl -w
use strict;
use DBI;
use Posda::Config 'Config';
my $usage = "usage: HideNonMrFilesByCollectionSiteSubject.pl <collection> <site><subject> <user> <reason>\n";
unless($#ARGV == 4) { die $usage }
my $dbh = DBI->connect("DBI:Pg:database=${\Config('files_db_name')}");
my $get_file = <<EOF;
select
  file_id, visibility
from
   ctp_file natural join file_patient natural join dicom_file
where
   project_name = ? and
   site_name = ? and
   patient_id = ? and 
   dicom_file_type != 'MR Image Storage'
EOF
my $gf = $dbh->prepare($get_file);
my $hide_Q = <<EOF;
update
  ctp_file
set
  visibility = 'hidden'
where 
  file_id = ?
EOF
my $hide = $dbh->prepare($hide_Q);
my $insert_q = <<EOF;
insert into file_visibility_change(
  file_id, user_name, time_of_change,
  prior_visibility, new_visibility, reason_for
)values(
  ?, ?, now(),
  ?, ?, ?
)
EOF
my $insert = $dbh->prepare($insert_q);
$gf->execute($ARGV[0], $ARGV[1], $ARGV[2]);
while(my $h = $gf->fetchrow_hashref){
  print "$h->{file_id} $h->{visibility}\n";
  $insert->execute($h->{file_id}, $ARGV[3], $h->{visibility}, 'hidden', $ARGV[4]);
  $hide->execute($h->{file_id});
}
