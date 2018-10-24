#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
my $usage = <<EOF;
PhiScan.pl <intake|posda> <description>
  description - description of scan
Expects a list of <series>, <signature> on STDIN
EOF
unless($#ARGV == 1){
  die "$usage\n";
}
my($type, $desc) = @ARGV;
unless(
  $type eq "intake" || $type eq "posda" || $type eq "public"
){
  die "type ($type) is illegal";
}
my %Series;
while(my $line = <STDIN>){
  chomp $line;
  if($line =~ /^([\d\.]+)\s*,\s*(.*)\s*$/){
    my $s = $1; my $sig = $2;
    $Series{$s} = $sig;
  } else {
    print STDERR "Can't process line: $line\n";
  }
}
my $num_series = keys %Series;
print "Received list of $num_series series to scan\n";
close STDOUT;
close STDIN;
fork and exit;
print STDERR "Survived fork with $num_series to process\n";
my $create_scan = PosdaDB::Queries->GetQueryInstance("CreateScanEvent");
my $get_scan_id = PosdaDB::Queries->GetQueryInstance("GetScanEventEventId");
my $update_series_scanned = PosdaDB::Queries->GetQueryInstance("UpdateSeriesScanned");

my $gfile;
if($type eq "posda"){
  $gfile = PosdaDB::Queries->GetQueryInstance("FirstFileInSeriesPosda");
} elsif($type eq "intake") {
  $gfile = PosdaDB::Queries->GetQueryInstance("FirstFileInSeriesIntake");
} elsif($type eq "public") {
  $gfile = PosdaDB::Queries->GetQueryInstance("FirstFileInSeriesPublic");
} else{
  die "type must be 'posda', 'intake', or 'public'";
}
my $finish_scan = PosdaDB::Queries->GetQueryInstance("UpdateSeriesFinished");
$create_scan->RunQuery(sub {}, sub {}, $desc, $num_series);
my $scan_id;
$get_scan_id->RunQuery(sub{
    my($row) = @_;
    $scan_id = $row->[0];
  }, sub {});
unless(defined $scan_id) { die "Can't get scan_id" }
my $num_scanned = 0;
series:
for my $series (keys %Series){
  my $sig = $Series{$series};
  my $file;
  $gfile->RunQuery(sub{
      my($row) = @_;
      $file = $row->[0];
    }, sub{}, $series);
  unless(defined $file) {
    print STDERR "can't find file for series $series\n";
    next series;
  }
  if($type eq "intake") {
    $file =~ s/sdd1/intake1-data/;
  }
  my $command = "PhiSeriesScan.pl $series '$sig' $scan_id " .
    "'$file'";
  open COMMAND, "$command|" or die "can't open command";
  my $resp;
  while (my $line = <COMMAND>){
    $resp .= $line;
  }
  $num_scanned += 1;
  $update_series_scanned->RunQuery(sub{}, sub{}, $num_scanned, $scan_id);
}
$finish_scan->RunQuery(sub{}, sub{}, $scan_id);
