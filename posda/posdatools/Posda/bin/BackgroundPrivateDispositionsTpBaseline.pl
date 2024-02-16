#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::BackgroundProcess;
use Posda::ActivityInfo;
use Posda::UUID;
use Posda::NBIASubmit;
use File::Basename;
use File::Path 'make_path';
use Posda::DB 'Query';

our $ug = Data::UUID->new;
sub get_uuid {
  return lc $ug->create_str();
}
my $usage = <<EOF;
BackgroundPrivateDispositionsTpBaseline.pl <?bkgrnd_id?> <activity_id> <notify> <skip_dispositions> <upd_nbia> <dir>
  activity_id - id of the activity
  email sent to <notify>
  skip private dispositions if <skip_dispositions> is set to 1
  if <upd_nbia> use nbia file conventions and nbia-api to update nbia
  else <dir> contains name of download subdirectory (no spaces or special characters)

<uid_root> and <offset> are obtained from patient_mapping table
  UID's not hashed if they begin with <uid_root>
  date's always offset with offset (days)

Expects nothing on <STDIN>

Constructs a destination file name as follows:
  <unique_generated_dir>/<patient_id>/<study_uid>/<series_uid>/<modality>_sop_inst_uid.dcm

Actually invokes ApplyPrivateDispositionUnconditionalDate2.pl to do the edits
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
my($invoc_id, $act_id, $notify, $skip_dispositions, $upd_nbia, $rel_dir) = @ARGV;

unless(defined $skip_dispositions) { $skip_dispositions = 0}
if($skip_dispositions == "") { $skip_dispositions = 0}
unless(defined $upd_nbia) { $upd_nbia = 0}
if($upd_nbia == "") { $upd_nbia = 0}

if($upd_nbia && $rel_dir){
  print "If <upd_nbia> is not 0 or blank (and it is \"$upd_nbia\") then <dir> should not be supplied (it is \"$rel_dir\")\n";
  exit;
}

if($rel_dir){
  if($rel_dir =~ /[^A-Za-z0-9_]/){
    print "Rel_dir is only allowed to have A-Z, a-z, 0-9, _ characters.  It is \"$rel_dir\".";
    exit;
  }
}

my %Patients;
my %PatientMapping;
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
    $sop_instance_uid, $modality, $path) = @$row;
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



my $tp_id;
Query("LatestActivityTimepointForActivity")->RunQuery(sub{
  my($row) = @_;
  $tp_id = $row->[0];
}, sub{}, $act_id);
print STDERR "Activity timepoint id: $tp_id\n";

my $num_reports = 0;

## Basic sanity checks:

# Patient Mapping (generate and check errors)
my $q3 = PosdaDB::Queries->GetQueryInstance(
  "GetPatientMappingByPatientId");
pat:
for my $pat (keys %Patients){
  $q3->RunQuery(sub{
    my($row) = @_;
    my($from_patient_id,
      $to_patient_id,
      $to_patient_name,
      $collection_name,
      $site_name,
      $batch_number,
      $uid_root,
      $diagnosis_date,
      $baseline_date,
      $date_shift,
      $computed_shift) = @$row;
    if(exists $PatientMapping{$from_patient_id}){
      print "$pat: More than one mapping\n";
      $num_reports += 1;
    }
    # TODO error if no computed shift, because this is the Baseline script???
    unless($computed_shift =~ /^([^\s]+)\s*days$/){
      print "$pat: No computed shift for patient_id\n";
      $num_reports += 1;
    }
    my $offset = $1;
    $PatientMapping{$pat}->{uid_root} = $uid_root;
    $PatientMapping{$pat}->{offset} = $offset;
  }, sub {}, $pat);
}
for my $pat (keys %Patients){
  unless(exists $PatientMapping{$pat}){
    print "$pat: No mapping found\n";
    $num_reports += 1;
  }
}

# Check DupSops, report and exit
  my $num_dups = keys %DupSops;
  if($num_dups > 0){
    print "$num_dups Duplicate Sops found in timepoint\n";
    for my $sop(keys %DupSops){
      print "$sop:\n";
      for my $fid (keys %{$DupSops{$sop}}){
        print "\t$fid\n";
      }
    }
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

$background->WriteToEmail("Checking visual_review_id: $visual_review_id\n");
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
$background->WriteToEmail("All SOPs in current_timepoint are in visual review\n");
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
## Compute the BaseDir
#
my $BaseDir;
if($upd_nbia){
  $BaseDir = $ENV{NBIA_STORAGE_ROOT}
  or die "NBIA_STORAGE_ROOT env var is undefined! cannot continue";
} else {
  my $cache_dir = $ENV{POSDA_CACHE_ROOT};
  unless(-d $cache_dir){
    print "Error: Cache dir ($cache_dir) isn't a directory\n";
    exit;
  }
  $BaseDir = "$cache_dir/linked_for_download/$rel_dir";
  make_path($BaseDir);
}
#
## End Compute the BaseDir
#############################

$background->WriteToEmail("$date\nStarting ApplyPrivateDispositions\n");

if($skip_dispositions) {
  $background->WriteToEmail("Private Dispositions will be skipped\n");
}

if($upd_nbia){
  $background->WriteToEmail("Files will be entered into nbia database\n");
} else {
  $background->WriteToEmail("Files will be written to downloadable " .
    "directory \"$rel_dir\"\nReal directory: $BaseDir\n");
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
  my $pat = $Files{$file_id}->{patient};
  my $path = $Files{$file_id}->{path};
  my $f_filename;
  my $offset = $PatientMapping{$pat}->{offset};
  my $uid_root = $PatientMapping{$pat}->{uid_root};
  if($upd_nbia){
    $f_filename = Posda::NBIASubmit::GenerateFilename($sop_instance_uid);
  } else {
    my $study = $Files{$file_id}->{study};
    my $series = $Files{$file_id}->{series};
    my $modality = $Files{$file_id}->{modality};
    $f_filename = "$pat/$study/$series/$modality$sop_instance_uid.dcm";
  }
  my $full_filename = "$BaseDir/$f_filename";
  my $dirname = dirname($full_filename);
  make_path($dirname);

  my $cmd = qq{ApplyPrivateDispositionUnconditionalDate2.pl $invoc_id } .
            qq{$file_id $path "$full_filename" $uid_root "$offset" "$tp_id" "$skip_dispositions" } .
            qq{"$upd_nbia" "$sop_instance_uid"};

  push @cmds, $cmd;
}
my $num_commands = @cmds;
$background->WriteToEmail(`date`);
$background->WriteToEmail("about to execute $num_commands in 5 subshells\n");
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
if($upd_nbia){
  $background->WriteToEmail("<a target=\"_blank\" onclick=\"javascript:event.target.port=80\" " .
  "href=\"/papi/v1/send_to_public_status/report/$invoc_id?pretty=1\">Public Copy Status Report</a>\n");
}
$background->Finish("Done");
