#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::BackgroundProcess;
my $usage = <<EOF;
FindSeriesInScanWithPhi.pl <?bkgrnd_id?> <scan_id> <notify>
  scan_id - id of scan to query
  notify - who to notify

Expects lines on STDIN:
<element>&<vr>&<value>&<description>

Uses the following query:
  GetSeriesForPhiInfo
  WhereSeriesSitsQuick
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
#print "not yet implemented\n";
#exit;

unless($#ARGV == 2){
  die "$usage\n";
}
my($invoc_id, $scan_id, $notify) = @ARGV;
my @SeriesQueries;
while(my $line = <STDIN>){
  chomp $line;
  my($element, $vr, $value, $description) = split(/&/, $line);
  if($element =~ /^<(.*)>$/){ $element = $1 }
  if($value =~ /^<(.*)>$/){ $value = $1 }
  my $q = {
   element => $element,
   vr => $vr,
   value => $value,
   description => $description,
  };
  push @SeriesQueries, $q;
}
my $num_series = @SeriesQueries;
print "Found list of $num_series queries to make\n";
my $back = Posda::BackgroundProcess->new($invoc_id, $notify);
$back->Daemonize;
my $get_series = PosdaDB::Queries->GetQueryInstance("GetSeriesForPhiInfo");
my $get_series_info = PosdaDB::Queries->GetQueryInstance(
  "WhereSeriesSitsQuick");
$back->WriteToEmail("Starting simple look up of Series with PHI\n" .
  "Scan_id: $scan_id\n");
my $rpt = $back->CreateReport("SeriesWithBadDates");
$rpt->print("element,vr,value,description,collection,site," .
  "patient_id,study_instance_uid,series_instance_uid\n");
for my $i (@SeriesQueries){
  my $el = $i->{element}; 
  my $vr = $i->{vr}; 
  my $val = $i->{value}; 
  my $desc = $i->{description}; 
  my @series;
  $get_series->RunQuery(sub{
      my($row) = @_;
      my $series_inst = $row->[0];
      push @series, $series_inst;
    },
    sub{},
    $el, $vr, $val, $scan_id
  );
  my $num_series = @series;
  for my $s (@series){
    $get_series_info->RunQuery(sub{
        my($row) = @_;
        my $col = $row->[0]; 
        my $site = $row->[1]; 
        my $pat = $row->[2]; 
        my $study = $row->[3]; 
        my $series = $row->[4]; 
        $rpt->print("\"<$el>\",$vr,\"$val\",\"$desc\"," .
        "\"$col\",\"$site\",\"$pat\",\"$study\",\"$s\"\n");
      },
      sub {},
      $s
    );
  }
  $back->WriteToEmail("Retrieved $num_series for:\n\telement: $el\n\tvalue: $val\n");
}
$back->Finish;
