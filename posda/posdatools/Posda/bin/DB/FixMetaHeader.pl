#!/usr/bin/perl -w
use strict;
use DBI;
use Posda::Parser;
use Posda::Dataset;
use Debug;
my $dbg = sub {print @_ };
my $usage = "FixMetaHeader.pl <db_name>  <series_instance_uid>\n";
unless($#ARGV == 1) { die $usage }
my $dbh = DBI->connect("dbi:Pg:dbname=$ARGV[0]");
my $q = <<EOF;
select file_id, root_path || '/' || rel_path as path
from
   file_meta natural join file_location natural join file_storage_root
   natural join ctp_file natural join file_series
where
   data_set_start is null
   and series_instance_uid = ?
limit 1000
EOF
my $update = <<EOF;
update file_meta set
  file_meta = ?,
  data_set_size = ?,
  data_set_start = ?,
  media_storage_sop_class = ?,
  media_storage_sop_instance = ?,
  xfer_syntax = ?,
  imp_class_uid = ?,
  imp_version_name = ?,
  source_ae_title = ?,
  private_info_uid = ?,
  private_info = ?
where
  file_id = ?
EOF
my $uh = $dbh->prepare($update);
my $qh = $dbh->prepare($q);
$qh->execute($ARGV[1]);
while (my $h = $qh->fetchrow_hashref){
  #print "$h->{file_id}, $h->{path}\n";
  my $fh;
  if(open $fh, "<$h->{path}"){
    my $df = Posda::Parser::ReadMetaHeader($fh);
    if($df) {
#      print "Meta header: ";
#      Debug::GenPrint($dbg, $df, 1);
#      print "\n";
    }
    my $mh = $df->{metaheader};
    my ($file_meta);
    if(exists $mh->{"(0002,0001)"}){
      $file_meta = unpack("v", $mh->{"(0002,0001)"});
    } else {
      $file_meta = 0x0101;
    }
    $uh->execute(
      $file_meta,
      $df->{DataSetSize},
      $df->{DataSetStart},
      $mh->{'(0002,0002)'},
      $mh->{'(0002,0003)'},
      $mh->{'(0002,0010)'},
      $mh->{'(0002,0012)'},
      $mh->{'(0002,0013)'},
      $mh->{'(0002,0016)'},
      $mh->{'(0002,0100)'},
      $mh->{'(0002,0102)'},
      $h->{file_id}
    );
    print "updated $h->{file_id}\n";
  } else {
    print "no metaheader for file $h->{path}\n";
  }
}
