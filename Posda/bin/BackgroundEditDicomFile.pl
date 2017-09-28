#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::BackgroundProcess;
use Posda::UUID;
use Posda::DownloadableFile; use Dispatch::Select;
use Dispatch::EventHandler;
use Dispatch::LineReader;
use Digest::MD5;
use FileHandle;
use Storable qw( store retrieve fd_retrieve store_fd );
#use Debug;
#my $dbg = sub { print STDERR @_ };
$| = 1; # this should probably be at the top of the script, maybe in the lib?

my $usage = <<EOF;
Usage:
BackgroundEditDicomFile.pl <bkgrnd_id> <dest_root> <who> <edit_desciption> <notify>
or
BackgroundEditDicomFile.pl -h


Expects lines of the formh:
<command>&<arg1>&<arg2>&<arg3>&<arg4>

Each line is a command.  A command may be either a control command, an
edit accumulation command, or a ProcessFiles command.

Generally, edits files specifed by list of commands, into hierarchy
based on collection, site, patient, study, and series underneath the <dest_root>
also records information about the edits performed in the database
also imports the new files into the database.
also prepares a spreadsheet summarizing the edits, stores it into Posda and
includes a URL to download it in the email.

When invoked, processes STDIN and writes to STDOUT a summary of the operations
it will perform.  Then forks a sub-process and exits (after closing
both STDIN and STDOUT, so parent will get result).

When the sub-process completes, it sends a notification email.

NOTE: you shouldn't run this for duplicate SOPs (its bad practice).  In general
  only one file will be edited per affected SOP Instance UID.

BackgroundEditDicomFile may run for a long time.

Control Commands:
  AddFile <arg1> = <file_name>, <arg2> = <modality>, <arg3> =
    SOP Instance UID.
    Starts the accumulation of edit commands to apply a single file.
    This accumulation terminates when the ProcessFiles command is 
    encountered.
  AddSop <arg1> = <sop_instance_uid>
    Same as AddFile except it does so by sop_instance_uid.  The file
    will be selected using the query named "FirstFileForSopPosda".
  AddSopsInSeries <arg1> = <series_instance_uid> like AddFile or
    AddSop, except that the edits accumulated will be applied to
    all the files in the specified series. Uses the query named
    "FilesInSeriesForApplicationOfPrivateDisposition" to get list of
    files, and Sops.
  AddFilesBySeriesPublic <arg1> = <series_instance_uid> like AddFile or
    AddSop, except that the edits accumulated will be applied to
    all the files in the specified series in the Public (nbia) database.
    Uses the query named "FilesInSeriesForApplicationOfPrivateDispositionPublic" 
    to get list of files, and Sops.
  AccumulateEdits - Start accumulating edits in following lines.
Accumulation Commands:
  The <command> is always 'edit',  <arg1> specifies the type of edit:
    uid_substitution - <arg2> = <from_uid>, <arg3> = <to_uid>
    hash_unhashed_uid - <arg2> = <leaf element>, <arg3> = <uid_root>
    short_ele_substitution - <arg2> = <leaf element>, <arg3> = <old_value>,
       <arg4> = <new_value>
    short_ele_replacement - <arg2> = <leaf element>, <arg3> = <new_value>
    full_ele_substitution - <arg2> = <full element>, <arg3> = <old_value>,
       <arg4> = <new_value>
    full_ele_replacement - <arg2> = <full element>, <arg3> = <new_value>
    full_ele_delete - <arg2> = <full element>
    full_ele_addition - <arg2> = <full element>, <arg3> = <new_value>
    leaf_delete - <arg2> = <leaf element>
ProcessFiles command:
   Applies all of the accumulated edits to the file[s] set in the active
   control command. Clear list of SOPs.  Expect Control Commands to follow.
