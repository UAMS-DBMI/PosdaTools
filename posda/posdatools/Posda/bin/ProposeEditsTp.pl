#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;

my $usage = <<EOF;
ProposeEditsTp.pl <bkgrnd_id> <activity_id> <scan_id> <notify>
  activity_id - Id of the currently selected activity
  scan_id - id of scan to query
  notify - email address for completion notification

Expects lines on STDIN:
<<element>>%<vr>%<<q_value>>%<num_series>%<p_op>%<<q_arg1>>%<<q_arg2>>

Note:
  The double metaquotes in the line specification are not errors.
  Those fields are to be metaquoted themselves.

Uses the following query:
  GetSeriesForPhiInfo
  WhereSeriesSitsQuick
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 3){
  die "$usage\n";
}
my($invoc_id, $activity_id, $scan_id, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);

my @SeriesQueries;
while(my $line = <STDIN>){
  chomp $line;
  $background->LogInputLine($line);
  my($element, $vr, $q_value, $num_series, $p_op, $q_arg1, $q_arg2) = 
    split(/%/, $line);
  if($element =~ /^<(.*)>$/){ $element = $1 } elsif($element){
    print "Warning - element: \"$element\" not metaquoted\n";
  }
  if($q_value =~ /^<(.*)>$/){ $q_value = $1 } elsif($q_value) {
    print "Warning - q_value: \"$q_value\" not metaquoted\n";
  }
  if($q_arg1 =~ /^<(.*)>$/){ $q_arg1 = $1 } elsif($q_arg1) {
    print "Warning - q_arg1: \"$q_arg1\" not metaquoted\n";
  }
  if($q_arg2 =~ /^<(.*)>$/){ $q_arg2 = $1 } elsif($q_arg2) {
    print "Warning - q_arg2: \"$q_arg2\" not metaquoted\n";
  }
  my $q = {
   element => $element,
   vr => $vr,
   value => $q_value,
   num_series => $num_series,
   op => $p_op,
   arg1 => $q_arg1,
   arg2 => $q_arg1,
   bucket => "$p_op|$element|$q_arg1|$q_arg2",
  };
  push @SeriesQueries, $q;
}
my $num_series = @SeriesQueries;
print "Found list of $num_series queries to make\n";

$background->ForkAndExit;
$background->LogInputCount($num_series);

my $get_series = Query("GetSeriesForPhiInfo");
my $get_series_count = Query("SeriesFileCount");

my $start_time = time;
$background->WriteToEmail("Starting simple look up of Series with PHI\n" .
  "Scan_id: $scan_id\n");
my %EditsBySeries;
my %FilesInSeries;
my $num_qs = @SeriesQueries;
for my $ii (0 .. $#SeriesQueries){
  my $i = $SeriesQueries[$ii];
  my $tag = $i->{element}; 
  my $vr = $i->{vr}; 
  my $val = $i->{value}; 
  my $num_series = $i->{num_series};
  my $op = $i->{op};
  my $arg1= $i->{arg1};
  my $arg2= $i->{arg2};
  my $bucket= $i->{bucket};
  my @series;
  $get_series->RunQuery(sub{
      my($row) = @_;
      my $series_inst = $row->[0];
      push @series, $series_inst;
    },
    sub{},
    $tag, $vr, $val, $scan_id
  );
  my $n_series = @series;
  for my $s (@series){
    $EditsBySeries{$s}->{$bucket} = 1;
    $get_series_count->RunQuery(sub{
        my($row) = @_;
        $FilesInSeries{$s} = $row->[0]; 
      },
      sub {},
      $s
    );
  }
  my $ith = $ii + 1;
  $background->SetActivityStatus("processed $ith of $num_qs");
  $background->WriteToEmail("Retrieved $n_series for:\n\telement: $tag\n\tvalue: $val\n");
}
my %SeriesByEditGroups;
for my $s (keys %EditsBySeries){
  my $EditGroupSummary;
  my @edit_keys = sort keys %{$EditsBySeries{$s}};
  for my $k (0 .. $#edit_keys){
    $EditGroupSummary .= $edit_keys[$k];
    unless($k == $#edit_keys){ $EditGroupSummary .= "%" }
  }
  $SeriesByEditGroups{$EditGroupSummary}->{$s} = 1;
}
my $rpt = $background->CreateReport("EditSpreadsheet");
my $num_edit_groups = keys %SeriesByEditGroups;
$background->WriteToEmail("$num_edit_groups distinct edit groups found\n");
$rpt->print("series_instance_uid,num_files," .
  "op,tag,val1,val2,Operation,description,notify,activity_id\n");
my $first_line = 1;
for my $c (sort keys %SeriesByEditGroups){
  for my $s (keys %{$SeriesByEditGroups{$c}}){
    $rpt->print("$s,$FilesInSeries{$s}");
    if($first_line){
      $rpt->print(",,,,,BackgroundEditTp," .
        "\"From PHI Scan: $scan_id\",\"$notify\",$activity_id\n");
      $first_line = 0;
    } else {
      $rpt->print("\n");
    }
  }
  $background->WriteToEmail("Command group: $c\n");
  my @edits = split /%/, $c;
  for my $edit (@edits){
  $background->WriteToEmail("Edit: $edit\n");
    my($op, $tag, $arg1, $arg2) = split(/\|/, $edit);
    $tag =~ s/"/""/g;
    $arg1 =~ s/"/""/g;
    $arg2 =~ s/"/""/g;
    $rpt->print(",,\"$op\",\"<$tag>\",\"<$arg1>\",\"<$arg2>\"\n");
  }
}
my $end = time;
my $duration = $end - $start_time;
$background->WriteToEmail("finished scan\nduration $duration seconds\n");
$background->Finish("Finished scan after $duration seconds");
