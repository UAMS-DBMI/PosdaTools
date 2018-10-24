#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::DownloadableFile;
use Posda::BackgroundProcess;
use Posda::UUID;

my $usage = <<EOF;
CompareCounts.pl <id> <collection> <site> <notify>
  id - id of row in subprocess_invocation table created for the
    invocation of the script
  collection - name of collection
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
if($#ARGV != 3){ print "Wrong args: $usage\n"; die "$usage\n\n" }
my($invoc_id, $collection, $site, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

my $num_lines = 0;
my %Patients;
while(my $line = <STDIN>){
  $num_lines += 1;
  chomp $line;
  my($id, $study, $series, $num_files) =
    split /&/, $line;
  if($collection eq "NSCLC Radiogenomics"){
    ## fix up patient id for NSCLC Radiomics
    unless($id =~ /^A/){
      $id =~ s/ /-/;
    }
  }
  if(exists $Patients{$id}->{$study}->{$series}){
    push @{$Patients{$id}->{$study}->{$series}}, $num_files;
  } else {
    $Patients{$id}->{$study}->{$series} = [$num_files];
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
  "patient_id,study,series,num_files,db_study,db_series,db_num_files," .
  "study_instance,series_instance\n");
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
    if(exists $Patients{$patient_id}->{$study_desc}->{$series_desc}){
      my $num_files_report = shift @{$Patients{$patient_id}->{$study_desc}->{$series_desc}};
      if($#{$Patients{$patient_id}->{$study_desc}->{$series_desc}} < 0){
        delete $Patients{$patient_id}->{$study_desc}->{$series_desc};
      }
      print $ReportHandle "$patient_id,\"$study_desc\",\"$series_desc\",$num_files_report," .
        "\"$study_desc\",\"$series_desc\",$num_files,$study_inst,$series_inst\n";
    } else {
      print $ReportHandle "$patient_id,\"\",\"\",\"\"," .
        "\"$study_desc\",\"$series_desc\",$num_files,$study_inst,$series_inst\n";
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
