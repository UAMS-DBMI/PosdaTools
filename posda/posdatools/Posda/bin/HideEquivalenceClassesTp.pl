#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
HideEquivalenceClassesTp.pl <?bkgrd_id?> <activity_id> <notify>
or 
HideEquivalenceClasses.pl -h

Expects line of form:
<image_equivalence_class_uid>&<processing_status>&<review_status>
on STDIN

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
my($invoc_id, $activity_id, $notify) = @ARGV;
my %EquivClasses;
my %dont_change;
while(my $line = <STDIN>){
  chomp $line;
  my($image_equivalence_class_id, $processing_status, $review_status) =
    split(/&/, $line);
  if($review_status eq "<undef>" && $processing_status eq "error") {
    $EquivClasses{$image_equivalence_class_id} = 1;
  }elsif($review_status eq "Bad" && $processing_status eq "Reviewed") {
    $EquivClasses{$image_equivalence_class_id} = 1;
  }elsif($review_status eq "Blank" && $processing_status eq "Reviewed") {
    $EquivClasses{$image_equivalence_class_id} = 1;
  } else {
    $dont_change{$image_equivalence_class_id} = 1;
  }
}
my $num_classes = keys %EquivClasses;
my $num_bad = keys %dont_change;
print "There are $num_classes equivalence classes to hide\n";
print "There are $num_bad equivalence classes which didn't qualify\n";
my $bg = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$bg->Daemonize;

##
## Get current activity_timepoint_id
##
$bg->SetActivityStatus("Getting current timepoint_id");
my $activity_timepoint_id;
Query("LatestActivityTimepointForActivity")->RunQuery(sub{
  my($row) = @_;
  $activity_timepoint_id = $row->[0];;
}, sub{}, $activity_id);
unless(defined($activity_timepoint_id)){
  $bg->WriteToEmail("Unable to get latest timepoint " .
    "for activity_id activity_id\n" .
    "Can't continue.\n"
  );
  $bg->Finish("Failed - couldn't find timepoint");
  exit;
}

##
## Build List of files in current activity_timepoint
##

my %FilesInCurrent;
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
      $num_hidden_files += 1;
    } else {
      $num_questionable_files += 1
    }
  } else {
    $FilesInCurrent{$file_id} = 1;
    $num_visible_files += 1;
  }
  $bg->SetActivityStatus(
    "In old (so far): $num_files, hidden: $num_hidden_files, ".
    "questionable: $num_questionable_files");
}, sub{}, $activity_timepoint_id);
$bg->WriteToEmail("Found $num_files in old timepoint $activity_timepoint_id\n" .
  "$num_visible_files were visible\n" .
  "$num_hidden_files were hidden\n" .
  "$num_questionable_files had non null visibility unequal to hidden\n");


$bg->WriteToEmail("Hiding visible files in $num_classes equivalence classes\n");

##
## Hide Files and populate %FilesHidden 
##

my %FilesHidden;
my $num_classes_processed = 0;
my $num_files_found = 0;
my $num_visible_files_found = 0;
my $num_hidden_files_found = 0;
my $num_questionable_files_found = 0;
my $num_files_found_not_in_tp = 0;
my $q2 = Query('GetVisibleFilesByEquivalenceClass');
for my $i (keys %EquivClasses){
  $num_classes_processed += 1;
  my %FilesToHide;
  $q2->RunQuery(sub {
    my($row) = @_;
    my($file_id, $visibility) = @$row;
    $num_files_found += 1;
    if(exists $FilesInCurrent{$file_id}){
      if(defined $visibility){
        if($visibility eq "hidden"){
          $num_hidden_files_found += 1;
        } else {
          $num_questionable_files_found += 1;
        }
      } else {
        $num_visible_files_found += 1;
        $FilesToHide{$file_id} = $visibility;
      }
    } else {
     $num_files_found_not_in_tp += 1;
    }
    $bg->SetActivityStatus("eqc: $num_classes_processed, " .
      "files: $num_files_found, not_in_tp: $num_files_found_not_in_tp, " .
      "hidden: $num_hidden_files_found, " .
      "questionable: $num_questionable_files_found, " .
      "to_hide: $num_visible_files_found");

  }, sub {}, $i);

  my $num_files = keys %FilesToHide;
  $bg->WriteToEmail("$num_files in equivalence class $i to hide\n");
  if($num_files > 0){
    open SUB, "|HideFilesWithStatus.pl $notify \"Hiding image_equivalence_class_id $i\"";
    for my $i (keys %FilesToHide){
      $FilesHidden{$i} = 1;
      print SUB "$i&<undef>\n";
    }
    close SUB;
  }
}
my $num_hidden = keys %FilesHidden;
$bg->WriteToEmail(
  "Processed $num_classes_processed equivalence classes\n" .
  "Found $num_files_found files\n" .
  "Not in Tp: $num_files_found_not_in_tp\n" .
  "Found Hidden: $num_hidden_files_found\n" .
  "Found Questionable: $num_questionable_files_found\n" .
  "Found Visible (to hide): $num_visible_files_found\n" .
  "Hidden: $num_hidden\n"
);

##
## Build new timepoint
##
my $new_activity_timepoint_id;
Query("CreateActivityTimepoint")->RunQuery(sub{
  my($row) = @_;
}, sub{}, $activity_id, $notify, "HideEquivalenceClasses $invoc_id", $notify);
Query("GetActivityTimepointId")->RunQuery(sub{
  my($row) = @_;
  $new_activity_timepoint_id = $row->[0];
},sub{});
my $q1 = Query("InsertActivityTimepointFile");
$num_files = keys %FilesInCurrent;
my $num_processed = 0;
my $num_copied = 0;
$num_hidden_files = 0;
for my $file_id (keys %FilesInCurrent){
  $num_processed += 1;
  if(exists $FilesHidden{$file_id}){
    $num_hidden_files += 1;
  } else {
    $num_copied += 1;
    $q1->RunQuery(sub {}, sub {},
       $new_activity_timepoint_id, $file_id);
  }
  $bg->SetActivityStatus("Of $num_files in old tp, " .
    "$num_copied copied to new, $num_hidden_files hidden");
}
$bg->WriteToEmail("Copied $num_copied files from " .
  "timepoint $activity_timepoint_id to timepoint " .
  "$new_activity_timepoint_id\n");

$bg->Finish("Done - hid $num_hidden_files files created new " .
  "timepoint $new_activity_timepoint_id");
