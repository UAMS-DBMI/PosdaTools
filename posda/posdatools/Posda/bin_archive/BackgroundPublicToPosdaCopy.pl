#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;

my $usage = <<EOF;
BackgroundPublicToPosdaCopy.pl <bkgrnd_id> <copy_id> <why> <notify>
or
BackgroundPublicToPosdaCopy.pl -h

The script doesn't expect lines on STDIN:

EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 3){
  die "$usage\n";
}

my ($invoc_id, $copy_id, $why, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

print "Going straight to background\n";

$background->ForkAndExit;

my $start_time = `date`;
chomp $start_time;
$background->WriteToEmail("Starting BackgroundPublicToPosdaCopy.pl at " .
  "$start_time\n");
my $get_status = Query("GetCopyInformation");
my $set_status = Query("UpdateCopyInformation");
my $my_pid = $$;
my($current_pid, $status);
$get_status->RunQuery(sub{
  my($row) = @_;
  $status = $row->[0];
  $current_pid = $row->[1];
}, sub {}, $copy_id);
unless(
  defined($status) && $status eq "waiting for start" && !defined($current_pid)
){
  unless(defined($current_pid)){ $current_pid = "<undef>" }
  $background->WriteToEmail("Error: At start - status = $status; " .
    "current_pid = $current_pid\n");
  $background->Finish;
  exit;
}
$set_status->RunQuery(sub {}, sub {}, "copy in progress", $my_pid, $copy_id);
$background->WriteToEmail("Set copy in progress ($my_pid) for $copy_id\n");
my $get_total_rows = Query("HowManyRowsInCopyFromPublic");
my $get_rows_to_hide = Query("HowManyFilesToHideInCopyFromPublic");
my $get_rows_to_copy = Query("HowManyFilesToCopyInCopyFromPublic");
my $get_rows_hidden = Query("HowManyFilesHiddenInCopyFromPublic");
my $get_rows_copied = Query("HowManyFilesCopiedInCopyFromPublic");
my($total_rows, $rows_to_hide, $rows_to_copy, $rows_hidden, $rows_copied);
$get_total_rows->RunQuery(sub {
  my($row) = @_; $total_rows = $row->[0];
},sub{}, $copy_id);
$get_rows_to_hide->RunQuery(sub {
  my($row) = @_; $rows_to_hide = $row->[0];
},sub{}, $copy_id);
$get_rows_to_copy->RunQuery(sub {
  my($row) = @_; $rows_to_copy = $row->[0];
},sub{}, $copy_id);
$get_rows_hidden->RunQuery(sub {
  my($row) = @_; $rows_hidden = $row->[0];
},sub{}, $copy_id);
$get_rows_copied->RunQuery(sub {
  my($row) = @_; $rows_copied = $row->[0];
},sub{}, $copy_id);
my $tt = `date`;
chomp $tt;
$background->WriteToEmail("$tt: Entering loop\n" .
  "copy_from_public_id = $copy_id\n" .
  "total rows = $total_rows\n" .
  "rows_to_hide = $rows_to_hide\n" .
  "rows_to_copy = $rows_to_copy\n" .
  "rows_hidden = $rows_hidden\n" .
  "rows_copied = $rows_copied\n"
);
my $get_some_copies = Query("GetNfilesToCopy");
my $get_public_info = Query("GetPublicCopyInfoBySop");
loop:
while(1){
  my($pid_in_db, $status_in_db);
  $get_status->RunQuery(sub {
    my($row) = @_;
    $status_in_db = $row->[0];
    $pid_in_db = $row->[1];
  }, sub {}, $copy_id);
  unless($status_in_db eq "copy in progress" && $pid_in_db eq $my_pid){
    if($status_in_db eq "stop request"){
      $set_status->RunQuery(sub{}, sub {},
         "waiting for start", undef, $copy_id);
      $background->WriteToEmail("Shutdown requested and acknowledged\n");
      last loop;
    } else {
      $background->WriteToEmail("Error in loop: status: $status_in_db; " .
        "pid: $pid_in_db; my_pid = $my_pid\n");
      last loop;
    }
  }
  my %BySop;
  my $num_rows = 0;
  $get_some_copies->RunQuery(sub {
    my($row) = @_;
    my $sop = $row->[0];
    my $replace_file_id = $row->[1];
    my($dicom_file_uri, $project, $site_name, $site_id);
    $get_public_info->RunQuery(sub {
      my($row) = @_;
      $dicom_file_uri = $row->[0];
      $project = $row->[1];
      $site_name = $row->[2];
      $site_id = $row->[3];
    }, sub {}, $sop);
    if(
      defined($sop) && defined($replace_file_id) &&
      defined($dicom_file_uri) && defined($project) &&
      defined($site_name) && defined($site_id)
    ){
      $dicom_file_uri =~  s/^.*\/storage/\/nas\/public\/storage/;
      unless(-f $dicom_file_uri){
        $background->WriteToEmail("Public file not found: $dicom_file_uri\n");
        $set_status->RunQuery(sub{}, sub {},
          "shutdown in error", undef, $copy_id);
        last loop;
      }
      $BySop{$sop} = {
        replace_file_id => $replace_file_id,
        dicom_file_uri => $dicom_file_uri,
        project => $project,
        site => $site_name,
        site_id => $site_id
      };
    } else {
      $background->WriteToEmail("Failed to Retrieve Proper Query Data:\n" .
        "sop: $sop\nreplace_file_id: $replace_file_id\n" .
        "dicom_file_uri: $dicom_file_uri\nproject: $project\n" .
        "site: $site_name\nsite_id: $site_id\n");
      $set_status->RunQuery(sub{}, sub {},
        "shutdown in error", undef, $copy_id);
      last loop;
    }
    $num_rows += 1;
  }, sub {}, $copy_id, 500);
  my $num_sops = keys %BySop;
  unless($num_sops == $num_rows) {
    $background->WriteToEmail(
      "Num sops ($num_sops) != num rows ($num_rows)\n");
    $set_status->RunQuery(sub{}, sub {},
      "shutdown in error", undef, $copy_id);
    last loop;
  }
  $background->WriteToEmail("Found $num_sops to copy\n");
  if($num_sops == 0){
    last loop;
  }
  open HIDE, "|StreamingHideFilesWithStatusAfterImportFromPublic.pl " .
    "$notify $copy_id";
  open MOVE, "|StreamingMoveFromPublicToPosda.pl $copy_id";
  for my $sop (keys %BySop){
    my $rfid = $BySop{$sop}->{replace_file_id};
    my $public_file_path = $BySop{$sop}->{dicom_file_uri};
    my $collection = $BySop{$sop}->{project};
    my $site = $BySop{$sop}->{site};
    my $site_id = $BySop{$sop}->{site_id};
    print HIDE "$rfid&$sop&<undef>\n";
    print MOVE "$collection&$site&$sop&$public_file_path\n";
  }
  close HIDE;
  close MOVE;
#  $set_status->RunQuery(sub{}, sub {},
#     "waiting for start", undef, $copy_id);
#  $background->WriteToEmail("Shutting down after first round of moves\n");
#  last loop;
}
$get_total_rows->RunQuery(sub {
  my($row) = @_; $total_rows = $row->[0];
},sub{}, $copy_id);
$get_rows_to_hide->RunQuery(sub {
  my($row) = @_; $rows_to_hide = $row->[0];
},sub{}, $copy_id);
$get_rows_to_copy->RunQuery(sub {
  my($row) = @_; $rows_to_copy = $row->[0];
},sub{}, $copy_id);
$get_rows_hidden->RunQuery(sub {
  my($row) = @_; $rows_hidden = $row->[0];
},sub{}, $copy_id);
$get_rows_copied->RunQuery(sub {
  my($row) = @_; $rows_copied = $row->[0];
},sub{}, $copy_id);
$set_status->RunQuery(sub{}, sub {},
     "copy completed", undef, $copy_id);
$tt = `date`;
chomp $tt;
$background->WriteToEmail("$tt: Exiting loop\n" .
  "copy_from_public_id = $copy_id\n" .
  "total rows = $total_rows\n" .
  "rows_to_hide = $rows_to_hide\n" .
  "rows_to_copy = $rows_to_copy\n" .
  "rows_hidden = $rows_hidden\n" .
  "rows_copied = $rows_copied\n"
);
$background->Finish;
