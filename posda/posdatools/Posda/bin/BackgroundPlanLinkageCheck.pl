#!/usr/bin/perl -w
use strict;
use File::Temp qw/ tempfile /;

use Posda::BackgroundProcess;
use Posda::DownloadableFile;
use Posda::DB::PosdaFilesQueries;

my $usage = <<EOF;
BackgroundPlanLinkageCheck.pl <bkgrnd_id> <notify_email>
or
BackgroundPlanLinkageCheck.pl -h

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

print STDERR "In child\n";
my $get_sop_ref = PosdaDB::Queries->GetQueryInstance(
  "GetSopOfSsReferenceByPlan");
my $get_ref_info = PosdaDB::Queries->GetQueryInstance(
  "GetExistenceClassModalityUniquenessOfReferencedFile");

$background->WriteToReport("\"Collection\"," .
  "\"Site\",\"Patient Id\",\"Series\"," . 
  "\"FileId\",\"Summary\"" . 
  "\r\n");

my @Files = sort keys %Files;
print STDERR "$num_files files to process in child\n";
{
  my $date = `date`;
  chomp $date;
  $background->WriteToEmail("At: $date\nEntering background:\n" .
  "Script: Starting BackgroundPlanLinkageCheck.pl\n");
  $background->WriteToEmail("Files to process:$num_files\n");
}
File:
for my $i (0 .. $#Files){
  my $file_id = $Files[$i];
  my $file_info = $Files{$file_id};
  my @Rows;
  $get_sop_ref->RunQuery(sub {
    my($row) = @_;
    push @Rows, $row;
  }, sub {}, $file_id);
  if(@Rows <= 0){
    $background->WriteToReport("\"$file_info->{collection}\"," .
      "\"$file_info->{site}\"," .
      "\"$file_info->{patient_id}\"," .
      "\"$file_info->{series}\"," .
      "\"$file_id\"," .
      "\"Does not reference a structure_set\"," .
      "\r\n");
    next File;
  } elsif(@Rows > 1){
    $background->WriteToReport("\"$file_info->{collection}\"," .
      "\"$file_info->{site}\"," .
      "\"$file_info->{patient_id}\"," .
      "\"$file_info->{series}\"," .
      "\"$file_id\"," .
      "\"File references more than one structure_set (????)\"," .
      "\r\n");
    next File;
  }
  my $ref = $Rows[0];
  my $ref_uid = $ref->[0];
  my $ref_class = $ref->[1];
  my @RefInfo;
  $get_ref_info->RunQuery(sub{
    my($row) = @_;
    push @RefInfo, $row;
  }, sub {}, $ref_uid);
  if(@RefInfo <= 0){
    $background->WriteToReport("\"$file_info->{collection}\"," .
      "\"$file_info->{site}\"," .
      "\"$file_info->{patient_id}\"," .
      "\"$file_info->{series}\"," .
      "\"$file_id\"," .
      "\"File references a structure_set which is not known\"" .
      "\r\n");
    next File;
  } elsif(@RefInfo > 1){
    $background->WriteToReport("\"$file_info->{collection}\"," .
      "\"$file_info->{site}\"," .
      "\"$file_info->{patient_id}\"," .
      "\"$file_info->{series}\"," .
      "\"$file_id\"," .
      "\"File references a structure_set with duplicate SOP instance UIDs\"" .
      "\r\n");
    next File;
  }
  my $ref_ss_info = $RefInfo[0];
  my $ref_file_id = $ref_ss_info->[0];
  my $ref_collection = $ref_ss_info->[1];
  my $ref_site = $ref_ss_info->[2];
  my $ref_patient_id = $ref_ss_info->[3];
  my $ref_sop_class_desc = $ref_ss_info->[4];
  my $ref_modality = $ref_ss_info->[5];
  my $ref_sop_class_uid = $ref_ss_info->[6];
  my $ref_series_uid = $ref_ss_info->[7];
  my @errors;
  if($ref_collection ne $file_info->{collection}){
    push(@errors, "different collection: " .
     "($ref_collection vs $file_info->{collection}");
  }
  if($ref_site ne $file_info->{site}){
    push(@errors, "different site " .
     "($ref_site vs $file_info->{site}");
  }
  if($ref_patient_id ne $file_info->{patient_id}){
    push(@errors, "different patient " .
     "($ref_patient_id vs $file_info->{patient_id}");
  }
#  if($ref_sop_class_uid ne $ref_class){
#    push(@errors, "different sop_class " .
#     "($ref_sop_class_uid vs $ref_class)");
#  }
  if(@errors > 0){
    $background->WriteToReport("\"$file_info->{collection}\"," .
      "\"$file_info->{site}\"," .
      "\"$file_info->{patient_id}\"," .
      "\"$file_info->{series}\"," .
      "\"$file_id\"," .
      "\"Has linkage_errors:\n");
    for my $i (0 .. $#errors){
      $background->WriteToReport("$errors[$i]");
      unless($i == $#errors){
        $background->WriteToReport("\n");
      }
    }
    $background->WriteToReport("\"\r\n");
    next File;
  }
  $background->WriteToReport("\"$file_info->{collection}\"," .
    "\"$file_info->{site}\"," .
    "\"$file_info->{patient_id}\"," .
    "\"$file_info->{series}\"," .
    "\"$file_id\"," .
    "\"File properly references structure_set\"" .
    "\r\n");
}
$background->LogCompletionTime;
my $link = $background->GetReportDownloadableURL;
my $report_file_id = $background->GetReportFileID;
{
  my $date = `date`;
  chomp $date;
  $background->WriteToEmail("At: $date\nFinished\n");
  $background->WriteToEmail("Report url: $link\n");
  $background->WriteToEmail("Report file_id: $report_file_id\n");
}
