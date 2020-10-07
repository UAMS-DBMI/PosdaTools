#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::DB qw(Query);
use Posda::BackgroundProcess;
use Posda::ActivityInfo;
use Posda::UUID;
use Posda::NBIASubmit;
use File::Basename;
use File::Path 'make_path';

our $ug = Data::UUID->new;
sub get_uuid {
  return lc $ug->create_str();
}
my $usage = <<EOF;
BackgroundPrivateDispositionsTp.pl <?bkgrnd_id?> <activity_id> <uid_root> <offset> <notify> <skip_dispositions>
  UID's not hashed if they begin with <uid_root>
  date's always offset with offset (days)
  email sent to <notify>
  skip private dispositions if <skip_dispositions> is set to 1

Expects nothing on <STDIN>

Constructs a destination file name as follows:
  <generated_unique_dir>/<patient_id>/<study_uid>/<series_uid>/<modality>_sop_inst_uid.dcm

Actually invokes ApplyPrivateDispositionUnconditionalDate.pl to do the edits
EOF





if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
my $script_start_time = time;
unless($#ARGV == 5){
  print "$usage\n";
  die "######################## subprocess failed to start:\n" .
      "$usage\n" .
      "#####################################################\n";
}
my($invoc_id, $act_id, $uid_root, $offset, $notify, $skip_dispositions) = @ARGV;

unless(defined $skip_dispositions) { $skip_dispositions = 0}
if($skip_dispositions == "") { $skip_dispositions = 0}

my %Patients;
my %Studies;
my %Series;
my %Sops;
my %Files;
my %DupSops;
my %Collections;
my %Sites;
Query("FilesForDispositionsByActivity")->RunQuery(sub{
  my($row) = @_;
  my($file_id, $collection, $site,
    $patient_id, $study_instance_uid, $series_instance_uid,
    $modality, $sop_instance_uid, $path) = @$row;
    $Files{$file_id} = {
      collection => $collection,
      site => $site,
      patient => $patient_id,
      study => $study_instance_uid,
      series => $series_instance_uid,
      sop => $sop_instance_uid,
      modality => $modality,
      path => $path,
    };
    if(defined $collection){
      $Patients{$patient_id}->{collection}->{$collection} = 1;
    }
    if(defined $site){
      $Patients{$patient_id}->{sites}->{$site} = 1;
    }
    $Patients{$patient_id}->{studies}->{$study_instance_uid}->{$series_instance_uid}->{$modality}->{$sop_instance_uid} =  $file_id;
    $Series{$series_instance_uid}->{$study_instance_uid} = 1;
    $Studies{$study_instance_uid}->{$patient_id} = 1;
    if(exists($Sops{$sop_instance_uid})){
      $DupSops{$sop_instance_uid}->{$file_id} = 1;
      $DupSops{$sop_instance_uid}->{$Sops{$sop_instance_uid}} = 1;
    } else {
      $Sops{$sop_instance_uid}->{$file_id} = 1;
    }
}, sub{}, $act_id);
my $num_reports = 0;

## Basic sanity checks:

# Check DupSops, report and exit
  my $num_dups = keys %DupSops;
  if($num_dups > 0){
    print "$num_dups Duplicate Sops found in timepoint\n";
    $num_reports += 1;
  }
# Check Patient in no collection or multiple collections, report
  for my $pat (keys %Patients){
    if(
      exists $Patients{$pat}->{collection} and 
      ref($Patients{$pat}->{collection}) eq "HASH"
    ){
      my $num_col = keys %{$Patients{$pat}->{collection}};
      unless($num_col == 1){
        print "Patient $pat is in $num_col collections\n";
      }
    } else {
      print "Patient $pat is in no collection\n";
      $num_reports += 1;
    }
  }
# Check Patient in no site or multiple sites, report
  for my $pat (keys %Patients){
    if(
      exists $Patients{$pat}->{sites} and 
      ref($Patients{$pat}->{sites}) eq "HASH"
    ){
      my $num_sites = keys %{$Patients{$pat}->{sites}};
      unless($num_sites == 1){
        print "Patient $pat is in $num_sites sites\n";
      }
    } else {
      print "Patient $pat is in no sites\n";
      $num_reports += 1;
    }
  }
# Check Study in multiple patients, report
# Check Series in multiple studies, report
# Exit if any errors reported above
if($num_reports > 0){
  print "Exiting for $num_reports errors\n";
  exit;
}

