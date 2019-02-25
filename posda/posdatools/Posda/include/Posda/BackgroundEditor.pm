#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::UUID;
use Posda::DownloadableFile; use Dispatch::Select;
use Dispatch::EventHandler;
use Dispatch::LineReader;
use Digest::MD5;
use FileHandle;
use Storable qw( store retrieve fd_retrieve store_fd );use Data::UUID;
  package Posda::BackgroundEditor;
  use Posda::DB 'Query';
  use vars qw( @ISA );
  @ISA = ( "Dispatch::EventHandler" );
  sub new{
    my($class, $list, $hash, $invoc_id, $notify, $back) = @_;
    my $this = {
     list_of_files => $list,
      file_hash => $hash,
      files_in_process => {},
      files_completed => {},
      compare_requests => {},
      comparing => {},
      compares_complete => {},
      compares_failed => {},
      start_time => time(),
      invoc_id => $invoc_id,
      notify => $notify,
      back => $back,
    };
    bless($this, $class);
    my $at_text = $this->now;
    $this->{back}->WriteToEmail("Starting at: $at_text\n");
    delete $this->{process_pending};
    $this->InvokeAfterDelay("RestartProcessing", 0);
    $this->{CompareSubprocess} = Dispatch::LineReader->NewWithTrickleWrite(
      "StreamingEditCompare.pl $this->{invoc_id} 2>/dev/null",
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
        exists $this->{file_hash} &&
        ref($this->{file_hash}) eq "HASH"
      ){
        $total_to_process = keys %{$this->{file_hash}};
      } else { $total_to_process = 0 }
      if(
        exists $this->{files_in_process} &&
        ref($this->{files_in_process}) eq "HASH"
      ){
        $num_in_process = keys %{$this->{files_in_process}};
      } else { $num_in_process = 0 }
      if(
        exists $this->{list_of_files} &&
        ref($this->{list_of_files}) eq "ARRAY"
      ){
        $num_waiting = keys @{$this->{list_of_files}};
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
        $num_compares_failed, $this->{invoc_id});
      if($this->{WeAreDone}) {
        my $finalize = Query("FinalizeDicomEditCompareDisposition");
        $finalize->RunQuery(sub{},sub{}, $this->{invoc_id});
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
        $this->{back}->WriteToEmail($report);
        print STDERR $report;
        if($this->{WeAreDone}) { 
          $this->{back}->Finish;
          exit;
        };
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
    my $num_simul = 10;
    my $num_in_process = keys %{$this->{files_in_process}};
    my $num_waiting = @{$this->{list_of_files}};
    my $num_comparing = keys %{$this->{comparing}};
    my $num_queued_for_compare = keys %{$this->{compare_requests}};
    while(
      $num_in_process < $num_simul && $num_waiting > 0
    ){
      my $next_file = shift @{$this->{list_of_files}};
      my $next_struct = $this->{file_hash}->{$next_file};
      $this->{files_in_process}->{$next_file} = $next_struct;
      $this->SerializedSubProcess($next_struct,
        "NewSubprocessEditor.pl 2>/dev/null",
        $this->WhenEditDone($next_file, $next_struct));
      $num_in_process = keys %{$this->{files_in_process}};
      $num_waiting = @{$this->{list_of_files}};
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
    my($this, $file, $struct) = @_;
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
        $this->QueueCompareRequest($file, $c_struct);
      } else {
        $this->{compares_failed}->{$file} = {
          edits => $struct,
          status => $status,
          report => $ret_struct,
        };
      }
      delete $this->{files_in_process}->{$file};
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
        my($file, $from_file, $to_file,$s_id, $l_id) = split(/\|/, $remain);
        delete $this->{comparing}->{$file};
        $this->{compares_complete}->{$file} = 1;
      } elsif($line =~ /Failed:\s*(.*)$/){
        my $remain = $1;
        my($file, $mess) = split(/\|/, $remain);
        delete $this->{comparing}->{$file};
        $this->{compares_failed}->{$file} = $mess;
        my $num_failed = keys %{$this->{compares_failed}};
        if($num_failed == 10){
          $this->{back}->WriteToEmail("...\n");
        } elsif(($num_failed % 1000) == 0) {
          $this->{back}->WriteToEmail("1000 failures ...\n");
        } elsif($num_failed < 10) {
          $this->{back}->WriteToEmail("Compare failed:\n\tfile:$file\n" .
          "\tmessage: $mess\n");
        }
      } else {
        $this->{back}->WriteToEmail(
          "Bad line from Compare: \"$line\"\n" .
          "Aborting (and finishing so email shows)\n");
        $this->{back}->Finish;
        exit;
      }
      # here is where we check from being done
      my $num_in_process = keys %{$this->{files_in_process}};
      my $num_waiting = @{$this->{list_of_files}};
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
    my $rpt_pipe = $this->{back}->CreateReport("EditDifferences");
    $rpt_pipe->print("\"Short Report\"," .
      "\"Long Report\",\"short_file_id\",\"long_file_id\",\"num_files\"\r\n");
    my $rpt_pipe1 = $this->{back}->CreateReport("ShortEditDifferences");
    $rpt_pipe1->print("\"Short Report\"," .
      "\"short_file_id\",\"num_files\"\r\n");

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
      class_ => "Posda::ProcessPopup",
      cap_ => "RejectEdits",
      subprocess_invoc_id => $this->{invoc_id},
      notify => $this->{notify}
    };
    $this->{back}->InsertEmailButton($caption, $op, $param_hash);
    $op = "ScriptButton";
    $caption = "Accept Edits, Import and Delete Temporary Files";
    $param_hash = {
      op => "OpenTableFreePopup",
      class_ => "Posda::ProcessPopup",
      cap_ => "ImportEdits",
      subprocess_invoc_id => $this->{invoc_id},
      notify => $this->{notify}
    };
    $this->{back}->InsertEmailButton($caption, $op, $param_hash);
###############
    my $at_text = $this->now;
    $this->{back}->WriteToEmail("Ending at: $at_text\n");
    $this->{back}->WriteToEmail("$num_edited edited, $num_failed failed in " .
      "$elapsed seconds\n");
    $this->{back}->WriteToEmail("Invocation Id: $this->{invoc_id}\n");
    $this->{WeAreDone} = 1;
  }
1;
