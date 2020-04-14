#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;

my $usage = <<EOF;
ExportTimepoint.pl <?bkgrnd_id?> <activity_id> "<destination_name>" "<only_group_13>" "<only_dicom>" "<apply_dispositions>" 
    "<base_line>" "<days_to_shift>" "<uid_root>" <notify>
or
ExportTimepoint.pl -h

Disposition params:
  <only_dicom> - only export dicom files
  <only_group_13>
    1 - don't do anything except modify group 13 (following Disposition params null)
    0 - interpret following Disposition params
  <base_line>
    1 - use patient_mapping table for next two params (following Disposition params null)
    0 - use next two parameters 
  <days_to_shift> - days to shift if not baseline
  <uid_root> - uid_root to use if not baseline

Expects no lines STDIN

Uses the following queries:
  
Does the following:
  Creates an export_event row:
    submitter_type: "subprocess_invocation"
    export_destination: <destination_name>
    subprocess_invocation_id: <bkgrnd_id>
    creation_time: now()
    request_pending: false
  For every row in activity_timepoint_file
  for the current activity_timepoint:
    if <only_dicom> and file is not DICOM:  next file 
    <export_file_dispositions_params> = null
    if(file is dicom):
      compute dispositions parameters and store
      into export_file_dispositions_params (normalizing)
      <export_file_dispositions_params_id> = id of row
    add a row to file_export:
      export_event_id: from creation of export_event
      export_file_dispositions_params_id = <export_file_dispositions_params_id>
      file_id: from activity_timepoint_file
      when_queued: now()
      transfer_status: "pending"
  After all files have been processed, the script will 
  update export_event:
      set request_status = "start"
      set request_pending = "true"

Queries Used:
  CreateExportEvent
  GetExportEventId
  LatestActivityTimepointForActivity
  FilesInTimepointWithType
  CreateFileExportRow
  ExportDaemonRequest
  GetPatientsForFilesInTimepoint
  GetPatientForMappingForPatientsInTimepointWithSiteCode
EOF

$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
unless($#ARGV == 9){
  die "$usage\n";
}

#ExportTimepoint.pl <?bkgrnd_id?> <activity_id> "<destination_name>" "<only_group_13>" "<only_dicom>" "<apply_dispositions>" 
#    "<base_line>" "<days_to_shift>" "<uid_root>" <notify>
my ($invoc_id, $activity_id, $destination, $only_13, $only_dicom, $apply_disp,
  $base_line, $offset, $uid_root, $notify) = @ARGV;

print "Going straight to Background\n";
my $bg = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$bg->Daemonize;
my $tpa_url = 
  Query('GetTPAURLBySubprocess')->FetchOneHash($invoc_id)->{third_party_analysis_url};
my $activity_timepoint_id;
Query("LatestActivityTimepointForActivity")->RunQuery(sub{
  my($row) = @_;
  $activity_timepoint_id = $row->[0];
}, sub {}, $activity_id);
if(defined $activity_timepoint_id){
  $bg->WriteToEmail("Exporting\n  activity_timepoint_id: $activity_timepoint_id\n");
} else {
  $bg->WriteToEmail("Unable to get activity_timepoint_id for activity $invoc_id\n");
  $bg->Finish("Failed: unable to get activity_timepoint_id");
  exit;
}
$bg->SetActivityStatus("Getting files in timepoint\n");
my %file_ids;
Query("FilesInTimepointWithType")->RunQuery(sub{
  my($row) = @_;
  if($only_dicom && ($row->[1] ne "parsed dicom file")){ return }
  $file_ids{$row->[0]} = $row->[1];
}, sub {}, $activity_timepoint_id);
my $num_files = keys %file_ids;
$bg->WriteToEmail("Found $num_files to export\n");

my %PatientsByFileId;
my %PatientMappingInTimepoint;
if($base_line){
  Query("GetPatientsForFilesInTimepoint")->RunQuery(sub{
    my($row) = @_;
    $PatientsByFileId{$row->[0]} = $row->[1];
  }, sub {}, $activity_timepoint_id);
  Query("GetPatientMappingForFilesInTimepointWithSiteCode")->RunQuery(sub{
    my($row) = @_;
    my($from_patient_id, $to_patient_id, $to_patient_name, $collection_name,
      $site_name, $site_code, $uid_root, $diagnosis_date, $baseline_date,
      $date_shift, $computed_shift) = @$row;
    my $h = {
      from_patient_id => $from_patient_id,
      to_patient_id => $to_patient_id,
      to_patient_name => $to_patient_name,
      collection_name => $collection_name,
      site_name => $site_name,
      site_code => $site_code,
      uid_root => $uid_root,
      diagnosis_date => $diagnosis_date,
      baseline_date => $baseline_date,
      date_shift => $date_shift,
      computed_shift => $computed_shift
    };
    $PatientMappingInTimepoint{$to_patient_id} = $h;
  }, sub {}, $activity_timepoint_id);
}
my @FileExportsToCreate;
my %FileExportErrors;
my $gfd = Query("GetFileDispositionsRow");
my $ifd = Query("InsertFileDispositionsRow");
my $gfd_id = Query("GetFileDispositionsRowId");
my $o_13 = 'false';
if($only_13){ $o_13 = 'true' }
file: 
for my $f (keys %file_ids){
  if($file_ids{$f} eq "parsed dicom file"){
    if($apply_disp || $only_13){
      my $disp_id;
      eval { $disp_id = GetFileDispositionsRow($f) };
      if($@){
        $FileExportErrors{$@} += 1;
        next file;
      }
      push @FileExportsToCreate, {
        file_id => $f,
        disp_id => $disp_id,
      };
    } else {
      push @FileExportsToCreate, {
        file_id => $f,
        disp_id => undef,
      };
    }
  } else {
    push @FileExportsToCreate, {
      file_id => $f,
      disp_id => undef,
    };
  }
}
my $num_errors = keys %FileExportErrors;
if($num_errors > 0){
  $bg->WriteToEmail("$num_errors errors encountered queuing file_exports:\n");
  for my $m (keys %FileExportErrors){
    $bg->WriteToEmail("$FileExportErrors{$m} of error: $m\n");
  }
  $bg->WriteToEmail("Not creating export_event\n");
  $bg->Finish("Done with $num_errors errors");
  exit;
}

