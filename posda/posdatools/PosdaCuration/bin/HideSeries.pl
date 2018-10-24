#!/usr/bin/perl -w
use strict;
use DBI;
use Posda::Config 'Config';
my $usage = "usage: HideSeries.pl <coll> <site> <series_uid>\n";
unless($#ARGV == 2) { die $usage }
my $dbh = DBI->connect("DBI:Pg:database=${\Config('files_db_name')}");
my $q= <<EOF;
update
  ctp_file
set
  visibility = 'hidden'
where 
  project_name = ? and
  site_name = ? and
  file_id in (
  select file_id from file_series where series_instance_uid = ?
  )
EOF
my $p = $dbh->prepare($q) or die "$!";
$p->execute($ARGV[0], $ARGV[1], $ARGV[2]) or die $!;
print "OK\n";
