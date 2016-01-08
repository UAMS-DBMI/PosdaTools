#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/PosdaCuration/bin/BuildExtractionCommands.pl,v $ #$Date: 2015/12/15 14:10:27 $
#$Revision: 1.2 $
#
use strict;
use DBI;
my $dbh = DBI->connect("DBI:Pg:database=$ARGV[0]", "", "");
my $q = <<EOF;
select
  digest, sop_instance_uid, root_path || '/' || rel_path as path,
  study_description, body_part_examined, series_description,
  modality, file.size as size, visibility, study_instance_uid,
  series_instance_uid
from
  ctp_file natural join file_patient natural join
  file_series natural join file_study natural join
  file_location natural join file_storage_root natural join
  file natural join file_sop_common
where
  project_name = ? and site_name = ? and patient_id = ?
EOF
my $p = $dbh->prepare($q) or die "$!";
$p->execute($ARGV[1], $ARGV[2], $ARGV[3]) or die $!;
my @list;
while(my $h = $p->fetchrow_hashref){
  push(@list, $h);
}
for my $i (@list) {
  my $sop_instance_uid = "<undef>";
  my $series_instance_uid = "<undef>";
  my $study_instance_uid = "<undef>";
  my $digest = "<undef>";
  my $path = "<undef>";
  my $modality = "<undef>";
  my $size = "<undef>";
  my $body_part = "<undef>";
  my $desc = "<undef>";
  my $t_desc = "<undef>";
  my $visibility = "<undef>";
  if(defined $i->{sop_instance_uid}) {
    $sop_instance_uid = $i->{sop_instance_uid}}
  if(defined $i->{series_instance_uid}) {
    $series_instance_uid = $i->{series_instance_uid}}
  if(defined $i->{study_instance_uid}) {
    $study_instance_uid = $i->{study_instance_uid}}
  if(defined $i->{digest}) {$digest = $i->{digest}}
  if(defined $i->{path}) {$path = $i->{path}}
  if(defined $i->{modality}) {$modality = $i->{modality}}
  if(defined $i->{size}) {$size = $i->{size}}
  if(defined $i->{body_part_examined}) {$body_part = $i->{body_part_examined}}
  if(defined $i->{series_description}) {$desc = $i->{series_description}}
  if(defined $i->{study_description}) {$t_desc = $i->{study_description}}
  if(defined $i->{visibility}) {$visibility = $i->{visibility}}
  print("$digest|$sop_instance_uid|$path|" .
    "$t_desc|$body_part|" .
    "$desc|$modality|$size|$visibility|" .
    "$series_instance_uid|$study_instance_uid\n");
}

