#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
ProcessSeriesWithHeads.pl <?bkgrnd_id?> <activity_id> <notify>
  <activity_id> - activity
  <notify> - user to notify

Expects the following list on <STDIN>
  <series_instance_uid>&<has_head>

Constructs a spreadsheet with the following columns for all series:
  <patient_id>
  <study_desc>
  <study_date>
  <series_instance_uid>
  <series_desc>
  <modality>
  <has_head>
  <num_sops>

Uses named query "NbiaSeriesInfoBySeriesInstanceUid"
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 2){
  my $n_args = @ARGV;
  my $mess = "Wrong number of args ($n_args vs 3). Usage:\n$usage\n";
  print $mess;
  die "######################## subprocess failed to start:\n" .
      "$mess\n" .
      "#####################################################\n";
}
my($invoc_id, $activity_id, $notify) = @ARGV;
my %Series;
while(my $line = <STDIN>){
  chomp $line;
  my($series, $has_head) = split(/&/, $line);
  $Series{$series} = $has_head;
}
my $num_series = keys %Series;
print "Going to background to process $num_series series\n";

my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;
my $q = Query("NbiaSeriesInfoBySeriesInstanceUid");
my $start = time;
my $rpt = $back->CreateReport("Report of Series With and Without heads for $num_series series");
$rpt->print("patient_id,study_description,study_date,series_instance_uid,series_description," .
  "modality,has_head,num_sops\n");
my $i = 0;
for my $series (keys %Series){
  $i += 1;
  $back->SetActivityStatus("Querying $i of $num_series");
  $q->RunQuery(sub{
    my($row) = @_;
    my($patient_id, $study_desc, $study_date, $series_instance_uid, $series_desc,
      $modality, $batchnum, $num_sops) = @$row;
    my $has_head = $Series{$series};
    $rpt->print("$patient_id,\"$study_desc\",$study_date, $series_instance_uid," .
      "\"$series_desc\", $modality,$has_head,$num_sops\n");
    }, sub {}, $series);
}
my $elapsed = time - $start;
$back->Finish("Processed $num_series series in $elapsed seconds");;
