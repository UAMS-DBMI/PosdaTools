#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Digest::MD5;
use Posda::BackgroundProcess;
use Posda::DB::PosdaFilesQueries;
use Socket;
use Debug;
my $dbg = sub { print STDERR @_ };

my $usage = <<EOF;
PublicPosdaCompareReport.pl <invoc_id> <notify>
or
PublicPosdaCompare.pl -h

The script doesn't expect lines on STDIN:
It generates lists of SOP Uids for a collection on both public and posda
and does a compare of the lists.

In test: reports on differences
EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
unless($#ARGV == 1){ die "$usage\n"; }

my ($invoc_id, $notify) = @ARGV;
my $background = Posda::BackgroundProcess->new(0, $notify);
print "Entering Background\n";
$background->Daemonize;
my $bk_id = $background->GetBackgroundID;
my $start_time = `date`;
chomp $start_time;
$background->WriteToEmail("Starting Public/Posda Comparison at $start_time\n");
$background->WriteToEmail("BackgroundProcess Id: $invoc_id\n");

close STDOUT;
close STDIN;
my $tt = `date`;
chomp $tt;
$background->WriteToEmail("Starting Difference Report\n");
#### Here to generate report
my $diff_report = $background->CreateReport("DifferenceReport");
$diff_report->print("\"Short Report\"," .
  "\"Long Report\",\"short_file_id\"," .
  "\"long_file_id\",\"num_sops\",\"num_files\"\r\n");
my %data;
my $num_rows = 0;
my $get_list = PosdaDB::Queries->GetQueryInstance(
  "PublicDifferenceReportBySubprocessId");
$get_list->RunQuery(sub {
    my($row) = @_;
    my($short_report_file_id, $long_report_file_id, $num_sops, $num_files) = 
      @$row;
    $num_rows += 1;
    $data{$short_report_file_id}->{$long_report_file_id} = 
      [$num_sops, $num_files];
  }, sub {}, $invoc_id);
my $num_short = keys %data;
#print STDERR "Data: ";
#Debug::GenPrint($dbg, \%data, 1);
#print STDERR "\n";
my $get_path = PosdaDB::Queries->GetQueryInstance("GetFilePath");
for my $short_id (keys %data){
  my $short_seen = 0;
  for my $long_id (keys %{$data{$short_id}}){
    my $num_sops = $data{$short_id}->{$long_id}->[0];
    my $num_files = $data{$short_id}->{$long_id}->[1];
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
    $diff_report->print("\"$short_rept\"," .
      "\"$long_rept\",$short_id,$long_id,$num_sops,$num_files\r\n");
  }
}
my $at_text = `date`;
chomp $at_text;
$background->WriteToEmail("Difference Report finished at: $at_text\n");
### Other reports:???

$background->Finish;
