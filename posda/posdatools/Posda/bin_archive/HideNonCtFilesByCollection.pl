#!/usr/bin/perl -w
use strict;
use DBI;
use Posda::Config 'Config';
my $usage = "usage: HideNonCtFilesByCollection.pl <collection> <user> <reason>\n";
unless($#ARGV == 2) { die $usage }
my $dbh = DBI->connect("DBI:Pg:database=${\Config('files_db_name')}");
my $get_file = <<EOF;
select
  file_id, visibility
from
   ctp_file natural join file_patient natural join dicom_file
where
   project_name = ? and
   dicom_file_type != 'CT Image Storage'
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
$gf->execute($ARGV[0]);
while(my $h = $gf->fetchrow_hashref){
  print "$h->{file_id} $h->{visibility}\n";
  $insert->execute($h->{file_id}, $ARGV[1], $h->{visibility}, 'hidden', $ARGV[2]);
  $hide->execute($h->{file_id});
}
