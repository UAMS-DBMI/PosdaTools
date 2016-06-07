#!/usr/bin/env perl

package Posda::Nicknames2;
use Modern::Perl '2010';
use Method::Signatures::Simple;
use Data::Dumper;
use DBI;

use constant DEBUG => 0;

#{{{ Public Methods
method new($class: $connection, $project_name, $site_name, $subj_id) {
  my $self = {
    project_name => $project_name,
    site_name => $site_name,
    subj_id => $subj_id,
    ndb => $connection
  };

  # print "Posda::Nicknames2($project_name, $site_name, $subj_id)\n";

  bless $self, $class;
  $self->__init();
  return $self;
}

method Study($study_instance_uid) {

  if (not defined $self->{study_cache}->{$study_instance_uid}) {
    $self->{study_cache}->{$study_instance_uid} = 
      $self->__study_nickname($self->{project_name}, 
                              $self->{site_name}, 
                              $self->{subj_id}, 
                              $study_instance_uid);
  }
  return $self->{study_cache}->{$study_instance_uid};

}

method Series($series_instance_uid) {
  if (not defined $self->{series_cache}->{$series_instance_uid}) {
    $self->{series_cache}->{$series_instance_uid} = 
      $self->__series_nickname($self->{project_name}, 
                             $self->{site_name}, 
                             $self->{subj_id}, 
                             $series_instance_uid);
  }
  return $self->{series_cache}->{$series_instance_uid};
}

method File($sop_instance_uid, $digest, $modality) {
  unless (defined $sop_instance_uid and defined $digest and defined $modality) {
    die "Posda::Nicknames2::File called without all parameters!";
  }
  if (not defined $self->{file_cache}->{$sop_instance_uid}->
                  {$digest}->{$modality}) {
    $self->{file_cache}->{$sop_instance_uid}->{$digest}->{$modality} =
      $self->__file_nickname($self->{project_name}, 
                             $self->{site_name}, 
                             $self->{subj_id}, 
                             $sop_instance_uid,
                             $digest,
                             $modality);
  }
  return $self->{file_cache}->{$sop_instance_uid}->{$digest}->{$modality};
}
method ToStudyUID($study_nn) {
  return $self->__to_study_uid($self->{project_name}, 
                             $self->{site_name}, 
                             $self->{subj_id}, 
                             $study_nn);
}
method ToSeriesUID($series_nn) {
  return $self->__to_series_uid($self->{project_name}, 
                             $self->{site_name}, 
                             $self->{subj_id}, 
                             $series_nn);
}
method ToSopUID($sop_nn) {
  return $self->__to_sop_uid($self->{project_name}, 
                             $self->{site_name}, 
                             $self->{subj_id}, 
                             $sop_nn);
}
#}}}

#{{{ Private Methods
method __init() {
  $self->__load_statements();
}

method __statement($name) {
  if (not defined $self->{statement_cache}->{$name}) {
    $self->{statement_cache}->{$name} = 
      $self->{ndb}->prepare($self->{sql_statements}->{$name});
  }

  return $self->{statement_cache}->{$name};
}

