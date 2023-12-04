#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::PrivateDispositions;

my $usage = <<EOF;
ProposeUIDchangeEdits.pl <?bkgrnd_id?> <act_id> <description> <notify>
  act_id - id of scan to query
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
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->Daemonize;




my $ActTpId;
my $ActTpIdComment;
my $ActTpIdDate;
my $FilesInTp;
my $SeriesInTp;
my $StudiesInTp;

Query('LatestActivityTimepointsForActivity')->RunQuery(sub{
  my($row) = @_;
  my($activity_id, $activity_created,
    $activity_description, $activity_timepoint_id,
    $timepoint_created, $comment, $creating_user) = @$row;
  $ActTpId = $activity_timepoint_id;
  $ActTpIdComment = $comment;
  $ActTpIdDate = $timepoint_created;
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
my $num_tp_files = keys $FilesInTp;
my $num_tp_series = keys %SeriesInTp;
my $num_tp_studies = keys %StudiesInTp;
print "Found $num_tp_files files, $num_tp_studies studies, $num_tp_series series\n";

# SOP and Series -  Study not required

# element = find the uid dicom tags <(####),(####)>
# vr = find the VR for that tag
# q_value = original uid uid_root
#  edit_description = UID shift for + "user input from op"
# disp = null
# num series - calculate
# p_op = hash_uid
# q_arg1 = new uid?
# q_arg2 = null
# Operation = name for this?
# activity_id = from user input
# act_id = ?
# notify =  "user input from op"
# sep_char = %
for my $file_id(keys %FilesInTp){
  my @myFiles;
    my $f = {
     $q_value => getUID
     $id = getFileID
    };
    push @FileQueries, $q;
}

my $rpt = $background->CreateReport("EditSpreadsheet");
my $num_edit_groups = keys %FilesByEditGroups;
$background->WriteToEmail("$num_edit_groups distinct edit groups found\n");
$rpt->print("file_id,subj," .
  "op,path,val1,val2,val3,Operation,description,notify\n");
my $first_line = 1;

my $rpt3 = $background->CreateReport("Edit UIDs");


foreach my $current_file (@myFiles) {
    $rpt3->print("<(0020,000D)>,UI,$q_value,$description,,$num_series," . #study
    "hash_uid,$q_arg1,$q_arg2,$Operation,$id,$notify\r\n");
}

#check Structs and reassign them too, is that done here??
# should it also make a new Activity for these?
my $end = time;
my $duration = $end - $start_time;
$background->WriteToEmail("finished scan\nduration $duration seconds\n");
$background->Finish;
