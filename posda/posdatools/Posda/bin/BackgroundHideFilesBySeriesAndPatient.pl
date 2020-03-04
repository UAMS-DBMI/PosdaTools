#!/usr/bin/perl -w
use strict;
use Posda::DB "Query";
use Posda::BackgroundProcess;

my $usage = <<EOF;
usage:
BackgroundHideFilesBySeriesAndPatient.pl <?bkgrnd_id?> <activity_id> <comment> <notify>
  receives list of file_ids on STDIN:
  <patient_id>&<series_instance_uid>

uses following named queries:
  LatestActivityTimepointForActivity
  FilesVisibilityByActivityTimepoint
  FilesVisibilityByPatientSeriesActivityTimepoint
  GetCtpFileRow
  HideFile
  HideFileWithNoCtp
  InsertVisibilityChange
  CreateActivityTimepoint
  GetActivityTimepointId
  InsertActivityTimepointFile

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
my $num_args = @ARGV;
unless($#ARGV == 3) {
 print "##############\n";
 print "Wrong number of args ($num_args vs 4)\n";
 print $usage;
}

my($invoc_id, $act_id, $comment, $notify) = @ARGV;
my @SpecList;
while(my $line = <STDIN>){
  chomp $line;
  my($patient_id, $series_instance_uid) = split /&/, $line;
  push @SpecList, [$patient_id, $series_instance_uid];
}
my $num_specs = @SpecList;
print "$num_specs specifications for Hiding\n" .
  "notify: $notify\n";
my %ToHide;
my $num_errors = 0;
my $num_lines = 0;
spec:
for my $i (@SpecList){
  my($patient_id, $series_instance_uid) = @$i;
  if(exists $ToHide{$series_instance_uid}){
    if($ToHide{$series_instance_uid} ne $patient_id){
      print "#### Error ####\nSeries_instance $series_instance_uid\n" .
        "is specified for multiple patients:\n" .
        "  $ToHide{$series_instance_uid}\n" .
        "  $patient_id\n" .
        "####\n";
      $num_errors += 1;
    } else {
      print "#### Warning ####\nSeries_instance $series_instance_uid\n" .
        "is specified multiple times for same patient:\n" .
        "  $patient_id\n" .
        "####\n";
    }
    next spec;
  }
  $ToHide{$series_instance_uid} = $patient_id;
}
if($num_errors > 0){
  print "Not going to background because of errors\n";
  exit;
}
my $num_series = keys %ToHide;
print "going to background to analyze and do hides\n" .
  "For $num_series series\n";
my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
$back->Daemonize;

##
## Get current activity_timepoint_id
##
$back->SetActivityStatus("Getting current timepoint_id");
my $activity_timepoint_id;
Query("LatestActivityTimepointForActivity")->RunQuery(sub{
  my($row) = @_;
  $activity_timepoint_id = $row->[0];;
}, sub{}, $act_id);
unless(defined($activity_timepoint_id)){
  $back->WriteToEmail("Unable to get latest timepoint " .
    "for activity_id act_id\n" .
    "Can't continue.\n"
  );
  $back->Finish("Failed - couldn't find timepoint");
  exit;
}

##
## Todo: Build List of files in current activity_timepoint
##
my %FilesInCurrent;
$back->SetActivityStatus("Building List of files in current timepoint");
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
  $back->SetActivityStatus(
    "In old (so far): $num_files, hidden: $num_hidden_files, ".
    "questionable: $num_questionable_files");
}, sub{}, $activity_timepoint_id);
$back->WriteToEmail("Found $num_files in old timepoint $activity_timepoint_id\n" .
  "$num_visible_files were visible\n" .
  "$num_hidden_files were hidden\n" .
  "$num_questionable_files had non null visibility unequal to hidden\n");

