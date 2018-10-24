#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;

my $usage = <<EOF;
TotalFilesForSelectedSeries.pl <bkgrnd_id> <notify>
or
TotalFilesForSelectedSeries.pl -h

Expects lines of series_instance_uids on <STDIN>

Produces report with the number of files in each series.
EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 1){
  die "$usage\n";
}

my ($invoc_id, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

my %Series;
my $lines = 0;
while(my $line = <STDIN>){
  chomp $line;
  $Series{$line} = 1;
  $lines += 1;
}
my $num_series = keys %Series;

print "Found $num_series series in $lines lines\n";
print "Entering Background\n";
$background->ForkAndExit;

my $start_time = `date`;
chomp $start_time;
$background->WriteToEmail(
  "Starting ImportEditedFilesFromDicomEditCompare.pl at $start_time\n");
my $get_series_count = Query("NumFilesInSeries");
my $rpt = $background->CreateReport("SeriesCounts");
$rpt->print("series_instance_uid,num_files\n");
for my $series(sort keys %Series){
  my $count = 0;
  $get_series_count->RunQuery(sub {
    my($row) = @_;
    $count += $row->[0];
  }, sub {}, $series);
  $rpt->print("\"$series\",\"$count\"\n");
}
$background->Finish;
