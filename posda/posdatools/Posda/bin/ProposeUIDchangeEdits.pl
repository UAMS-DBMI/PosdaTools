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

Expects lines on STDIN:
<type>&<<path>>&<<q_value>>&<num_files>&<p_op>&<<q_arg1>>&<<q_arg2>>&<<q_arg3>>

Note:
  The double metaquotes in the line specification are not errors.
  Those fields are to be metaquoted themselves.

Uses the following query:
  NonDicomFileInPosdaByScanPathValue
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
# my $series_instance_uid;
# my $study_instance_uid;
# my $sop;

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
my $num_tp_files = keys %FilesInTp;
my $num_tp_series = keys %SeriesInTp;
my $num_tp_studies = keys %StudiesInTp;
print "Found $num_tp_files files, $num_tp_studies studies, $num_tp_series series\n";


my @myFiles;
for my $file_id (keys %FilesInTp) {
    my $series_instance_uid;
    my $study_instance_uid;
    my $sop;
    Query('GetSeriesAndStudyUID')->RunQuery(sub{
      my($row) = @_;
      my($series_instance_uid, $study_instance_uid, $sop) = @$row;
    }, sub {}, $file_id);
    my $f = {
        series_instance_uid => $series_instance_uid,
        study_instance_uid => $study_instance_uid,
        sop => $sop,
        q_arg1 => "1.3.6.1.4.1.14519.5.2.1.",
    };
    push @myFiles, $f;
}

my $rpt;
$rpt = $background->CreateReport("Edit UIDs");
$rpt->print("element,vr,q_value,edit_description,disp,num_series,p_op,q_arg1,q_arg2,Operation,Operation,activity_id,scan_id,notify,sep_char\n");
foreach my $current_file (@myFiles) {
    if ($include_series_instance_uid == 1){
      $rpt->print("\"<(0020,000E)>\",UI,$current_file->{series_instance_uid},$description,,$num_tp_series,hash_uid,$current_file->{q_arg1},, ProposeEditsTp,$activity_id,1,$notify,%\r\n");
    }
    if ($include_study_instance_uid == 1){
      $rpt->print("\"<(0020,000D)>\",UI,$current_file->{study_instance_uid},$description,,$num_tp_series,hash_uid,$current_file->{q_arg1},, ProposeEditsTp,$activity_id,1,$notify,%\r\n");
    }
    if ($include_sop == 1){
      $rpt->print("\"<(0008,0018)>\",UI,$current_file->{sop},$description,,$num_tp_series,hash_uid,$current_file->{q_arg1},, ProposeEditsTp,$activity_id,1,$notify,%\r\n");
    }
}


#check Structs and reassign them too, is that done here??
# should it also make a new Activity for these?
my $end = time;
my $duration = $end - $start_time;
$background->WriteToEmail("finished scan\nduration $duration seconds\n");
$background->Finish;


# element = DICOM tag for relevant uid
# vr = UI
# q_value = original uid
# edit_description = user input
# disp = null
# num series - calculated
# p_op = hash_uid
# q_arg1 = new uid root to use for hashing
# q_arg2 = null
# Operation = ProposeEditsTp
# activity_id = from user input
# scan_id = 1
# notify =  "user input from op"
# sep_char = %
