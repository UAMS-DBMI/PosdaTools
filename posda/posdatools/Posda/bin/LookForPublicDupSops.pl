#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;

my $usage = <<EOF;
LookForPublicDupSops.pl <bkgrnd_id> <collection> <site> <notify>
or
LookForPublicDupSops.pl -h

The script doesn't expect lines on STDIN:

EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 3){
  die "$usage\n";
}

my ($invoc_id, $collection, $site, $notify) = @ARGV;
my $get_sop_list = Query("GetSopListByCollectionSite");
my %PosdaSopList;
$get_sop_list->RunQuery(sub {
  my($row) = @_;
  my($collection,
    $site,
    $patient_id,
    $study_instance_uid,
    $series_instance_uid,
    $sop_instance_uid) = @$row;
  $PosdaSopList{$sop_instance_uid} = [
    $collection, $site, $patient_id, $study_instance_uid, $series_instance_uid
  ];
}, sub {}, $collection, $site);
my $num_sops = keys %PosdaSopList;
print "Found $num_sops sops\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

print "Entering Background\n";

$background->ForkAndExit;
my $get_public_info = Query("GetPublicInfoBySop");

my $start_time = `date`;
chomp $start_time;
$background->WriteToEmail("Starting LookForPublicDupSops.pl at " .
  "$start_time\n" . "Building Public Tables\n");
my %PublicSopList;
for my $sop(keys %PosdaSopList){
  $get_public_info->RunQuery(sub {
    my($row) = @_;
    my($project, $site, $site_id, $patient_id, $study_instance_uid,
      $series_instance_uid) = @$row;
    $PublicSopList{$sop} = [
       $project, $site, $patient_id, $study_instance_uid, $series_instance_uid
    ]
  }, sub{}, $sop);
}
my $num_sops_in_public = keys %PublicSopList;
my $tt = `date`;
chomp $tt;
$background->WriteToEmail("$tt :Built Public Tables\n" .
  "$num_sops_in_public Sops in Public\n");

$background->Finish;
