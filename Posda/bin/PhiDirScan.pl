#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
my $usage = <<EOF;
PhiScan.pl <dir> <description>
  dir - directory to scan for files
      - Must contain files with names of the form <uid>.dcm
  description - description of scan
EOF
unless($#ARGV == 1){
  die "$usage\n";
}
my($dir, $desc) = @ARGV;
my %Files;
unless(-d $dir) { die "$dir is not a directory" }
my $find = "find \"$dir\" -type f -name \"*.dcm\"";
open FIND, "$find|" or die "Can't open finder";
while(my $line = <FIND>){
  chomp $line;
  if($line =~ /^$dir\/(.*)\.dcm$/){
    my $sop = $1;
    $Files{$line} = $sop;
  } else {
    print STDERR "Can't process line: $line\n";
  }
}
close FIND;
my $num_files = keys %Files;
print "Found list of $num_files files to scan\n";
close STDOUT;
close STDIN;
fork and exit;
print STDERR "Survived fork with $num_files to process\n";
my $create_scan = PosdaDB::Queries->GetQueryInstance("CreateScanEvent");
my $get_scan_id = PosdaDB::Queries->GetQueryInstance("GetScanEventEventId");
my $update_series_scanned = PosdaDB::Queries->GetQueryInstance("UpdateSeriesScanned");

my $finish_scan = PosdaDB::Queries->GetQueryInstance("UpdateSeriesFinished");
$create_scan->RunQuery(sub {}, sub {}, $desc, $num_files);
my $scan_id;
$get_scan_id->RunQuery(sub{
    my($row) = @_;
    $scan_id = $row->[0];
  }, sub {});
unless(defined $scan_id) { die "Can't get scan_id" }
my $num_scanned = 0;
series:
for my $file (keys %Files){
  my $sop = $Files{$file};
  my $command = "PhiSeriesScan.pl $sop '<unknown>' $scan_id " .
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
