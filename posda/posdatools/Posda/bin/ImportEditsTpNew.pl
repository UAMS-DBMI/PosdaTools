#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::EditStateChange;
use Posda::File::Import 'insert_file';
use JSON;

my $usage = <<EOF;
ImportEditsTp.pl <?bkgrnd_id?> <activity_id> <sub_invoc_id> <notify>
or
ImportEditsTp.pl -h

This is the new visibility agnostic version of this script.
It still doesn't expect lines on STDIN:

It does the following:

First it does the following "state" processing:
It will only start if the edit_compare_disposition has a state of
"Comparisons Complete". If not, it will finish with an error.

If the state was Comparsions Complete, it will have been changed (atomically)
to "Importing Edited Files", and the import will proceed as follows:

  1) It invokes GetCountOfEditsBySubprocessInvocationId to get a count
    of the number of edits in DicomEditCompare for this <sub_invoc_id>
    this is used only for reporting progress
  2) It invokes GetDicomEditCompareDigestsAndToPath to get the following things
    from DicomEditCompare for this <sub_invoc_id>:
    - from_file_digest
    - to_file_digest
    - to_file_path
    Each row is processed as it is read as follows:
     1) Use the query GetFileIdByDigest to get the file_id of the from_file
      if none is found, die. This should not occur.
     2) Use the query GetFileIdByDigest to get the file_id of the to_file.
      if none is found, then import the file using the posda_import_api
      and get its id.  In either case, after the file is imported or
      its id is ascertained, if the file exists in the temp dir, unlink it.
     3) While this is going on, update the activity task status with
      "Importing Edited file n of m (<n_sec> elapsed)"
      And use the file_ids to build the following tables
      \$FileConversions{\$from_file_id} = \$to_file_id,
      \$InverseConversionsInNewTimepoint{\$to_file_id} = \$from_file_id;
     4) When Finished this, advance state to "Files Imported";
  3) When this is done, build the new activity_timepoint:
    While this is going on, the Activity Task Status will have the follow
    format: 
    "NewTp (<old> => <new>) (c: <num_copied> n: <num_new> t: <total> of <count>"
    Then get the latest activity_timepoint_id of the activity as
    old_activity_timepoint_id 
    Then do all of the following:
     1) Create a new activity_timepoint and get its id
        Advance state to "Building New Activity Timepoint"
     2) For every file_id in the old timepoint:
      if (exists \$FileConversions{\$file_id}) {
       - insert a row in activity_timepoint_file for the new_timepoint and
        the new_file
       - delete the row in %InverseConversionsInNewTimepoint for the new file
      } else {
       - insert a row in activity_timepoint_file for the new_activity_time 
        and the file_id in the old timepoint
      }
    When this is done, there should be no entries in 
    InverseConversionsInNewTimepoint (if there are, then their from_files 
    weren't in the old timepoint)
    So, if there are entries in %InverseConversionsInNewTimepoint:
      - Prepare an error report spreadsheet for all the files that were there 
       with fild_ids of original files
      - Write an explantory error to email
    If there are no entries in %InverseConversionsInNewTimepoint:
      -Write a summary message to email
  Finish background.  The final activity_task status should be:
  "Done (<old> => <new>) (c: <num_copied>,n: <num_added>, e: <num_errors>, t: <num_sec>)"
  
After finishing the background.  Advance the state to "New Timepoint Created"
Then get a new subprocess_invocation_id, and fork into a new background process
which will do the following:
  1) Advance the state to "Deleting Temp Directory"
  2) Use rmtree to delete the temp directories
  3) Advance state to "Import Complete - to files deleted"
  4) Write a summary email

EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 3){
  my $num_args = $#ARGV;
  print "Error: wrong number of args ($num_args) vs 2:\n";
  print "$usage\n";
  die "$usage\n";
}

my ($invoc_id, $activity_id, $subproc_invoc_id, $notify) = @ARGV;
my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
print "Entering Background\n";
$background->Daemonize;

#\$FileConversions{\$from_file_id} = \$to_file_id,
#\$InverseConversionsInNewTimepoint{\$to_file_id} = \$from_file_id;
my %FileConversions;
my %InverseConversionsInNewTimepoint;
my($code, $content) = Posda::EditStateChange::Trans(
  $subproc_invoc_id, "Comparisons Complete", "Importing Files");
