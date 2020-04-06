#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
StartAnExport.pl.pl <?bkgrnd_id?> <activity_id> <export_event_id>  <notify>
  activity_id - activity id
  export_event_id -  export_event_id
  notify - email address for completion notification

Expects nothing on STDIN

Uses the following queries:
  PendingExportRequestsForActivity
  ExportDestinationInfo
  StartExport
  EndExport
  GetExportRequest
  SetFileExportPending
  FileExportForEvent
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}

unless($#ARGV == 3){
  print "$usage\n";
  die "######################## subprocess failed to start:\n" .
      "$usage\n" .
      "#####################################################\n";
}
my($invoc_id, $act_id, $export_event_id, $notify) = @ARGV;
my($creation_id, $export_destination_name, $creation_time,
  $request_pending, $request_status, $act_status, $num_files);
Query("PendingExportRequestsForActivity")->RunQuery(sub {
  my($row) = @_;
  if($row->[0] != $export_event_id){
    return;
  }
  if($row->[1] != $act_id){
    print "Activity_id ($row->[1]) " .
     " of export doesn't match ($act_id)\n" .
     "aborting\n";
    exit;
  }
  $creation_id = $row->[2];
  $export_destination_name = $row->[3];
  $creation_time = $row->[4];
  $request_pending = $row->[5];
  $request_status = $row->[6];
  $act_status = $row->[7];
  $num_files = $row->[8];
}, sub{}, $act_id);
unless(defined $export_destination_name){
  print "Unable to locate export_event ($export_event_id) in DB\n";
  exit;
}
unless($request_pending) { print "Warning: no request pending\n" }
my($protocol, $base_url, $config_string);
Query("ExportDestinationInfo")->RunQuery(sub{
  my($row) = @_;
  $protocol = $row->[0];
  $base_url = $row->[1];
  $config_string = $row->[1];
}, sub {}, $export_destination_name);
unless(defined $protocol){
  print "Unable to locate export_destination $export_destination_name\n";
  exit;
}
my %PendingFiles;
my %TransferredFiles;
my %FailedTemporaryFiles;
my %FailedPermanentFiles;
my %WaitingFiles;
my %FilesInBadState;
Query("FileExportForEvent")->RunQuery(sub{
  my($row) = @_;
  my($file_id, $has_disp_parms, $when_queued, $when_transferred,
    $transfer_status, $transfer_status_message, $offset, $root, $batch) =
    @{$row};
  if(!defined $when_transferred){
    my $stat = {
      when_queued => $when_queued,
      transfer_status => $transfer_status,
      transfer_status_message => $transfer_status_message,
    };
    if($has_disp_parms){
      $stat->{has_disp_parms} = 1;
      $stat->{offset} = $offset;
      $stat->{root} = $root;
      $stat->{batch} = $batch;
    }
    if($transfer_status eq "pending"){
      $PendingFiles{$file_id} = $stat;
    } else {
      $WaitingFiles{$file_id} = $stat;
    }
  } else {
    my $stat = {
      when_queued => $when_queued,
      when_transfered => $when_transferred,
      transfer_status => $transfer_status,
      transfer_status_message => $transfer_status_message,
    };
    if($has_disp_parms){
      $stat->{has_disp_parms} = 1;
      $stat->{offset} = $offset;
      $stat->{root} = $root;
      $stat->{batch} = $batch;
    }
    if($transfer_status eq "pending"){
      $PendingFiles{$file_id} = $stat;
    } elsif ($transfer_status eq "success"){
      $TransferredFiles{$file_id} = $stat;
    } elsif ($transfer_status eq "failed temporary"){
      $FailedTemporaryFiles{$file_id} = $stat;
    } elsif ($transfer_status eq "failed permanent"){
      $FailedPermanentFiles{$file_id} = $stat;
    } else {
      $FilesInBadState{$file_id} = $stat;
    }
  }
},sub{}, $export_event_id);
my $num_waiting = keys %WaitingFiles;
my $num_pending = keys %PendingFiles;
my $num_success = keys %TransferredFiles;
my $num_failed_temp = keys %FailedTemporaryFiles;
my $num_failed_perm = keys %FailedPermanentFiles;
my $num_bad_state = keys %FilesInBadState;;
#  print a message and go to background
print 
  "Export_event: $export_event_id, num_files: $num_files " .
  "to $export_destination_name ($protocol, $base_url)\n" .
  "created by subprocess $creation_id, at: $creation_time, status: $act_status\n" .
  ($request_pending ? "request pending: $request_status\n" :
    "no request_pending, (apparent) last request: $request_status\n");
