#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::Try;
my $usage = <<EOF;
ProcessRtRecord.pl <?bkgrnd_id?> <activity_id> <notify>
  <activity_id> - activity
  <notify> - user to notify

Expects the following list on <STDIN>
  <file_id>,
  ...
  <file_id>

All of these file_ids are RT Beams Treatment Record Storage files, and all have same
patient_id.

Constructs a spreadsheet with the following columns for all records:
  <beam_name>
  <beam_type>
  <beam_number>
  <radiation_type>
  <treatment_date>
  <treatment_time>
  <number_control_points>
  <beginning_specified_meterset>
  <ending_specified_meterset>
  <beginning_delivered_meterset>
  <ending_delivered_meterset>
  <referenced_plan>

Uses named queries
   GetFilePathAndDicomFileType

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
my @Files;
while(my $line = <STDIN>){
  chomp $line;
  $line =~ s/^\s*//;
  $line =~ s/\s*$//;
  push @Files, $line;
}
my $num_files = @Files;
print "Going to background to process $num_files files\n";

my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;
$back->WriteToEmail("Process PT record:\n\tinvoc_id = $invoc_id\n" .
  "\tactivity_id = $activity_id\n" .
  "\tnotify = $notify\n");
my %BeamReports;
my $PatientId;
file:
for my $i (0 .. $#Files){
  my $file = $Files[$i];
  my $file_path; 
  my $num = $i + 1;
  $back->SetActivityStatus("Processing $num of $num_files");
  Query('GetFilePathAndDicomFileType')->RunQuery(sub{
    my($row) = @_;
    my($fp, $dft) = @$row;
    $file_path = $fp;
  }, sub{}, $file, "RT Beams Treatment Record Storage");
  unless(defined $file_path){
    $back->WriteToEmail("file_id $file is not a Beams Treatment Record (in DB)\n");
    next file;
  }
  my $try = Posda::Try->new($file_path);
  unless(defined $try->{dataset}){
    $back->WriteToEmail("file_id $file didn't parse as DICOM file\n");
    next file;
  }
  my $ds = $try->{dataset};
  my $pat_id = $ds->Get("(0010,0020)");
  unless(defined $pat_id){
    $back->WriteToEmail("file_id $file has no patient_id\n");
    next file;
  }
  unless(defined $PatientId){
    $back->WriteToEmail("file_id $file has no patient_id\n");
    $PatientId = $pat_id;
    $back->WriteToEmail("Setting patient_id to $pat_id (from first file $file)\n");
  }
  unless($pat_id eq $PatientId){
    $back->WriteToEmail("file_id $file has non-matching patient_id (" .
      "$pat_id vs $PatientId)\n");
    next file;
  }
  my $hash = {};
  $hash->{beam_name} = $ds->Get("(3008,0020)[0](300a,00c2)"); $hash->{beam_type} = $ds->Get("(3008,0020)[0](300a,00c4)"); $hash->{radiation_type} = $ds->Get("(3008,0020)[0](300a,00c6)");
  $hash->{treatment_date} = $ds->Get("(3008,0250)");
  $hash->{treatment_time} = $ds->Get("(3008,0251)");
  $hash->{referenced_plan} = $ds->Get("(300c,0002)[0](0008,1155)");
  $hash->{beam_number} = $ds->Get("(3008,0020)[0](300c,0006)");
  $hash->{number_control_points} = $ds->Get("(3008,0020)[0](300a,0110)");
  my $begin_index = 0;
  my $end_index = $hash->{number_control_points} - 1;
  $hash->{beginning_specified_meterset} = $ds->Get("(3008,0020)[0](3008,0040)[$begin_index](3008,0042)");
  $hash->{ending_specified_meterset} = $ds->Get("(3008,0020)[0](3008,0040)[$end_index](3008,0042)");
  $hash->{beginning_delivered_meterset} = $ds->Get("(3008,0020)[0](3008,0040)[$begin_index](3008,0044)");
  $hash->{ending_delivered_meterset} = $ds->Get("(3008,0020)[0](3008,0040)[$end_index](3008,0042)");
  $BeamReports{$file} = $hash;
}
my $num_reports = keys %BeamReports;
if($num_reports < 1){
  $back->WriteToEmail("No beam reports generated\n");
  $back->Finish("No beam reports generated");
  exit;
}
$back->SetActivityStatus("Generating Summary for $num_reports beam reports");
my $rpt = $back->CreateReport("Beam Report Summary for Patient $PatientId");
my $ColNames = {
  beam_name => {
    sort_order => 1,
  },
  beam_type => {
    sort_order => 2,
  },
  radiation_type => {
    sort_order => 3,
  },
  treatment_date => {
    sort_order => 4,
    meta_escape => 1
  },
  treatment_time => {
    sort_order => 5,
    meta_escape => 1
  },
  number_control_points => {
    sort_order => 6,
  },
  beginning_specified_meterset => {
    sort_order => 7,
  },
  ending_specified_meterset => {
    sort_order => 8,
  },
  beginning_delivered_meterset => {
    sort_order => 9,
  },
  ending_delivered_meterset => {
    sort_order => 10,
  },
  referenced_plan => {
    sort_order => 11,
  },
  beam_number => {
    sort_order => 2.5,
  },
};
my @headers = sort {$ColNames->{$a}->{sort_order} <=> $ColNames->{$b}->{sort_order}} keys %$ColNames;
for my $i (0 .. $#headers){
  my $header = $headers[$i];
  $rpt->print("$header");
  unless($i == $#headers){ $rpt->print(",")};
}
$rpt->print("\n");
my @Reports = sort {
    $BeamReports{$a}->{treatment_date} cmp $BeamReports{$b}->{treatment_date} or
    $BeamReports{$a}->{beam_number} cmp $BeamReports{$b}->{beam_number}
  } keys %BeamReports;
for my $i (@Reports){
  my $br = $BeamReports{$i};
  for my $j (0 .. $#headers){
    my $header = $headers[$j];
    if(exists $ColNames->{$header}->{meta_escape}){ $rpt->print("<")};
    $rpt->print($BeamReports{$i}->{$header});
    if(exists $ColNames->{$header}->{meta_escape}){ $rpt->print(">")};
    unless($j == $#headers){ $rpt->print(",")};
  }
  $rpt->print("\n");
}
$back->Finish("Produced summary for $num_reports");;
