#!/usr/bin/perl -w
use strict;
use Text::CSV;
use DBI;
my $dbh = DBI->connect("DBI:Pg:dbname=dicom_roots", "", "");
my $csv = Text::CSV->new({binary => 1});
my $get_collection_by_code = <<EOF;
  select * from Collection where collection_code = ?
EOF
my $get_site_by_code = <<EOF;
  select * from site where site_code = ?
EOF
my $get_submission_by_ids = <<EOF;
  select * from Submission where collection_id  = ? and site_id = ?
EOF
my $get_submission_by_names = <<EOF;
  select * 
  from Collection natural join Site natural join Submission
  where collection_name  = ? and site_name = ?
EOF
my $create_collection = <<EOF;
  insert into collection(collection_code)
  values(?)
EOF
my $create_site = <<EOF;
  insert into Site(site_code)
  values(?)
EOF
my $create_submission = <<EOF;
  insert into Submission
    (collection_id, site_id, collection_name, site_name, patient_id_prefix,
     body_part_entered, access_type, date_inc, extra)
  values
    (?, ?, ?, ?, ?, ?, ?, ?, ?)
EOF
my $create_submission_event = <<EOF;
  insert into SubmissionEvent
    (submission_id, event_type, occurance_date_time, reporting_user, comment)
  values
    (?, ?, ?, ?, ?)
EOF
my $select_spreadsheet = <<EOF;
select
  collection_name, site_name, collection_code, site_code,
  patient_id_prefix, body_part_entered, access_type, date_inc, extra
from
  submission natural join collection natural join site
EOF
my $gcbc = $dbh->prepare($get_collection_by_code);
my $gsbc = $dbh->prepare($get_site_by_code);
my $gsbi = $dbh->prepare($get_submission_by_ids);
my $gsbbn = $dbh->prepare($get_submission_by_names);
my $cc = $dbh->prepare($create_collection);
my $cs = $dbh->prepare($create_site);
my $csb = $dbh->prepare($create_submission);
my $csbe = $dbh->prepare($create_submission_event);
sub GetCollectionByCode{
  my($code) = @_;
  $gcbc->execute($code);
  my @results;
  while(my $h = $gcbc->fetchrow_hashref){
    push @results, $h;
  }
  my $num_results = @results;
  if($num_results > 1){
    die "$num_results collections with code \"$code\"";
  }
  if($num_results == 0) { return undef }
  return $results[0];
}
sub GetSiteByCode{
  my($code) = @_;
  $gsbc->execute($code);
  my @results;
  while(my $h = $gsbc->fetchrow_hashref){
    push @results, $h;
  }
  my $num_results = @results;
  if($num_results > 1){
    die "$num_results sites with code \"$code\"";
  }
  if($num_results == 0) { return undef }
  return $results[0];
}
sub GetSubmissionByIds{
  my($collection_id, $site_id) = @_;
  $gsbi->execute($collection_id, $site_id);
  my @results;
  while(my $h = $gsbi->fetchrow_hashref){
    push @results, $h;
  }
  my $num_results = @results;
  if($num_results > 1){
    die "$num_results collection/site pairs for ids " .
      "\"$collection_id/$site_id\"";
  }
  if($num_results == 0) { return undef }
  return $results[0];
}
sub GetSubmissionByNames{
  my($collection_name, $site_name) = @_;
  $gsbi->execute($collection_name, $site_name);
  my @results;
  while(my $h = $gsbi->fetchrow_hashref){
    push @results, $h;
  }
  my $num_results = @results;
  if($num_results > 1){
    die "$num_results collection/site pairs for ids " .
      "\"$collection_name/$site_name\"";
  }
  if($num_results == 0) { return undef }
  return $results[0];
}
sub CreateCollection{
  my($root_code) = @_;
  $cc->execute($root_code);
}
sub CreateSite{
  my($site_code, $site_name) = @_;
  $cs->execute($site_code);
}
sub CreateSubmission{
  my($col_id, $site_id, $col_name, $site_n, $body_part, 
     $pat_pre, $acc_type, $data_inc, $extra) = @_;
  $csb->execute($col_id, $site_id, $col_name, $site_n, $body_part,
                $pat_pre, $acc_type, $data_inc, $extra);
}
sub CreateSubmissionEvent{
  my($submission_id, $evt_t, $occur, $user, $comment) = @_;
  $csbe->execute($submission_id, $evt_t, $occur, $user, $comment);
}

# $h = GetCollectionByCode($code)
# $h = GetSiteByName($code)
# $h = GetSubmissionByIds($collection_id, $site_id)
# $h = GetSubmissionByNames($collection_name, $site_name)
# CreateCollection($root_code, $collection_name, $date_inc)
# CreateSite($site_code, $site_name)
# CreateSubmission($col_id, $site_id, $col_name, $site_n, $body_part,
#     $pat_pre, $acc_type, $data_inc, $extra) = @_;
# CreateSubmissionEvent($submission_id, $evt_t, $occur, $user, $comment)

while(my $row = $csv->getline(*STDIN)){
  my($one, $submission_begun, $site_code, $collection_code,
    $site_id, $collection, $site, $patient_id_prefix, $body_part_imaged, 
    $access, $date_inc, $comment) = @$row;
  unless($site && $collection){
    print STDERR "bad line\n";
    next;
  }
  my $site_h = GetSiteByCode($site_code);
  unless(defined $site_h){
print "Creating site for $site_code ($site)\n";
    $cs->execute($site_code);
    $site_h = GetSiteByCode($site_code);
    unless(defined $site_h) { die "can't create site $site_code ($site)" }
  }
  my $col_h = GetCollectionByCode($collection_code);
  unless(defined $col_h){
print "Creating Collecton for $collection_code ($collection)\n";
    $cc->execute($collection_code);
    $col_h = GetCollectionByCode($collection_code);
    unless(defined $col_h) { die "can't create collection $collection_code" }
  }
  my $sub_h = GetSubmissionByIds($col_h->{collection_id}, $site_h->{site_id});
  unless(defined $sub_h){
    $csb->execute(
      $col_h->{collection_id}, $site_h->{site_id}, $site, $collection,
      $patient_id_prefix, $body_part_imaged, $access, $date_inc, $comment);
    $sub_h = GetSubmissionByIds($col_h->{collection_id}, $site_h->{site_id});
    unless(defined $sub_h) { die "can't create submission($collection, $site)" }
  }
}
