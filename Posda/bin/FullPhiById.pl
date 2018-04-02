#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::Background::PhiScan;

my $usage = <<EOF;
FullPhiById.pl <bkgrnd_id> <id> <notify> <max_rows>
or
FullPhiById.pl -h

The script doesn't expect lines on STDIN:

EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 3){
  die "$usage\n";
}

my ($invoc_id, $scan_id, $notify, $max_rows) = @ARGV;
unless($max_rows > 50000) { $max_rows = 50000 }
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
print "Going to background\n";
$background->Daemonize;
my $start_time = time;
my $scan = Posda::Background::PhiScan->NewFromId($scan_id);
my $end_time = time;
my $elapsed = $end_time - $start_time;
my $description = $scan->{description};
$background->WriteToEmail("Scan ($scan_id) description: $description\n");
$background->WriteToEmail("Creating " .
  "\"SimplePhiReportAllMetaQuotes\" report\n");
my $rpt = $background->CreateReport("Full PHI Report");
$scan->PrintTableFromQuery(
  "SimplePhiReportAllMetaQuotes", $rpt);
$background->Finish;
