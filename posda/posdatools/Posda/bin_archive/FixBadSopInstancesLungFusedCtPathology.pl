#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::UUID;
use Posda::DownloadableFile;
use Posda::PrivateDispositions;
use Dispatch::Select;
use Dispatch::EventHandler;
use Dispatch::LineReader;
use Digest::MD5;
use FileHandle;
use Storable qw( store retrieve fd_retrieve store_fd );
use Data::UUID;
our $ug = Data::UUID->new;
sub get_uuid {
  return lc $ug->create_str();
}

use Debug;
my $dbg = sub { print @_ };
$| = 1; # this should probably be at the top of the script, maybe in the lib?

my $usage = <<EOF;
Usage:
FixBadSopInstancesLungFusedCtPathology.pl <bkgrnd_id> <notify>
or
FixBadSopInstancesLungFusedCtPathology.pl -h
Expects no lines on STDIN

EOF
#Inputs will be parsed into these data structures
my %FilesToEdit;
# $FilesToEdit = {
#   <file_id> => {
#     from_file => <from_file>,
#     to_file => <to_file>,
#     edits => [
#       {
#         op => "set_tag",
#         tag => "(0008,0018)",
#         tag_mode => "exact",
#         arg1 => <new unique UID>,
#         arg2 => "",
#       },
#       {
#         op => "set_tag",
#         tag => "(0020,0052)",
#         tag_mode => "exact",
#         arg1 => <frame of reference from CT>,
#         arg2 =>  "",
#       },
#     ]
#   },
#   ...
# };
#

