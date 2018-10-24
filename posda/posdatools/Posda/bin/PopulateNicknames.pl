#!/usr/bin/perl -w
use strict;#{{{
use DBI;
my $usage = <<EOF;
PopulateNicknames.pl <posda_db_name> <nickname_db_name>
EOF
unless($#ARGV == 1) { die $usage }#}}}
##############################
# !!!  Stuff to move to object
my $ndb = DBI->connect("dbi:Pg:dbname=$ARGV[1]");
my $start_trans = $ndb->prepare("begin");
my $lock_sequence_for_update = $ndb->prepare(
  "select * from nickname_sequence where\n" .
  "project_name = ? and site_name = ? and subj_id = ?\n" .
  "and nickname_type = ?\n" .
  "FOR UPDATE"
);
my $update_nn_seq = $ndb->prepare(
  "update nickname_sequence set next_value = ? where\n" .
  "project_name = ? and site_name = ? and subj_id = ? and nickname_type = ?"
);
my $new_nn_seq = $ndb->prepare(
  "insert into nickname_sequence(" .
  "project_name, site_name, subj_id, nickname_type, next_value)\n" .
  "values(?, ?, ?, ?, 1)"
);
my $unlock = $ndb->prepare("commit");
my $abort = $ndb->prepare("rollback");

my $select_study_nn = $ndb->prepare(
  "select study_nickname from study_nickname where\n" .
  "project_name = ? and site_name = ? and subj_id = ?\n" .
  "and study_instance_uid = ?"
);
my $insert_study_nn = $ndb->prepare(
  "insert into study_nickname(" .
  "project_name, site_name, subj_id, study_nickname, study_instance_uid)\n" .
  "values(?, ?, ?, ?, ?)"
);
#  my $study_nn =
#    study_nickname($ndb, $project_name, $site_name, $subj_id, 
#      $study_instance_uid);
sub study_nickname {
  my($ndb, $project_name, $site_name, $subj_id, $study_instance_uid) = @_;
  $start_trans->execute;
  $select_study_nn->execute($project_name, $site_name, $subj_id,
    $study_instance_uid);
  my @rows;
  while(my $row = $select_study_nn->fetchrow_hashref){ push @rows, $row }
  if(@rows > 1) {
     die "multiple study rows for project: $project_name, " .
      "site: $site_name, study: $study_instance_uid, subj: $subj_id"
  }
  if(@rows == 1) { $unlock->execute; return $rows[0]->{study_nickname} }
  $lock_sequence_for_update->execute($project_name, $site_name, $subj_id,
     "study");
  my $seq;
  @rows = ();
  while(my $row = $lock_sequence_for_update->fetchrow_hashref){
    push @rows, $row;
  }
  if(@rows > 1) {
    $abort->execute;
    die "multiple sequences for $project_name, $site_name, $subj_id, study";
  }
  if(@rows == 1){
    $seq = $rows[0]->{next_value};
    my $next_value = $seq + 1;
    $update_nn_seq->execute($next_value, $project_name, $site_name, $subj_id,
      "study");
  } else {
    $seq = 0;
    $new_nn_seq->execute($project_name, $site_name, $subj_id, "study");
  }
  my $nn = "STUDY_$seq";
  $insert_study_nn->execute(
    $project_name, $site_name, $subj_id, $nn, $study_instance_uid);
  $unlock->execute;
  return $nn;
}
my $select_series_nn = $ndb->prepare(
  "select series_nickname from series_nickname where\n" .
  "project_name = ? and site_name = ? and subj_id = ?\n" .
  "and series_instance_uid = ?"
);
my $insert_series_nn = $ndb->prepare(
  "insert into series_nickname(" .
  "project_name, site_name, subj_id, series_nickname, series_instance_uid)\n" .
  "values(?, ?, ?, ?, ?)"
);
#  my $series_nn =
#    series_nickname($ndb, $project_name, $site_name, $subj_id, 
#    $series_instance_uid);
sub series_nickname {
  my($ndb, $project_name, $site_name, $subj_id, $series_instance_uid) = @_;
  $start_trans->execute;
  $select_series_nn->execute($project_name, $site_name, $subj_id,
    $series_instance_uid);
  my @rows;
  while(my $row = $select_series_nn->fetchrow_hashref){ push @rows, $row }
  if(@rows > 1) {
     die "multiple series rows for project: $project_name, " .
      "site: $site_name, series: $series_instance_uid"
  }
  if(@rows == 1) { $unlock->execute; return $rows[0]->{series_nickname} }
  $lock_sequence_for_update->execute($project_name, $site_name, $subj_id,
    "series");
  my $seq;
  @rows = ();
  while(my $row = $lock_sequence_for_update->fetchrow_hashref){
    push @rows, $row;
  }
  if(@rows > 1) {
    $abort->execute;
    die "multiple sequences for $project_name, $site_name, $subj_id, series";
  }
  if(@rows == 1){
    $seq = $rows[0]->{next_value};
    my $next_value = $seq + 1;
    $update_nn_seq->execute($next_value, $project_name, $site_name, $subj_id,
      "series");
  } else {
    $seq = 0;
    $new_nn_seq->execute($project_name, $site_name, $subj_id, "series");
  }
  my $nn = "SERIES_$seq";
  $insert_series_nn->execute(
    $project_name, $site_name, $subj_id, $nn, $series_instance_uid);
  $unlock->execute;
  return $nn;
}
my $select_sop_nn = $ndb->prepare(
  "select * from sop_nickname where\n" .
  "project_name = ? and site_name = ? and subj_id = ? and sop_instance_uid = ?"
);
my $insert_sop_nn = $ndb->prepare(
  "insert into sop_nickname(" .
  "project_name, site_name, subj_id, sop_nickname,\n" .
  "modality, sop_instance_uid)\n" .
  "values(?, ?, ?, ?, ?, ?)"
);
my $set_sop_modality_conflict = $ndb->prepare(
  "update sop_nickname set has_modality_conflict = true\n" .
  "where project_name = ? and site_name = ? and subj_id = ?\n" .
  "and sop_instance_uid = ?"
);
#  $sop_nn = sop_nickname($ndb, $project_name, $site_name, $subj_id,
#  $sop_instance_uid, $modality);
sub sop_nickname {
  my($ndb, $project_name, $site_name, $subj_id,
    $sop_instance_uid, $modality) = @_;
#  $start_trans->execute;
  $select_sop_nn->execute($project_name, $site_name, $subj_id,
    $sop_instance_uid);
  my @rows;
  while(my $row = $select_sop_nn->fetchrow_hashref) { push @rows, $row }
  if(@rows > 1){
    $abort->execute;
    die "Multiple nicknames for project: $project_name, site $site_name, " .
      "subj: $subj_id, sop: $sop_instance_uid";
  }
  if(@rows == 1) {
    unless($rows[0]->{modality} eq $modality){
      print STDERR "Modality conflict for SOP: $sop_instance_uid\n";
      $set_sop_modality_conflict->execute(
        $project_name, $site_name, $subj_id, $sop_instance_uid);
    }
#    $unlock->execute;
    return $rows[0]->{sop_nickname};
  }
  $lock_sequence_for_update->execute($project_name, $site_name, $subj_id,
    "sop");
  my $seq;
  @rows = ();
  while(my $row = $lock_sequence_for_update->fetchrow_hashref){
    push @rows, $row;
  }
  if(@rows > 1) {
    $abort->execute;
    die "multiple sequences for $project_name, $site_name, $subj_id, sop";
  }
  if(@rows == 1){
    $seq = $rows[0]->{next_value};
    my $next_value = $seq + 1;
    $update_nn_seq->execute($next_value, $project_name, $site_name, $subj_id,
       "sop");
  } else {
    $seq = 0;
    $new_nn_seq->execute($project_name, $site_name, $subj_id, "sop");
  }
  my $nn = "$modality" ."_$seq";
  $insert_sop_nn->execute(
    $project_name, $site_name, $subj_id, $nn, $modality, $sop_instance_uid);
#  $unlock->execute;
  return $nn;
}
my $get_related_file_nicknames = $ndb->prepare(
  "select * from file_nickname where\n" .
  "project_name = ? and site_name = ? and subj_id = ? and sop_instance_uid = ?"
);
my $lock_file_nicknames = $ndb->prepare(
  "LOCK file_nickname in ACCESS EXCLUSIVE mode"
);
my $insert_file_nn = $ndb->prepare(
  "insert into file_nickname(" .
  "project_name, site_name, subj_id, sop_instance_uid,\n" .
  "version_number, file_digest, " .
  "sop_nickname_copy)\n" .
  "values(?, ?, ?, ?, ?, ?, ?)"
);
#  my $file_nn =
#    file_nickname($ndb, $project_name, $site_name, $subj_id, 
#    $sop_instance_uid, $digest,
#      $modality);
sub file_nickname {
  my($ndb, $project_name, $site_name, $subj_id,  $sop_instance_uid, $digest,
    $modality) = @_;
  $start_trans->execute;
  $get_related_file_nicknames->execute($project_name, $site_name, $subj_id,
    $sop_instance_uid);
  my %rows;
  while(my $row = $get_related_file_nicknames->fetchrow_hashref){
    if(exists $rows{$row->{file_digest}}){
      $abort->execute;
      die "digest $row->{file_digest} not unique in file_nickname";
    }
    $rows{$row->{file_digest}} = $row;
  }
  if(exists $rows{$digest}){
    $unlock->execute;
    if($rows{$digest}->{version_number} ==  0){
      return "$rows{$digest}->{sop_nickname_copy}";
    } else {
      return "$rows{$digest}->{sop_nickname_copy}" .
        "[$rows{$digest}->{version_number}]";
    }
  }
  my $max_i;
  my $sop_nn;
  for my $k (keys %rows){
    my $vn = $rows{$k}->{version_number};
    $sop_nn = $rows{$k}->{sop_nickname_copy};
    unless(defined $max_i) { $max_i = $vn }
    if($vn > $max_i) { $max_i = $vn }
  }
  if(defined $max_i){
    my $next = $max_i + 1;
    $insert_file_nn->execute($project_name, $site_name, $subj_id,
      $sop_instance_uid, $next, $digest, $sop_nn);
    $unlock->execute;
    return "$sop_nn" . "[$next]";
  }
  $sop_nn = sop_nickname($ndb, $project_name, $site_name, $subj_id,
    $sop_instance_uid, $modality);
  $insert_file_nn->execute($project_name, $site_name, $subj_id,
    $sop_instance_uid, 0, $digest, $sop_nn);
  $unlock->execute;
  return "$sop_nn";
}
#^^^  Stuff to move to object
#############################

my $pdb = DBI->connect("dbi:Pg:dbname=$ARGV[0]");
my $get_files = $pdb->prepare(
  "select\n" .
  "  distinct\n" .
  "    digest, study_instance_uid, series_instance_uid, sop_instance_uid,\n" .
  "    project_name, site_name, patient_id, modality\n" .
  "from\n" .
  "  file natural join file_series natural join file_study\n" .
  "  natural join file_patient\n" .
  "  natural join file_sop_common natural join ctp_file\n"
);
$get_files->execute;
while(my $row = $get_files->fetchrow_hashref){
  my $project_name = $row->{project_name};
  my $site_name = $row->{site_name};
  my $sop_instance_uid = $row->{sop_instance_uid};
  my $study_instance_uid = $row->{study_instance_uid};
  my $series_instance_uid = $row->{series_instance_uid};
  my $modality = $row->{modality};
  my $digest = $row->{digest};
  my $subj_id = $row->{patient_id};
  my $study_nn =
    study_nickname($ndb, $project_name, $site_name, $subj_id,
      $study_instance_uid);
  my $series_nn =
    series_nickname($ndb, $project_name, $site_name, $subj_id,
      $series_instance_uid);
  my $file_nn =
    file_nickname($ndb, $project_name, $site_name, $subj_id,
      $sop_instance_uid, $digest, $modality);
  print "$project_name|$site_name|$subj_id|$study_nn|$series_nn|$file_nn\n";
}
