#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
BackgroundHelloWorldWithInput.pl <?bkgrnd_id?> <activity_id> <notify>
  <activity_id>> - activity
  <notify> - user to notify

Expects the following list on <STDIN>
  <series_instance_uid>

Constructs a spreadsheet with the following columns for all series:
  <collection>
  <site>
  <patient_id>
  <study_instance_uid>
  <study_date>
  <study_description>
  <series_instance_uid>
  <series_date>
  <series_desc>
  <modality>
  <dicom_file_type>
  <number_of_files>

Uses named query "SeriesInHierarchyBySeriesExtendedFurther"
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
my @Series;
while(my $line = <STDIN>){
  chomp $line;
  $line =~ s/^\s*//;
  $line =~ s/\s*$//;
  push @Series, $line;
}
my $num_series = @Series;
print "Going to background to process $num_series series\n";

my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;
my %Hierarchy;
my $q = Query("SeriesInHierarchyBySeriesExtendedFurther");
my $i = 0;
$back->WriteToEmail("Initial line written to email\n");
my $start = time;
my $rpt = $back->CreateReport("DICOM Hierarchy for $num_series series");
$rpt->print("collection,site,patient_id,study_instance_uid,study_date," .
  "study_description,series_instance_uid,series_date,series_description," .
  "modality,dicom_file_type,num_files\n");
for my $series (@Series){
  $i += 1;
  $back->SetActivityStatus("Querying $i of $num_series");
  $q->RunQuery(sub{
    my($row) = @_;
    my($collection, $site, $patient_id, $study_instance_uid,
      $study_date, $study_description, $series_instance_uid,
      $series_date, $series_description, $modality,
      $dicom_file_type, $num_files) = @$row;
    $rpt->print("$collection,$site,$patient_id,$study_instance_uid,$study_date," .
      "\"$study_description\",$series_instance_uid,$series_date,\"$series_description\"," .
      "$modality,$dicom_file_type,$num_files\n");
    }, sub {}, $series);
}
$back->WriteToEmail("Final line written to email\n");
my $elapsed = time - $start;
$back->Finish("Processed $num_series series in $elapsed seconds");;