if($#ARGV == 0) { die "$usage\n\n" }
if($#ARGV != 1){ print "Wrong args: $usage\n"; die "$usage\n\n" }
my($invoc_id, $notify) = @ARGV;

my $description = "Giving Poorly produced SOPs in Lung-Fused-CT-Pathology ".
  "New SOP instance_uids and proper frame_of_reference_uids";

#############################
# Compute the Destination Dir (and die if it already exists)
my $sub_dir = get_uuid();
my $CacheDir = $ENV{POSDA_CACHE_ROOT};
unless(-d $CacheDir){
  print "Error: Cache dir ($CacheDir) isn't a directory\n";
}
my $EditDir = "$CacheDir/edits";
unless(-d $EditDir){
  unless(mkdir($EditDir) == 1){
    print "Error: can't mkdir $EditDir ($!)";
    exit;
  }
}
my $DestDir = "$EditDir/$sub_dir";
if(-e $DestDir) {
  print "Error: Destination dir ($DestDir) already exists\n";
  exit;
}
unless(mkdir($DestDir) == 1){
  print "Error: can't mkdir $DestDir ($!)";
  exit;
}

#############################
## This creates the Edits (i.e it populates %FilesToEdit)
#
my $get_sops = Query('GetSopsInSeriesforLGCP');
my $get_files = Query('GetFilesToEditBySopForLGCP');
Query('GetTheBaseCtSeriesForLGCP')->RunQuery(sub {
  my($row) = @_;
  my($pat_id, $series_uid, $num_files) = @$row;
  $get_sops->RunQuery(sub {
    my($row) = @_;
    my($sop_inst, $source_file_id, $for_uid) = @$row;
    $get_files->RunQuery(sub{
      my($row) = @_;
      my $new_sop_inst = Posda::PrivateDispositions->NewSopInstanceBasedOn($sop_inst);
      my($file_id, $path) = @$row;
      my $edt = {
        from_file => $path,
        to_file => "$DestDir/$new_sop_inst.dcm",
        edits => [
          {
            op => "set_tag",
            tag => "(0008,0018)",
            tag_mode => "exact",
            arg1 => $new_sop_inst,
            arg2 => "",
          },
          {
            op => "set_tag",
            tag => "(0020,0052)",
            tag_mode => "exact",
            arg1 => $for_uid,
            arg2 => "",
          }
        ],
      };
      $FilesToEdit{$file_id} = $edt;
    }, sub {}, $sop_inst, $series_uid);
  }, sub {}, $series_uid);
}, sub {});

#############################
## Uncomment these lines when testing just the processing of
## input
## Only do this for small test cases - it generates a lot of
## rows in subprocess_lines and chews up a lot of time, etc.
#print "FilesToEdit ";
#Debug::GenPrint($dbg, \%FilesToEdit, 1);
#exit;
#############################

my $num_files = keys %FilesToEdit;
print "Found list of $num_files to edit\n";
print "Directory: $DestDir\n";
print "Subprocess_invocation_id: $invoc_id\n";
print "Forking background process\n";
#############################
# This is code which sets up the Background Process and Starts it
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->Daemonize;
my $BackgroundPid = $$;
# now in the background...
$background->WriteToEmail("Starting edits on $num_files files\n" .
  "Description: $description\n" .
  "Results dir: $DestDir\n" .
  "Subprocess_invocation_id: $invoc_id\n");
$background->WriteToEmail("About to enter Dispatch Environment\n");
my $rpt_pipe = $background->CreateReport("EditDifferences");
$rpt_pipe->print("\"Short Report\"," .
  "\"Long Report\",\"short_file_id\",\"long_file_id\",\"num_files\"\r\n");
my $rpt_pipe1 = $background->CreateReport("ShortEditDifferences");
$rpt_pipe1->print("\"Short Report\"," .
  "\"short_file_id\",\"num_files\"\r\n");

# Create row in dicom_edit_compare_disposition
my $ins = Query("CreateDicomEditCompareDisposition");
$ins->RunQuery(sub {}, sub{}, $invoc_id, $BackgroundPid, $DestDir);

# skip to after editor definition to enter dispatch

##############  This is the editor object which handles events

{
  package Editor;
  use Posda::DB 'Query';
  use vars qw( @ISA );
  @ISA = ( "Dispatch::EventHandler" );
  sub new{
    my($class, $list, $hash, $invoc_id) = @_;
    my $this = {
     list_of_sops => $list,
      sop_hash => $hash,
      sops_in_process => {},
      sops_completed => {},
      compare_requests => {},
      comparing => {},
      compares_complete => {},
      compares_failed => {},
      start_time => time(),
      invoc_id => $invoc_id,
    };
    bless($this, $class);
    my $at_text = $this->now;
    $background->WriteToEmail("Starting at: $at_text\n");
    delete $this->{process_pending};
    $this->InvokeAfterDelay("RestartProcessing", 0);
    $this->{CompareSubprocess} = Dispatch::LineReader->NewWithTrickleWrite(
      "StreamingEditCompare.pl $invoc_id 2>/dev/null",
      $this->FeedDifferencer,
      $this->HandleInputFromCompare,
      $this->HandleEndOfInputFromCompare
    );
    Dispatch::Select::Background->new($this->CountPrinter)->timer(10);
    return $this;
  }

  sub CountPrinter{
    my($this) = @_;
    my $int_count = 360;      # 360 10 second intervals (1 hour)
    my $count = $int_count;
    my $sub = sub {
      my($disp) = @_;
      $count -= 1;
      my $at_text = $this->now;
      my($num_in_process, $num_waiting, $num_queued_for_compare,
        $num_comparing, $num_compares_complete, $num_compares_failed,
        $total_to_process);
      if(
        exists $this->{sop_hash} &&
        ref($this->{sop_hash}) eq "HASH"
      ){
        $total_to_process = keys %{$this->{sop_hash}};
      } else { $total_to_process = 0 }
      if(
        exists $this->{sops_in_process} &&
        ref($this->{sops_in_process}) eq "HASH"
      ){
        $num_in_process = keys %{$this->{sops_in_process}};
      } else { $num_in_process = 0 }
      if(
        exists $this->{list_of_sops} &&
        ref($this->{list_of_sops}) eq "ARRAY"
      ){
        $num_waiting = keys @{$this->{list_of_sops}};
      } else { $num_waiting = 0 }
      if(
        exists $this->{compare_requests} &&
        ref($this->{compare_requests}) eq "HASH"
      ){
        $num_queued_for_compare = keys %{$this->{compare_requests}};
      } else { $num_queued_for_compare = 0 }
      if(
        exists $this->{comparing} &&
        ref($this->{comparing}) eq "HASH"
      ){
        $num_comparing = keys %{$this->{comparing}};
      } else { $num_comparing = 0 }
      if(
        exists $this->{compares_complete} &&
        ref($this->{compares_complete}) eq "HASH"
      ){
        $num_compares_complete = keys %{$this->{compares_complete}};
      } else { $num_comparing = 0 }
      if(
        exists $this->{compares_failed} &&
        ref($this->{compares_failed}) eq "HASH"
      ){
        $num_compares_failed = keys %{$this->{compares_failed}};
      } else { $num_compares_failed = 0 }
      unless(defined $this->{update_q}){
        $this->{update_q} = Query("UpdateDicomEditCompareDisposition");
      }
      $this->{update_q}->RunQuery(sub {}, sub {},
        $total_to_process, $num_compares_complete,
        $num_compares_failed, $invoc_id);
      if($this->{WeAreDone}) {
        my $finalize = Query("FinalizeDicomEditCompareDisposition");
        $finalize->RunQuery(sub{},sub{}, $invoc_id);
      }
      if($count <= 0 || $this->{WeAreDone}){
        $count = $int_count;
        my $elapsed = time - $this->{start_time};
        my $report =
          "#############################\n" .
          "BackgroundEditDicomFile.pl running report\n" .
          "After $elapsed seconds ($at_text):\n" .
          "\tTotal to process:   $total_to_process\n" .
          "\tIn process:         $num_in_process\n" .
          "\tWaiting:            $num_waiting\n" .
          "\tQueued for compare: $num_queued_for_compare\n" .
          "\tComparing           $num_comparing\n" .
          "\tCompares complete:  $num_compares_complete\n" .
          "\tCompares failed:    $num_compares_failed\n";
        if($this->{WeAreDone}) {
          $report .= "We are done\n";
        }
        $report .= "#############################\n";
        $background->WriteToEmail($report);
        print STDERR $report;
        if($this->{WeAreDone}) { exit };
      }
      unless($this->{WeAreDone}){
        $disp->timer(10);
      }
    };
    return $sub;
  }

  sub StartProcessing{
    my($this) = @_;
    delete $this->{process_pending};
    my $num_simul = 8;
    my $num_in_process = keys %{$this->{sops_in_process}};
    my $num_waiting = @{$this->{list_of_sops}};
    my $num_comparing = keys %{$this->{comparing}};
    my $num_queued_for_compare = keys %{$this->{compare_requests}};
    while(
      $num_in_process < $num_simul && $num_waiting > 0
    ){
      my $next_sop = shift @{$this->{list_of_sops}};
      my $next_struct = $this->{sop_hash}->{$next_sop};
      $this->{sops_in_process}->{$next_sop} = $next_struct;
      $this->SerializedSubProcess($next_struct,
        "NewSubprocessEditor.pl 2>/dev/null",
        $this->WhenEditDone($next_sop, $next_struct));
      $num_in_process = keys %{$this->{sops_in_process}};
      $num_waiting = @{$this->{list_of_sops}};
    }
    if(
      $num_waiting == 0 &&
      $num_in_process == 0 &&
      $num_comparing == 0 &&
      $num_queued_for_compare == 0
    ){
      $this->AtTheEnd;
    }
  }

  sub WhenEditDone{
    my($this, $sop, $struct) = @_;
    my $sub = sub {
      my($status, $ret_struct) = @_;
      my $from_file = $struct->{from_file};
      my $to_file = $struct->{to_file};
      if($status eq "Succeeded" && $ret_struct->{Status} eq "OK"){
        my $c_struct = {
          subprocess_invocation_id => $this->{invoc_id},
          from_file_path => $from_file,
          to_file_path => $to_file,
        };
        $this->QueueCompareRequest($sop, $c_struct);
      } else {
        $this->{compares_failed}->{$sop} = {
          edits => $struct,
          status => $status,
          report => $ret_struct,
        };
      }
      delete $this->{sops_in_process}->{$sop};
      $this->RestartProcessing;
    };
  }
  sub RestartProcessing{
    my($this) = @_;
    unless(exists $this->{process_pending}){
      $this->{process_pending} = 1;
      $this->InvokeAfterDelay("StartProcessing", 0);
    }
  }

  sub HandleInputFromCompare{
    my($this) = @_;
    my $sub = sub{
      my($line) = @_;
      if($line =~ /Completed:\s*(.*)$/){
        my $remain = $1;
        my($sop, $from_file, $to_file,$s_id, $l_id) = split(/\|/, $remain);
        delete $this->{comparing}->{$sop};
        $this->{compares_complete}->{$sop} = 1;
      } elsif($line =~ /Failed:\s*(.*)$/){
        my $remain = $1;
        my($sop, $mess) = split(/\|/, $remain);
        delete $this->{comparing}->{$sop};
        $this->{compares_failed}->{$sop} = $mess;
        $background->WriteToEmail("Compare failed:\n\tsop:$sop\n" .
          "\tmessage: $mess\n");
      } else {
        print STDERR
          "!!!!!!!!!!!!!!!!!!!!!!!!!!!!  Auuuuugh!!   !!!!!!!!!!!!!!!!!\n" .
          "!!!!!!!  You idiot!  !!!!!!!!!!!!" .
          "Bad line: \"$line\"\n" .
          "!!!!!!!!! Always have default case !!!!!!!!";
        $background->WriteToEmail(
          "!!!!!!!!!!!!!!!!!!!!!!!!!!!!  Auuuuugh!!!!!!!!!!!!!!!!!!!\n" .
          "!!!!!!!  You idiot !!!!!!!!!!!!" .
          "Bad line: \"$line\"\n" .
          "!!!!!!!!! Always have default case !!!!!!!!\n");
        exit;
      }
      # here is where we check from being done
      my $num_in_process = keys %{$this->{sops_in_process}};
      my $num_waiting = @{$this->{list_of_sops}};
      my $num_comparing = keys %{$this->{comparing}};
      my $num_queued_for_compare = keys %{$this->{compare_requests}};
      if(
         $num_waiting == 0 &&
         $num_in_process == 0 &&
         $num_comparing == 0 &&
         $num_queued_for_compare == 0
      ){
        # if so, shutdown writer (after returning undef)
        my $writer = $this->{CompareSubprocess};
        Dispatch::Select::Background->new(sub {
          my($disp) = @_;
          $writer->ShutdownWriter;
        })->queue;
        delete $this->{CompareSubprocess};
      }
    };
    return $sub;
  }
  sub HandleEndOfInputFromCompare{
    my($this) = @_;
    my $sub = sub{
      $this->RestartProcessing;
    };
    return $sub;
  }

  sub FeedDifferencer{
    my($this) = @_;
    my $sub = sub {
      my $num_to_send = keys %{$this->{compare_requests}};
      if($num_to_send > 0){
        my $next_to_send = [keys %{$this->{compare_requests}}]->[0];
        my $next_struct = $this->{compare_requests}->{$next_to_send};
        my $from = $next_struct->{from_file_path};
        my $to = $next_struct->{to_file_path};
        my $id = $next_struct->{subprocess_invocation_id};
        delete $this->{compare_requests}->{$next_to_send};
        my $command = "$next_to_send|$from|$to";
        $this->{comparing}->{$next_to_send} = $command;
        return $command;
      } else {
        # Here we can't check to see if all have been queued
        # (We can't shutdown writer without losing contents
        # backed up in pipes);
        return undef;
      }
    };
    return $sub;
  }
  sub QueueCompareRequest{
    my($this, $key, $value) = @_;
    my $existing_request_count  = keys %{$this->{compare_requests}};
    $this->{compare_requests}->{$key} = $value;
    if($existing_request_count == 0){
      $this->{CompareSubprocess}->StartWriter;
    }
  }
  sub AtTheEnd{
    my($this) = @_;
###############
    my $elapsed  = time - $this->{start_time};
    my $num_edited = keys %{$this->{compares_complete}};
    my $num_failed = keys %{$this->{compares_failed}};
    my %data;
    my $num_rows = 0;
    my $get_list = Query("DifferenceReportByEditId");
    $get_list->RunQuery(sub {
        my($row) = @_;
        my($short_report_file_id, $long_report_file_id, $num_files) = @$row;
        $num_rows += 1;
        $data{$short_report_file_id}->{$long_report_file_id} = $num_files;
      }, sub {}, $this->{invoc_id});
    my $num_short = keys %data;
    my $get_path = Query("GetFilePath");
    for my $short_id (keys %data){
      my $short_seen = 0;
      for my $long_id (keys %{$data{$short_id}}){
        my $num_files = $data{$short_id}->{$long_id};
        my $short_rept = "-";
        my $long_rept = "";
        unless($short_seen){
          $short_seen = 1;
          $get_path->RunQuery(sub{
            my($row) = @_;
            my $file = $row->[0];
            $short_rept = `cat $file`;
            chomp $short_rept;
          }, sub {}, $short_id);
        }
        $get_path->RunQuery(sub{
          my($row) = @_;
          my $file = $row->[0];
          $long_rept = `cat $file`;
          chomp $long_rept;
        }, sub {}, $long_id);
        $short_rept =~ s/"/""/g;
        $long_rept =~ s/"/""/g;
        $rpt_pipe->print("\"$short_rept\"," .
          "\"$long_rept\",$short_id,$long_id,$num_files\r\n");
      }
    }
    for my $short_id (keys %data){
      my $shorts_seen = 0;
      my $short_rept;
      $get_path->RunQuery(sub{
        my($row) = @_;
        my $file = $row->[0];
        $short_rept = `cat $file`;
        chomp $short_rept;
      }, sub {}, $short_id);
      $short_rept =~ s/"/""/g;
      for my $long_id (keys %{$data{$short_id}}){
        my $num_files = $data{$short_id}->{$long_id};
        $shorts_seen += $num_files;
      }
      $rpt_pipe1->print("\"$short_rept\",$short_id, $shorts_seen\r\n");
    }
    my $op = "ScriptButton";
    my $caption = "Reject Edits and Delete Temporary Files";
    my $param_hash = {
      op => "OpenTableFreePopup",
      class_ => "Posda::NewerProcessPopup",
      cap_ => "RejectEdits",
      subprocess_invoc_id => $this->{invoc_id},
      notify => $notify
    };
    $background->InsertEmailButton($caption, $op, $param_hash);
    $op = "ScriptButton";
    $caption = "Accept Edits, Import and Delete Temporary Files";
    $param_hash = {
      op => "OpenTableFreePopup",
      class_ => "Posda::NewerProcessPopup",
      cap_ => "ImportEdits",
      subprocess_invoc_id => $this->{invoc_id},
      notify => $notify
    };
    $background->InsertEmailButton($caption, $op, $param_hash);
###############
    my $at_text = $this->now;
    $background->WriteToEmail("Ending at: $at_text\n");
    $background->WriteToEmail("$num_edited edited, $num_failed failed in " .
      "$elapsed seconds\n");
    $background->WriteToEmail("Invocation Id: $this->{invoc_id}\n");
    $background->Finish;
    $this->{WeAreDone} = 1;
  }
}
##############  This is the end of editor object which handles events

#
# The code which follows is used to create an instance of this object
# and turn it over to the Dispatcher
#

sub MakeEditor{
  my($file_list, $file_hash, $invoc_id) = @_;
  my $sub = sub {
    my($disp) = @_;
    Editor->new($file_list, $file_hash, $invoc_id);
  };
  return $sub;
}
{
  my @files = sort keys %FilesToEdit;
  Dispatch::Select::Background->new(
    MakeEditor(\@files, \%FilesToEdit, $invoc_id))->queue;
}
Dispatch::Select::Dispatch();