Uses SubProcessEditor.pl to perform edits
EOF
my %SopsToEdit;
sub CheckFiles{
  my($from_file, $to_file, $sop) = @_;
  unless(exists $SopsToEdit{$sop}){
    $SopsToEdit{$sop} = {
      from_file => $from_file,
      to_file => $to_file,
    };
  }
  my $sop_p = $SopsToEdit{$sop};
  unless(
    $sop_p->{from_file} eq $from_file &&
    $sop_p->{to_file} eq $to_file
  ){
    print "SOP vs file collision:\n" .
      "\tSOP: $sop\n" .
      "\tFrom:\n" .
      "\t\t$sop_p->{from_file}\n" .
      "\tvs\n" .
      "\t\t$from_file\n" .
      "\tTo:\n" .
      "\t\t$sop_p->{to_file}\n" .
      "\tvs\n" .
      "\t\t$to_file\n" .
      "Editing transaction aborted\n";
     die "abort";
  }
  return $sop_p;
}
if($#ARGV == 0) { die "$usage\n\n" }
if($#ARGV != 4){ print "Wrong args: $usage\n"; die "$usage\n\n" }
my $getf = PosdaDB::Queries->GetQueryInstance('FirstFileForSopPosda');
my $getfs = PosdaDB::Queries->GetQueryInstance(
  'FilesInSeriesForApplicationOfPrivateDisposition');
my $getfsp = PosdaDB::Queries->GetQueryInstance(
  'FilesInSeriesForApplicationOfPrivateDispositionPublic');
my($invoc_id, $DestRoot, $who, $description, $notify) = @ARGV;

my $background = Posda::BackgroundProcess->new($invoc_id, $notify);


my $wdir = Posda::UUID::GetGuid;
my $WorkDir = "$DestRoot/$wdir";
unless(mkdir($WorkDir) == 1) {
  die "Couldn't mkdir $WorkDir ($!)";
}
my $pstate = "Search";
my $working_file_list = [];
line:
while(my $line = <STDIN>){
  chomp $line;
  ######?????
  $line =~ s/^\s+//;  ###WTF?
  ######
  my($command, $arg1, $arg2, $arg3, $arg4) = split /&/, $line;
  $background->LogInputLine($line);

  if($pstate eq "Search"){
    if($command eq "AddFile"){
      my $from_file = $arg1;
      my $modality = $arg2;
      my $sop = $arg3;
      my $to_file = "$WorkDir/$modality" . "_$sop.dcm";
      push @$working_file_list, [$from_file, $modality, $sop, $to_file];
    } elsif ($command eq "AddSop"){
      $getf->RunQuery(sub {
          my($row) = @_;
          my $from_file = $row->[0];
          my $modality = $row->[1];
          my $sop = $arg1;
          my $to_file = "$WorkDir/$modality" . "_$sop.dcm";
          push @$working_file_list, [$from_file, $modality, $sop, $to_file];
        }, sub {}, $arg1);
    } elsif ($command eq "AccumulateEdits"){
      $pstate = "AccumulateEdits";
    } elsif ($command eq "AddSopsInSeries"){
      $getfs->RunQuery(sub {
          my($row) = @_;
          my($from_file, $sop, $modality) = @$row;
          my $to_file = "$WorkDir/$modality" . "_$sop.dcm";
          push @$working_file_list, [$from_file, $modality, $sop, $to_file];
        }, sub {}, $arg1);
    } elsif ($command eq "AddFilesBySeriesPublic"){
      $getfsp->RunQuery(sub {
          my($row) = @_;
          my($from_file, $sop, $modality) = @$row;
          my $to_file = "$WorkDir/$modality" . "_$sop.dcm";
          unless($from_file =~ /.*\/storage(\/.*)$/){
            print "Can't translate public path to nfs path:\n" .
              "\t$from_file\n". 
              "Aborting\n";
            die "abort";
          }
          $from_file = "/mnt/public-nfs/storage" . $1;
          push @$working_file_list, [$from_file, $modality, $sop, $to_file];
        }, sub {}, $arg1);
    } else {
      print "Invalid line: \"$line\" in state $pstate\n" .
        "Editing transaction aborted\n";
      die "abort";
    }
    next line;
  } elsif($pstate eq "AccumulateEdits"){
    if($command eq "ProcessFiles"){
      $working_file_list = [];
      $pstate = "Search";
      next line;
    } elsif($command eq "edit"){
      for my $f (@$working_file_list){
        my($from_file, $modality, $sop, $to_file) = @$f;
        unless(exists $SopsToEdit{$sop}){
          $SopsToEdit{$sop} = {
            from_file => $from_file,
            to_file => $to_file,
          };
        }
        my $sop_p = CheckFiles($from_file, $to_file, $sop);
        if($arg1 eq "uid_substitution"){
          my $from_uid = $arg2;
          my $to_uid = $arg3;
          unless(exists $sop_p->{uid_substitution}->{$from_uid}){
            $sop_p->{uid_substitution}->{$from_uid} = $to_uid;
          }
          unless($sop_p->{uid_substitution}->{$from_uid} eq $to_uid){
            print "Conflicting uid translation:\n" .
              "from: $from_uid to both:\n" .
              "\t$to_uid\n" .
              "\t$sop_p->{uid_substitution}->{$from_uid}\n" .
              "Editing transaction aborted\n";
            die "abort";
          }
        }elsif($arg1 eq "hash_unhashed_uid"){
          my $leaf_ele = $arg2;
          my $uid_root = $arg3;
          unless(exists $sop_p->{hash_unhashed_uid}->{$leaf_ele}){
            $sop_p->{hash_unhashed_uid}->{$leaf_ele} = $uid_root;
          }
          unless($sop_p->{hash_unhashed_uid}->{$leaf_ele} eq $uid_root){
            print "Conflicting uid hash:\n" .
              "ele: $leaf_ele to both:\n" .
              "\t$uid_root\n" .
              "\t$sop_p->{hash_unhashed_uid}->{$leaf_ele}\n" .
              "Editing transaction aborted\n";
            die "abort";
          }
        }elsif($arg1 eq "short_ele_substitution"){
          my $leaf_ele = $arg2;
          my $old_v = $arg3;
          my $new_v = $arg4;
          unless(
            exists $sop_p->{short_ele_substitutions}->{$old_v}
          ){
            $sop_p->{short_ele_substitutions}->{$old_v} = $new_v;
          }
          unless(
            $sop_p->{short_ele_substitutions}->{$old_v} eq $new_v
          ){
            print "Conflicting short_ele substitution:\n" .
              "ele: $leaf_ele from $old_v to both:\n" .
              "\t$sop_p->{sort_ele_substitutions}->{$leaf_ele}->{$old_v}\n" .
              "\t$new_v\n" .
              "Editing transaction aborted\n";
            die "abort";
          }
        }elsif($arg1 eq "short_ele_replacement"){
          my $leaf_ele = $arg2;
          if($leaf_ele =~ /^<(.*)>$/){ $leaf_ele = $1 }
          my $new_v = $arg3;
        }elsif($arg1 eq "full_ele_substitution"){
          my $ele = $arg2;
          if($ele =~ /^<(.*)>$/){ $ele = $1 }
          my $old_v = $arg3;
          my $new_v = $arg4;
          unless(
            exists $sop_p->{full_ele_substitutions}->{$ele}->{$old_v}
          ){
            $sop_p->{full_ele_substitutions}->{$ele}->{$old_v} = $new_v;
          }
          unless(
            $sop_p->{full_ele_substitutions}->{$ele}->{$old_v} eq $new_v
          ){
            print "Conflicting full_ele substitution:\n" .
              "ele: $ele from $old_v to both:\n" .
              "\t$sop_p->{full_ele_substitutions}->{$ele}->{$old_v}\n" .
              "\t$new_v\n" .
              "Editing transaction aborted\n";
            die "abort";
          }
        }elsif($arg1 eq "full_ele_replacement"){
          my $ele = $arg2;
          if($ele =~ /^<(.*)>$/){ $ele = $1 }
          my $new_v = $arg3;
          unless(
            exists $sop_p->{full_ele_replacements}->{$ele}
          ){
            $sop_p->{full_ele_replacements}->{$ele} = $new_v;
          }
          unless(
            $sop_p->{full_ele_replacements}->{$ele} eq $new_v
          ){
            print "Conflicting full_ele_replacement:\n" .
              "ele: $ele to both:\n" .
              "\t$sop_p->{full_ele_replacements}->{$ele}\n" .
              "\t$new_v\n" .
              "Editing transaction aborted\n";
            die "abort";
          }
        }elsif($arg1 eq "full_ele_delete"){
          my $ele = $arg2;
          if($ele =~ /^<(.*)>$/){ $ele = $1 }
          $sop_p->{full_ele_deletes}->{$ele} = 1;
        }elsif($arg1 eq "full_ele_addition"){
          my $ele = $arg2;
          if($ele =~ /^<(.*)>$/){ $ele = $1 }
          my $new_v = $arg3;
          unless(
            exists $sop_p->{full_ele_additions}->{$ele}
          ){
            $sop_p->{full_ele_additions}->{$ele} = $new_v;
          }
          unless(
            $sop_p->{full_ele_additions}->{$ele} eq $new_v
          ){
            print "Conflicting full_ele_additions:\n" .
              "ele: $ele to both:\n" .
              "\t$sop_p->{full_ele_additions}->{$ele}\n" .
              "\t$new_v\n" .
              "Editing transaction aborted\n";
            die "abort";
          }
        }elsif($arg1 eq "leaf_delete"){
          my $leaf_ele = $arg2;
          if($leaf_ele =~ /^<(.*)>$/){ $leaf_ele = $1 }
          $sop_p->{leaf_delete}->{$leaf_ele} = 1;
        }else{
          print "Unrecognized edit: \"$line\"\n" .
            "Editing transaction aborted\n";
          die "abort";
        }
      }
    } else {
      print "Non edit in $pstate: \"$line\"\n" .
        "Editing transaction aborted\n";
      die "abort";
    }
  } else {
    die "Invalid State $pstate";
  }
}
my $num_sops = keys %SopsToEdit;
print "Found list of $num_sops to edit\nForking background process\n";
$getf = undef;
$getfs = undef;
$getfsp = undef;
$background->Daemonize;
my $rpt_pipe = $background->CreateReport("EditDifferences");
$rpt_pipe->print("\"Short Report\"," .
  "\"Long Report\",\"short_file_id\",\"long_file_id\",\"num_files\"\r\n");
$background->WriteToEmail("Starting edits on $num_sops sop_instance_uids\n" .
  "Description: $description\n" .
  "Results dir: $WorkDir\n");
$background->WriteToEmail("About to enter Dispatch Environment\n");


{
  package Editor;
  use vars qw( @ISA );
  @ISA = ( "Dispatch::EventHandler" );
  sub new{
    my($class, $list, $hash, $invoc_id) = @_;
    my $this = {
      list_of_sops => $list,
      sop_hash => $hash,
      sops_in_process => {},
      sops_completed => {},
      sops_failed => {},
      compare_requests => {},
      comparing => {},
      compare_complete => {},
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
    my $count = 60; # 60 10 second intervals
    my $sub = sub {
      my($disp) = @_;
      $count -= 10;
      if($count <= 0 || $this->{WeAreDone}){
        $count = 60;
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
          exists $this->{sops_failed} &&
          ref($this->{sops_failed}) eq "HASH"
        ){
          $num_compares_failed = keys %{$this->{compares_failed}};
        } else { $num_compares_failed = 0 }
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
        if($this->{WeAreDone}) { print "We are done\n" }
        $report .= "#############################\n";
        $background->WriteToEmail($report);
        print STDERR $report;
if(exists $this->{CompareSubprocess}){
  $this->{CompareSubprocess}->AdHocDebug;
}
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
        "SubProcessEditor.pl 2>/dev/null",
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
        $this->{sops_failed}->{$sop} = {
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
      } else {
        print STDERR
          "!!!!!!!!!!!!!!!!!!!!!!!!!!!!  Auuuuugh!!!!!!!!!!!!!!!!!!!\n" .
          "!!!!!!!  You idiot !!!!!!!!!!!!" .
          "Bad line: \"$line\"\n" .
          "!!!!!!!!! Always have default case !!!!!!!!";
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
    my $num_edited = keys %{$this->{sops_completed}};
    my $num_failed = keys %{$this->{sops_failed}};
    my %data;
    my $num_rows = 0;
    my $get_list = PosdaDB::Queries->GetQueryInstance(
      "DifferenceReportByEditId");
    $get_list->RunQuery(sub {
        my($row) = @_;
        my($short_report_file_id, $long_report_file_id, $num_files) = @$row;
        $num_rows += 1;
        $data{$short_report_file_id}->{$long_report_file_id} = $num_files;
      }, sub {}, $this->{invoc_id});
    my $num_short = keys %data;
    my $get_path = PosdaDB::Queries->GetQueryInstance("GetFilePath");
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
sub MakeEditor{
  my($sop_list, $sop_hash, $invoc_id) = @_;
  my $sub = sub {
    my($disp) = @_;
    Editor->new($sop_list, $sop_hash, $invoc_id);
  };
  return $sub;
}
{
  my @sops = sort keys %SopsToEdit;
  Dispatch::Select::Background->new(
    MakeEditor(\@sops, \%SopsToEdit, $invoc_id))->queue;
}
Dispatch::Select::Dispatch();
