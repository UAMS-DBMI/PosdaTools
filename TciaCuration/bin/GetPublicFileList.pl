#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/TciaCuration/bin/GetPublicFileList.pl,v $
#$Date: 2015/10/01 13:10:47 $
#$Revision: 1.1 $
#
use strict;
use DBI;
use Digest::MD5;
my $dbh = DBI->connect("DBI:mysql:database=ncia;host=10.28.163.86", "nciauser",
                       "nciA#112");
my $q = "select dicom_file_uri, md5_digest, dicom_size, curation_timestamp
  from general_image";
my $p = $dbh->prepare($q);
$p->execute();
while(my $h = $p->fetchrow_hashref){
  print "$h->{dicom_file_uri}|" .
    "$h->{md5_digest}|" .
    "$h->{dicom_size}|" .
    "$h->{curation_timestamp}\n";
}
