#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Debug;
my $dbg = sub { print @_ };
$| = 1; # this should probably be at the top of the script, maybe in the lib?

my $usage = <<EOF;
Usage:
CondensedActivityTimepointReport.pl <?bkgrnd_id?> <activity_id> <notify>
  or
CondensedActivityTimepointReport.pl -h
Expects no lines on STDIN
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }

unless($#ARGV == 2) { print $usage; exit }

my($invoc_id, $act_id, $notify) = @ARGV;
my $start = time;
##################
## Get List of Study and Series in this Current Activity Timepoint for this Activity
my $ActTpId;
my $ActTpComment;
my $ActTpDate;
my %FilesInTp;
my %SeriesInTp;
my %StudiesInTp;
Query('LatestActivityTimepointsForActivity')->RunQuery(sub{
  my($row) = @_;
  my($activity_id, $activity_created,
    $activity_description, $activity_timepoint_id,
    $timepoint_created, $comment, $creating_user) = @$row;
  $ActTpId = $activity_timepoint_id;
  $ActTpComment = $comment;
  $ActTpDate = $timepoint_created;
}, sub {}, $act_id);
Query('FileIdsByActivityTimepointId')->RunQuery(sub {
  my($row) = @_;
  $FilesInTp{$row->[0]} = 1;
}, sub {}, $ActTpId);
my $q = Query('StudySeriesForFile');
for my $file_id(keys %FilesInTp){
  $q->RunQuery(sub {
    my($row) = @_;
    $SeriesInTp{$row->[1]} = 1;
    $StudiesInTp{$row->[0]} = 1;
  }, sub {}, $file_id);
}
my $num_tp_series = keys %SeriesInTp;
my $num_tp_studiea = keys %StudiesInTp;
print "Found $num_tp_studiea studies, $num_tp_series series\n";
my $forground_time = time - $start;
print "Going to background to analyze after $forground_time seconds\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
$background->Daemonize;
my $now = `date`;
###

##################
## Now get rows for constructing Report
my @attr_names = (
  'collection', 'site', 'patient_id', 'study_instance_uid',
  'series_instance_uid', 'sop_instance_uid', 'dicom_file_type', 'modality',
  'file_id');
my @Rows;
for my $series_instance_uid (keys %SeriesInTp){
  Query("DistinctVisibleFileReportBySeries")->RunQuery(sub{
    my($row) = @_;
    my %values;
    for my $i (@attr_names) {
      my $v = shift (@$row);
      unless(defined $v) { $v = '<undef>' }
      $values{$i} = $v;
    }
    push @Rows, \%values;
  }, sub {}, $series_instance_uid);
}
##

######### Globals for report
my %Report;
my %Patients;
my %Studies;
my %Series;
my %Sops;
my %NewFiles;
my %NewChangedFiles;
##

##################
## Now Construct Report
for my $i (@Rows){
  $Report{$i->{collection}}->{$i->{site}}->{$i->{patient_id}}
    ->{files}->{$i->{file_id}} = 1;

  $Report{$i->{collection}}->{$i->{site}}->{$i->{patient_id}}
    ->{sops}->{$i->{sop_instance_uid}} = 1;

  $Report{$i->{collection}}->{$i->{site}}->{$i->{patient_id}}
    ->{sop_classes}->{$i->{dicom_file_type}} = 1;

  $Report{$i->{collection}}->{$i->{site}}->{$i->{patient_id}}
    ->{modalities}->{$i->{modality}} = 1;

  $Report{$i->{collection}}->{$i->{site}}->{$i->{patient_id}}
   ->{studies}->{$i->{study_instance_uid}} = 1;

  $Report{$i->{collection}}->{$i->{site}}->{$i->{patient_id}}
   ->{series}->{$i->{series_instance_uid}} = 1;

  $Patients{$i->{patient_id}} = 1;
  $Studies{$i->{study_instance_uid}} = 1;
  $Series{$i->{series_instance_uid}} = 1;
  $Sops{$i->{sop_instance_uid}} = 1;
  $NewFiles{$i->{file_id}} = 1;
}
my $num_patients = keys %Patients;
my $num_studies = keys %Studies;
my $num_series = keys %Series;
my $num_sops = keys %Sops;
my $num_files = keys %NewFiles;
my $files_in_tp = keys %FilesInTp;
my $series_in_tp = keys %SeriesInTp;
$background->WriteToEmail( "Timepoint ($ActTpId:$ActTpDate:$ActTpComment)\n" .
  "\thas $files_in_tp files in $series_in_tp series\n");
$background->WriteToEmail("Patients: $num_patients\n");
$background->WriteToEmail("Studies: $num_studies\n");
$background->WriteToEmail("Series: $num_series\n");
$background->WriteToEmail("Sops: $num_sops\n");
$background->WriteToEmail("Total Files: $num_files\n");
### Creation of tables here
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
$rpt->print("activity_id,\"$act_id\"\r\n");
$rpt->print("activity_timepoint_id,\"$ActTpId\"\r\n");
$rpt->print("activity_timepoint_comment,\"$ActTpComment\"\r\n");
$rpt->print("activity_timepoint_date,\"$ActTpDate\"\r\n");
my $when = `date`;
chomp $when;
$rpt->print("when,\"$when\"\r\n");
$rpt->print("who,$notify\r\n");
$rpt->print("\r\n");
$rpt->print("collection,site,patient_id,num_studies,num_series," .
  "num_modalities,num_sop_classes,num_sops,num_files\r\n");
my $rpt_time = time - $start;
for my $coll(sort keys %Report){
  my $site_h = $Report{$coll};
  for my $site (sort keys %$site_h){
    my $pat_h = $site_h->{$site};
    for my $pat_id (sort keys %$pat_h){
      my $h = $pat_h->{$pat_id};
      my $num_files = keys %{$h->{files}};
      my $num_modalities = keys %{$h->{modalities}};
      my $num_sop_class = keys %{$h->{sop_classes}};
      my $num_studies = keys %{$h->{studies}};
      my $num_series = keys %{$h->{series}};
      my $num_sops = keys %{$h->{sops}};
      $rpt->print("$coll,$site,$pat_id,$num_studies,$num_series,$num_modalities," .
        "$num_sop_class,$num_sops,$num_files\n");
    }
  }
}
$background->WriteToEmail("Prepared report in $rpt_time seconds.\n");
$background->Finish;
