#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
my $usage = <<EOF;
PhiSimpleScan.pl <description> <file_query_name> <notify>
  description - description of scan
  file_query_name - name of query to get list of files in series
    "IntakeFilesInSeries" - get list of series in intake database
    "PublicFilesInSeries" - get list of series in public database
    "FilesInSeries" - get list of series in posda database
  notify - email address for completion notification

Expects a list of series on STDIN

Uses the following queries (in addition to file_query_name):
  CreateSimplePhiScanRow(description, num_series, file_query_name)
  GetSimplePhiScanId()
  CreateSimpleSeriesScanInstance(scan_instance_id, series_instance_uid)
  GetSimpleSeriesScanId()
  GetSimpleElementSeen(tag, vr)
  CreateSimpleElementSeen(tag, vr)
  GetSimpleElementSeenIndex()
  GetSimpleValueSeen(value)
  CreateSimpleValueSeen(value)
  GetSimpleValueSeenId()
  CreateSimpleElementValueOccurance(element_seen_id, value_seen_id,
    series_scan_instance_id, phi_scan_instance_id)
  FinalizeSimpleSeriesScan(num_files, id)
  IncrementSimpleSeriesScanned(id)
  FinalizeSimpleScanInstance()  
EOF

unless($#ARGV == 2){
  die "$usage\n";
}
my($description, $q_name, $notify) = @ARGV;
my @Series;
while(my $line = <STDIN>){
  chomp $line;
  push @Series, $line;
}
my $num_series = @Series;
print "Found list of $num_series series to scan\n";
close STDOUT;
close STDIN;
fork and exit;
print STDERR "Survived fork with $num_series to process\n";
open EMAIL, "|mail -s \"Posda Job Complete\" $notify" or die
  "can't open pipe ($!) to mail $notify";
my $start_time = time;
print EMAIL "Starting Simple PHI Scan\n" .
  "Description: $description\n" .
  "File Query: $q_name\n";
my $get_series_count = PosdaDB::Queries->GetQueryInstance($q_name);
my $create_scan = PosdaDB::Queries->GetQueryInstance("CreateSimplePhiScanRow");
my $get_scan_id = PosdaDB::Queries->GetQueryInstance("GetSimplePhiScanId");
my $create_series_scan =
  PosdaDB::Queries->GetQueryInstance("CreateSimpleSeriesScanInstance");
my $get_series_scan_id = 
  PosdaDB::Queries->GetQueryInstance("GetSimpleSeriesScanId");
my $get_ele = PosdaDB::Queries->GetQueryInstance("GetSimpleElementSeen");
my $create_ele = PosdaDB::Queries->GetQueryInstance("CreateSimpleElementSeen");
my $get_ele_id =
   PosdaDB::Queries->GetQueryInstance("GetSimpleElementSeenIndex");
my $get_value = PosdaDB::Queries->GetQueryInstance("GetSimpleValueSeen");
my $create_value = PosdaDB::Queries->GetQueryInstance("CreateSimpleValueSeen");
my $get_value_id =
  PosdaDB::Queries->GetQueryInstance("GetSimpleValueSeenId");
my $create_occurance = 
  PosdaDB::Queries->GetQueryInstance("CreateSimpleElementValueOccurance");
my $finalize_series = 
  PosdaDB::Queries->GetQueryInstance("FinalizeSimpleSeriesScan");
my $increment_series_done = 
  PosdaDB::Queries->GetQueryInstance("IncrementSimpleSeriesScanned");
my $finalize_scan = 
  PosdaDB::Queries->GetQueryInstance("FinalizeSimpleScanInstance");

$create_scan->RunQuery(sub {}, sub{}, $description, $num_series, $q_name);
my $scan_id;
$get_scan_id->RunQuery(sub {
  my($row) = @_;
  $scan_id = $row->[0];
}, sub {});
for my $series (@Series){
  my $num_files_in_series = 0;
  $get_series_count->RunQuery(sub {
    my($row) = @_;
    $num_files_in_series += 1;
  }, sub {}, $series);
  $create_series_scan->RunQuery(sub {}, sub {}, $scan_id,
    $series);
  my $series_scan_id;
  $get_series_scan_id->RunQuery(sub {
    my($row) = @_;
    $series_scan_id = $row->[0];
  }, sub {});
  open SUBP, "PhiSimpleSeriesScan.pl $series $q_name|";
  while(my $line = <SUBP>){
    chomp $line;
    my($tagp, $vr, $value) = split(/\|/, $line);
    my $tag_id;
    $get_ele->RunQuery(sub {
      my($row) = @_;
      $tag_id = $row->[0];
    }, sub {}, $tagp, $vr);
    unless(defined $tag_id){
      $create_ele->RunQuery(sub {}, sub {},
        $tagp, $vr);
      $get_ele_id->RunQuery(sub {
        my($row) = @_;
        $tag_id = $row->[0];
      }, sub {} );
    }
    my $value_id;
    $get_value->RunQuery(sub {
      my($row) = @_;
      $value_id = $row->[0];
    }, sub {}, $value);
    unless(defined $value_id){
      $create_value->RunQuery(sub {}, sub {},
        $value);
      $get_value_id->RunQuery(sub {
        my($row) = @_;
        $value_id = $row->[0];
      }, sub {} );
    }
    $create_occurance->RunQuery(sub {}, sub {},
      $tag_id, $value_id, $series_scan_id, $scan_id)
  }
  close SUBP;
  $finalize_series->RunQuery(sub {}, sub {},
    $num_files_in_series, $series_scan_id);
  $increment_series_done->RunQuery(sub {}, sub {}, $scan_id);
}
$finalize_scan->RunQuery(sub {}, sub {}, $scan_id);
my $end = time;
my $duration = $end - $start_time;
print EMAIL "finished scan\nduration $duration seconds\n";
close EMAIL;
