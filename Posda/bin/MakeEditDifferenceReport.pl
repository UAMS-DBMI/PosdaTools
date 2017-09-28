#!/usr/bin/perl -w
use strict;
use File::Temp qw/ tempfile /;

use Posda::BackgroundProcess;
use Posda::DownloadableFile;
use Posda::DB::PosdaFilesQueries;

my $usage = <<EOF;
Posda/bin/MakeEditDifferenceReport.pl <bkgrnd_id> <edit_command_file_id> <notify_email>
or
BackgroundCompareDupSopList.pl -h

Generates a csv report file
Sends email when done, which includes a link to the report

Doesn't Expect input lines

Gets list of error_reports and file_counts from dicom_edit_compare table
by edit_command_file_uid;
EOF

$|=1;

unless($#ARGV == 2 ){ die $usage }

my ($invoc_id, $edit_command_file_id, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

my $get_list = PosdaDB::Queries->GetQueryInstance("DifferenceReportByEditId");

my %data;
my $num_rows = 0;
$get_list->RunQuery(sub {
    my($row) = @_;
    my($short_report_file_id, $long_report_file_id, $num_files) = @$row;
    $num_rows += 1;
    $data{$short_report_file_id}->{$long_report_file_id} = $num_files;
  }, sub {}, $edit_command_file_id);
my $num_short = keys %data;
print "$num_rows reports total\n";
print "$num_short are short\n";

$background->ForkAndExit;
$background->LogInputCount($num_rows);

print STDERR "In child\n";
my $start_timetag = `date`;
chomp $start_timetag;
$background->WriteToEmail("At $start_timetag, Starting generation of Difference" .
  " report for $edit_command_file_id\n");
$background->WriteToReport("\"Short Report\"," .
  "\"Long Report\",\"short_file_id\",\"long_file_id\",\"num_files\"\r\n");
close STDOUT;
close STDIN;
my $get_path = PosdaDB::Queries->GetQueryInstance("GetFilePath");
for my $short_id (keys %data){
  my $short_seen = 0;
  for my $long_id (keys %{$data{$short_id}}){
    my $num_files = $data{$short_id}->{$long_id};
    my $short_rept = "-";
    my $long_rept = "";
    unless($short_seen){
      $short_seen = 1;
      $get_path->RunQuery(sub{
        my($row) = @_;
        my $file = $row->[0];
        $short_rept = `cat $file`;
        chomp $short_rept;
      }, sub {}, $short_id);
    }
    $get_path->RunQuery(sub{
      my($row) = @_;
      my $file = $row->[0];
      $long_rept = `cat $file`;
      chomp $long_rept;
    }, sub {}, $long_id);
    $short_rept =~ s/"/""/g;
    $long_rept =~ s/"/""/g;
    $background->WriteToReport("\"$short_rept\",\"$long_rept\",$short_id,$long_id,$num_files\r\n");
  }
}
$background->LogCompletionTime;
my $link = $background->GetReportDownloadableURL;
my $report_file_id = $background->GetReportFileID;
$background->WriteToEmail("Report url: $link\n");
$background->WriteToEmail("Report file_id: $report_file_id\n");
