#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::DownloadableFile;
use Posda::BackgroundProcess;
my $usage = <<EOF;
BackgroundDciodvfyTp.pl <?bkgrnd_id?> <activity_id> <type>  <notify>
  activity_id - activity id
  type -  Type of scan:
    "one_per_series" - scan one file in series
    "all_per_series" - scan all files in series
    "per_sop" - sops are SOP instances - one file per SOP
  notify - email address for completion notification

Expects nothing on STDIN

Uses the following script to do most of the work:
  ProcessDciodvfyScanTp.pl <activity_timpoint_id> <type> <uid> <scan_id>

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}

my $child_pid = $$;
my $command = $0;
my $script_start_time = time;
unless($#ARGV == 3){
  print "$usage\n";
  die "######################## subprocess failed to start:\n" .
      "$usage\n" .
      "#####################################################\n";
}
my($invoc_id, $act_id, $type_of_unit, $notify) = @ARGV;
my $start = time;
##################
## Get List of Study and Series in this Current Activity Timepoint for this Activity
my $ActTpId;
my $ActTpComment;
my $ActTpDate;
my %FilesInTp;
my %SeriesInTp;
my %StudiesInTp;
Query('LatestActivityTimepointsForActivity')->RunQuery(sub{
  my($row) = @_;
  my($activity_id, $activity_created,
    $activity_description, $activity_timepoint_id,
    $timepoint_created, $comment, $creating_user) = @$row;
  $ActTpId = $activity_timepoint_id;
  $ActTpComment = $comment;
  $ActTpDate = $timepoint_created;
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
my $num_tp_series = keys %SeriesInTp;
my $num_tp_studiea = keys %StudiesInTp;
print "Found $num_tp_studiea studies, $num_tp_series series\n";
my $forground_time = time - $start;
print "Going to background to analyze after $forground_time seconds\n";
###
my $num_series = keys %SeriesInTp;
my $description = "Dciodvy scan activity $act_id, timpoint: $ActTpId";
my $date = `date`;
#  print a message and go to background
my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
$background->Daemonize;
$background->WriteToEmail("$date\nStarting Simple PHI Scan\n" .
  "Description: $description\n" .
  "type: $type_of_unit\n" .
  "background_subprocess_id: $invoc_id\n");
#######################################################################
### Create a dciodvy scan instance
my $create_scan = PosdaDB::Queries->GetQueryInstance(
  "CreateDciodvfyScanInstance");
my $get_scan_id = PosdaDB::Queries->GetQueryInstance(
  "GetDciodvfyScanInstanceId");
my $update_inst = PosdaDB::Queries->GetQueryInstance(
  "SetDciodvfyScanInstanceNumScanned");
my $finalize_inst = PosdaDB::Queries->GetQueryInstance(
  "FinalizeDciodvfyScanInstance");
$create_scan->RunQuery(sub {}, sub {},
  $type_of_unit, $description, $num_series);
my $scan_id;
$get_scan_id->RunQuery(sub {
  my($row) = @_;
  $scan_id = $row->[0];
}, sub {});
my $num_scanned = 0;
for my $uid (keys %SeriesInTp){
  my $cmd = "ProcessDciodvfyScanTp.pl $ActTpId $type_of_unit $uid $scan_id";
#print EMAIL "command: $cmd\n";
  `$cmd`;
  $num_scanned += 1;
  $update_inst->RunQuery(sub {}, sub {},
    $num_scanned, $scan_id);
}
$finalize_inst->RunQuery(sub{}, sub {}, $scan_id);
my $end = time;
my $duration = $end - $script_start_time;
$background->WriteToEmail("finished scan\n" .
  "num scanned $num_scanned\n" .
  "duration $duration seconds\n" .
  "id of PHI scan: $scan_id\n");
### Scan created
###################################################################
#Set report
my $get_scan_desc = Query("GetDciodvfyScanDesc");
$get_scan_desc->RunQuery(sub {
  my($row) = @_;
  my($type_of_unit,
    $description_of_scan,
    $number_units,
    $scanned_so_far,
    $start_time,
    $end_time) = @$row;
  $background->WriteToEmail("$start_time: Starting Dciodvfy Report:\n" .
    "        ScanId: $scan_id\n" .
    "     Unit type: $type_of_unit\n" .
    "   Description: $description_of_scan\n" .
    "Number to scan: $number_units\n" .
    " Number scaned: $scanned_so_far\n" .
    "    Start time: $start_time\n" .
    "      End time: $end_time\n"
  );
}, sub {}, $scan_id);
my $start_report = time;
#######################################################################
### Generate report
my %SeriesErrorClasses;
my $get_error_ids = PosdaDB::Queries->GetQueryInstance(
  "DciodvfyErrorIdsBySeriesAndScanInstance"
);
my $get_error_string= PosdaDB::Queries->GetQueryInstance(
  "DciodvfyErrorsStringByErrorId"
);
for my $series(keys %SeriesInTp){
  my $sig = "";
  $get_error_ids->RunQuery(sub {
    my($row) = @_;
    my $id = $row->[0];
    if($sig) { $sig .= "-$id";
    } else { $sig = $id }
  }, sub {}, $scan_id, $series);
  $SeriesErrorClasses{$sig}->{$series} = 1;
}
$background->WriteToEmail("This is a test version of this script\n");
my $rpt = $background->CreateReport("DciodvfySeriesReport");
$rpt->print("Series,Errors\n");
my $report_rows = 0;
for my $error_str (sort keys %SeriesErrorClasses){
  my @ids = split(/-/, $error_str);
  my @series = sort keys %{$SeriesErrorClasses{$error_str}};
  $rpt->print('"');
  for my $i (0 .. $#series){
    $rpt->print("$series[$i]");
    unless($i == $#series) {$rpt->print("\n")}
  }
  $rpt->print('","');
  if($#ids >= 0){
    for my $i (0 .. $#ids){
      my $string;
      $get_error_string->RunQuery(sub {
        my($row) = @_;
        $string = $row->[0];
      }, sub {}, $ids[$i]);
      my $converted_string = ConvertString($string);
      $rpt->print("$converted_string");
      unless($i == $#ids) { $rpt->print("\n") }
    }
  } else {
    $rpt->print('none');
  }
  $rpt->print('"' . "\r\n");
  $report_rows += 1;
}
my $report_time = time - $start_report;
$background->WriteToEmail("Took $report_time seconds to generate report\n");
### Finished Report
###################################################################

###################################################################
### Begin DciodvfyNew experimental output
###################################################################

my $new_report = $background->CreateReport("DciodvfySeriesReport-New");
open FILE, "dciodvfynew.py $ActTpId |";
while (my $line = <FILE>) {
  # chomp $line;
  $new_report->print($line);
}
close FILE;


$background->Finish;
exit;
sub ConvertString{
  my($string) = @_;
  my($dciodvfy_error_id, $error_type,
    $error_tag, $error_value,
    $error_subtype, $error_module,
    $error_reason, $error_index,
    $error_text) = split(/\|/, $string);
  if($error_type eq 'Uncategorized'){
    $error_text =~ s/"/""/g;
    return $error_text;
  } elsif($error_type eq 'MayNotBePresent'){
    return "Tag: $error_tag : May not be present because $error_reason";
  } elsif($error_type eq 'UnrecognizedEnumeratedValue'){
    return "Tag: $error_tag : has an unrecognized enumerated value ($error_value) in index $error_index";
  } elsif($error_type eq 'AttributeSpecificError'){
    return "Tag: $error_tag : $error_subtype";
  } elsif($error_type eq 'AttributeSpecificErrorWithIndex'){
    return "Tag: $error_tag : $error_subtype for index $error_index";
  } elsif($error_type eq 'MissingAttributes'){
    return "Tag: $error_tag : Missing Tag : $error_subtype : $error_module";
  } elsif($error_type eq 'BadValueMultiplicity'){
    return "Tag: $error_tag : has bad value multiplicity : $error_value vs $error_index : per $error_module";
  } elsif($error_type eq 'CantBeNegative'){
    return "Tag: $error_tag : has illegal negative value: $error_value\n";
  } elsif($error_type eq 'AttributesPresentWhenConditionNotSatisfied'){
    return "Tag: $error_tag : is conditional and is present when condition not satisfied : per $error_module module";
  } elsif($error_type eq 'InvalidElementLength'){
    return "Tag: $error_tag : has value ($error_value) with invalid length ($error_index vs $error_reason)";
  } elsif($error_type eq 'UnrecognizedPublicTag'){
    return "Unrecognized public tag: $error_tag";
  } elsif($error_type eq 'InvalidValueForVr'){
    return "Tag: $error_tag : Invalid Value for VR : $error_value : $error_reason : $error_subtype";
  } else {
    return $string;
  }
  return $string;
}
