#!/usr/bin/perl -w
use strict;
use DBI;
use Digest::MD5;
my $usage = "ClonePosdaDb.pl <from_db> <to_db>";
unless($#ARGV == 1) { die $usage }
my $fdb = DBI->connect("dbi::Pg::dbname=$ARGV[0]");
my $tdb = DBI->connect("dbi::Pg::dbname=$ARGV[2]");
my $get_fsr = "select * from file_storage_root";
my $ent_fsr = "insert into file_storage_root(" .
 "root_path, current) values (?, ?)";
my $gfsrid = "select currval('file_storage_root_file_storage_root_id_seq')";
my $gfsr = $fdb->prepare($get_fsr);
my $cnfsr = $tdb->prepare($ent_fsr);
my $gnfsrid = $tdb->prepare($gfsrid);
  " as id";
my $get_import_event = <<EOF;
select 
  file_id, file_name, r.root_path || '/' || l.rel_path as path,
  l.rel_path as rel_path, r.root_path
from
  file_location l, file_import i, file f, file_storage_root r
where
  l.file_id = i.file_id and l.file_id = f.file_id
  and l.file_storage_root_id = r.file_storage_root_id
  and file_storage_root_id = ?
EOF
my $gie = $fdb->prepare($get_import_event);
while(my $h = $gfsr->fetchrow_hashref){
  $ent_fsr->execute($h->{root_path}, $h->{current});
  $gnfsrid->excute;
  my $h1 = $gnfsrid->fetchrow_hashref;
  $gnfsrd->finish;
  unless($h->{file_storage_root_id} eq $h1->{id}) { die "non-matching ids" }
  $gie->execute($h->{file_storage_root_id});
  while(my $ie = $gie->fetchrow_hashref){
  }
}

