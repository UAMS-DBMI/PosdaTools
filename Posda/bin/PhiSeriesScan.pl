#!/usr/bin/perl -w
use strict;
use DBI;
use Posda::Dataset;
my $usage = <<EOF;
PhiSeriesScan.pl <db> <series_instance_uid> <signature> <scan id> <file>
  db                   - name of database
  series_jnstance_uid  - series_instance_uid
  signature            - signature of equipment for series
  scan id              - id of scan_event to which this file scan belongs
  file                 - file for scanning
EOF
unless($#ARGV == 4){ die $usage }
my($db, $series_inst, $sig, $scan_id, $file) = @ARGV;
my $dbh = DBI->connect("DBI:Pg:dbname=$db", "", "");
#####################
#  Create Series Scan
#  my $ss_id = CreateSeriesScan($id, $series, $sig_id);
#
my $gsce = $dbh->prepare("select * from scan_event where scan_event_id = ?");
my $in_sse = $dbh->prepare("insert into series_scan(\n" .
  "  scan_event_id, equipment_signature_id, series_instance_uid,\n" .
  "  series_scan_status, series_scanned_file\n" .
  ") values (\n" .
  "  ?, ?, ?, 'In Process', ?)");
my $gscecv = $dbh->prepare(
"select currval('series_scan_series_scan_id_seq') as id"
);
sub CreateSeriesScan{
  my($id, $series, $sig_id) = @_;
print STDERR "Create series scan($id, $series, $sig_id, $file)\n";
  $gsce->execute($id);
  my $h = $gsce->fetchrow_hashref;
  $gsce->finish;
  unless($h) { die "Scan event $id doesn't exist" }
  unless($h->{scan_status} eq "In Process"){
    die "Scan event $id is not \"In Process\" for series $series";
  }
  $in_sse->execute($id, $sig_id, $series, $file);
  my $scan_id;
  $gscecv->execute;
  while(my $h = $gscecv->fetchrow_hashref){
    $scan_id = $h->{id};
  }
  if(defined $scan_id) { return $scan_id }
  die "Can't create scan_id";
}
#####################
#  Get Equipment Signature ID
#  my $id = GetEquipSignature($sig)
#
my $eqidq = <<EOF;
select * from equipment_signature where equipment_signature = ?
EOF
my $geid = $dbh->prepare($eqidq);
my $ineqidq = <<EOF;
insert into equipment_signature(equipment_signature)values(?)
EOF
my $ineqid = $dbh->prepare($ineqidq);
my $eqcvq = <<EOF;
select currval('equipment_signature_equipment_signature_id_seq') as id
EOF
my $eqcv = $dbh->prepare($eqcvq);
sub GetEquipSignature{
  my($sig) = @_;
  my $id;
  $geid->execute($sig);
  while(my $h = $geid->fetchrow_hashref){
    $id = $h->{equipment_signature_id};
  }
  if(defined $id) { return $id }
  $ineqid->execute($sig);
  $eqcv->execute;
  while(my $h = $eqcv->fetchrow_hashref){
    $id = $h->{id};
  }
  if(defined $id) { return $id }
  die "Can't get equipment_id for sig: $sig, series $series_inst";
}
#####################
#  Get Seen Value
#  my $v_id  = GetSeenValue($value);
#
my $gsv = $dbh->prepare("select * from seen_value where value = ?");
my $insv = $dbh->prepare("insert into seen_value(value)values(?)");
my $svcvg = $dbh->prepare("select currval('seen_value_seen_value_id_seq') " .
  "as id");
sub GetSeenValue{
  my($value) = @_;
  my $id;
  $gsv->execute($value);
  while(my $h = $gsv->fetchrow_hashref){
    $id = $h->{seen_value_id};
  }
  if(defined $id) { return $id }
  $insv->execute($value);
  $svcvg->execute;
  while(my $h = $svcvg->fetchrow_hashref){
    $id = $h->{id};
  }
  if(defined $id) { return $id }
  die "Can't get equipment_id for sig: $sig, series $series_inst";
}
#####################
#  Get Element Sig
#  my $es_id  = GetElementSig($pattern, $vr);
#
my $ges = $dbh->prepare("select * from element_signature\n" .
  "where element_signature = ? and vr = ?");
my $ines = $dbh->prepare("insert into element_signature(\n" .
   "  element_signature, vr, is_private\n" .
   ")values(?, ?, ?)");
my $esgcv = $dbh->prepare(
  "select currval('element_signature_element_signature_id_seq') as id");
sub GetElementSig{
  my($pattern, $vr) = @_;
  my $id;
  $ges->execute($pattern, $vr);
  while(my $h = $ges->fetchrow_hashref){
    $id = $h->{element_signature_id};
  }
  if(defined $id) { return $id }
  my $is_private = "false";
  if($pattern =~ /,\"/){
    $is_private = "true";
  }
  $ines->execute($pattern, $vr, $is_private);
  $esgcv->execute;
  while(my $h = $esgcv->fetchrow_hashref){
    $id = $h->{id};
  }
  if(defined $id) { return $id }
  die "Can't get element_sig for sig: $pattern, vr: $vr";
}
#####################
#  Create Table Sequence Index
#  CreateTableSequenceIndex($scan_id, $i, $item);
#
my $ins_se = $dbh->prepare("insert into sequence_index(\n" .
  "  scan_element_id, sequence_level, item_number\n" .
  ") values (?, ?, ?)");
sub CreateTableSequenceIndex{
  my($se_id, $seql, $in) = @_;
  $ins_se->execute($se_id, $seql, $in);
}
#####################
#  Update Series Scan Status
#  UpdateSeriesScanStatus($scan_id, $status);
#
my $upd_sss = $dbh->prepare("update series_scan\n" .
  "  set series_scan_status = ?\n" .
  "where series_scan_id = ?");
sub UpdateSeriesScanStatus{
  my($status, $id) = @_;
  $upd_sss->execute($status, $id);
}
#####################
#  Create Scan Element
#  my $scan_id = CreateScanElement($el_sig_id, $seen_value_id, $series_scan_id);
#  CreateScanElement($el_sig_id, $seen_value_id, $series_scan_id);
#
my $c_se = $dbh->prepare("insert into scan_element(\n" .
  "  element_signature_id, seen_value_id, series_scan_id\n" .
  ")values(\n" .
  "  ?, ?, ?)"
);
my $gcv_se = $dbh->prepare(
  "select currval('scan_element_scan_element_id_seq') as id");
sub CreateScanElement{
  my($el_sig_id, $seen_value_id, $series_scan_id) = @_;
  $c_se->execute($el_sig_id, $seen_value_id, $series_scan_id);
  $gcv_se->execute;
  my $se_id;
  while(my $h = $gcv_se->fetchrow_hashref){
    $se_id = $h->{id};
  }
  if(defined $se_id) { return $se_id }
  die "Can't get ScanElementId";
}
#####################
## Program here
my $sig_id = GetEquipSignature($sig);
my $series_scan_id = CreateSeriesScan($scan_id, $series_inst, $sig_id);
print STDERR "Created SeriesScan: $series_scan_id\n";
my $cmd = "FindUniqueWords.pl \"$file\"";
#print STDERR "cmd: $cmd\n";
open SUBP, "$cmd|";
while(my $line = <SUBP>){
  chomp $line;
  my($value, $tag, $vr) = split(/\|/, $line);
  my($pat, $indices) = Posda::Dataset->MakeMatchPat($tag);
  my $seen_value_id = GetSeenValue($value);
  my $el_sig_id = GetElementSig($pat, $vr);
  my $scan_id = CreateScanElement($el_sig_id, $seen_value_id, $series_scan_id);
  if(defined($indices) && ref($indices) eq "ARRAY"){
    for my $i (0 .. $#{$indices}){
      CreateTableSequenceIndex($scan_id, $i, $indices->[$i]);
    }
  }
}
UpdateSeriesScanStatus('TerminatedNormally', $series_scan_id);
