#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
my $usage = <<EOF;
MakeEditProposal.pl <scan_id> <report_file> <notify>
  scan_id - id of scan to query
  report_file - where to store report
  notify - email address for completion notification

Expects lines on STDIN:
<element>&<vr>&<value>&<description>

Note:
  <element> can be in any of the following three forms:
     <(0000,0000)>
     -(0000,0000)-
     (0000,0000)
  The first if preferred, Excel leaves it alone.
  The second is left alone by Excel, but the leading "-"
    causes Excel to make silly assumptions when you try
    to edit it. It is now deprecated.
  The third (even if you clearly mark it as text with a
    leading "'") causes Excel to go insane...

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
my($scan_id, $path, $notify) = @ARGV;
my @SeriesQueries;
while(my $line = <STDIN>){
  chomp $line;
  my($element, $vr, $value, $description) = split(/&/, $line);
  if($element =~ /^<(.*)>$/){ $element = $1 }
  if($element =~ /^-(.*)-$/){ $element = $1 }
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
close STDOUT;
close STDIN;
fork and exit;
my $get_series = PosdaDB::Queries->GetQueryInstance("GetSeriesForPhiInfo");
my $get_series_info = PosdaDB::Queries->GetQueryInstance(
  "WhereSeriesSitsQuick");
print STDERR "Survived fork with $num_series to process\n";
open EMAIL, "|mail -s \"Posda Job Complete\" $notify" or die
  "can't open pipe ($!) to mail $notify";
my $start_time = time;
print EMAIL "Starting simple look up of Series with PHI\n" .
  "Scan_id: $scan_id\n" .
  "Report file: $path\n";
unless(open REPORT, ">$path"){
  print EMAIL "Couldn't open report file: \"$path\" ($!)\n";
  die "Couldn't open report file: $path ($!)";
}
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
  #      print REPORT "\"<$el>\",$vr,\"$val\",\"$desc\"," .
  #      "\"$col\",\"$site\",\"$pat\",\"$study\",\"$s\"\n";
       $EditsBySeries{$s}->{"$el|$vr|$val"} = 1; 
      },
      sub {},
      $s
    );
  }
  print EMAIL "Retrieved $n_series for:\n\telement: $el\n\tvalue: $val\n";
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
print EMAIL "$num_edit_groups distinct edit groups found\n";
print REPORT "command,arg1,arg2,arg3,arg4\n";
for my $c (sort keys %SeriesByEditGroups){
  for my $s (keys %{$SeriesByEditGroups{$c}}){
    print REPORT "AddSopsInSeries,$s\n";
  }
  print REPORT "AccumulateEdits\n";
print EMAIL "Command group: $c\n";
  my @edits = split /&/, $c;
  for my $edit (@edits){
print EMAIL "Edit: $edit\n";
    my($el, $vr, $val) = split(/\|/, $edit);
    $el =~ s/"/""/g;
    print REPORT "edit,edit_op,\"<$el>\",\"$val\"\n";
  }
  print REPORT "ProcessFiles\n";
}
my $end = time;
my $duration = $end - $start_time;
print EMAIL "finished scan\nduration $duration seconds\n";
