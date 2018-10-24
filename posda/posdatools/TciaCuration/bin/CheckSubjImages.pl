#!/usr/bin/perl -w
#
use strict;
use Posda::Try;
use DBI;
my $dbhost;
my $db_root = "/usr/local/apps/ncia/CTP-server/CTP/";
my $fs_root;
if($ARGV[0] eq "intake"){
  $dbhost = "tcia-intake-1";
  $fs_root = "/mnt/erlbluearc/systems/cipa1-v01/data/";
} elsif($ARGV[0] eq "public"){
  $dbhost = "10.28.163.86";
  $fs_root = "/mnt/erlbluearc/systems/cipa-images/";
} elsif($ARGV[0] eq "nlst"){
  $dbhost = "10.28.163.64";
  $fs_root = "/mnt/erlbluearc/systems/public-lss/data/";
} else { die "Unrecognized db: $ARGV[0]" }
my $dbh = DBI->connect("DBI:mysql:database=ncia;host=$dbhost", "nciauser", "nciA#112");
my $q = <<EOF;
select
  p.patient_id as PID,
  t.study_instance_uid,
  t.study_desc,
  s.series_instance_uid,
  s.general_series_pk_id,
  s.series_desc,
  s.body_part_examined,
  p.patient_name,
  s.patient_id,
  s.visibility,
  t.study_pk_id,
  t.study_date,
  t.study_desc,
  s.modality
from
  general_series s,
  study t,
  patient p,
  trial_data_provenance tdp
where
  s.study_pk_id = t.study_pk_id and
  t.patient_pk_id = p.patient_pk_id and
  p.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ? and
  tdp.dp_site_name = ? and
  p.patient_id = ?;
EOF
my $q1 = <<EOF;
select 
  dicom_file_uri, md5_digest, curation_timestamp, dicom_size, image_pk_id,
  sop_instance_uid
from
  general_image
where
  general_series_pk_id = ?;
EOF
my $p = $dbh->prepare($q) or die "$!";
$p->execute($ARGV[1], $ARGV[2], $ARGV[3]) or die $!;
my @list;
while(my $h = $p->fetchrow_hashref){
  push(@list, $h);
}
my %DirsWithMatching;
my %DirsWithErrors;
my $Matching = 0;
my $NotMatching = 0;
for my $i (@list) {
  my $body_part = "<undef>";
  if(defined $i->{body_part_examined}) {$body_part = $i->{body_part_examined}}
  my $desc = "<undef>";
  my $t_desc = "<undef>";
  if(defined $i->{series_desc}) {$desc = $i->{series_desc}}
  if(defined $i->{study_desc}) {$t_desc = $i->{study_desc}}
#  print "series: $i->{modality}, " .
#    "$i->{general_series_pk_id}, $i->{visibility}, $desc\n" .
#    "study: $i->{study_pk_id}, body_part: $body_part\n";
  my $p1 = $dbh->prepare($q1) or die "$!";
  $p1->execute($i->{general_series_pk_id});
  while(my $h = $p1->fetchrow_hashref){
    my $old_uri = $h->{dicom_file_uri};
    my $uri = $old_uri;
    my $md5 = $h->{md5_digest};
    my $tim = $h->{curation_timestamp};
    unless(defined $tim) { $tim = "" }
    my $size = $h->{dicom_size};
    my $image_pk_id = $h->{image_pk_id};
    $uri =~ s/$db_root/$fs_root/o;
#    if($uri =~ /(storage\/.*)$/){
#      $uri = "/mnt/erlbluearc/systems/cipa1-v01/data/$1";
#    }
    my $try = Posda::Try->new($uri);
    unless(exists $try->{dataset}) {
      die "Can't parse $uri\n";
    }
    my $pat_id = $try->{dataset}->Get("(0010,0020)");
    my $study_uid = $try->{dataset}->Get("(0020,000d)");
    my $series_uid = $try->{dataset}->Get("(0020,000e)");
    my $modality = $try->{dataset}->Get("(0008,0060)");
    my $study_desc = $try->{dataset}->Get("(0008,1030)");
    my $series_desc = $try->{dataset}->Get("(0008,103e)");
    my $dir = $uri;
    if($dir =~ /^(.*)\/[^\/]+$/){
      $dir = $1;
    }
    if(
      $pat_id eq $i->{patient_id} &&
      $study_uid eq $i->{study_instance_uid} &&
      $series_uid eq $i->{series_instance_uid} &&
      $modality eq $i->{modality} 
    ){
      $DirsWithMatching{$dir} = 1;
      $Matching += 1;
      print "$uri matches\n";
    } else {
      $DirsWithErrors{$dir} = 1;
      $NotMatching += 1;
      print "$old_uri doesn't match\n";
    }
    next;
    print "##############################################\nParsed $uri\n";
    if($pat_id ne $i->{patient_id}) {
      print "Pat id: $pat_id vs $i->{patient_id}\n";
    }
    if($study_uid ne $i->{study_instance_uid}) {
      print "Study uid: $study_uid vs $i->{study_instance_uid}\n";
    }
    if($series_uid ne $i->{series_instance_uid}) {
      print "Series uid: $series_uid vs $i->{series_instance_uid}\n";
    }
    if($modality ne $i->{modality}) {
      print "Modality: $modality vs $i->{modality}\n";
    }
  }
}
print "Matching: $Matching Not Matching: $NotMatching\n";
exit;
print "Dirs with Errors:\n";
for my $d (sort keys %DirsWithErrors){
  print "\t$d\n";
}
print "Dirs with Matching:\n";
for my $d (sort keys %DirsWithMatching){
  print "\t$d\n";
}

