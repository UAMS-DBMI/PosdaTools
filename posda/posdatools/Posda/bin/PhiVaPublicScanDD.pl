#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::Background::PhiScan;

my $usage = <<EOF;
PhiVaPublicScanDD.pl <?bkgrnd_id?> <activity_id> <sub_dir> <max_rows> <notify>
or
PhiVaPublicScanDD.pl -h

The script doesn't expect lines on STDIN:

EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 4){
  die "$usage\n";
}

my ($invoc_id, $act_id, $sub_dir, $max_rows, $notify) = @ARGV;

my $description = "VA 'Public' Scan of download " .
  "directory $sub_dir ($notify)";
print "Background to do scan: \"$description\"\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
$background->Daemonize;
my $dir = "$ENV{POSDA_CACHE_ROOT}/linked_for_download/$sub_dir";
my $cmd = "find -L $dir -type f";
my $num_files = 0;
my %SeriesInDownloadDir;
open CMD, "$cmd|";
while (my $line = <CMD>){
  chomp $line;
  $num_files += 1;
  my $s_cmd = "GetElementValue.pl  \"$line\"  \"(0020,000e)\"";
  my $series_instance_uid =  `$s_cmd`;
  chomp $series_instance_uid;
  $series_instance_uid =~ s/\0$//;
  $SeriesInDownloadDir{$series_instance_uid}->{$line} = 1;
  my $num_series = keys %SeriesInDownloadDir;
  $background->SetActivityStatus("Found $num_series after scanning $num_files");
}

my $num_series = keys %SeriesInDownloadDir;
$background->WriteToEmail("Found $num_series in download directory $sub_dir\n");
unless($num_series > 0) {
  $background->WriteToEmail("nothing to scan\n");
  $background->Finish("Done: no series to scan");
  exit;
}
my $start_time = time;
$background->WriteToEmail("Starting PHI scan: \"$description\"\n");
my $scan = Posda::Background::PhiScan->NewFromScan(
  \%SeriesInDownloadDir, $description, "DownloadDirectory($sub_dir)",
  $invoc_id, $act_id, $background);
my $end_time = time;
my $elapsed = $end_time - $start_time;
my $id = $scan->{phi_scan_instance_id};
$background->WriteToEmail("Created scan id: $id in $elapsed seconds\n");
$background->WriteToEmail("Scan ($id) description: $description\n");
$background->WriteToEmail("Creating " .
  "\"SimplePhiReportAllMetaQuotes\" report\n");
$background->SetActivityStatus("Preparing Report");
$background->PrepareBackgroundReportBasedOnQuery(
  "SimplePhiReportAllMetaQuotes", "Phi Report All", $max_rows, $id);
$background->Finish("Done");
