#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;

my $usage = <<EOF;
MakeEditProposal.pl <bkgrnd_id> <scan_id> <notify>
  scan_id - id of scan to query
  notify - email address for completion notification

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

unless($#ARGV == 2){
  die "$usage\n";
}
my($invoc_id, $scan_id, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

my @SeriesQueries;
while(my $line = <STDIN>){
  chomp $line;
  $background->LogInputLine($line);
  my($element, $vr, $value, $description) = split(/&/, $line);
  if($element =~ /^<(.*)>$/){ $element = $1 }
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

$background->ForkAndExit;
$background->LogInputCount($num_series);

my $get_series = Query("GetSeriesForPhiInfo");
my $get_series_info = Query("WhereSeriesSitsQuick");

my $start_time = time;
$background->WriteToEmail("Starting simple look up of Series with PHI\n" .
  "Scan_id: $scan_id\n");
my %EditsBySeries;
for my $i (@SeriesQueries){
  my $el = $i->{element}; 
  my $vr = $i->{vr}; 
  my $val = $i->{value}; 
  my $desc = $i->{description}; 
  my @series;
  my $n_series = @series;
  $get_series->RunQuery(sub{
      my($row) = @_;
      my $series_inst = $row->[0];
      push @series, $series_inst;
    },
    sub{},
    $el, $vr, $val, $scan_id
  );
  for my $s (@series){
    $get_series_info->RunQuery(sub{
        my($row) = @_;
        my $col = $row->[0]; 
        my $site = $row->[1]; 
        my $pat = $row->[2]; 
        my $study = $row->[3]; 
        my $series = $row->[4]; 
       $EditsBySeries{$s}->{"$el|$vr|$val"} = 1; 
      },
      sub {},
      $s
    );
  }
  $background->WriteToEmail("Retrieved $n_series for:\n\telement: $el\n\tvalue: $val\n");
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
my $num_edit_groups = keys %SeriesByEditGroups;
$background->WriteToEmail("$num_edit_groups distinct edit groups found\n");
$background->WriteToReport("command,arg1,arg2,arg3,arg4\n");
for my $c (sort keys %SeriesByEditGroups){
  for my $s (keys %{$SeriesByEditGroups{$c}}){
    $background->WriteToReport("AddSopsInSeries,$s\n");
  }
  $background->WriteToReport("AccumulateEdits\n");
$background->WriteToEmail("Command group: $c\n");
  my @edits = split /&/, $c;
  for my $edit (@edits){
$background->WriteToEmail("Edit: $edit\n");
    my($el, $vr, $val) = split(/\|/, $edit);
    $el =~ s/"/""/g;
    $background->WriteToReport("edit,edit_op,\"<$el>\",\"$val\"\n");
  }
  $background->WriteToReport("ProcessFiles\n");
}
my $end = time;
my $duration = $end - $start_time;
$background->WriteToEmail("finished scan\nduration $duration seconds\n");
my $link = $background->GetReportDownloadableURL;
$background->WriteToEmail("Report: $link\n");

$background->LogCompletionTime;