print "Passed basic checks\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);

print "Going to background for further processing\n";
$background->Daemonize;



$background->SetActivityStatus("Checking and Marking Tags");
my $q1 = PosdaDB::Queries->GetQueryInstance(
  "PrivateTagsWhichArentMarked");
my $q2 = PosdaDB::Queries->GetQueryInstance(
  "DoAnyPrivateTagsNeedDispositions");
my $error = 0;

my @new_tags;
$q1->RunQuery(sub{
  my($row) = @_;
  my($id, $ele_sig, $vr, $name, $disp) = @$row;
  push(@new_tags, [$id, $ele_sig, $vr, $name, $disp]);
}, sub {});
if(@new_tags > 0){
  my $num_new_tags = @new_tags;
  $background->WriteToEmail("Error: there are $num_new_tags new private tags to be processed (for name)\n");
  open PIPE, "UpdatePrivateElementNames.pl|";
  $background->WriteToEmail("Running UpdatePrivateElementNames.pl:\n");
  while(my $line = <PIPE>){
    chomp $line;
    $background->WriteToEmail(">>>>$line\n");
  }
  my $now = `date`;
  chomp $now;
  $background->WriteToEmail("$now: finished UpdatePrivateElementNames.pl:\n");
}
$background->SetActivityStatus("Checking Missing Dispositions");

my @dispositions_needed;
$q2->RunQuery(sub {
  my($row) = @_;
  my($id, $ele_sig, $vr, $name) = @$row;
  push @dispositions_needed, [$id, $ele_sig, $vr, $name];
}, sub {});
my $num_needing_disp = @dispositions_needed;

if($num_needing_disp > 0){
  $background->WriteToEmail("\n############\n" .
    "$num_needing_disp private tags need dispositions\n");
  my %SeriesNeedingDispositions;
  my $c_series = Query('DoesSeriesHaveAnyTagsWithNoDispositions');
  for my $series (keys %Series){
    $c_series->RunQuery(sub{
      my($row) = @_;
      $SeriesNeedingDispositions{$row->[0]} = 1;
    }, sub {}, $series);
  }
  my $num_series_missing_dispositions = keys %SeriesNeedingDispositions;
  if($num_series_missing_dispositions > 0){
    $background->WriteToEmail("including $num_series_missing_dispositions" .
      " series in this timepoint\n############\n");
    $background->Finish("$num_series_missing_dispositions missing dispositions");
    exit;
  } else {
    $background->WriteToEmail("$num_needing_disp private tags need dispositions\n");
  }
}

####
#### Visual Review Checking
####
$background->SetActivityStatus("Checking Visual Review");

### Get visual review for this activity
my $visual_review_id;
my $num_visual_reviews = 0;
Query("GetVisualReviewByActivityIdLatest")->RunQuery(sub{
  my($row) = @_;
  $visual_review_id = $row->[0];
  $num_visual_reviews += 1;
}, sub{}, $act_id);

unless(defined $visual_review_id){
  $background->WriteToEmail("Internal Error: visual review id undefined\n");
  $background->Finish("Error: No visual review");
  exit;
}
my $num_sops_not_reviewed;
Query("VerifyAllSopsInTpAreInVR")->RunQuery(sub {
  $num_sops_not_reviewed += 1;
}, sub {}, $act_id, $visual_review_id);
if($num_sops_not_reviewed > 0){
  $background->WriteToEmail("There are $num_sops_not_reviewed SOPs in the activity " .
    "which were not reviewed\n");
  $background->Finish("There are $num_sops_not_reviewed SOPs in the activity " .
    "which were not reviewed");
  exit;
}
my $unfinished_reviews = 0;
Query("SopsInTimepointWithUnfinishedVR")->RunQuery(sub {
  $unfinished_reviews += 1;
}, sub{}, $act_id, $visual_review_id);
if ($unfinished_reviews > 0){
  $background->WriteToEmail("There are $unfinished_reviews SOPs in the activity " .
    "have review status other than Good or Bad\n");
  $background->Finish("There are $unfinished_reviews SOPs in the activity " .
    "have review status other than Good or Bad");
  exit;
}
my $bad_status = 0;
Query("SopsInTimepointWithBadVR")->RunQuery(sub {
  $bad_status += 1;
}, sub{}, $act_id, $visual_review_id);
if ($bad_status > 0){
  $background->WriteToEmail("There are $bad_status SOPs in the activity " .
    "have review status of Bad\n");
  $background->Finish("There are $bad_status SOPs in the activity " .
    "have review status of Bad");
  exit;
}
####
#### End - Visual Review Checking
####