##
## Todo:  Build @FileList from %ToHide
##
my @FileList;
$back->SetActivityStatus("Building List of Files to Edit");
my $q = Query("FilesVisibilityByPatientSeriesActivityTimepoint");
$num_series = keys %ToHide;
my $num_processing = 0;
$num_files = 0;
$num_visible_files = 0;
$num_hidden_files = 0;
$num_questionable_files = 0;
for my $series(keys %ToHide){
  $num_processing += 1;
  my $patient_id = $ToHide{$series};
  my $files_this_query = 0;
  $back->WriteToEmail("FilesVisibilityByPatientSeriesActivityTimepoint('$patient_id', '$series', $activity_timepoint_id)\n");
  $q->RunQuery(sub{
    my($row) = @_;
    $files_this_query += 1;
    $num_files += 1;
    my($file_id, $visibility) = @$row;
    if(defined $visibility){
      if($visibility eq "hidden"){
        $num_hidden_files += 1;
      } else {
        $num_questionable_files += 1;
      }
    } else {
      $num_visible_files += 1;
      push @FileList, [$file_id, $visibility];
    }
  }, sub{}, $patient_id, $series, $activity_timepoint_id);
#  $back->WriteToEmail("Returned $files_this_query files\n");
  $back->SetActivityStatus("Processed $num_processing of $num_series series. " .
    "Found $num_files files.");
}
$back->WriteToEmail("Processed $num_series series finding $num_files total\n" .
  "$num_visible_files were visible (to be hidden)\n" .
  "$num_hidden_files were already hidden\n" .
  "$num_questionable_files had non-null visiblity not equal hidden.\n");
  

##
## Hide files in @FileList with status
##
my $new_comment = "Hiding files  /BackgroundHideFilesBySeriesAndPatient.pl $invoc_id";
my %FilesHidden;
my $get_ctp = PosdaDB::Queries->GetQueryInstance("GetCtpFileRow");
my $hide = PosdaDB::Queries->GetQueryInstance('HideFile');
my $hide_no_ctp = PosdaDB::Queries->GetQueryInstance('HideFileWithNoCtp');
my $ins_vc = PosdaDB::Queries->GetQueryInstance('InsertVisibilityChange');
my $files_processed = 0;
$num_files = @FileList;
for my $i (@FileList){
  $files_processed += 1;
  my($file_id, $old_visibility) = @$i;
  if($old_visibility eq ""){ $old_visibility = undef }
  if($old_visibility eq "<undef>"){ $old_visibility = undef }
  my $has_ctp = 0;;
  $get_ctp->RunQuery(sub{
    my($row) = @_;
    $has_ctp = 1;
  }, sub {}, $file_id);
  if($has_ctp){
    $hide->RunQuery(sub {}, sub {}, $file_id);
  } else {
    $hide_no_ctp->RunQuery(sub {}, sub {}, $file_id);
  }
  $FilesHidden{$file_id} = 1;
  $ins_vc->RunQuery(sub {}, sub {},
    $file_id, $notify, $old_visibility, 'hidden',
     $new_comment);
  $back->SetActivityStatus("Hid $files_processed of $num_files");
  #$back->WriteToEmail("Hid file $file_id and recorded visibility change\n");
}
my $files_hidden = keys %FilesHidden;
$back->WriteToEmail("Hid $files_hidden files\n");

##
## Todo:  Build New ActivityTimepoint
##

my $new_activity_timepoint_id;
Query("CreateActivityTimepoint")->RunQuery(sub{
  my($row) = @_;
}, sub{}, $act_id, $notify, $new_comment, $notify); 
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
  $back->SetActivityStatus("Of $num_files in old tp, " .
    "$num_copied copied to new, $num_hidden_files hidden");
}
$back->WriteToEmail("Copied $num_copied files from " .
  "timepoint $activity_timepoint_id to timepoint " .
  "$new_activity_timepoint_id\n");

$back->Finish("Done - hid $num_files files created new " .
  "timepoint $new_activity_timepoint_id");
