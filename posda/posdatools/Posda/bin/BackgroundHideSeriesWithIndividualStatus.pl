#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;

my $usage = <<EOF;
BackgroundHideSeriesWithIndividualStatus.pl <bkgrnd_id> <notify>
or
BackgroundHideSeriesWithIndividualStatus.pl -h

The script expects lines in the following format on STDIN:
<series_instance_uid>&<reason_to_hide>
EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 1){
  print "Wrong number of args\n";
  die "$usage\n";
}

my ($invoc_id, $notify) = @ARGV;

my %Series;
while(my $line = <STDIN>){
  chomp $line;
  my($series_uid, $reason) = split(/&/, $line);
  if(exists $Series{$series_uid}){
    print "Error: series ($series_uid) listed twice\n";
  }
  $Series{$series_uid} = $reason;
}
my $num_series = keys %Series;
print "Num series: $num_series\n";
print "Entering Background\n";

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->Daemonize;;

my $start_time = time;
$background->WriteToEmail("Starting BackgroundHideSeriesWithIndividualStatus.pl\n");
my $files_in_series = Query("DistinctUnhiddenFilesInSeries");
my @FileHides;
for my $s (keys %Series){
  my $reason = $Series{$s};
  $files_in_series->RunQuery(sub {
    my($row) = @_;
    my $file_id = $row->[0];
    push @FileHides, [$file_id, '<undef>', $reason];
  }, sub {}, $s);
}
my $files_to_hide = @FileHides;
my $query_elapsed = time - $start_time;
$background->WriteToEmail("From $num_series series, found $files_to_hide files in $query_elapsed seconds\n");
open SUBP, "|-", "StreamHideFilesWithIndividualStatus.pl $notify";
for my $i (@FileHides){
  print SUBP "$i->[0]&$i->[1]&$i->[2]\n";
}
my $output_elapsed = time - $start_time;
$background->WriteToEmail("Wrote commands to subprocess after $output_elapsed seconds\n");
close SUBP;
my $output_cleared = time - $start_time;
$background->WriteToEmail("Subprocess cleared after $output_cleared seconds\n");

$background->Finish;
