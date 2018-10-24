#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;

my $usage = <<EOF;
GetHierarchyFromPatientId.pl <id>  <notify>
  id - id of row in subprocess_invocation table created for the
    invocation of the script
  notify - email of party to notify

Gets a list of series by patient_id adds a row to table with 
diagnosis date following 

Expects the following list on <STDIN>
  <patient_id>

EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
if($#ARGV != 1){ print "Wrong args: $usage\n"; die "$usage\n\n" }
my($invoc_id, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

my $num_lines = 0;
my %Patients;
while(my $line = <STDIN>){
  $num_lines += 1;
  chomp $line;
  $Patients{$line} = 1;
}

print "processed $num_lines lines\n" .
  "Forking background process\n";
$background->ForkAndExit;
my $start_text = `date`;
chomp $start_text;
$background->WriteToEmail("Starting at $start_text\n");
my $get_series_info = Query("FilesInHierarchyByPatient");
my $rpt = $background->CreateReport("PatientHierarchyByPatient");
$rpt->print("collection,site,patient_id,study_uid,series_uid,study_date," .
  "num_files\n");
for my $series(keys %Patients){
  $get_series_info->RunQuery(sub {
    my($row) = @_;
    my($collection, $site, $patient, $study, $series, $study_date,
      $num_files) = @$row;
    $rpt->print("\"$collection\",\"$site\",\"$patient\"," .
      "\"$study\",\"$series\",\"<$study_date>\",\"$num_files\"\n");
  }, sub {}, $series);
}
my $at_text = `date`;
chomp $at_text;
$background->WriteToEmail("Ending at: $at_text\n");
$background->Finish;
