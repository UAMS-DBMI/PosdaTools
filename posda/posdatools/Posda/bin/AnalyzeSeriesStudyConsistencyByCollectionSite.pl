#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Debug;
my $dbg = sub { print @_ };
$| = 1; # this should probably be at the top of the script, maybe in the lib?

my $usage = <<EOF;
Usage:
AnalyzeSeriesStudyConsistencyByCollectionSite.pl <bkgrnd_id> <collection> <site> <notify>
  or
AnalyzeSeriesStudyConsistencyByCollectionSite.pl -h
Expects no lines on STDIN:
EOF
# This is the Data Structure which will represent all Series Inconsistencies
my %SeriesWithConsistencyProblems;
# $SeriesWithConsistencyProblems{<series_instance_uid>} = {
#   <attr_name_1> => {
#     <val_1> => <count>,
#     ...
#   },
#   ...
# };
#
# This is the Data Structure which will represent all Studies Inconsistencies
my %StudiesWithConsistencyProblems;
# $StudiesWithConsistencyProblems{<study_instance_uid>} = {
#   <attr_name_1> => {
#     <val_1> => <count>,
#     ...
#   },
#   ...
# };
#

if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }

unless($#ARGV == 3) { print $usage; exit }

my($invoc_id, $coll, $site, $notify) = @ARGV;
my $start = time;

my $ser_inc = Query('SeriesConsistency');
Query("FindInconsistentSeriesIgnoringTimeCollectionSite")->RunQuery(sub{
  my($row) = @_;
  my($series) = @$row;
  my %AttrValues;
  $ser_inc->RunQuery(sub {
    my($row) = @_;
    my %values;
    my @attr_names = ('series_instance_uid', 'modality', 'series_number',
      'laterality', 'series_date', 'series_time', 'performing_phys',
      'protocol_name', 'series_description', 'operators_name',
      'body_part_examined', 'patient_position', 'smallest_pixel_value',
      'largest_pixel_value', 'performed_procedure_step_id',
      'performed_procedure_step_start_date', 
      'performed_procedure_step_start_time', 'performed_procedure_step_desc',
      'performed_procedure_step_comments');
    for my $i (@attr_names) {
      my $v = shift (@$row);
      unless(defined $v) { $v = '<undef>' }
      $values{$i} = $v;
    }
    my $count = shift(@$row);
    for my $i (keys %values){
      my $v = $values{$i};
      if(exists $AttrValues{$i}->{$v}){
        $AttrValues{$i}->{$v} += $count;
      } else {
        $AttrValues{$i}->{$v} = $count;
      }
    }
  }, sub {}, $series);
  for my $attr (keys %AttrValues){
    my @values = keys %{$AttrValues{$attr}};
    if(@values > 1){
      for my $i (@values){
        $SeriesWithConsistencyProblems{$series}->{$attr}->{$i} =
          $AttrValues{$attr}->{$i};
      }
    }
  }
}, sub {}, $coll, $site);
my $std_inc = Query('StudyConsistencyWithPatientId');
Query("FindInconsistentStudyIgnoringStudyTimeByCollectionSite")->RunQuery(sub{
  my($row) = @_;
  my($series) = @$row;
  my %AttrValues;
  $std_inc->RunQuery(sub {
    my($row) = @_;
    my %values;
    my @attr_names = (
      'patient_id', 'study_instance_uid', 'study_date', 'study_time',
      'referring_phy_name', 'study_id', 'accession_number',
      'study_description', 'phys_of_record', 'phys_reading',
      'admitting_diag'
    );
    for my $i (@attr_names) {
      my $v = shift (@$row);
      unless(defined $v) { $v = '<undef>' }
      $values{$i} = $v;
    }
    my $count = shift(@$row);
    for my $i (keys %values){
      my $v = $values{$i};
      if(exists $AttrValues{$i}->{$v}){
        $AttrValues{$i}->{$v} += $count;
      } else {
        $AttrValues{$i}->{$v} = $count;
      }
    }
  }, sub {}, $series);
  for my $attr (keys %AttrValues){
    my @values = keys %{$AttrValues{$attr}};
    if(@values > 1){
      for my $i (@values){
        $StudiesWithConsistencyProblems{$series}->{$attr}->{$i} =
          $AttrValues{$attr}->{$i};
      }
    }
  }
}, sub {}, $coll, $site);
my $num_series = keys %SeriesWithConsistencyProblems;
my $num_studies = keys %StudiesWithConsistencyProblems;
my %SeriesDupReport;
my %SeriesWithDups;
#############################
# This is code which sets up the Background Process and Starts it
print "Found $num_series series with dups for $coll, $site\n";
unless($invoc_id) {
  print "Not running as background\n";
  print "Series: ";
  Debug::GenPrint($dbg, \%SeriesWithConsistencyProblems, 1);
  print "\nStudies: ";
  Debug::GenPrint($dbg, \%StudiesWithConsistencyProblems, 1);
  print "\n\n";
  exit;
}
my $forground_time = time - $start;
print "Going to background to analyze after $forground_time seconds\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->Daemonize;
$background->WriteToEmail("Analyzing duplicate SOPs for $num_series \n" .
  "found for $coll, $site\n");
my $start_analysis = time;
for my $series(keys %SeriesWithDups){
  Query("DuplicateSopsInSeriesNew")->RunQuery(sub {
    my($row) = @_;
    my($sop, $tt, $file_id) = @$row;
    my $day = substr $tt, 0, 10;
    $SeriesDupReport{$series}->{$day}->{sops}->{$sop}->{$file_id} = 1;
    $SeriesDupReport{$series}->{$day}->{files}->{$file_id} = $sop;
  }, sub {}, $series);
}
for my $series(keys %SeriesDupReport){
  for my $day(keys %{$SeriesDupReport{$series}}){
    my $p = $SeriesDupReport{$series}->{$day};
    my @sops = keys %{$p->{sops}};
    $p->{num_sops} =  @sops;
    my @files = sort keys %{$p->{files}};
    $p->{num_files} = @files;
    $p->{max_file_id} = $files[$#files];
    $p->{min_file_id} = $files[0];
  }
}
my $analysis_time = time - $start_analysis;
$background->WriteToEmail("Analysis complete after $analysis_time seconds.\n");
my $rpt = $background->CreateReport("DuplicateAnalysis");
$rpt->print("key,value\n\r");
$rpt->print("collection,\"$coll\"\r\n");
$rpt->print("site,\"$site\"\r\n");
my $when = `date`;
chomp $when;
$rpt->print("when,\"$when\"\r\n");
$rpt->print("who,$notify\r\n");
$rpt->print("\r\n");
$rpt->print("series,num_files,num_sops,num_days,day1," .
  "day1_files,day1_sops,day2,day2_files,day2_sops,check_set,comparison\r\n");
my $get_path = Query('GetFilePath');
series:
for my $series (keys %SeriesDupReport){
  my $num_sops = $SeriesWithDups{$series}->{num_sops};
  my $num_files = $SeriesWithDups{$series}->{num_files};
  $rpt->print("$series,$num_files,$num_sops,");
  my @days = sort (keys %{$SeriesDupReport{$series}});
  my $num_days = @days;
  $rpt->print ("$num_days,");
  my $day1 = $days[0];
  my $day2 = $days[$#days];
  my $p1= $SeriesDupReport{$series}->{$day1};
  my $p2 = $SeriesDupReport{$series}->{$day2};
  my $day1_num_files = $p1->{num_files};
  my $day1_num_sops = $p1->{num_sops};
  my @day1_sops = sort keys %{$p1->{sops}};
  my $day2_num_files = $p2->{num_files};
  my $day2_num_sops = $p2->{num_sops};
  my @day2_sops = sort keys %{$p2->{sops}};
  my $check_set = "Ok";
  for my $i (0 .. $#day1_sops){
    unless($day2_sops[$i] eq $day1_sops[$i]){
      $check_set = "Bad";
      last;
    }
  }
  $rpt->print("\"$day1\",$day1_num_files,$day1_num_sops,");
  $rpt->print("\"$day2\",$day2_num_files,$day2_num_sops,");
  $rpt->print("$check_set");
  if($check_set ne "Ok"){
    $rpt->print("\r\n");
    next series;
  }
  my $first_sop = $day1_sops[0];
  my $day1_file_id = [ keys %{$p1->{sops}->{$first_sop}} ]->[0];
  my $day2_file_id = [ keys %{$p2->{sops}->{$first_sop}} ]->[0];
  my $day1_file_path;
  $get_path->RunQuery(sub
  {
    my($row) = @_;
    $day1_file_path = $row->[0];
  }, sub {}, $day1_file_id);
  my $day2_file_path;
  $get_path->RunQuery(sub
  {
    my($row) = @_;
    $day2_file_path = $row->[0];
  }, sub {}, $day2_file_id);
  my $try1 = Posda::Try->new($day1_file_path);
  unless(exists $try1->{dataset}){
    $rpt->print(",$day1_file_path didn't parse as DICOM\r\n");
    next series;
  }
  my $try2 = Posda::Try->new($day2_file_path);
  unless(exists $try2->{dataset}){
    $rpt->print(",$day2_file_path didn't parse as DICOM\r\n");
    next series;
  }
  my $diff = Posda::DiffDicom->new($try1->{dataset}, $try2->{dataset});
  $diff->Analyze;
  my($short_rpt, $long_rpt) = $diff->DiffReport;
  $long_rpt =~ s/"/""/g;
  $rpt->print(",\"$long_rpt\"\r\n");
}
$background->Finish;