method __load_statements() {
  $self->{sql_statements}->{start_trans} = "begin";
  $self->{sql_statements}->{unlock} = "commit";
  $self->{sql_statements}->{abort} = "rollback";

  $self->{sql_statements}->{select_study_uid} = qq{
    select
      study_instance_uid
    from study_nickname
    where project_name = ?
      and site_name = ?
      and subj_id = ?
      and study_nickname = ?
  };

  $self->{sql_statements}->{select_series_uid} = qq{
    select
      series_instance_uid
    from series_nickname
    where project_name = ?
      and site_name = ?
      and subj_id = ?
      and series_nickname = ?
  };

  $self->{sql_statements}->{select_sop_uid} = qq{
    select distinct
      sop_instance_uid
    from sop_nickname
    where project_name = ?
      and site_name = ?
      and subj_id = ?
      and sop_nickname = ?
  };

  $self->{sql_statements}->{select_nn_file} = qq{
    select
      file_digest
    from
      file_nickname
    where project_name = ?
      and site_name = ?
      and subj_id = ?
      and sop_nickname_copy = ?
      and version_number = ?
  };
  $self->{sql_statements}->{select_nn_files} = qq{
    select
      file_digest
    from
      file_nickname
    where project_name = ?
      and site_name = ?
      and subj_id = ?
      and sop_nickname_copy = ?
  };

  $self->{sql_statements}->{lock_sequence_for_update} =
    "select * from nickname_sequence where\n" .
    "project_name = ? and site_name = ? and subj_id = ?\n" .
    "and nickname_type = ?\n" .
    "FOR UPDATE";

  $self->{sql_statements}->{update_nn_seq} =
    "update nickname_sequence set next_value = ? where\n" .
    "project_name = ? and site_name = ? and subj_id = ? and nickname_type = ?";

  $self->{sql_statements}->{new_nn_seq} =
    "insert into nickname_sequence(" .
    "project_name, site_name, subj_id, nickname_type, next_value)\n" .
    "values(?, ?, ?, ?, 1)";


  $self->{sql_statements}->{select_study_nn} =
    "select study_nickname from study_nickname where\n" .
    "project_name = ? and site_name = ? and subj_id = ?\n" .
    "and study_instance_uid = ?";

  $self->{sql_statements}->{insert_study_nn} =
    "insert into study_nickname(" .
    "project_name, site_name, subj_id, study_nickname, study_instance_uid)\n" .
    "values(?, ?, ?, ?, ?)";


  $self->{sql_statements}->{select_series_nn} =
    "select series_nickname from series_nickname where\n" .
    "project_name = ? and site_name = ? and subj_id = ?\n" .
    "and series_instance_uid = ?";

  $self->{sql_statements}->{insert_series_nn} =
    "insert into series_nickname(" .
    "project_name, site_name, subj_id, series_nickname, series_instance_uid)\n" .
    "values(?, ?, ?, ?, ?)";


  $self->{sql_statements}->{get_related_file_nicknames} =
    "select * from file_nickname where\n" .
    "project_name = ? and site_name = ? and subj_id = ? and sop_instance_uid = ?";

  $self->{sql_statements}->{lock_file_nicknames} =
    "LOCK file_nickname in ACCESS EXCLUSIVE mode";

  $self->{sql_statements}->{insert_file_nn} =
    "insert into file_nickname(" .
    "project_name, site_name, subj_id, sop_instance_uid,\n" .
    "version_number, file_digest, " .
    "sop_nickname_copy)\n" .
    "values(?, ?, ?, ?, ?, ?, ?)";

  $self->{sql_statements}->{select_sop_nn} =
    "select * from sop_nickname where\n" .
    "project_name = ? and site_name = ? and subj_id = ? and sop_instance_uid = ?";

  $self->{sql_statements}->{insert_sop_nn} =
    "insert into sop_nickname(" .
    "project_name, site_name, subj_id, sop_nickname,\n" .
    "modality, sop_instance_uid)\n" .
    "values(?, ?, ?, ?, ?, ?)";

  $self->{sql_statements}->{set_sop_modality_conflict} =
    "update sop_nickname set has_modality_conflict = true\n" .
    "where project_name = ? and site_name = ? and subj_id = ?\n" .
    "and sop_instance_uid = ?";
}

method __to_study_uid ($project_name,
                       $site_name,
                       $subj_id,
                       $study_nickname) {

  my $statement = $self->__statement('select_study_uid');
  $statement->execute($project_name, $site_name, $subj_id, $study_nickname);
  return $statement->fetchrow_arrayref()->[0];
}

method __to_series_uid ($project_name,
                       $site_name,
                       $subj_id,
                       $study_nickname) {
  my $statement = $self->__statement('select_series_uid');
  $statement->execute($project_name, $site_name, $subj_id, $study_nickname);
  return $statement->fetchrow_arrayref()->[0];
}

method __to_sop_uid ($project_name,
                       $site_name,
                       $subj_id,
                       $sop_nickname) {

  # nickname could have a version component, get rid of it
  $sop_nickname =~ /([^\[\]]+)/;
  my $version_free = $1;

  my $statement = $self->__statement('select_sop_uid');
  $statement->execute($project_name, $site_name, $subj_id, $version_free);
  return $statement->fetchrow_arrayref()->[0];
}

