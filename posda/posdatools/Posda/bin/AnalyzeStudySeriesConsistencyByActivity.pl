#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Debug;
my $dbg = sub { print @_ };
sub MakeDebug{
  my($hand) = @_;
  my $sub = sub {
    $hand->print(@_);
  };
  return $sub;
}
sub MakeBackgroundDebug{
  my($back) = @_;
  my $sub = sub {
    my($text) = @_;
    $back->WriteToEmail($text);
  };
  return $sub;
}
$| = 1; # this should probably be at the top of the script, maybe in the lib?

my $usage = <<EOF;
Usage:
AnalyzeStudySeriesConsistencyByActivity.pl <bkgrnd_id> <activity_id> <notify>
  or
AnalyzeStudySeriesConsistencyByActivity.pl -h
Expects no lines on STDIN:
EOF
# All Studies in current activity_timepoint:
my %StudiesInActTp;
# All Series in current activity_timepoint:
my %SeriesInActTp;
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

unless($#ARGV == 2) { print $usage; exit }

my($invoc_id, $act_id, $notify) = @ARGV;
my $start = time;

##################
# Get List of Study and Series in this Current Activity Timepoint for this Activity
my $OldActTpId;
my $OldActTpComment;
my $OldActTpDate;
my %FilesInOldTp;
my %SeriesInOldTp;
my %StudiesInOldTp;
Query('LatestActivityTimepointsForActivity')->RunQuery(sub{
  my($row) = @_;
  my($activity_id, $activity_created,
    $activity_description, $activity_timepoint_id,
    $timepoint_created, $comment, $creating_user) = @$row;
  $OldActTpId = $activity_timepoint_id;
  $OldActTpComment = $comment;
  $OldActTpDate = $timepoint_created;
}, sub {}, $act_id);
Query('FileIdsByActivityTimepointId')->RunQuery(sub {
  my($row) = @_;
  $FilesInOldTp{$row->[0]} = 1;
}, sub {}, $OldActTpId);
my $q = Query('StudySeriesForFile');
for my $file_id(keys %FilesInOldTp){
  $q->RunQuery(sub {
    my($row) = @_;
    $SeriesInOldTp{$row->[1]} = 1;
    $StudiesInOldTp{$row->[0]} = 1;
  }, sub {}, $file_id);
}
my $num_tp_series = keys %SeriesInOldTp;
my $num_tp_studiea = keys %StudiesInOldTp;
print "Found $num_tp_studiea studies, $num_tp_series series\n";
my $forground_time = time - $start;
print "Going to background to analyze after $forground_time seconds\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
$background->Daemonize;
$background->WriteToEmail("Checking Study/Series Consistency by Activity\n");
$background->WriteToEmail("Activity id: $act_id\n");
$background->WriteToEmail("Activity timepoint id: $OldActTpId\n");
$background->WriteToEmail("Found $num_tp_studiea studies, $num_tp_series series\n");
##################
# Analyze Series Consistency for Inconsistent Series
my $start_analysis = time;
my $ser_inc = Query('SeriesConsistency');
Query("FindInconsistentSeriesIgnoringTimeAll")->RunQuery(sub{
  my($row) = @_;
  my($series) = @$row;
  my %AttrValues;
#  unless(exists $SeriesInOldTp{$series}){ print "not in tp\n"; return }
  unless(exists $SeriesInOldTp{$series}){ return }
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
}, sub {});
##################
# Analyze Study Consistency for Inconsistent Studies
my $std_inc = Query('StudyConsistencyWithPatientId');
Query("FindInconsistentStudyIgnoringStudyTimeIncludingPatientIdAll")->RunQuery(sub{
  my($row) = @_;
  my($study) = @$row;
#  unless(exists $StudiesInOldTp{$study}){ print "not in tp\n"; return }
  unless(exists $StudiesInOldTp{$study}){ return }
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
  }, sub {}, $study);
  for my $attr (keys %AttrValues){
    my @values = keys %{$AttrValues{$attr}};
    if(@values > 1){
      for my $i (@values){
        $StudiesWithConsistencyProblems{$study}->{$attr}->{$i} =
          $AttrValues{$attr}->{$i};
      }
    }
  }
}, sub {});
my $num_series = keys %SeriesWithConsistencyProblems;
my $num_studies = keys %StudiesWithConsistencyProblems;
my %SeriesDupReport;
my $analysis_time = time - $start_analysis;
$background->WriteToEmail("Analysis complete after $analysis_time seconds.\nSeries: ");
$background->WriteToEmail("Found $num_series inconsistent series for activity: $act_id\n");
$background->WriteToEmail("Found $num_studies inconsistent studies for activity: $act_id\n");
#Debug::GenPrint(MakeBackgroundDebug($background), \%SeriesWithConsistencyProblems);
#$background->WriteToEmail("\nStudies: ");
#Debug::GenPrint(MakeBackgroundDebug($background), \%StudiesWithConsistencyProblems);
#$background->WriteToEmail("\n");
if($num_studies > 0){
  my %StudyProblems;
  for my $study(keys %StudiesWithConsistencyProblems){
    for my $field (keys %{$StudiesWithConsistencyProblems{$study}}){
      $StudyProblems{$field} = 1;
    }
  }
  my @StudyHeaders = keys %StudyProblems;
  my $rpt1 = $background->CreateReport("StudyInconsistencies");
  $rpt1->print("study_instance_uid");
  for my $i (@StudyHeaders){
    $rpt1->print(",$i");
  }
  $rpt1->print("\r\n");
  for my $study (keys %StudiesWithConsistencyProblems){
    $rpt1->print("$study,");
    for my $i (0 .. $#StudyHeaders){
      my $field = $StudyHeaders[$i];
      if(exists $StudiesWithConsistencyProblems{$study}->{$field}){
        $rpt1->print("\"");
        my $h = $StudiesWithConsistencyProblems{$study}->{$field};
        for my $k (keys %$h){
          my $t = $k;
          $t =~ s/"/""/g;
          $rpt1->print("$h->{$k}: $t\n");
        }
        $rpt1->print("\"");
      }
      if($i < $#StudyHeaders) {$rpt1->print(",")} else { $rpt1->print("\r\n") }
    }
  }
}
if($num_series > 0){
  my %SeriesProblems;
  for my $series(keys %SeriesWithConsistencyProblems){
    for my $field (keys %{$SeriesWithConsistencyProblems{$series}}){
      $SeriesProblems{$field} = 1;
    }
  }
  my @SeriesHeaders = keys %SeriesProblems;
  my $rpt1 = $background->CreateReport("SeriesInconsistencies");
  $rpt1->print("series_instance_uid");
  for my $i (@SeriesHeaders){
    $rpt1->print(",$i");
  }
  $rpt1->print("\r\n");
  for my $series (keys %SeriesWithConsistencyProblems){
    $rpt1->print("$series,");
    for my $i (0 .. $#SeriesHeaders){
      my $field = $SeriesHeaders[$i];
      if(exists $SeriesWithConsistencyProblems{$series}->{$field}){
        $rpt1->print("\"");
        my $h = $SeriesWithConsistencyProblems{$series}->{$field};
        for my $k (keys %$h){
          my $t = $k;
          $t =~ s/"/""/g;
          $rpt1->print("$h->{$k}: $t\n");
        }
        $rpt1->print("\"");
      }
      if($i < $#SeriesHeaders) {$rpt1->print(",")} else { $rpt1->print("\r\n") }
    }
  }
}
$background->Finish;
