#!/usr/bin/perl -w
use strict;
use PosdaCuration::PerformBulkOperations;
use Posda::UUID;
use Posda::Try;
my $usage = "$0 <root> <collection> <site> <subj>";
unless($#ARGV == 3) { die $usage }
my $sub = sub {
  my($coll, $site, $subj, $f_list, $info, $nicknames) = @_;
#  print "Callback: $coll, $site, $subj, $f_list, $info, $nicknames\n";
  my $dicom_info = $info->{"dicom.pinfo"};
  my %PixelDigests;
  for my $dig (keys %{$dicom_info->{FilesByDigest}}){
    $PixelDigests{$dicom_info->{FilesByDigest}->{$dig}->{pixel_digest}}
      ->{$dig} = $dicom_info->{FilesByDigest}->{$dig};
  }
  my $by_dig = $dicom_info->{FilesByDigest};
  for my $pdig (keys %PixelDigests){
    if(keys %{$PixelDigests{$pdig}} > 1){
      print "Pixel digest ($pdig) is duplicated\n";
      for my $dig (keys %{$PixelDigests{$pdig}}){
        my $study_uid = $by_dig->{$dig}->{study_uid};
        my $series_uid = $by_dig->{$dig}->{series_uid};
        my $sop_uid = $by_dig->{$dig}->{sop_inst_uid};
        my $modality = $by_dig->{$dig}->{modality};
#        print "\t$study_uid|$series_uid|$sop_uid|$modality|$dig\n";
        my $study_nn = $nicknames->Study($study_uid);
        my $series_nn = $nicknames->Series($series_uid);
        my $file_nn = $nicknames->File($sop_uid, $dig, $modality);
        print "\t$study_nn, $series_nn, $file_nn\n";
      }
    }
  }
  return undef;
};
my $root = $ARGV[0];
my $coll = $ARGV[1];
my $site = $ARGV[2];
my $subj = $ARGV[3];
my $user = `whoami`;
chomp $user;
my $port = 64612;
my $session = Posda::UUID::GetGuid;
my $Bulk = PosdaCuration::PerformBulkOperations->new(
  $root,
  $coll, $site, $session, $user, $port);
$Bulk->SetSubjectList([$subj]);
$Bulk->MapEdits($sub, $0);
