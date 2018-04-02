#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::Background::NonDicomPhiScan;

my $usage = <<EOF;
NonDicomPhiScan.pl <bkgrnd_id> <collection> <site> <notify>
or
NonDicomPhiScan.pl -h

Retrieve list of files to scan based on <collection>, and <site>
make list format:
\$list = [
  [<file_id>, <file_type>, <file_path],
];
verify all file_types are either "json" or "csv"

Create a non_dicom_phi_scan

Produce reports base on queries

Construct edit skeleton

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
my $file_list = Query("GetNonDicomFileIdTypeAndPathByCollectionSite");
my @FileList;
$file_list->RunQuery(sub {
  my($row) = @_;
  push @FileList, $row;
}, sub {}, $collection, $site);

my $num_files = @FileList;
my $num_json = 0;
my $num_csv = 0;
my $num_other = 0;
for my $i (@FileList){
  if($i->[1] eq "json") { $num_json += 1 }
  elsif($i->[1] eq "csv") { $num_csv += 1 }
  else {
    print "Error: file $i->[0] ($i->[2]) has type $i->[1]\n";
    $num_other += 1
  }
}
print "Found $num_files total\n" .
  "$num_json json\n" .
  "$num_csv csv\n";
if($num_other > 0){
  print "not proceeding because $num_other files of type other found\n";
  exit;
}

#print "not doing stuff for test\n"; exit;
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
print "Going to background\n";
$background->Daemonize;
my $start_time = time;
$background->WriteToEmail("Starting PHI scan: \"Non dicom file scan ($collection, $site)\"\n");
my $scan = Posda::Background::NonDicomPhiScan->NewFromScan(
  \@FileList, "Non dicom file scan ($collection, $site)");
my $end_time = time;
my $elapsed = $end_time - $start_time;
my $id = $scan->{phi_scan_instance_id};
$background->WriteToEmail("Created scan id: $id in $elapsed seconds\n");
$background->WriteToEmail("Creating " .
  "\"\" report.\n");
my $rpt1 = $background->CreateReport("Json Phi Report");
my $lines = $scan->PrintTableFromQuery(
  "NonDicomPhiReportJsonMetaQuotes", $rpt1);
$background->WriteToEmail("Creating " .
  "\"NonDicomPhiReportJsonMetaQuotes\" report.\n");
my $rpt2 = $background->CreateReport("Csv Phi Report");
$lines = $scan->PrintTableFromQuery(
  "NonDicomPhiReportCsvMetaQuotes", $rpt2);
my $rpt3 = $background->CreateReport("Csv Edit Skeleton");
$rpt3->print("type,path,q_value,num_files," .
  "p_op,q_arg1,q_arg2,q_arg3,Operation,scan_id,descriptionnotify\r\n");
$rpt3->print(",,,,,,,,ProposeCsvEdits,$id,\"$scan->{description}\",$notify\r\n");
my $rpt3 = $background->CreateReport("Json Edit Skeleton");
$rpt3->print("type,path,q_value,num_files," .
  "p_op,q_arg1,q_arg2,q_arg3,Operation,scan_id,descriptionnotify\r\n");
$rpt3->print(",,,,,,,,ProposeJsonEdits,$id,\"$scan->{description}\",$notify\r\n");
$background->Finish;
