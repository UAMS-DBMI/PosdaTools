#!/usr/bin/perl -w
#
use strict;
use DBI;
use Digest::MD5;
my $dbh = DBI->connect("DBI:mysql:database=ncia;host=tcia-intake-1", "nciauser",
                       "nciA#112");
my $q = "select image_pk_id, dicom_file_uri, md5_digest, dicom_size, curation_timestamp
  from general_image";
my $p = $dbh->prepare($q);
$p->execute();
while(my $h = $p->fetchrow_hashref){
  print "$h->{dicom_file_uri}|$h->{image_pk_id}\n";
}