unless($code == 200){
  $background->WriteToEmail("Failed to lock Edits:\n");
  $background->WriteToEmail("Code: $code\n");
  if($content eq ""){
    $background->WriteToEmail("No Json");
  } else {
    my $stat = decode_json($content);
    for my $i (keys %$stat){
      $background->WriteToEmail("$i - $stat->{$i}\n");
    }
  }
  $background->Finish("Error - wrong state");
  exit;
}
#  1) It invokes GetCountOfEditsBySubprocessInvocationId to get a count
#    of the number of edits in DicomEditCompare for this <sub_invoc_id>
#    this is used only for reporting progress
my $NumEdits;
my $Start = time;
Query('GetCountOfEditsBySubprocessInvocationId')->RunQuery(sub{
  my($row) = @_;
  $NumEdits = $row->[0];
}, sub{}, $subproc_invoc_id);
unless($NumEdits > 0){
  $background->WriteToEmail(
    "No edits for subprocess_invocation_id $subproc_invoc_id\n");
  $background->Finish("Nothing to import");
  exit;
}
############################################################
# Create import_event
Query('InsertEditImportEvent')->RunQuery(
  sub{}, sub{}, "ImportEditsTp.pl", "New files in edits $subproc_invoc_id");
####GetImportEventId
my $IeId;
Query('GetImportEventId')->RunQuery(sub{
  my($row) = @_;
    $IeId = $row->[0];
  }, sub {});

#  2) It invokes GetDicomEditCompareDigestsAndToPath to get the following things
#    from DicomEditCompare for this <sub_invoc_id>:
#    - from_file_digest
#    - to_file_digest
#    - to_file_path
my $get_id = Query('GetFileIdByDigest');
my $f_cnt = 0;
my $num_new_found = 0;
my $num_new_imported = 0;
Query('GetDicomEditCompareDigestsAndToPath')->RunQuery(sub{
  my($row) = @_;
  my($ff_dig, $tf_dig, $tf_path) = @$row;
  my($ff_id, $tf_id);
  $f_cnt += 1;
#     3) While this is going on, update the activity task status with
#      "Importing Edited file n of m ($n_sec elapsed)"
#    Each row is processed as it is read as follows:
#     1) Use the query GetFileIdByDigest to get the file_id of the from_file
#      if none is found, die. This should not occur.
  my $elapsed = time - $Start;
  $background->SetActivityStatus(
   "Importing Edited file $f_cnt of $NumEdits ($elapsed elapsed)"
  );
  $get_id->RunQuery(sub{
    my($r1) = @_;
    $ff_id = $r1->[0];
  }, sub{}, $ff_dig);
  unless(defined $ff_id) {
    die "Error: from file_id not defined for digest $ff_dig";
  }
#     2) Use the query GetFileIdByDigest to get the file_id of the to_file.
  $get_id->RunQuery(sub{
    my($r1) = @_;
    $tf_id = $r1->[0];
  }, sub{}, $tf_dig);
#      if none is found, then import the file using the posda_import_api
#      and get its id.  In either case, after the file is imported or
#      its id is ascertained, if the file exists in the temp dir, unlink it.
  if(defined($tf_id) && -f $tf_path){
    unlink $tf_path;
  }
  if(defined $tf_id) {
    $num_new_found += 1;
  } else {
    unless(-f $tf_path) {
      die "Neither file_id nor path exists for to_file $tf_dig";
    }
    my $resp = Posda::File::Import::insert_file($tf_path, "", $IeId);
    if ($resp->is_error){
      die $resp->error;
    }else{
      $num_new_imported += 1;
      $tf_id =  $resp->file_id;
    }
    unlink $tf_path;
  }
#      And use the file_ids to build the following tables
#      \$FileConversions{\$from_file_id} = \$to_file_id,
#      \$InverseConversionsInNewTimepoint{\$to_file_id} = \$from_file_id;
  $FileConversions{$ff_id} = $tf_id;
  $InverseConversionsInNewTimepoint{$tf_id} = $ff_id;
}, sub{}, $subproc_invoc_id);
#     4) When Finished this, advance state to "Files Imported";
my $elapsed = time - $Start;
$background->WriteToEmail("Finished Import:\n" .
  "New Imports: $num_new_imported\n" .
  "Num Found: $num_new_found\n" .
  "Elapsed: $elapsed\n");

($code, $content) = Posda::EditStateChange::Trans(
$subproc_invoc_id, "Importing Files", "Files Imported");
unless($code == 200){
  $background->WriteToEmail(
    "Failed to Advance state \"Importing Files\" => \"Files Imported\":\n");
  $background->WriteToEmail("Code: $code\n");
  if($content eq ""){
    $background->WriteToEmail("No Json");
  } else {
    my $stat = decode_json($content);
    for my $i (keys %$stat){
      $background->WriteToEmail("$i - $stat->{$i}\n");
    }
  }
  $background->Finish("Error - wrong state");
  exit;
}

