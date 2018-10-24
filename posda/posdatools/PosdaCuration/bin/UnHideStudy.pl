#!/usr/bin/perl -w
#
use strict;
use DBI;
my $usage = "UnHideStudy.pl <db> <coll> <site> <study_uid>\n";
unless($#ARGV == 3) { die $usage }
my $dbh = DBI->connect("DBI:Pg:database=$ARGV[0]", "", "");
my $q= <<EOF;
update
  ctp_file
set 
  visibility = null 
where 
  project_name = ? and
  site_name = ? and
  file_id in (
  select file_id from file_study where study_instance_uid = ?
  )
EOF
my $p = $dbh->prepare($q) or die "$!";
$p->execute($ARGV[1], $ARGV[2], $ARGV[3]) or die $!;
print "OK\n";
