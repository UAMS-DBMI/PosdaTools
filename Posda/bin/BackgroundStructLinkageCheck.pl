#!/usr/bin/perl -w
use strict;
use File::Temp qw/ tempfile /;

use Posda::BackgroundProcess;
use Posda::DownloadableFile;
use Posda::DB::PosdaFilesQueries;

my $usage = <<EOF;
BackgroundStructLinkageCheck.pl <bkgrnd_id> <notify_email>
or
BackgroundStructLinkageCheck.pl -h

Generates a csv report file
Sends email when done, which includes a link to the report
Expect input lines in following format:
<file_id>&<collection>&<site>&<patient_id>&<series_instance_uid>
EOF

$|=1;

unless($#ARGV == 1 ){ die $usage }

my ($invoc_id, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);


my %Files;
my $num_lines;
while(my $line = <STDIN>){
  chomp $line;
  $num_lines += 1;
  $background->LogInputLine($line);
  my($file_id, $collection, $site, $pat_id, $series_instance_uid) = 
    split(/&/, $line);
  if(exists $Files{$file_id}){
    print "File id: $file_id has multiple rows\n";
  }
  $Files{$file_id} = {
    collection => $collection,
    site => $site,
    patient_id => $pat_id,
    series => $series_instance_uid
  };
}
my $num_files = keys %Files;
print "$num_files files identified\n";

$background->ForkAndExit;
close STDOUT;
close STDIN;

$background->LogInputCount($num_lines);
#############################################
print STDERR "In child\n";
my $get_sop_ref = PosdaDB::Queries->GetQueryInstance(
  "GetSopOfPlanReferenceByDose");
my $get_ref_info = PosdaDB::Queries->GetQueryInstance(
  "GetExistenceClassModalityUniquenessOfReferencedFile");

$background->WriteToReport("\"Collection\"," .
  "\"Site\",\"Patient Id\",\"Series\"," . 
  "\"FileId\",\"Summary\"" . 
  "\r\n");

my @Files = sort keys %Files;
{
  print STDERR "$num_files files to process in child\n";
  my $date = `date`;
  $background->WriteToEmail("At: $date\nEntering background:\n" .
    "Script: Starting BackgroundStructLinkageCheck.pl\n");
  $background->WriteToEmail("Files to process:$num_files\n");
}
File:
for my $i (0 .. $#Files){
  my $file_id = $Files[$i];
  my $file_info = $Files{$file_id};
  {  # Until implemented...
    $background->WriteToReport("\"$file_info->{collection}\"," .
      "\"$file_info->{site}\"," .
      "\"$file_info->{patient_id}\"," .
      "\"$file_info->{series}\"," .
      "\"$file_id\"," .
      "\"Checking Not currently implemented\"," .
      "\r\n");
    next File;
  }
}
#############################################
$background->LogCompletionTime;
my $link = $background->GetReportDownloadableURL;
my $report_file_id = $background->GetReportFileID;
{
  my $date = `date`;
  $background->WriteToEmail("$date\nFinished\n");
  $background->WriteToEmail("Report url: $link\n");
  $background->WriteToEmail("Report file_id: $report_file_id\n");
}