$bg->SetActivityStatus("Creating Export Event\n");
my $export_event_id;
Query("CreateExportEvent")->RunQuery(sub{
}, sub{}, "subprocess_invocation", $invoc_id, $destination);
Query("GetExportEventId")->RunQuery(sub{
  my($row) = @_;
  $export_event_id = $row->[0];
}, sub{});
if(defined $export_event_id){
  $bg->WriteToEmail("Export Event ($export_event_id) to $destination\n");
} else {
  $bg->WriteToEmail("Unable to create Export Event\n");
  $bg->Finish("Failed: unable to create Export Event");
  exit;
}

my $num_queued = 0;
my $q = Query("CreateFileExportRow");
for my $f_info (@FileExportsToCreate){
  my $f = $f_info->{file_id};
  my $d = $f_info->{disp_id};
  $q->RunQuery(sub{}, sub {}, $export_event_id, $f, $d);
  $num_queued += 1;
  $bg->SetActivityStatus("Queued $num_queued of $num_files for export $export_event_id\n");
}

Query("ExportDaemonRequest")->RunQuery(sub{}, sub{}, "start", $export_event_id);

$bg->Finish("Done: queued $num_files to export_event $export_event_id");

#################################
#  <only_group_13>
#    1 - don't do anything except modify group 13 (following Disposition params null)
#    0 - interpret following Disposition params
#  <base_line>
#    1 - use patient_mapping table for next two params (following Disposition params null)
#    0 - use next two parameters 
#  <days_to_shift> - days to shift if not baseline
#  <uid_root> - uid_root to use if not baseline
#
#  Data structs:
#  %PatientsByFileId{$file_id} = <patient_id>1;
#  %PatientMappingInTimepoint{$patient_id} = {
#      from_patient_id => <from_patient_id>,
#      to_patient_id => <to_patient_id>,
#      to_patient_name => <to_patient_name>,
#      collection_name => <collection_name>,
#      site_name => <site_name>,
#      site_code => <site_code>,
#      uid_root => <uid_root>,
#      diagnosis_date => <diagnosis_date>,
#      baseline_date => <baseline_date>,
#      date_shift => <date_shift>,
#      computed_shift => <computed_shift>,
#  };

sub GetFileDispositionsRow{
  my($file_id) = @_;
  my $l_uid_root = $uid_root;
  my $l_offset = $offset;
  if($o_13 eq "true"){
    $l_uid_root = "";
    $l_offset = "";
  }
  if($base_line){
    print STDERR "looking up offset, uid_root from patient_mapping\n";
    ($l_offset, $l_uid_root) = GetFileDispositionsRowBaseline($file_id);
  } else {
    print STDERR "taking offset, uid_root from params\n";
  }
  #my $gfd = Query("GetFileDispositionsRow");
  #my $ifd = Query("InsertFileDispositionsRow");
  #my $gfd_id = Query("GetFileDispositionsRowId");
print STDERR ("($l_offset, $l_uid_root, $o_13)\n");
  unless($l_offset =~ /^[\+\-\s]*[\d]+\s*$/) {
    if($l_offset eq ""){
      $l_offset = 0;
    }  else {
      die "date doesn't look like integer";
    }
  }
  my $id;
  $gfd->RunQuery(sub{
    my($row) = @_;
    $id = $row->[0];
  }, sub{}, $l_offset, $l_uid_root, $o_13);
if(defined($id)){
  print "Existing id for params: $id\n";
}
  if($id){ return $id }
  $ifd->RunQuery(sub{}, sub{}, $l_offset, $l_uid_root, $o_13);
  $gfd_id->RunQuery(sub{
    my($row) = @_;
    $id = $row->[0];
  }, sub {});
if(defined($id)){
  print "Created id for params: $id\n";
}
  if($id){ return $id }
  die "unable to create export_file_dispositions_params row";
} 
sub GetFileDispositionsRowBaseline{
  my($file_id) = @_;
  unless(exists $PatientsByFileId{$file_id}) {
    die "No patient found for file ($file_id)";
  }
  my $pat_id = $PatientsByFileId{$file_id};
  unless(defined $PatientMappingInTimepoint{$pat_id}->{baseline_date}){
    die "No baseline_date for patient $pat_id";
  }
  my $uid_root = $PatientMappingInTimepoint{$pat_id}->{uid_root};
  my $offset = $PatientMappingInTimepoint{$pat_id}->{computed_shift};
  if($offset =~ /^(.*)\s*days$/) {$offset = $1}
  return $offset, $uid_root;
}
