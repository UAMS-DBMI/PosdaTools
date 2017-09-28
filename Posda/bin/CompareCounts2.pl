#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::DownloadableFile;
use Posda::BackgroundProcess;
use Posda::PrivateDispositions;
use Posda::UUID;

my $usage = <<EOF;
CompareCounts.pl <id> <collection> <uid_root> <site> <notify>
  id - id of row in subprocess_invocation table created for the
    invocation of the script
  collection - name of collection
  uid_root - UID root for collection
  site - site_name
  notify - email of party to notify

Expects the following list on <STDIN>
  <id>&<study>&<series>&<num files>

EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
if($#ARGV != 4){ print "Wrong args: $usage\n"; die "$usage\n\n" }
my($invoc_id, $collection, $uid_root, $site, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

my $num_lines = 0;
my %Patients;
my $disp = Posda::PrivateDispositions->new($uid_root);
while(my $line = <STDIN>){
  $num_lines += 1;
  chomp $line;
  my($id, $study, $series, $num_files) =
    split /&/, $line;
  my $n_study = $disp->HashUID($study);
  my $n_series = $disp->HashUID($series);
  if(exists $Patients{$id}->{$n_study}->{$n_series}){
    push @{$Patients{$id}->{$n_study}->{$n_series}}, $num_files;
  } else {
    $Patients{$id}->{$n_study}->{$n_series} = [$num_files];
  }
}

print "processed $num_lines lines\n" .
  "Forking background process\n";
$background->ForkAndExit;
$background->LogInputCount($num_lines);

my $temp_file = Posda::UUID::GetGuid;
my $ReportPath = "/tmp/$temp_file";
my $ReportHandle = FileHandle->new(">$ReportPath");
unless($ReportHandle) { die "Couldn't open ReportHandle handle ($!)" }
$ReportHandle->print(
  "patient_id,study,series,num_files,db_num_files,db_study,db_series\n");
$background->WriteToEmail("Checking Counts\n" .
  "Collection: $collection\n" .
  "site:$site\n");
$background->WriteToEmail("About to enter Dispatch Environment\n");
my $patr = PosdaDB::Queries->GetQueryInstance("PatientReport");
for my $patient_id (sort keys %Patients){
  for my $study(keys %{$Patients{$patient_id}}){
    for my $series(keys %{$Patients{$patient_id}->{$study}}){
      if($#{$Patients{$patient_id}->{$study}->{$series}} > 0){
        $Patients{$patient_id}->{$study}->{$series} =
          [ sort {$a <=> $b} @{$Patients{$patient_id}->{$study}->{$series}} ];
      }
    }
  }
}
for my $patient_id (sort keys %Patients){
  $patr->RunQuery(sub {
    my($row) = @_;
    my $study_inst = $row->[3];
    my $study_desc = $row->[4];
    my $series_inst = $row->[5];
    my $series_desc = $row->[6];
    my $num_files = $row->[7];
    if(exists $Patients{$patient_id}->{$study_inst}->{$series_inst}){
      my $num_files_report = shift @{$Patients{$patient_id}->{$study_inst}->{$series_inst}};
      if($#{$Patients{$patient_id}->{$study_inst}->{$series_inst}} < 0){
        delete $Patients{$patient_id}->{$study_inst}->{$series_inst};
      }
      print $ReportHandle "$patient_id,\"$study_inst\",\"$series_inst\",$num_files_report," .
        "$num_files,\"$study_inst\",\"$series_inst\"\n";
#    } else {
#      print $ReportHandle "$patient_id,\"\",\"\",\"\"," .
#        "$num_files,\"$study_inst\",\"$series_inst\"\n";
    }
  }, sub {}, $collection, $site, $patient_id);
  for my $study (keys %{$Patients{$patient_id}}){
    for my $series(keys %{$Patients{$patient_id}->{$study}}){
      for my $count(@{$Patients{$patient_id}->{$study}->{$series}}){
        print $ReportHandle "$patient_id,\"$study\",\"$series\",$count," .
          "\"\",\"\",\"\",\"\",\"\",\"\"\n";
      }
    }
  }
}
open IMPORT, "ImportSingleFileIntoPosdaAndReturnId.pl \"$ReportPath\" " .
  "\"Compare Counts Report\"|";
my $report_id;
while(my $line = <IMPORT>){
  chomp $line;
  if($line =~ /File id: (.*)/){
    my $report_id = $1;
    my $link = Posda::DownloadableFile::make_csv($report_id);
    $background->WriteToEmail("Report file: $link\n");
  }
}
my $at_text = `date`;
$background->WriteToEmail("Ending at: $at_text\n");
$background->LogCompletionTime;
