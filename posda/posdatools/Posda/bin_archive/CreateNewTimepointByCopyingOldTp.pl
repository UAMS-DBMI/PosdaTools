#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
CreateNewTimepointByCopyingOldTp.pl <?bkgrd_id?> <activity_id> <old_tp_id> <notify>
or 
CreateNewTimepointByCopyingOldTp.pl -h

Expects nothing on STDIN

Creates a new timepoint with all of the files in the old timepoint

For each file in the new timepoint this script will:
1) Unhide the old file
2) Hide all other files with the same SOP Instance UID which are not hidden

"Hidden" means a non-null visibility.  
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
my($invoc_id, $activity_id, $old_tp_id, $notify) = @ARGV;

print "Everything in background\n";

my $bg = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);

$bg->Daemonize;

##
## Build List of files in old activity_timepoint
##

my %VisibleFilesInOld;
my %HiddenFilesInOld;
my %AllFilesInOld;
my $num_files = 0;
my $num_visible_files = 0;
my $num_hidden_files = 0;
my $num_questionable_files = 0;
Query("FilesVisibilityByActivityTimepoint")->RunQuery(sub{
  my($row) = @_;
  my($file_id, $visibility) = @$row;
  $num_files += 1;
  if(defined $visibility) {
    if($visibility eq "hidden"){
      $HiddenFilesInOld{$file_id} = 1;
      $num_hidden_files += 1;
    } else {
      $HiddenFilesInOld{$file_id} = 1;
      $num_questionable_files += 1;
    }
  } else {
    $VisibleFilesInOld{$file_id} = 1;
    $num_visible_files += 1;
  }
  $AllFilesInOld{$file_id} = 1;
  $bg->SetActivityStatus(
    "In old (so far): $num_files, hidden: $num_hidden_files, ".
    "questionable: $num_questionable_files");
}, sub{}, $old_tp_id);
$bg->WriteToEmail("Found $num_files in old timepoint $old_tp_id\n" .
  "$num_visible_files were visible\n" .
  "$num_hidden_files were hidden\n" .
  "$num_questionable_files had non null visibility unequal to hidden\n");


$bg->WriteToEmail("Adding $num_files files to new timepoint\n");

##
## Create new activity timepoint
##

my $new_activity_timepoint_id;
Query("CreateActivityTimepoint")->RunQuery(sub{
  my($row) = @_;
}, sub{}, $activity_id, $notify, "HideEquivalenceClasses $invoc_id", $notify);
Query("GetActivityTimepointId")->RunQuery(sub{
  my($row) = @_;
  $new_activity_timepoint_id = $row->[0];
},sub{});

##
## Copy files to new from old
##

my $q1 = Query("InsertActivityTimepointFile");
$num_files = keys %AllFilesInOld;
my $num_copied = 0;
$num_hidden_files = 0;
for my $file_id (keys %AllFilesInOld){
  $num_copied += 1;
  $q1->RunQuery(sub {}, sub {}, $new_activity_timepoint_id, $file_id);
  $bg->SetActivityStatus("Of $num_files in old tp, " .
    "$num_copied copied to new");
}
$bg->WriteToEmail("Copied $num_copied files from " .
  "timepoint $old_tp_id to timepoint " .
  "$new_activity_timepoint_id\n");


##
## Unhide Hidden files in new timepoint
##
my $tot_hidden = keys %HiddenFilesInOld;
$bg->WriteToEmail("Unhiding $tot_hidden hidden files copied\n");
open UNHIDE, "|UnhideFilesWithStatus.pl $notify " .
  "\"Copying from tp $old_tp_id to tp $new_activity_timepoint_id\"";
for my $file_id (keys %HiddenFilesInOld){
  print UNHIDE "$file_id&hidden\n";
}
$bg->SetActivityStatus("Waiting for unhide of $tot_hidden files to clear");
close UNHIDE;
$bg->WriteToEmail ("Unhid $tot_hidden files in tp $new_activity_timepoint_id\n");

###
### Get a list of SOP duplicates for all files in new timepoint
###

#my %DuplicateSopFiles;
#Query("DuplicatesOfSopsInTp")->RunQuery(sub{
#  my($row) = @_;
#  $DuplicateSopFiles{$row->[0]} = 1;
#}, sub {}, $new_activity_timepoint_id, $new_activity_timepoint_id);

###
### Hide all of the Duplicate SOPs outside the timepoint
###
#my $num_to_hide = keys %DuplicateSopFiles;

#open HIDE, "|HideFilesWithStatusIrrespectiveOfCtp.pl $notify " .
#  "\"Hiding files which are dups of files from tp " .
#  "$new_activity_timepoint_id\"";
#for my $file_id (keys %DuplicateSopFiles){
#  print HIDE "$file_id&<undef>\n";
#}
#$bg->SetActivityStatus("Waiting for hide of $num_to_hide files to clear");
#close HIDE;
#$bg->WriteToEmail("Hid $num_to_hide files\n");

$bg->Finish("Done - copied $num_files files unhid $tot_hidden files " .
  "from tp $old_tp_id to tp $new_activity_timepoint_id");