method __study_nickname ($project_name, 
                         $site_name, 
                         $subj_id, 
                         $study_instance_uid) {

  my $ndb = $self->{ndb};
  $self->__statement('start_trans')->execute;
  $self->__statement('select_study_nn')->execute(
    $project_name, $site_name, $subj_id, $study_instance_uid);
  my @rows;

  while(my $row = $self->__statement('select_study_nn')->fetchrow_hashref){ 
    push @rows, $row;
  }

  if(@rows > 1) {
     die "multiple study rows for project: $project_name, " .
      "site: $site_name, study: $study_instance_uid, subj: $subj_id"
  }
  if(@rows == 1) { 
    $self->__statement('unlock')->execute; 
    return $rows[0]->{study_nickname} 
  }
  $self->__statement('lock_sequence_for_update')->execute(
    $project_name, $site_name, $subj_id, "study");
  my $seq;
  @rows = ();
  while(my $row = $self->__statement('lock_sequence_for_update')->fetchrow_hashref){
    push @rows, $row;
  }
  if(@rows > 1) {
    $self->__statement('abort')->execute;
    die "multiple sequences for $project_name, $site_name, $subj_id, study";
  }
  if(@rows == 1){
    $seq = $rows[0]->{next_value};
    my $next_value = $seq + 1;
    $self->__statement('update_nn_seq')->execute(
      $next_value, $project_name, $site_name, $subj_id, "study");
  } else {
    $seq = 0;
    $self->__statement('new_nn_seq')->execute(
      $project_name, $site_name, $subj_id, "study");
  }
  my $nn = "STUDY_$seq";
  $self->__statement('insert_study_nn')->execute(
    $project_name, $site_name, $subj_id, $nn, $study_instance_uid);
  $self->__statement('unlock')->execute;
  return $nn;
}

method __series_nickname ($project_name, 
                          $site_name, 
                          $subj_id, 
                          $series_instance_uid) {

  $self->__statement('start_trans')->execute;
  $self->__statement('select_series_nn')->execute($project_name, $site_name, $subj_id,
    $series_instance_uid);
  my @rows;
  while(my $row = $self->__statement('select_series_nn')->fetchrow_hashref){ 
    push @rows, $row 
  }
  if(@rows > 1) {
     die "multiple series rows for project: $project_name, " .
      "site: $site_name, series: $series_instance_uid"
  }
  if(@rows == 1) { 
    $self->__statement('unlock')->execute; 
    return $rows[0]->{series_nickname} 
  }
  $self->__statement('lock_sequence_for_update')->execute(
    $project_name, $site_name, $subj_id, "series");
  my $seq;
  @rows = ();
  while(my $row = $self->__statement('lock_sequence_for_update')->fetchrow_hashref){
    push @rows, $row;
  }
  if(@rows > 1) {
    $self->__statement('abort')->execute;
    die "multiple sequences for $project_name, $site_name, $subj_id, series";
  }
  if(@rows == 1){
    $seq = $rows[0]->{next_value};
    my $next_value = $seq + 1;
    $self->__statement('update_nn_seq')->execute(
      $next_value, $project_name, $site_name, $subj_id, "series");
  } else {
    $seq = 0;
    $self->__statement('new_nn_seq')->execute(
      $project_name, $site_name, $subj_id, "series");
  }
  my $nn = "SERIES_$seq";
  $self->__statement('insert_series_nn')->execute(
    $project_name, $site_name, $subj_id, $nn, $series_instance_uid);
  $self->__statement('unlock')->execute;
  return $nn;
}

