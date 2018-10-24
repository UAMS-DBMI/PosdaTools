#!/usr/bin/perl -w
#
use strict;
use DBI;
use Digest::MD5;
my %Files;
my $dbh = DBI->connect("DBI:mysql:database=ncia;host=tcia-intake-1", "nciauser",
                       "nciA#112");
my $q = "select image_pk_id, dicom_file_uri, md5_digest, dicom_size, curation_timestamp
  from general_image";
my $p = $dbh->prepare($q);
$p->execute();
while(my $h = $p->fetchrow_hashref){
  if(exists $Files{$h->{dicom_file_uri}}){
    print "$h->{dicom_file_uri}|$h->{image_pk_id}|$Files{$h->{dicom_file_uri}}\n";
    next;
  }
  $Files{$h->{dicom_file_uri}} = $h->{image_pk_id};
}
