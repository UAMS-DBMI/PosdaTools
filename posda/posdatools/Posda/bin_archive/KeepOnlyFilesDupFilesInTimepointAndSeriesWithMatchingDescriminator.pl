#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
KeepOnlyFilesDupFilesInTimepointAndSeriesWithMatchingDescriminator.pl <?bkgrnd_id?> <activity_id> "<comment>" <notify>
  <activity_id> - activity_id
  <comment> - descriptive comment
  <notify> - user to notify

Expects the following list on <STDIN>
<series_instance_uid>:<descriminator>:<value>

Hides every file in the timepoint which has a duplicate sop in the timepoint, except those
with a value of the discriminator which matches the specified value.

Allowed values for discriminator:
  dicom_file_type
  modality

Produces an error message and does not delete files if all files for a given SOP will be deleted.

Updates timepoint when done.

Uses named queries:
   "DupSopsLatestTpByActivity"
   "DupSopsLatestTpBySopInstance"
   "LatestActivityTimepointForActivity"
   "CreateActivityTimepoint"
   "GetActivityTimepointId"
   "InsertActivityTimepointFile"
   "FilesInTimepoint"

Uses script: HideFilesWithStatusIrrespectiveOfCtp.pl to hide files.

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 3){
  my $n_args = @ARGV;
  my $mess = "Wrong number of args ($n_args vs 4). Usage:\n$usage\n";
  print $mess;
  die "######################## subprocess failed to start:\n" .
      "$mess\n" .
      "#####################################################\n";
}
my($invoc_id, $activity_id, $comment, $notify) = @ARGV;
my %SeriesDesc;
while(my $line = <STDIN>){
  chomp $line;
  my($series, $desc, $value) = split(/:/, $line);
  unless($desc eq "dicom_file_type" || $desc eq "modality"){
    my $mess = "Error: unknown discriminator \"$desc\"\n";
    print $mess;
    die $mess;
  }
  $SeriesDesc{$series}->{$desc}->{$value} = 1;
}
my $num_series = keys %SeriesDesc;
my %DupSops;
Query("DupSopsLatestTpByActivity")->RunQuery(sub {
  my($row) = @_;
  my $sop = $row->[0];
  $DupSops{$sop} = 1;
}, sub {}, $activity_id);

my $num_dups = keys %DupSops;
print "Going to background to process $num_dups dup sops preserving $num_series series\n";

my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;
my %Hierarchy;
my $q = Query("DupSopsLatestTpBySopInstance");
my $i = 0;
$back->WriteToEmail("Starting Script " .
  "KeepOnlyFilesDupFilesInTimepointAndSeriesWithMatchingDescriminator.pl $invoc_id $activity_id \"$comment\" $notify\n");
my $start = time;
my %FilesToHide;
my %FilesNotToHide;
my @Errs;
for my $sop (sort keys %DupSops){
  my @files_to_hide;
  my @files_not_to_hide;
  $i += 1;
  $back->SetActivityStatus("Querying $i of $num_dups");
  my $num_files = 0;
  $q->RunQuery(sub{
    my($row) = @_;
    $num_files += 1;
    my($series_instance_uid, $sop_instance_uid, $dicom_file_type, $modality, $file_id) = @$row;
    my $save = 0;
    if(exists $SeriesDesc{$series_instance_uid}->{dicom_file_type}->{$dicom_file_type}){
      $save = 1;
    }
    if(exists $SeriesDesc{$series_instance_uid}->{modality}->{$modality}){
      $save = 1;
    }
    if($save){ push @files_not_to_hide, $file_id }
    else { push @files_to_hide, $file_id }
  }, sub {}, $activity_id, $sop);
  my $to_hide = @files_to_hide;
  my $not_to_hide = @files_not_to_hide;
  unless(@files_not_to_hide == 1){
    my $num_files_left = @files_not_to_hide;
    push @Errs, "sop $sop has $num_files_left";
  }
  unless(@files_to_hide > 0){
    push @Errs, "sop $sop doesn't delete any files";
  }
#  $back->WriteToEmail("$sop:\ntot_files:$num_files\nto_hide:$to_hide\nnot_to_hide:$not_to_hide\n");
  for my $file_id (@files_to_hide){ $FilesToHide{$file_id} = 1 }
  for my $file_id (@files_not_to_hide){ $FilesNotToHide{$file_id} = 1 }
}
unless(@Errs == 0){
  my $num_errs = @Errs;
  $back->WriteToEmail("Not proceeding because of $num_errs errors:\n");
  for my $i (@Errs){
    $back->WriteToEmail("$i\n");
  }
  $back->Finish("Failed with $num_errs errors");;
  exit;
}
my $num_files_to_hide = keys %FilesToHide;
my $num_files_not_to_hide = keys %FilesNotToHide;
$back->WriteToEmail("There are $num_files_to_hide files to hide, and\n" .
  "There are $num_files_not_to_hide files to not hide\n");
$back->SetActivityStatus("Hiding $num_files_to_hide files");
my $cmd = "HideFilesWithStatusIrrespectiveOfCtp.pl \"$comment\" $notify";
open HIDE, "|$cmd";
for my $file_id (keys %FilesToHide){
  print HIDE "$file_id&<undef>\n";
}
$back->SetActivityStatus("Waiting for hides to finish");
close HIDE;
$back->SetActivityStatus("Building new timepoint");

my $old_tp;
Query('LatestActivityTimepointForActivity')->RunQuery(sub{
  my($row) = @_;
  $old_tp = $row->[0];
}, sub {}, $activity_id);

unless(defined $old_tp){
  $back->WriteToEmail("ERROR: couldn't get current timepoint for activity $activity_id\n");
  $back->Finish("Failed - check report");
  exit;
}
$comment = "New Timepoint after hidind DupSops: \"$comment\"";
Query("CreateActivityTimepoint")->RunQuery(sub {}, sub {},
  $activity_id, $0, $comment, $notify);
my $new_tp;
Query("GetActivityTimepointId")->RunQuery(sub {
  my($row) = @_;
  $new_tp = $row->[0];
}, sub{});

unless(defined $new_tp){
  $back->WriteToEmail("ERROR: Unable to get new activity timepoint id.\n");
  $back->Finish("Failed - check report");
  exit;
}
$back->WriteToEmail("Activity Timepoint Ids: old = $old_tp, new = $new_tp\n");
$back->SetActivityStatus("Adding unhidden files from old tp to new tp");
my $q1 = Query('InsertActivityTimepointFile');
my $num_copied_from_old = 0;
Query('FilesInTimepoint')->RunQuery(sub {
  my($row) = @_;
  my $file_id = $row->[0]; 
  unless(exists $FilesToHide{$file_id}){
    $q1->RunQuery(sub{}, sub{}, $new_tp, $file_id);
    $num_copied_from_old += 1;
  }
}, sub{}, $old_tp);
$back->WriteToEmail("$num_copied_from_old files copied from old_tp ($old_tp) " .
  "to new_tp ($new_tp)\n");

my $elapsed = time - $start;
$back->Finish("Hid $num_files_to_hide files and created new timepoint in $elapsed seconds");;
