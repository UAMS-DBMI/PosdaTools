#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Debug;
my $dbg = sub { print @_ };
$| = 1; # this should probably be at the top of the script, maybe in the lib?

my $usage = <<EOF;
Usage:
UpdateActivityTimepointForChange.pl <?bkgrnd_id?> <activity_id> <comment> <notify>
  or
UpdateActivityTimepointForChange.pl -h
Expects no lines on STDIN
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }

unless($#ARGV == 3) { print $usage; exit }

my($invoc_id, $act_id, $comment, $notify) = @ARGV;

###### Globals
my $OldActTpId;
my $OldActTpComment;
my $OldActTpDate;
my %FilesInOldTp;
my %SeriesInOldTp;
###### end Globals
my $start = time;
Query('LatestActivityTimepointsForActivity')->RunQuery(sub{
  my($row) = @_;
  my($activity_id, $activity_created,
    $activity_description, $activity_timepoint_id,
    $timepoint_created, $comment, $creating_user) = @$row;
  $OldActTpId = $activity_timepoint_id;
  $OldActTpComment = $comment;
  $OldActTpDate = $timepoint_created;
}, sub {}, $act_id);

my @attr_names = (
  'collection', 'site', 'patient_id', 'study_instance_uid',
  'series_instance_uid', 'sop_instance_uid', 'dicom_file_type', 'modality',
  'file_id');
my @Rows;

Query("getVisibleActivityTimepointFilesForActivity")->RunQuery(sub{
  my($row) = @_;
  my %values;
  for my $i (@attr_names) {
    my $v = shift (@$row);
    unless(defined $v) { $v = '<undef>' }
    $values{$i} = $v;
  }
  push @Rows, \%values;
}, sub {}, $act_id );

######### More Globals
my %Report;
my %Patients;
my %Studies;
my %Series;
my %Sops;
my %NewFiles;
my %NewChangedFiles;
######### end More Globals
for my $i (@Rows){
  $Report{$i->{collection}}->{$i->{site}}->{$i->{patient_id}}
    ->{$i->{study_instance_uid}}->{$i->{series_instance_uid}}
    ->{$i->{dicom_file_type}}
    ->{$i->{modality}}->{files}->{$i->{file_id}} = 1;

  $Report{$i->{collection}}->{$i->{site}}->{$i->{patient_id}}
    ->{$i->{study_instance_uid}}->{$i->{series_instance_uid}}
    ->{$i->{dicom_file_type}}
    ->{$i->{modality}}->{sops}->{$i->{sop_instance_uid}} = 1;

  $Patients{$i->{patient_id}} = 1;
  $Studies{$i->{study_instance_uid}} = 1;
  $Series{$i->{series_instance_uid}} = 1;
  $Sops{$i->{sop_instance_uid}} = 1;
  $NewFiles{$i->{file_id}} = 1;
  unless(exists $FilesInOldTp{$i->{file_id}}){
    $NewChangedFiles{$i->{file_id}} = 1;
  }
}
my $num_patients = keys %Patients;
my $num_studies = keys %Studies;
my $num_series = keys %Series;
my $num_sops = keys %Sops;
my $num_files = keys %NewFiles;
my $changed_files = keys %NewChangedFiles;
my $files_in_old_tp = keys %FilesInOldTp;
my $series_in_old_tp = keys %SeriesInOldTp;
print "Old timepoint ($OldActTpId:$OldActTpDate:$OldActTpComment)\n" .
  "\thas $files_in_old_tp files in $series_in_old_tp series\n";
print "Patients: $num_patients\n";
print "Studies: $num_studies\n";
print "Series: $num_series\n";
print "Sops: $num_sops\n";
print "Total Files: $num_files\n";
print "Changed Files: $changed_files\n";
#############################
# This is code which sets up the Background Process and Starts it
my $forground_time = time - $start;
print "Going to background to create timepoint  after $forground_time seconds\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->Daemonize;
my $now = `date`;
###### Globals
#my $OldActTpId;
#my $OldActTpComment;
#my $OldActTpDate;
#my %FilesInOldTp;
#my %SeriesInOldTp;
$background->WriteToEmail("Updating activity_timepoint:\n" .
  "Activity id: $act_id\n" .
  "comment:  $comment\n" .
  "old_timepoint_id:  $OldActTpId\n" .
  "old_timepoint_comment:  $OldActTpComment\n" .
  "old_timepoint_date: $OldActTpDate\n" .
  "at $now\n");
my $start_creation = time;
### Creation of tables here
my $cre = Query("CreateActivityTimepoint");
$cre->RunQuery(sub {}, sub {},
  $act_id, $0, $comment, $notify);
my $act_time_id;
my $gid = Query("GetActivityTimepointId");
$gid->RunQuery(sub {
  my($row) = @_;
  $act_time_id = $row->[0];
}, sub{});
unless(defined $act_time_id){
  $background->WriteToEmail("Unable to get activity timepoint id.\n");
  $background->Finish;
  exit;
}
$background->WriteToEmail("Activity Timepoint Id: $act_time_id\n");
my $ins_file = Query("InsertActivityTimepointFile");
for my $file_id (keys %NewFiles){
  $ins_file->RunQuery(sub{}, sub{}, $act_time_id, $file_id);
}
my $creation_time = time;
my $creation = $creation_time - $start_creation;
$background->WriteToEmail("Created tables in $creation seconds.\n");
$background->WriteToEmail("Preparing report.\n");
######### More Globals
#my %Report;
#my %Patients;
#my %Studies;
#my %Series;
#my %Sops;
#my %NewFiles;
#my %NewChangedFiles;
my $rpt = $background->CreateReport("Timepoint Creation Report");
$rpt->print("key,value\r\n");
$rpt->print("script,\"$0\"\r\n");
$rpt->print("comment,\"$comment\"\r\n");
$rpt->print("activity_id,\"$act_id\"\r\n");
$rpt->print("old_activity_timepoint_id,\"$OldActTpId\"\r\n");
$rpt->print("old_activity_timepoint_comment,\"$OldActTpComment\"\r\n");
$rpt->print("old_activity_timepoint_date,\"$OldActTpDate\"\r\n");
$rpt->print("new_activity_timepoint_id,\"$act_time_id\"\r\n");
my $when = `date`;
chomp $when;
$rpt->print("when,\"$when\"\r\n");
$rpt->print("who,$notify\r\n");
$rpt->print("why,$comment\r\n");
$rpt->print("\r\n");
$rpt->print("collection,site,patient_id,study_instance_uid,series_instance_uid," .
  "dicom_file_type,modality,num_sops,num_files\r\n");
my $rpt_time = time - $creation_time;
for my $coll(sort keys %Report){
  my $site_h = $Report{$coll};
  for my $site (sort keys %$site_h){
    my $pat_h = $site_h->{$site};
    for my $pat_id (sort keys %$pat_h){
      my $study_h = $pat_h->{$pat_id};
      for my $study_uid (sort keys %$study_h){
        my $series_h = $study_h->{$study_uid};
        for my $series_uid (sort keys %$series_h){
          my $dft_h = $series_h->{$series_uid};
          for my $dft (sort keys %$dft_h){
            my $mod_h = $dft_h->{$dft};
            for my $mod (keys %$mod_h){
              my $file_h = $mod_h->{$mod}->{files};
              my $sop_h = $mod_h->{$mod}->{sops};
              my $num_files = keys %$file_h;
              my $num_sops = keys %$sop_h;
              $rpt->print("\"$coll\",\"$site\"," .
                "\"$pat_id\",$study_uid,$series_uid," .
                "\"$dft\",$mod,$num_sops,$num_files\r\n");
            }
          }
        }
      }
    }
  }
}
$background->WriteToEmail("Prepared report in $rpt_time seconds.\n");
$background->Finish;