method __sop_nickname ($project_name, 
                       $site_name, 
                       $subj_id, 
                       $sop_instance_uid, 
                       $modality) {
  $self->__statement('select_sop_nn')->execute(
    $project_name, $site_name, $subj_id, $sop_instance_uid);
  my @rows;
  while(my $row = $self->__statement('select_sop_nn')->fetchrow_hashref) { 
    push @rows, $row 
  }
  if(@rows > 1){
    $self->__statement('abort')->execute;
    die "Multiple nicknames for project: $project_name, site $site_name, " .
      "subj: $subj_id, sop: $sop_instance_uid";
  }
  if(@rows == 1) {
    unless($rows[0]->{modality} eq $modality){
      print STDERR "Modality conflict for SOP: $sop_instance_uid\n";
      $self->__statement('set_sop_modality_conflict')->execute(
        $project_name, $site_name, $subj_id, $sop_instance_uid);
    }
    return $rows[0]->{sop_nickname};
  }
  $self->__statement('lock_sequence_for_update')->execute(
    $project_name, $site_name, $subj_id, "sop");
  my $seq;
  @rows = ();
  while(my $row = $self->__statement('lock_sequence_for_update')->fetchrow_hashref){
    push @rows, $row;
  }
  if(@rows > 1) {
    $self->__statement('abort')->execute;
    die "multiple sequences for $project_name, $site_name, $subj_id, sop";
  }
  if(@rows == 1){
    $seq = $rows[0]->{next_value};
    my $next_value = $seq + 1;
    $self->__statement('update_nn_seq')->execute(
      $next_value, $project_name, $site_name, $subj_id, "sop");
  } else {
    $seq = 0;
    $self->__statement('new_nn_seq')->execute(
      $project_name, $site_name, $subj_id, "sop");
  }
  my $nn = "$modality" ."_$seq";
  $self->__statement('insert_sop_nn')->execute(
    $project_name, $site_name, $subj_id, $nn, $modality, $sop_instance_uid);
  return $nn;
}

method __file_nickname ($project_name, 
                        $site_name, 
                        $subj_id,  
                        $sop_instance_uid, 
                        $digest, 
                        $modality) {
  $self->__statement('start_trans')->execute;
  $self->__statement('get_related_file_nicknames')->execute(
    $project_name, $site_name, $subj_id, $sop_instance_uid);
  my %rows;
  while(my $row = $self->__statement('get_related_file_nicknames')->fetchrow_hashref){
    if(exists $rows{$row->{file_digest}}){
      $self->__statement('abort')->execute;
      die "digest $row->{file_digest} not unique in file_nickname";
    }
    $rows{$row->{file_digest}} = $row;
  }
  if(exists $rows{$digest}){
    $self->__statement('unlock')->execute;
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
    $self->__statement('insert_file_nn')->execute(
      $project_name, $site_name, $subj_id,
      $sop_instance_uid, $next, $digest, $sop_nn);
    $self->__statement('unlock')->execute;
    return "$sop_nn" . "[$next]";
  }
  $sop_nn = $self->__sop_nickname(
    $project_name, $site_name, $subj_id,
    $sop_instance_uid, $modality);
  $self->__statement('insert_file_nn')->execute(
    $project_name, $site_name, $subj_id,
    $sop_instance_uid, 0, $digest, $sop_nn);
  $self->__statement('unlock')->execute;
  return "$sop_nn";
}

method Sop($sop_instance_uid, $modality) {
  $self->__sop_nickname($self->{project_name},
                        $self->{site_name},
                        $self->{subj_id},
                        $sop_instance_uid,
                        $modality);
}

method ToFiles($nickname) {
  $self->__nickname_to_file($self->{project_name},
                            $self->{site_name},
                            $self->{subj_id},
                            $nickname);
}
method __nickname_to_file ($project_name,
                           $site_name,
                           $subj_id,
                           $nickname) {


  if (DEBUG) { 
    say "__nickname_to_file($project_name, $site_name, $subj_id, $nickname)";
  }
  # if $nickname has a version number, return only that version
  # if $nickname has no version number, return all files
  # always return a list

  # drop any version info
  my $short_nn = ($nickname =~ /(\w+)/)[0];
  if (DEBUG) { say "short_nn = $short_nn" }

  # extract the version number
  my $version = ($nickname =~ /\[(\d)\]/) ? $1:undef;
  if (DEBUG) { 
    if (defined $version) {
      say "version = $version";
    } else {
      say "version is undef";
    }
  }

  my $statement;
  if (defined $version) {
    $statement = $self->__statement('select_nn_file');
    $statement->execute(
      $project_name, $site_name, $subj_id, $short_nn, $version);
  } else {
    $statement = $self->__statement('select_nn_files');
    $statement->execute(
      $project_name, $site_name, $subj_id, $short_nn);
  }
  if (DEBUG) { say "statement executed" }

  my @rows;
  map { push @rows, $_->[0]; } @{$statement->fetchall_arrayref()};
  if (DEBUG) { 
    say "Rows returned: ", scalar @rows;
    for my $r (@rows) {
      say $r;
    }
  }
  return \@rows;
}
#}}}

1;