$background->SetActivityStatus("Building Commands");
my $num_files = keys %Files;
$background->WriteToEmail("Found list of $num_files files to send\n");

# Abort if we found nothing to do
if($num_files <= 0) {
  $background->Finish("No files found");
  exit;
}

my $date = `date`;
chomp $date;

#############################
## Compute the Destination Dir
#
my $sub_dir = get_uuid();

my $BaseDir = $ENV{NBIA_STORAGE_ROOT}
  or die "NBIA_STORAGE_ROOT env var is undefined! cannot continue";

unless(-d $BaseDir){
  print "Error: Base dir ($BaseDir) isn't a directory\n";
}

$background->WriteToEmail("$date\nStarting ApplyPrivateDispositions\n");

if($skip_dispositions) {
  $background->WriteToEmail("$date\nPrivate Dispositions will be skipped\n");
}
#######################################################################
### Body of script

#    $Files{$file_id} = {
#      collection => $collection,
#      site => $site,
#      patient => $patient_id,
#      study => $study_instance_uid,
#      series => $series_instance_uid,
#      sop => $sop_instance_uid,
#      modality => $modality,
#      path => $path,
#    };
#

$background->SetActivityStatus("Building Commands");
my @cmds;
for my $file_id (keys %Files){
  my $sop_instance_uid = $Files{$file_id}->{sop};
  my $path = $Files{$file_id}->{path};
  my $f_filename = Posda::NBIASubmit::GenerateFilename($sop_instance_uid);
  my $full_filename = "$BaseDir/$f_filename";
  my $dirname = dirname($full_filename);
  make_path($dirname);

  my $cmd = qq{ApplyPrivateDispositionUnconditionalDate2.pl $invoc_id } .
            qq{$file_id $path "$full_filename" $uid_root "$offset" "$skip_dispositions"};

  push @cmds, $cmd;
}
my $num_commands = @cmds;
$background->WriteToEmail(`date`);
$background->WriteToEmail("about to execute $num_commands in 5 subshells\n");
$background->SetActivityStatus("Queueing Commands (in parallel)");
open SCRIPT1, "|/bin/sh";
open SCRIPT2, "|/bin/sh";
open SCRIPT3, "|/bin/sh";
open SCRIPT4, "|/bin/sh";
open SCRIPT5, "|/bin/sh";
open SCRIPT6, "|/bin/sh";
open SCRIPT7, "|/bin/sh";
open SCRIPT8, "|/bin/sh";
open SCRIPT9, "|/bin/sh";
open SCRIPT0, "|/bin/sh";
command:
while(1){
  my $cmd = shift @cmds;
  unless(defined $cmd){ last command }
  print SCRIPT1 "$cmd\n";

  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
  print SCRIPT2 "$cmd\n";

  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
  print SCRIPT3 "$cmd\n";

  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
  print SCRIPT4 "$cmd\n";

  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
  print SCRIPT5 "$cmd\n";

  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
  print SCRIPT6 "$cmd\n";

  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
  print SCRIPT7 "$cmd\n";

  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
  print SCRIPT8 "$cmd\n";

  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
  print SCRIPT9 "$cmd\n";

  $cmd = shift @cmds;
  unless(defined $cmd){ last command }
  print SCRIPT0 "$cmd\n";

}
$background->SetActivityStatus("Waiting For commands to clear");
$background->WriteToEmail(`date`);
$background->WriteToEmail("All commands queued\n");
close SCRIPT1;
close SCRIPT2;
close SCRIPT3;
close SCRIPT4;
close SCRIPT5;
close SCRIPT6;
close SCRIPT7;
close SCRIPT8;
close SCRIPT9;
close SCRIPT0;
$background->WriteToEmail(`date`);
$background->WriteToEmail("All subshells complete\n");

### Body of script
###################################################################
my $end = time;
my $duration = $end - $script_start_time;
$background->WriteToEmail( "finished conversion in $duration seconds\n");
$background->WriteToEmail("<a target=\"_blank\" onclick=\"javascript:event.target.port=80\" href=\"/papi/v1/send_to_public_status/report/$invoc_id?pretty=1\">Public Copy Status Report</a>\n");
$background->Finish("Done");
