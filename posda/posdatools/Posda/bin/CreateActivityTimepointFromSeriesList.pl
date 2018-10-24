#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Debug;
my $dbg = sub { print @_ };
$| = 1; # this should probably be at the top of the script, maybe in the lib?

my $usage = <<EOF;
Usage:
CreateActivityFromSeriesList.pl <?bkgrnd_id?> <activity_id> <comment> <notify>
  or
CreateActivityFromSeriesList.pl -h
Expects lines on STDIN:
<series_instance_uid>
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }

unless($#ARGV == 3) { print $usage; exit }

my($invoc_id, $act_id, $comment, $notify) = @ARGV;
my $start = time;
my %InputSeries;
while(my $line = <STDIN>){
  chomp $line;
  $InputSeries{$line} = 1;
}

my @attr_names = (
  'collection', 'site', 'patient_id', 'study_instance_uid',
  'series_instance_uid', 'sop_instance_uid', 'dicom_file_type', 'modality',
  'file_id');
my @Rows;
#########new queries etc
for my $series_instance_uid (keys %InputSeries){
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
#########new queries etc
my %Report;
my %Patients;
my %Studies;
my %Series;
my %Sops;
my %Files;
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
  $Files{$i->{file_id}} = 1;
}
my $num_patients = keys %Patients;
my $num_studies = keys %Studies;
my $num_series = keys %Series;
my $num_sops = keys %Sops;
my $num_files = keys %Files;
print "Patients: $num_patients\n";
print "Studies: $num_studies\n";
print "Series: $num_series\n";
print "Sops: $num_sops\n";
print "Files: $num_files\n";
#############################
# This is code which sets up the Background Process and Starts it
my $forground_time = time - $start;
print "Going to background to create timepoint  after $forground_time seconds\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->Daemonize;
my $now = `date`;
$background->WriteToEmail("Creating timepoint from series list: $comment\n" .
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
for my $file_id (keys %Files){
  $ins_file->RunQuery(sub{}, sub{}, $act_time_id, $file_id);
}
my $creation_time = time;
my $creation = $creation_time - $start_creation;
$background->WriteToEmail("Created tables in $creation seconds.\n");
$background->WriteToEmail("Preparing report.\n");
my $rpt = $background->CreateReport("Timepoint Creation Report");
$rpt->print("key,value\r\n");
$rpt->print("script,\"$0\"\r\n");
$rpt->print("comment,\"$comment\"\r\n");
$rpt->print("activity_id,\"$act_id\"\r\n");
$rpt->print("activity_timepoint_id,\"$act_time_id\"\r\n");
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
