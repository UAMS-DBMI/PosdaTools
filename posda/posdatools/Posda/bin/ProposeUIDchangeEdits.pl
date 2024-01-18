#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::PrivateDispositions;

my $usage = <<EOF;
ProposeUIDchangeEdits.pl <?bkgrnd_id?> <activity_id> <include_series_instance_uid> <include_study_instance_uid> <include_sop> <notify> <description>
  activity_id - id of scan to query
  description - well, description
  notify - email address for completion notification
  include_series_instance_uid - 1 means change the series uid
  include_study_instance_uid - 1 means change the study uid
  include_sop_instance_uid - 1 means change the sop uid

  Creates a spreadsheet to upload to BackgroundEditTp
  in order to create new UIDs for the specificed tags.
  Used to create new versions of a collection after defacing or other major changes

  WARNING - this does not shift RtStructs

Note:
  The double metaquotes in the line specification are not errors.
  Those fields are to be metaquoted themselves.

Uses the following query:
  LatestActivityTimepointsForActivity
  FileIdsByActivityTimepointId
  GetSeriesAndStudyUID
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

my($invoc_id, $activity_id,$include_series_instance_uid, $include_study_instance_uid, $include_sop, $notify, $description) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->Daemonize;
my $start_time = time;
my $ActTpId;
my $ActTpIdComment;
my $ActTpIdDate;
my %FilesInTp;
my %SeriesInTp;
my %StudiesInTp;
my %SopsInTp;

Query('LatestActivityTimepointsForActivity')->RunQuery(sub{
  my($row) = @_;
  my($activity_id, $activity_created,
    $activity_description, $activity_timepoint_id,
    $timepoint_created, $comment, $creating_user) = @$row;
  $ActTpId = $activity_timepoint_id;
  $ActTpIdComment = $comment;
  $ActTpIdDate = $timepoint_created;
}, sub {}, $activity_id);
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
my $q2 = Query('GetSeriesAndStudyUID');
for my $file_id (keys %FilesInTp) {
      $q2->RunQuery(sub {
        my($row) = @_;
        $SopsInTp{$row->[2]} = 1;
      }, sub {}, $file_id);
}
my $num_tp_files = keys %FilesInTp;
my $num_tp_series = keys %SeriesInTp;
my $num_tp_studies = keys %StudiesInTp;
my $num_tp_sops = keys %SopsInTp;
print "Found $num_tp_files files, $num_tp_sops sops, $num_tp_studies studies, $num_tp_series series\n";
my $uid_root = "!1.3.6.1.4.1.14519.5.2.1.";

my $rpt;
$rpt = $background->CreateReport("Edit UIDs");
$rpt->print("series_instance_uid,op,tag,val1,val2,Operation,edit_description,notify,activity_id\n");

my $i = 0;
foreach my $current_series (keys %SeriesInTp) {
  if ($i == 0){
    $rpt->print("$current_series,,,,,BackgroundEditTp,From Shift UIDs, $notify, $activity_id\n");
  }else{
    $rpt->print("$current_series,,,,,,,\n"); #$num_tp_files is not the correct number, calculate actual files per series
  }
  $i++;
}

if ($include_study_instance_uid == 1){
  $rpt->print(",hash_unhashed_uid,\"<(0020,000D)>\",$uid_root,,,,,,\n");
}
if ($include_sop == 1){
    $rpt->print(",hash_unhashed_uid,\"<(0008,0018)>\",$uid_root,,,,,,\n");
}

if ($include_series_instance_uid == 1){
    $rpt->print(",hash_unhashed_uid,\"<(0020,000E)>\",$uid_root,,,,,,\n");
}
# check Structs and reassign them too, is that done here??
# should it also make a new Activity for these?
my $end = time;
my $duration = $end - $start_time;
$background->WriteToEmail("finished scan\nduration $duration seconds\n");
$background->Finish;
