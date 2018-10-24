#!/usr/bin/perl -w
use strict;
use DBI;
use Debug;
my $usage = <<EOF;
GetNicknameFromUid.pl <uid>
EOF
unless($#ARGV == 0) { die $usage }
my $uid = $ARGV[0];
my $dbh = DBI->connect("DBI:Pg:dbname=posda_nicknames", "", "");
my $check_study = <<EOF;
  select * from study_nickname where study_instance_uid = ?
EOF
my $check_series = <<EOF;
  select * from series_nickname where series_instance_uid = ?
EOF
my $check_sop = <<EOF;
  select * from sop_nickname where sop_instance_uid = ?
EOF
my $c_study = $dbh->prepare($check_study);
my $c_series = $dbh->prepare($check_series);
my $c_sop = $dbh->prepare($check_sop);
$c_study->execute($uid);
while(my $h = $c_study->fetchrow_hashref){
  print "$h->{project_name}//$h->{site_name}//" .
    "$h->{subj_id}//$h->{study_nickname}\n";
}
$c_series->execute($uid);
while(my $h = $c_series->fetchrow_hashref){
  print "$h->{project_name}//$h->{site_name}//" .
    "$h->{subj_id}//$h->{series_nickname}\n";
}
$c_sop->execute($uid);
while(my $h = $c_sop->fetchrow_hashref){
  print "$h->{project_name}//$h->{site_name}//" .
    "$h->{subj_id}//$h->{sop_nickname}\n";
}
