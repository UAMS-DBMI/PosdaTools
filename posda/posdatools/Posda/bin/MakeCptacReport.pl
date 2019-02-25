#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Digest::MD5;
use Posda::BackgroundProcess;
use Posda::ActivityInfo;

my $usage = <<EOF;
CompareSopsTpPosdaPublic.pl <?bkgrnd_id?> <notify>
or
CompareSopsTpPosdaPublic.pl -h

The script doesn't expect lines on STDIN:

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
unless($#ARGV == 1){ die "$usage\n"; }

my ($invoc_id,  $notify) = @ARGV;
print "script: $0\n";
print "going to background to collect and analyze data\n";
my $back = Posda::BackgroundProcess->new($invoc_id, $notify);
$back->Daemonize;
my $main_q = Query("GetAllQualifiedCTQPByLikeCollectionWithFIleCountAndLoadTimes");
my $get_posda_counts = Query("GetPosdaSopCountByPatientId");
my $get_public_counts = Query("GetPublicSopCountByPatientId");
my $now = `date`;
chomp $now;
my $start = time;
$back->WriteToEmail("script: $0\n");
$back->WriteToEmail("at: $now\n");
$back->WriteToEmail("by $notify\n\n");
my $rpt = $back->CreateReport("Report of Patients Received in CPTAC");
$rpt->print("Collection,Site,Subject,Qualification,Files,Sops In Posda," .
  "Sops in Pubic,Earliest received date,Latest Received Date\r\n");
$main_q->RunQuery(sub {
  my($row) = @_;
  my($collection, $site, $patient_id, $qualified, $num_files, 
    $earliest_day, $latest_day) = @$row;
  if(defined $qualified){
    if($qualified){
      $qualified = "QUALIFIED";
    } else {
      $qualified = "DISQUALIFIED";
    }
  } else {
    $qualified = "UNKNOWN";
  }
  if($earliest_day =~ /^(\d\d\d\d\-\d\d\-\d\d)/){
    $earliest_day = $1;
  } 
  if($latest_day =~ /^(\d\d\d\d\-\d\d\-\d\d)/){
    $latest_day = $1;
  } 
  my $sops_in_posda;
  $get_posda_counts->RunQuery(sub {
    my($row) = @_;
    my($patient_id, $num_sops) = @$row;
    $sops_in_posda = $num_sops;
  }, sub{}, $patient_id);
  my $sops_in_public;
  $get_public_counts->RunQuery(sub {
    my($row) = @_;
    my($patient_id, $num_sops) = @$row;
    $sops_in_public = $num_sops;
  }, sub{}, $patient_id);
  $rpt->print("$collection,$site,$patient_id," .
    "$qualified,$num_files,$sops_in_posda,$sops_in_public," .
    "$earliest_day,$latest_day\r\n");
}, sub{}, "CPTAC%");
#######################################################
$back->Finish;
