#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::UUID;
use Posda::DownloadableFile;
use Dispatch::Select;
use Dispatch::EventHandler;
use Dispatch::LineReader;
use Digest::MD5;
use FileHandle;
use Storable qw( store retrieve fd_retrieve store_fd );
use Data::UUID;
  package Posda::BackgroundComparePublicPosda;
  use Posda::DB 'Query';
  use vars qw( @ISA );
  @ISA = ( "Dispatch::EventHandler" );
  sub new{
    my($class, $hash, $invoc_id, $notify, $back) = @_;
    my $this = {
      sop_hash => $hash,
      sops_in_process => {},
      sops_completed => {},
      sops_errored => {},
      start_time => time(),
      invoc_id => $invoc_id,
      notify => $notify,
      back => $back,
    };
    my $num_submitted = keys %$hash;
    $this->{num_submitted} = $num_submitted;
    bless($this, $class);
    my $at_text = $this->now;
    $this->{back}->WriteToEmail("Starting at: $at_text\n");
    $this->{CompareSubprocess} = Dispatch::LineReader->NewWithTrickleWrite(
      "StreamingPublicPosdaCompare.pl $this->{invoc_id} 2>/dev/null",
#      "StreamingPublicPosdaCompare.pl $this->{invoc_id}",
      $this->FeedDifferencer,
      $this->HandleInputFromCompare,
      $this->HandleEndOfInputFromCompare
    );
    $this->{CompareSubprocess}->StartWriter;
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
      my($num_submitted, $num_waiting, 
        $num_comparing, $compares_complete, $compares_failed);
      $num_submitted = $this->{num_submitted};
      if(
        exists $this->{sop_hash} &&
        ref($this->{sop_hash}) eq "HASH"
      ){
        $num_waiting = keys %{$this->{sop_hash}};
      } else { $num_waiting = 0 }
      if(
        exists $this->{sops_in_process} &&
        ref($this->{sops_in_process}) eq "HASH"
      ){
        $num_comparing = keys %{$this->{sops_in_process}};
      } else { $num_comparing = 0 }
      if(
        exists $this->{sops_completed} &&
        ref($this->{sops_completed}) eq "HASH"
      ){
        $compares_complete = keys %{$this->{sops_completed}};
      } else { $compares_complete = 0 }
      if(
        exists $this->{sops_errored} &&
        ref($this->{sops_errored}) eq "HASH"
      ){
        $compares_failed = keys %{$this->{sops_errored}};
      } else { $compares_failed = 0 }
      unless(defined $this->{update_q}){
        $this->{update_q} = Query("UpdateComparePublicToPosdaInstance");
      }
      $this->{update_q}->RunQuery(sub {}, sub {}, 
        $compares_complete,
        $compares_failed, $this->{invoc_id});
      if($this->{WeAreDone}) {
        my $finalize = Query("FinalizeComparePublicToPosdaInstance");
        $finalize->RunQuery(sub{},sub{}, $this->{invoc_id});
      }
      if($count <= 0 || $this->{WeAreDone}){
        $count = $int_count;
        my $elapsed = time - $this->{start_time};
        my $report =
          "#############################\n" .
          "Posda::BackgroundComparePublicPosda running report\n" .
          "After $elapsed seconds ($at_text):\n" .
          "\tSubmitted:          $num_submitted\n" .
          "\tWaiting:            $num_waiting\n" .
          "\tComparing:          $num_comparing\n" .
          "\tCompares complete:  $compares_complete\n" .
          "\tCompares failed:    $compares_failed\n";
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
  sub FeedDifferencer{
    my($this) = @_;
    my $sub = sub {
      my $num_to_send = keys %{$this->{sop_hash}};
      if($num_to_send > 0){
        my $next_to_send = [keys %{$this->{sop_hash}}]->[0];
        my $next_struct = $this->{sop_hash}->{$next_to_send};
        my $file_id = $next_struct->{file_id};
        my $from = $next_struct->{path};
        my $to = $next_struct->{public_path};
        my $id = $next_struct->{subprocess_invocation_id};
        delete $this->{sop_hash}->{$next_to_send};
        my $command = "$next_to_send|$file_id|$from|$to";
        $this->{comparing}->{$next_to_send} = $next_struct;
        return $command;
      } else {
        $this->{CompareSubprocess}->ShutdownWriter;
        return undef;
      }
    };
    return $sub;
  }
  sub HandleInputFromCompare{
    my($this) = @_;
    my $sub = sub{
      my($line) = @_;
      if($line =~ /Completed:\s*(.*)$/){
        my $remain = $1;
        my($sop, $file_id, $from_file, $to_file) = split(/\|/, $remain);
        delete $this->{comparing}->{$sop};
        $this->{sops_completed}->{$sop} = 1;
      } elsif($line =~ /Failed:\s*(.*)$/){
        my $remain = $1;
        my($sop, $mess) = split(/\|/, $remain);
        delete $this->{comparing}->{$sop};
        $this->{sops_errored}->{$sop} = $mess;
        $this->{back}->WriteToEmail("Compare failed:\n\tsop:$sop\n" .
          "\tmessage: $mess\n");
      } else {
        $this->{back}->WriteToEmail(
          "Unexpected line back from StreamingPublicPosdaCompare.pl:\n" .
          "\t$line\n"
        );
      }
    };
    return $sub;
  }
  sub HandleEndOfInputFromCompare{
    my($this) = @_;
    my $sub = sub{
      $this->AtTheEnd;
    };
    return $sub;
  }
  sub AtTheEnd{
    my($this) = @_;
#compare_requests##############
    my $rpt_pipe = $this->{back}->CreateReport("EditDifferences");
    $rpt_pipe->print("\"Short Report\"," .
      "\"Long Report\",\"short_file_id\",\"long_file_id\",\"num_files\"\r\n");
    my $rpt_pipe1 = $this->{back}->CreateReport("ShortEditDifferences");
    $rpt_pipe1->print("\"Short Report\"," .
      "\"short_file_id\",\"num_files\"\r\n");

    my $elapsed  = time - $this->{start_time};
    my $compares_complete = keys %{$this->{sops_completed}};
    my $num_failed = keys %{$this->{sops_errored}};
    my %data;
    my $num_rows = 0;
    my $get_list = Query("PosdaPublicDifferenceReportByEditId");
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
###############
    my $at_text = $this->now;
    $this->{back}->WriteToEmail("Ending at: $at_text\n");
    $this->{back}->WriteToEmail("$compares_complete compared, " .
      "$num_failed failed in " .
      "$elapsed seconds\n");
    $this->{back}->WriteToEmail("Invocation Id: $this->{invoc_id}\n");
    $this->{WeAreDone} = 1;
  }
1;
