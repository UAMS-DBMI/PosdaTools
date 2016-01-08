#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/PosdaCuration/bin/GetNlstLinkFromSop.pl,v $ #$Date: 2015/12/15 14:13:07 $
#$Revision: 1.1 $
#
use strict;
use DBI;
my $usage = "GetNlstLinkFromSop.pl <db_host> <sop_instance_uid>\n";
unless($#ARGV == 1) { die $usage }
my $dbhost = $ARGV[0];
my $sop_inst = $ARGV[1];
my $dbh = DBI->connect("DBI:mysql:database=ncia;host=$dbhost",
  "nciauser", "nciA#112");
unless($dbh) { die "connect failed" }
my $q = <<EOF;
select
  dicom_file_uri
from
  general_image
where
  sop_instance_uid = ?
EOF
my $p = $dbh->prepare($q) or die "$!";
$p->execute($sop_inst) or die $!;
my @list;
while(my $h = $p->fetchrow_hashref){
  my $uri = $h->{dicom_file_uri};
  if($uri =~ /(storage-acrin.*)$/){
    print "/mnt/nlst2-data/$1\n";
  }
}