print "$num_waiting files waiting to be transferred\n" .
  "$num_pending files are pending transfer\n" .
  "$num_success files have already been transferred successfully\n" .
  "$num_failed_temp files have failed with temporary status\n" .
  "$num_failed_perm files have failed with permanent status\n" .
  "$num_bad_state files are in a bad transfer state.\n";

my $protocol_handlers = {
  posda => "ActivityBasedCuration::SendToAnotherPosda",
  public => "ActivityBasedCuration::SendToPublic",
  simulate_slow_transfer => "ActivityBasedCuration::SimulateSlowSend",
};
unless(defined $protocol_handlers->{$protocol}){
  print "Not going to background or otherwise processing request " .
    "(protocol $protocol has no handler defined)\n";
  exit;
}
my $prot_hand_class = $protocol_handlers->{$protocol};

eval "require $prot_hand_class";
if($@){
  print "Not going to background or otherwise processing request\n" .
    "Protocol_handler_class $prot_hand_class failed to load:\n$@\n";
  exit;
}
#print "Not going to background or otherwise processing request\n" .
#  "Loop not implemented yet\n";
#exit;

print "\nEntering background\n";

my $prot_hand = $prot_hand_class->new($export_event_id,
  \%WaitingFiles, \%PendingFiles, \%TransferredFiles,
  \%FailedTemporaryFiles, \%FailedPermanentFiles);
my $start = time;
my $date = `date`;
my $bg = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
$bg->Daemonize;
$bg->WriteToEmail("$date\nPosda Transfer Agent Starting\n" .
  "Export_event: $export_event_id, num_files: $num_files " .
  "to $export_destination_name\n" .
  "created by subprocess $creation_id, at: $creation_time, status: $act_status\n" .
  $request_pending ? "request pending: $request_status\n" :
    "no request_pending, (apparent) last request: $request_status\n"
);

Query("StartExport")->RunQuery(sub{}, sub {}, $export_event_id);

my $set_file_status = Query("SetFileExportPending");
main_loop:
while($num_waiting > 0){
  if(PauseRequested($export_event_id)) { PauseTransfer($export_event_id) }
  my $ftt = [keys %WaitingFiles]->[0];
  my $ftt_info = $WaitingFiles{$ftt};

  $set_file_status->RunQuery(sub {}, sub {}, $export_event_id, $ftt);
  ## to do - set pending status in file_edit
 
  $PendingFiles{$ftt} = $ftt_info;
  delete $WaitingFiles{$ftt};
  my $num_waiting = keys %WaitingFiles;
  my $num_pending = keys %PendingFiles;
  my $num_success = keys %TransferredFiles;
  my $num_failed_temp = keys %FailedTemporaryFiles;
  my $num_failed_perm = keys %FailedPermanentFiles;
  my $num_bad_state = keys %FilesInBadState;;
  $bg->SetActivityStatus("In progess W: $num_waiting, P: " .
    "$num_pending, S: $num_success, Ft: $num_failed_temp, " .
    "Fp: $num_failed_perm, B: $num_bad_state");
  if(defined($ftt_info->{has_disp_parms})){
    my $temp_file = ApplyDispositions($ftt, $ftt_info);
    $prot_hand->TransferAnImage($export_event_id, $ftt, $temp_file);
    unlink($temp_file);
  } else {
    my $file_path;
    Query("GetFilePath")->RunQuery(sub {
      my($row) = @_;
      $file_path = $row->[0];
    }, sub{}, $ftt);
    $prot_hand->TransferAnImage($export_event_id, $ftt, $file_path);
  }
}
my $end_status;
if($num_failed_perm > 0){
  $end_status = "failed permanent";
} elsif($num_failed_temp > 0){
  $end_status = "failed temporary";
} else {
  $end_status = "success";
}

Query("EndExportEvent")->RunQuery(sub{}, sub{}, $end_status, $export_event_id);

$bg->Finish("Transfer Complete W: $num_waiting, P: " .
    "$num_pending, S: $num_success, Ft: $num_failed_temp, " .
    "Fp: $num_failed_perm, B: $num_bad_state");
exit;

sub PauseTransfer{
  my($export_event_id) = @_;

  Query("EndExportEvent")->RunQuery(sub{}, sub{}, "paused", $export_event_id);

  $bg->Finish("Transfer Paused, W: $num_waiting, P: " .
    "$num_pending, S: $num_success, Ft: $num_failed_temp, " .
    "Fp: $num_failed_perm, B: $num_bad_state");
  exit;
}

sub PauseRequested {
  my($export_event_id) = @_;
  my $req;
  Query("GetExportRequest")->RunQuery(sub {
    my($row) = @_;
    $req = $row->[0];
  }, sub {}, $export_event_id);
  if($req eq "pause") { return 1}
  return 0;
} 
