#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;

my $usage = <<EOF;
ProposeEdits.pl <bkgrnd_id> <scan_id> <notify>
  scan_id - id of scan to query
  notify - email address for completion notification

Expects lines on STDIN:
<<element>>&<vr>&<<q_value>>&<num_series>&<p_op>&<<q_arg1>>&<<q_arg2>>

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

unless($#ARGV == 2){
  die "$usage\n";
}
my($invoc_id, $scan_id, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

my @SeriesQueries;
while(my $line = <STDIN>){
  chomp $line;
  $background->LogInputLine($line);
  my($element, $vr, $q_value, $num_series, $p_op, $q_arg1, $q_arg2) = 
    split(/&/, $line);
  if($element =~ /^<(.*)>$/){ $element = $1 } elsif($element){
    print "Waning - element: \"$element\" not metaquoted\n";
  }
  if($q_value =~ /^<(.*)>$/){ $q_value = $1 } elsif($q_value) {
    print "Waning - q_value: \"$q_value\" not metaquoted\n";
  }
  if($q_arg1 =~ /^<(.*)>$/){ $q_arg1 = $1 } elsif($q_arg1) {
    print "Waning - q_arg1: \"$q_arg1\" not metaquoted\n";
  }
  if($q_arg2 =~ /^<(.*)>$/){ $q_arg2 = $1 } elsif($q_arg2) {
    print "Waning - q_arg2: \"$q_arg2\" not metaquoted\n";
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
my $get_series_info = Query("WhereSeriesSitsQuick");

my $start_time = time;
$background->WriteToEmail("Starting simple look up of Series with PHI\n" .
  "Scan_id: $scan_id\n");
my %EditsBySeries;
my %FilesInSeries;
for my $i (@SeriesQueries){
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
  my $files_in_series = 0;
  for my $s (@series){
    $get_series_info->RunQuery(sub{
        my($row) = @_;
        my $col = $row->[0]; 
        my $site = $row->[1]; 
        my $pat = $row->[2]; 
        my $study = $row->[3]; 
        my $series = $row->[4]; 
        $EditsBySeries{$s}->{$bucket} = 1; 
        $files_in_series += 1;
      },
      sub {},
      $s
    );
    $FilesInSeries{$s} = $files_in_series;
  }
  $background->WriteToEmail("Retrieved $n_series for:\n\telement: $tag\n\tvalue: $val\n");
}
my %SeriesByEditGroups;
for my $s (keys %EditsBySeries){
  my $EditGroupSummary;
  my @edit_keys = sort keys %{$EditsBySeries{$s}};
  for my $k (0 .. $#edit_keys){
    $EditGroupSummary .= $edit_keys[$k];
    unless($k == $#edit_keys){ $EditGroupSummary .= "&" }
  }
  $SeriesByEditGroups{$EditGroupSummary}->{$s} = 1;
}
my $rpt = $background->CreateReport("EditSpreadsheet");
my $num_edit_groups = keys %SeriesByEditGroups;
$background->WriteToEmail("$num_edit_groups distinct edit groups found\n");
$rpt->print("series_instance_uid,num_files," .
  "op,tag,val1,val2,Operation,description,notify\n");
my $first_line = 1;
for my $c (sort keys %SeriesByEditGroups){
  for my $s (keys %{$SeriesByEditGroups{$c}}){
    $rpt->print("$s,$FilesInSeries{$s}");
    if($first_line){
      $rpt->print(",,,,,BackgroundEdit," .
        "\"From PHI Scan: $scan_id\",\"$notify\"\n");
      $first_line = 0;
    } else {
      $rpt->print("\n");
    }
  }
  $background->WriteToEmail("Command group: $c\n");
  my @edits = split /&/, $c;
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
$background->Finish;
