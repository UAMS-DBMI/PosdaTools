#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
ConsolidateActivities.pl <?bkgrnd_id?> <activity_id> <notify>
or 
ConsolidateActivities.pl -h

Expects lines STDIN:
<activity_id>

Creates a new timepoint with all of the files in latest timepoint of all the activities

For each file in the new timepoint this script will:
1) Unhide the old file (if hidden)
2) Hide all other files not in the timepoint with the same SOP Instance UID which are not hidden

Then it will produce a report of any duplicate SOPs in the new timepoint.

"Hidden" means a non-null visibility.  
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 2){
  my $num_args = @ARGV;
  my $msg = "Error: wrong number of args ($num_args vs 3)\n" . $usage;
  print $msg;
  die $msg;
}
my($invoc_id, $activity_id, $notify) = @ARGV;

my %OldTpIds;
while(my $line = <STDIN>){
  chomp $line;
  $OldTpIds{$line} = 1;
}
my $num_old_activities = keys %OldTpIds;

print "Going to background to consolidate $num_old_activities\n";

my $bg = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);

$bg->Daemonize;

##
## Build List of files in old activity_timepoint
##

my %VisibleFilesInOld;
my %HiddenFilesInOld;
my %AllFilesInOld;
my %QuestionableFilesInOld;
for my $old_tp_id (keys %OldTpIds){
  my $num_files = 0;
  my $num_visible_files = 0;
  my $num_hidden_files = 0;
  my $num_questionable_files = 0;
  my $num_dups = 0;
  Query("FilesVisibilityByActivity")->RunQuery(sub{
    my($row) = @_;
    my($file_id, $visibility) = @$row;
    if(exists $AllFilesInOld{$file_id}){
      $num_dups += 1;
      return;
    }
    $num_files += 1;
    if(defined $visibility) {
      if($visibility eq "hidden"){
        $HiddenFilesInOld{$file_id} = 1;
        $num_hidden_files += 1;
      } else {
        $QuestionableFilesInOld{$file_id} = 1;
        $num_questionable_files += 1;
      }
    } else {
      $VisibleFilesInOld{$file_id} = 1;
      $num_visible_files += 1;
    }
    $AllFilesInOld{$file_id} = 1;
    $bg->SetActivityStatus(
      "In old $old_tp_id (so far): $num_files, hidden: $num_hidden_files, ".
      "questionable: $num_questionable_files, dups: $num_dups");
  }, sub{}, $old_tp_id);
  $bg->WriteToEmail("Found $num_files in old timepoint $old_tp_id\n" .
    "$num_visible_files were visible\n" .
    "$num_hidden_files were hidden\n" .
    "$num_questionable_files had non null visibility unequal to hidden\n" .
    "$num_dups were duplicates of files already seen\n");
}
my $num_files = keys %AllFilesInOld;
my $num_hidden_files = keys %HiddenFilesInOld;
my $num_visible_files = keys %VisibleFilesInOld;
my $num_questionable_files = keys %QuestionableFilesInOld;
$bg->WriteToEmail("Found $num_files in all timepoints\n" .
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
}, sub{}, $activity_id, $notify, "ConsolidateActivityTimepoints $invoc_id", $notify);
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
  "$num_old_activities old activities to new timepoint " .
  "$new_activity_timepoint_id\n");


##
## Unhide Hidden files in new timepoint
##
my $tot_hidden = keys %HiddenFilesInOld;
$bg->WriteToEmail("Unhiding $tot_hidden hidden files copied\n");
open UNHIDE, "|UnhideFilesWithStatus.pl $notify " .
  "\"Consolidating $num_old_activities to new timepoint $new_activity_timepoint_id\"";
for my $file_id (keys %HiddenFilesInOld){
  print UNHIDE "$file_id&hidden\n";
}
$bg->SetActivityStatus("Waiting for unhide of $tot_hidden files to clear");
close UNHIDE;
$bg->WriteToEmail ("Unhid $tot_hidden files in tp $new_activity_timepoint_id\n");

##
## Get a list of SOP duplicates for all files in new timepoint
##

my %DuplicateSopFiles;
Query("DuplicatesOfSopsInTp")->RunQuery(sub{
  my($row) = @_;
  $DuplicateSopFiles{$row->[0]} = 1;
}, sub {}, $new_activity_timepoint_id, $new_activity_timepoint_id);

##
## Hide all of the Duplicate SOPs outside the timepoint
##
my $num_to_hide = keys %DuplicateSopFiles;
$bg->WriteToEmail("Found $num_to_hide Duplicate SOPS of " .
  "timepoint files outside timepoint\n");

open HIDE, "|HideFilesWithStatusIrrespectiveOfCtp.pl $notify " .
  "\"Hiding files which are dups of files from tp " .
  "$new_activity_timepoint_id\"";
for my $file_id (keys %DuplicateSopFiles){
  print HIDE "$file_id&<undef>\n";
}
$bg->SetActivityStatus("Waiting for hide of $num_to_hide files to clear");
close HIDE;
$bg->WriteToEmail("Hid $num_to_hide files\n");
###########
# here add TimepointDuplicateSop Report
###########
$bg->Finish("Done - copied $num_files files unhid $tot_hidden files " .
  "from $num_old_activities old activities  to new activity_timepoint $new_activity_timepoint_id and hid " .
  "$num_to_hide duplicate SOPs");
