#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::Dataset;
my $usage = <<EOF;
PhiSeriesScan.pl  <series_instance_uid> <signature> <scan id> <file>
  series_jnstance_uid  - series_instance_uid
  signature            - signature of equipment for series
  scan id              - id of scan_event to which this file scan belongs
  file                 - file for scanning
EOF
unless($#ARGV == 3){ die $usage }
my($series_inst, $sig, $scan_id, $file) = @ARGV;
#####################
#  Create Series Scan
#  my $ss_id = CreateSeriesScan($id, $series, $sig_id);
#
my $gsce = PosdaDB::Queries->GetQueryInstance("GetScanEventById");
my $in_sse = PosdaDB::Queries->GetQueryInstance("InsertIntoSeriesScan");
my $gscecv = PosdaDB::Queries->GetQueryInstance("GetScanEventId");
sub CreateSeriesScan{
  my($id, $series, $sig_id) = @_;
print STDERR "Create series scan($id, $series, $sig_id, $file)\n";
  my $scan_status;
  $gsce->RunQuery(
    sub {
      my($row) = @_;
      $scan_status = $row->[3];
    }, sub {},
    $id
  );
  unless(defined $scan_status) { die "Scan event $id doesn't exist" }
  unless($scan_status eq "In Process"){
    die "Scan event $id is not \"In Process\" for series $series";
  }
  $in_sse->RunQuery(
  sub {
  },
  sub {
  },$id, $sig_id, $series, $file);
  my $scan_id;
  $gscecv->RunQuery(
    sub {
      my($row) = @_;
      $scan_id = $row->[0];
    },
    sub {});
  if(defined $scan_id) { return $scan_id }
  die "Can't create scan_id";
}
#####################
#  Get Equipment Signature ID
#  my $id = GetEquipSignature($sig)
#
my $geid = PosdaDB::Queries->GetQueryInstance("GetEquipmentSignature");
my $ineqid = PosdaDB::Queries->GetQueryInstance("CreateEquipmentSignature");
my $eqcv = PosdaDB::Queries->GetQueryInstance("GetEquipmentSignatureId");
sub GetEquipSignature{
  my($sig) = @_;
  my $id;
  $geid->RunQuery(sub {
      my($row) = @_;
      $id = $row->[0];
    }, sub {}, $sig);
  if(defined $id) { return $id }
  $ineqid->RunQuery(sub {}, sub {}, $sig);
  $eqcv->RunQuery(sub {
      my($row) = @_;
      $id = $row->[0];
    }, sub {});
  if(defined $id) { return $id }
  die "Can't get equipment_id for sig: $sig, series $series_inst";
}
#####################
#  Get Seen Value
#  my $v_id  = GetSeenValue($value);
#
my $gsv = PosdaDB::Queries->GetQueryInstance("GetSeenValue");
my $insv = PosdaDB::Queries->GetQueryInstance("CreateSeenValue");
my $svcvg = PosdaDB::Queries->GetQueryInstance("GetSeenValueId");
sub GetSeenValue{
  my($value) = @_;
  my $id;
  $gsv->RunQuery(sub {
      my($row) = @_;
      $id = $row->[0];
    }, sub {}, $value);
  if(defined $id) { return $id }
  $insv->RunQuery(sub {}, sub {}, $value);
  $svcvg->RunQuery(sub {
      my($row) = @_;
      $id = $row->[0];
    }, sub {});
  if(defined $id) { return $id }
  die "Can't get equipment_id for sig: $sig, series $series_inst";
}
#####################
#  Get Element Sig
#  my $es_id  = GetElementSig($pattern, $vr);
#
my $ges = PosdaDB::Queries->GetQueryInstance("GetElementSignature");
my $ines = PosdaDB::Queries->GetQueryInstance("CreateElementSignature");
my $esgcv = PosdaDB::Queries->GetQueryInstance("GetElementSignatureId");
sub GetElementSig{
  my($pattern, $vr) = @_;
  my $id;
  $ges->RunQuery(sub {
      my($row) = @_;
      $id = $row->[0];
    }, sub {}, $pattern, $vr);
  if(defined $id) { return $id }
  my $is_private = "false";
  if($pattern =~ /,\"/){
    $is_private = "true";
  }
  $ines->RunQuery(sub {}, sub {}, $pattern, $vr, $is_private);
  $esgcv->RunQuery(sub {
      my($row) = @_;
      $id = $row->[0];
    }, sub {});
  if(defined $id) { return $id }
  die "Can't get element_sig for sig: $pattern, vr: $vr";
}
#####################
#  Create Table Sequence Index
#  CreateTableSequenceIndex($scan_id, $i, $item);
#
my $ins_se = PosdaDB::Queries->GetQueryInstance("CreateTableSequenceIndex");
sub CreateTableSequenceIndex{
  my($se_id, $seql, $in) = @_;
  $ins_se->RunQuery(sub {}, sub {}, $se_id, $seql, $in);
}
#####################
#  Update Series Scan Status
#  UpdateSeriesScanStatus($scan_id, $status);
#
my $upd_sss = PosdaDB::Queries->GetQueryInstance("UpdateSeriesScan");
sub UpdateSeriesScanStatus{
  my($status, $id) = @_;
  $upd_sss->RunQuery(sub {}, sub {}, $status, $id);
}
#####################
#  Create Scan Element
#  my $scan_id = CreateScanElement($el_sig_id, $seen_value_id, $series_scan_id);
#  CreateScanElement($el_sig_id, $seen_value_id, $series_scan_id);
#
my $c_se = PosdaDB::Queries->GetQueryInstance("CreateScanElement");
my $gcv_se = PosdaDB::Queries->GetQueryInstance("GetScanElementId");
sub CreateScanElement{
  my($el_sig_id, $seen_value_id, $series_scan_id) = @_;
  $c_se->RunQuery(sub {}, sub {}, $el_sig_id, $seen_value_id, $series_scan_id);
  my $se_id;
  $gcv_se->RunQuery(sub {
      my($row) = @_;
      $se_id = $row->[0];
    }, sub {});
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
