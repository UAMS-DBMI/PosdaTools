#!/usr/bin/perl -w
#
use strict;
use DBI;
use Digest::MD5;
my $dbh = DBI->connect("DBI:mysql:database=ncia;host=10.28.163.86", "nciauser",
                       "nciA#112");
my $qs = "select general_series_pk_id from general_series where series_instance_uid = ?";
my $ps = $dbh->prepare($qs);
$ps->execute($ARGV[0]);
my $hs = $ps->fetchrow_hashref;
$ps->finish;
my $pk_id = $hs->{general_series_pk_id};
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
for my $i (@images){
  my $file = $i->{dicom_file_uri};
  my $db_root = "/usr/local/apps/ncia/CTP-server/CTP";
  my $fs_root = "/mnt/erlbluearc/systems/cipa-images";
  $file =~ s/$db_root/$fs_root/o;
  if (-f $file) {
    $num_present += 1;
    my $ctx = Digest::MD5->new;
    open FILE, "<$file" or die "can't open $file ($!)";
    $ctx->addfile(*FILE);
    close FILE;
    my $digest = $ctx->hexdigest;
    my $len_dig = length($digest);
    while(length($i->{md5_digest}) < $len_dig){
      $i->{md5_digest} = "0" . $i->{md5_digest};
    }
    if($digest eq $i->{md5_digest}){
      print "\t present matching: $file\n";
      if(exists $digests{$digest}){ $num_collisions += 1 }
      $digests{$digest} = 1;
    } else {
#      print "\t present: $file\n";
      if(exists $digests{$digest}){ $num_collisions += 1 }
      $digests{$digest} = 1;
      if(exists $digests{$i->{md5_digest}}){ $num_collisions += 1 }
      $digests{$i->{md5_digest}} = 1;
#      print "$digest vs $i->{md5_digest}\n";
#      print "\t non-matching digest: $file\n";
    }
  } else {
    $num_absent += 1;
      print "\t  absent: $file\n";
  }
}
print "Series $ARGV[0] has $num_present present and " .
  "$num_absent absent files $num_collisions md5_digest collisions\n"; 
