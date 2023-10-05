#!/usr/bin/perl -w
#
use strict;
use DBI;
use Posda::Nicknames2;
my $usage = "GetCountsRange.pl <db> <start_date> <end_date> <nn_db>\n";
unless ($#ARGV == 3) { die $usage };
my $dbh = DBI->connect("DBI:Pg:database=$ARGV[0]", "", "");
my $nn_db = DBI->connect("DBI:Pg:database=$ARGV[3]", "", "");
my $base_q = <<EOF;
select
  distinct project_name, site_name,
  file_id, patient_id, study_instance_uid, series_instance_uid,
  modality, min(import_time)as first_import, max(import_time)as last_import
from
  import_event natural join file_import natural join ctp_file
  natural join file_series natural join file_study natural join file_patient
group by
  project_name, site_name,
  file_id, patient_id, study_instance_uid, series_instance_uid, modality
EOF
my $where = <<EOF;
where first_import >= ?  and last_import < ?
EOF
my $rollup = <<EOF;
select
  distinct project_name, site_name,
  patient_id, study_instance_uid, series_instance_uid,
  modality, count(*)
EOF
my $rollup_group = <<EOF;
group by
  project_name, site_name,
  patient_id, study_instance_uid, series_instance_uid, modality
order by
  project_name, site_name,
  patient_id, study_instance_uid, modality
EOF
my $query = <<EOF;
$rollup from ( $base_q ) as foo $where $rollup_group
EOF
my $gstd = $dbh->prepare(
  "select distinct study_description from file_study where " .
  "study_instance_uid = ?");
my $gsed = $dbh->prepare(
  "select distinct series_description from file_series where " .
  "series_instance_uid = ?");
my $gstda = $dbh->prepare(
  "select distinct study_date from file_study where " .
  "study_instance_uid = ?");
my $gseda = $dbh->prepare(
  "select distinct series_date from file_series where " .
  "series_instance_uid = ?");

my $nn;
my $current_pat_id;
print "\"Subject\",\"Study\",\"Study Date\",\"Description\"," .
  "\"Series\",\"Series Date\",\"Description\",\"Modality\",\"Num Files\"," .
  "\"Study UID\",\"Series UID\"\n";
my $ov = $dbh->prepare($query);
$ov->execute($ARGV[1], $ARGV[2]);
while (my $h = $ov->fetchrow_hashref){
  unless(defined $current_pat_id){
    $current_pat_id = $h->{patient_id};
    $nn = Posda::Nicknames2->new(
      $nn_db, $h->{project_name}, $h->{site_name}, $h->{patient_id});
  }
  unless($current_pat_id eq $h->{patient_id}){
    $current_pat_id = $h->{patient_id};
    $nn = Posda::Nicknames2->new(
      $nn_db, $h->{project_name}, $h->{site_name}, $h->{patient_id});
  }
  my($study_desc, $study_date) =
    GetStudyDescAndDate($h->{study_instance_uid});
  my($series_desc, $series_date) =
    GetSeriesDescAndDate($h->{series_instance_uid});
  my $study_nn = $nn->Study($h->{study_instance_uid});
  my $series_nn = $nn->Series($h->{series_instance_uid});
  print "\"$h->{patient_id}\"," .
    "\"$study_nn\",\"$study_date\",\"$study_desc\"," .
    "\"$series_nn\",\"$series_date\",\"$series_desc\"," .
    "\"$h->{modality}\",\"$h->{count}\",\"$h->{study_instance_uid}\"," .
    "\"$h->{series_instance_uid}\"\n";
}
sub GetStudyDescAndDate{
  my($study_inst_uid) = @_;
  my %StudyDesc;
  $gstd->execute($study_inst_uid);
  while(my $h = $gstd->fetchrow_hashref){
    $StudyDesc{$h->{study_description}} = 1;
  }
  my $desc;
  if(keys %StudyDesc == 0){
    $desc = undef;
  } elsif(keys %StudyDesc == 1) { $desc = [keys %StudyDesc]->[0] }
  else {
    $desc = "<inconsistent>:(";
    my @study_desc = keys %StudyDesc;
    for my $k (0 .. $#study_desc){
      $desc .= "'$study_desc[$k]'";
      if($k == $#study_desc){
        $desc .= ")";
      } else {
        $desc .= ", ";
      }
    }
  }
  my $date;
  my %StudyDate;
  $gstda->execute($study_inst_uid);
  while(my $h = $gstda->fetchrow_hashref){
    $StudyDate{$h->{study_date}} = 1;
  }
  if(keys %StudyDate == 0){
    $date = undef;
  } elsif(keys %StudyDate == 1) { $date = [keys %StudyDate]->[0] }
  else {
    $date = "<inconsistent>:(";
    my @study_date = keys %StudyDate;
    for my $k (0 .. $#study_date){
      $date .= "'$study_date[$k]'";
      if($k == $#study_date){
        $date .= ")";
      } else {
        $date .= ", ";
      }
    }
  }
  return $desc, $date;
}
sub GetSeriesDescAndDate{
  my($series_inst_uid) = @_;
  my %SeriesDesc;
  $gsed->execute($series_inst_uid);
  while(my $h = $gsed->fetchrow_hashref){
    $SeriesDesc{$h->{series_description}} = 1;
  }
  my $desc;
  if(keys %SeriesDesc == 0){
    $desc = undef;
  } elsif(keys %SeriesDesc == 1) { $desc = [keys %SeriesDesc]->[0] }
  else {
    $desc = "<inconsistent>:(";
    my @series_desc = keys %SeriesDesc;
    for my $k (0 .. $#series_desc){
      $desc .= "'$series_desc[$k]'";
      if($k == $#series_desc){
        $desc .= ")";
      } else {
        $desc .= ", ";
      }
    }
  }
  my $date;
  my %SeriesDate;
  $gseda->execute($series_inst_uid);
  while(my $h = $gseda->fetchrow_hashref){
    $SeriesDate{$h->{series_date}} = 1;
  }
  if(keys %SeriesDate == 0){
    $date = undef;
  } elsif(keys %SeriesDate == 1) { $date = [keys %SeriesDate]->[0] }
  else {
    $date = "<inconsistent>:(";
    my @series_date = keys %SeriesDate;
    for my $k (0 .. $#series_date){
      $date .= "'$series_date[$k]'";
      if($k == $#series_date){
        $date .= ")";
      } else {
        $date .= ", ";
      }
    }
  }
  return $desc, $date;
}
