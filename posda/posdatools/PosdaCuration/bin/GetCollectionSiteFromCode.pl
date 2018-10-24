#!/usr/bin/perl -w
#
use strict;
use DBI;
my $usage = "GetCollectionSiteFromCode.pl <code>";
unless($#ARGV == 0) { die $usage }
unless($ARGV[0] =~ /(\d\d\d\d)(\d\d\d\d)/){
  die "code must be 8 digits";
}
my $site_code = $1; my $collection_code = $2;
my $dbh = DBI->connect("DBI:Pg:database=dicom_roots", "", "");
my $q = <<EOF;
select
  collection_name, site_name
from
  collection natural join site natural join submission
where
  collection_code = ? and site_code = ?
EOF
my $p = $dbh->prepare($q) or die "$!";
$p->execute($collection_code, $site_code) or die $!;
my @list;
while(my $h = $p->fetchrow_hashref){
  print "$h->{collection_name}|$h->{site_name}\n";
}
