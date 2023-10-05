#!/usr/bin/perl -w
use strict;
use DBI;
use Debug;
my $dbg = sub {print @_ };
my $dbh = DBI->connect("DBI:Pg:dbname=posda_files", "", "");
my $lq = <<EOF;
select distinct project_name, site_name from ctp_file;
EOF
my $q = $dbh->prepare($lq);
$q->execute;
while (my $h = $q->fetchrow_hashref){
  print "PosdaStatusQuery.pl \"$h->{project_name}\" \"$h->{site_name}\"\n";
}
