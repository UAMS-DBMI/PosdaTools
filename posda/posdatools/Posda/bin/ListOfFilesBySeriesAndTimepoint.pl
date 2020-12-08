#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::DownloadableFile;
use Posda::BackgroundProcess;
my $usage = <<EOF;
ListOfFilesBySeriesAndTimepoint.pl <?bkgrnd_id?> <activity_id> <activity_timepoint_id> <notify>

Expects list of series_instance_uid's on STDIN


EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}

unless($#ARGV == 3){
  print "$usage\n";
  die "######################## subprocess failed to start:\n" .
      "$usage\n" .
      "#####################################################\n";
}
my($invoc_id, $act_id, $act_tp_id, $notify) = @ARGV;
##################
my $q = Query('GetFilesAndSopsBySeriesAndTP');
my $num_lines = 0;
my %Files;
while(my $line = <STDIN>){
  chomp $line;
  $num_lines += 1;
  $q->RunQuery(sub {
    my($row) = @_;
    my ($patient_id, $study_instance_uid, $series_instance_uid,
      $sop_instance_uid, $file_id, $path) = @$row;
    $Files{$file_id} = {
      patient_id => $patient_id,
      study_instance_uid => $study_instance_uid,
      series_instance_uid => $series_instance_uid,
      sop_instance_uid => $sop_instance_uid,
      path => $path,
    };
  }, sub{}, $line, $act_tp_id);
}
my $num_files = keys %Files;
my $b = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
print "Going to background to produce report for $num_files files" .
  " in $num_lines series\n";
$b->Daemonize;
$b->WriteToEmail("FileReport for:\n" .
  "     activity: $act_id,\n" .
  "    timepoint: $act_tp_id,\n" .
  "subprocess id: $invoc_id,\n" .
  "   num series: $num_lines,\n" .
  "    num files: $num_files,\n");
$b->SetActivityStatus("Producing Report");
my $rpt = $b->CreateReport("FileReport");
$rpt->print("file_id,patient_id,study_instance_uid,series_instance_uid,path\n");
for my $file_id (sort
  {
    $Files{$a}->{patient_id} cmp $Files{$b}->{patient_id} ||
    $Files{$a}->{study_instance_uid} cmp $Files{$b}->{study_instance_uid} ||
    $Files{$a}->{series_instance_uid} cmp $Files{$b}->{series_instance_uid}
  }
  keys %Files
){
  $rpt->print("$file_id,$Files{$file_id}->{patient_id}," .
    "$Files{$file_id}->{study_instance_uid}," .
    "$Files{$file_id}->{series_instance_uid}," .
    "$Files{$file_id}->{path}\n");
}

###
$b->Finish("Done");