#  3) When this is done, build the new activity_timepoint:
#    While this is going on, the Activity Task Status will have the follow
#    format: 
#  "NewTp (<old> => <new>) (c: <num_copied> n: <num_new> u: <total> of <count>"
#    Then get the latest activity_timepoint_id of the activity as
#    old_activity_timepoint_id 
#    Then do all of the following:
#     1) Create a new activity_timepoint and get its id
#        Advance state to "Building New Activity Timepoint"
#     2) For every file_id in the old timepoint:
#      if (exists $FileConversions{$file_id}) {
#       - insert a row in activity_timepoint_file for the new_timepoint and
#        the new_file
#       - insert a row in activity_timepoint_file for the new_activity_time 
#        and the file_id in the old timepoint
#      }
($code, $content) = Posda::EditStateChange::Trans(
  $subproc_invoc_id, "Files Imported", "Building Timepoint");
unless($code == 200){
  $background->WriteToEmail(
    "Failed to Advance state \"Files Imported\" => \"Building Timepoint\":\n");
  $background->WriteToEmail("Code: $code\n");
  if($content eq ""){
    $background->WriteToEmail("No Json");
  } else {
    my $stat = decode_json($content);
    for my $i (keys %$stat){
      $background->WriteToEmail("$i - $stat->{$i}\n");
    }
  }
  $background->Finish("Error - wrong state");
  exit;
}
my $OldActivityTimepoint;
Query('LatestActivityTimepointForActivity')->RunQuery(sub{
  my($row) = @_;
  $OldActivityTimepoint = $row->[0];
}, sub {}, $activity_id);
unless(defined $OldActivityTimepoint){
  die "No latest timepoint found for activity $activity_id";
}
my $atp_com = "New Timepoint for ImportedEdits $subproc_invoc_id";
Query("CreateActivityTimepoint")->RunQuery(sub {}, sub {},
  $activity_id, $0, $atp_com, $notify);
my $NewTp;
Query("GetActivityTimepointId")->RunQuery(sub {
  my($row) = @_;
  $NewTp = $row->[0];
}, sub{});
unless(defined $NewTp){
  $background->WriteToEmail(
    "ERROR: Unable to get new activity timepoint id.\n");
  $background->Finish("Failed - check report");
  exit;
}
$background->WriteToEmail("Building timepoint: " .
  "($OldActivityTimepoint -> $NewTp)\n");
my $tt_text = "($OldActivityTimepoint -> $NewTp)";
my $n_c = 0;
my $n_n = 0;
my $n_u = keys %InverseConversionsInNewTimepoint;
my $n_t = $NumEdits;
my $ins_atp = Query("InsertActivityTimepointFile");
Query('FilesInTimepoint')->RunQuery(sub {
  my($row) = @_;
  my $file_id = $row->[0];
  my $ntp_fid;
  if(exists $FileConversions{$file_id}){
    $ntp_fid = $FileConversions{$file_id};
    if(exists($InverseConversionsInNewTimepoint{$ntp_fid})){
      delete $InverseConversionsInNewTimepoint{$ntp_fid};
    }
    $n_n += 1
  } else {
    $n_c += 1;
    $ntp_fid = $file_id;
  }
  $ins_atp->RunQuery(sub{},sub{}, $NewTp, $ntp_fid);
  $n_u = keys %InverseConversionsInNewTimepoint;
  my $elapsed = time - $Start;
  $background->SetActivityStatus(
    "NewTp $tt_text (c: $n_c n: $n_n u: $n_u of $n_t) ($elapsed elapsed)");
}, sub{}, $OldActivityTimepoint);
($code, $content) = Posda::EditStateChange::Trans(
  $subproc_invoc_id, "Building Timepoint", "Timepoint Created");
unless($code == 200){
  $background->WriteToEmail(
   "Failed to Advance state \"Building Timepoint\" => \"Timepoint Created\"\n");
  $background->WriteToEmail("Code: $code\n");
  if($content eq ""){
    $background->WriteToEmail("No Json");
  } else {
    my $stat = decode_json($content);
    for my $i (keys %$stat){
      $background->WriteToEmail("$i - $stat->{$i}\n");
    }
  }
  $background->Finish("Error - wrong state");
  exit;
}
$background->WriteToEmail(
  "Finished Import\n" .
  "NewTp $tt_text (c: $n_c n: $n_n u: $n_u of $n_t)\n"
);
if($n_u > 0){
  $background->WriteToEmail(
    "$n_u files are to_files not converted from from_files\n");
  my $rpt = $background->CreateReport("Orphan To Files");
  $rpt->print("file_id\n");
  for my $k (keys %InverseConversionsInNewTimepoint){
    $rpt->print("$k\n");
  }
}

$elapsed = time - $Start;
$background->Finish(
  "Done $tt_text (c: $n_c n: $n_n u: $n_u of $n_t) ($elapsed elapsed)\n");
