#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/TciaCuration/bin/FindMissingDirectoriesInPublic.pl,v $
#$Date: 2015/08/12 21:29:27 $
#$Revision: 1.1 $
#
use strict;
use DBI;
use Digest::MD5;
#The URI paths in the DB are:
#/usr/local/apps/ncia/CTP-server/CTP/storage
#/usr/local/apps/ncia/CTP-server/CTP/storage-acrin
#
#These map to:
#/mnt/erlbluearc/systems/public-lss/data/storage
#/mnt/erlbluearc/systems/public-lss/data/storage-acrin
#
my %DirectoriesSeen;
my %SeriesAffected;
my $dbh = DBI->connect("DBI:mysql:database=ncia;host=10.28.163.86", "nciauser",
                       "nciA#112");
my $qs = "select general_series_pk_id, series_instance_uid from general_series";
my $ps = $dbh->prepare($qs);
$ps->execute;
my $q = <<EOF;
select 
  dicom_file_uri, md5_digest, curation_timestamp, dicom_size, image_pk_id,
  sop_instance_uid
from
  general_image
where
  general_series_pk_id = ?
EOF
my $p = $dbh->prepare($q);
while (my $hs = $ps->fetchrow_hashref){
  my $pk_id = $hs->{general_series_pk_id};
  my $series_instance_uid = $hs->{series_instance_uid};
  $p->execute($pk_id);
  my @images;
  while(my $h = $p->fetchrow_hashref){
    push @images, $h;
  }
  my $ser_count = @images;
  my $num_present = 0;
  my $num_absent = 0;
  my $num_collisions = 0;
  my %digests;
  file:
  for my $i (@images){
    my $file = $i->{dicom_file_uri};
    my $db_root = "/usr/local/apps/ncia/CTP-server/CTP/";
    my $fs_root = "/mnt/erlbluearc/systems/cipa-images/";
    $file =~ s/$db_root/$fs_root/o;
    if(-f $file){
#      print "$file exists\n";
      next file;
    }
    unless($file =~ /^(.*)\/([^\/])+$/){
      print STDERR "Can't extract directory from path: $file\n";
      next file;
    }
    my $dir = $1;
    $SeriesAffected{$dir}->{$series_instance_uid} = 1;
    unless(exists $DirectoriesSeen{$dir}){
      print "Found Missing Dir: $dir\n";
      print STDERR "Found Missing Dir: $dir\n";
      $DirectoriesSeen{$dir} = 1;
    }
  }
}
for my $dir (keys %SeriesAffected){
  print "Missing Dir: $dir affects following series:\n";
  for my $series (keys %{$SeriesAffected{$dir}}){
    print "\t$series\n";
  }
}
