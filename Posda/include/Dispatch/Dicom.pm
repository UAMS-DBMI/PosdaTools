#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Dispatch/Dicom.pm,v $
#$Date: 2015/02/23 22:36:07 $
#$Revision: 1.24 $

use strict;
use Dispatch::Select;
use Dispatch::Acceptor;
use Dispatch::Dicom::Assoc;
use Dispatch::Queue;
use File::Find;
use IO::Socket;
use Posda::Command;
use HexDump;
{
  package Dispatch::Dicom::PdataAssembler;
  sub new {
    my($class, $len) = @_;
    my $this = {
      pdu_length => $len,
      pdu_remaining => $len,
    };
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW: $this\n";
    }
    return $this;
  }
  sub crank {
    my($this, $dcm_conn) = @_;
    unless(defined $this->{pdv_header}){
      unless(length($dcm_conn->{buff}) eq $dcm_conn->{to_read}){
        return;
      }
      $this->{pdu_remaining} -= 6;
      my $len = length($dcm_conn->{buff});
      my($pdv_len, $pc_id, $flags) =
        unpack("NCC", $dcm_conn->{buff});
      my $cmd = $flags & 1;
      my $last = $flags & 2;
      $this->{pdv_header} = {
         cmd => $cmd,
         pc_id => $pc_id,
         last  => $last,
         len => $pdv_len,
      };
      $dcm_conn->{to_read} = $pdv_len - 2;
      $dcm_conn->{buff} = "";
      unless(exists $dcm_conn->{message_being_received}){
        unless($this->{pdv_header}->{cmd}){
          return($this->Abort("ds pdv with no command"));
        }
        $dcm_conn->{message_being_received} =
          Dispatch::Dicom::Message->new(
            $this->{pdv_header}->{pc_id}, $dcm_conn);
      }
      return;
    }
    my $length_read = length($dcm_conn->{buff});
    $this->{pdu_remaining} -= $length_read;
    $dcm_conn->{to_read} -= $length_read;
    if(exists $dcm_conn->{message_being_received}){
      if($this->{pdv_header}->{cmd}){
        $dcm_conn->{message_being_received}->command_data(
          $this->{pdv_header}->{pc_id}, $dcm_conn->{buff});
        if($dcm_conn->{to_read} == 0 && $this->{pdv_header}->{last}){ 
          $dcm_conn->{message_being_received}->finalize_command($dcm_conn);
          unless($dcm_conn->{message_being_received}->has_dataset){
            delete $dcm_conn->{message_being_received};
          }
        }
      } else {
        $dcm_conn->{message_being_received}->ds_data(
          $this->{pdv_header}->{pc_id}, $dcm_conn->{buff});
        if($dcm_conn->{to_read} == 0 && $this->{pdv_header}->{last}){ 
          $dcm_conn->{message_being_received}->finalize_ds($dcm_conn);
          delete $dcm_conn->{message_being_received};
        }
      }
      $dcm_conn->{buff} = "";
      if($dcm_conn->{to_read} == 0){
        delete $this->{pdv_header};
        if($this->{pdu_remaining} == 0){
          delete $dcm_conn->{pdata_assembler};
          delete $dcm_conn->{pdu_type};
        }
      }
    }
    $dcm_conn->{buff} = "";
    return;
  }
  sub DESTROY{
    my($this) = @_;
    if($ENV{POSDA_DEBUG}){
      print "DESTROY: $this\n";
    }
  }
}
{
  package Dispatch::Dicom::Connection;
  use vars qw( @ISA );
  @ISA = ( "Dispatch::DebugHandler" );
  sub new_negot {
    my($class, $socket, $negot, $descrip) = @_;
    my $this = {
      socket => $socket,
      state => "STA2",
      negot_callback => $negot,
      incoming_message_handler => $descrip->{incoming_message_handler},
      storage_root => $descrip->{storage_root},
      message_queue => [],
      response_queue => [],
      type => "acceptor",
      mess_seq => 1,
    };
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW: $this\n";
    }
    return $this;
  }
  sub new_accept {
    my($class, $socket, $descrip) = @_;
    my $this = {
      socket => $socket,
      state => "STA2",
      descrip => $descrip,
      incoming_message_handler => $descrip->{incoming_message_handler},
      storage_root => $descrip->{storage_root},
      message_queue => [],
      response_queue => [],
      type => "acceptor",
      mess_seq => 1,
    };
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW: $this\n";
    }
    return $this;
  }
  sub new_connect{
    my($class, $host, $port, $assoc_config, $con_config, $callback, $debug) 
      = @_;
    my $socket = IO::Socket::INET->new(
      PeerAddr => $host,
      PeerPort => $port,
      Proto => 'tcp',
      Timeout => 1,
      Blocking => 0,
    ) or die "Couldn't create socket ($!) for host $host, port: $port";
    my $this = {
      socket => $socket,
      state => "STA5",
      message_queue => [],
      response_queue => [],
      type => "initiator",
      mess_seq => 1,
    };
    for my $i (keys %{$con_config->{incoming_message_handler}}){
      $this->{incoming_message_handler}->{$i} =
        $con_config->{incoming_message_handler}->{$i};
    }
    if(defined $callback && ref($callback) eq "CODE"){
      $this->{connection_callback} = $callback;
    }
    my $a_assoc_rq = Dispatch::Dicom::AssocRq->new_from_descrip($assoc_config);
    $this->{assoc_rq} = $a_assoc_rq;
    bless $this, $class;
    if($debug){
      $this->Debug("connection to $host:$port");
    }
    $this->CreatePduReaderSta5($socket);
    $this->DebugMsg("Created Sta5 PduReader");
    $this->CreateOutputQueue($this->{socket});
    $this->DebugMsg("Created OutputQueue");
    $this->DebugMsg("queueing assoc_rq");
    $this->{output_queue}->queue($this->{assoc_rq}->encode());
    $this->DebugMsg("queued assoc_rq");
    if($ENV{DEBUG_POSDA}){
      print "NEW: $this\n";
    }
    return $this;
  }
  sub connect {
    my($class, $host, $port, $file, $callback, $overrides) = @_;
    my $socket = IO::Socket::INET->new(
      PeerAddr => $host,
      PeerPort => $port,
      Proto => 'tcp',
      Blocking => 0,
    ) or return undef;
    my $this = {
      socket => $socket,
      state => "STA5",
      message_queue => [],
      response_queue => [],
      type => "initiator",
      mess_seq => 1,
    };
    if(defined $callback && ref($callback) eq "CODE"){
      $this->{connection_callback} = $callback;
    }
    my $a_assoc_rq;
    if($overrides && ref($overrides) eq "HASH"){
      $a_assoc_rq = Dispatch::Dicom::AssocRq->new_from_file(
        $file, $this, $overrides
      );
    } else {
      $a_assoc_rq = Dispatch::Dicom::AssocRq->new_from_file($file, $this);
    }
    $this->{assoc_rq} = $a_assoc_rq;
    bless $this, $class;
    $this->CreatePduReaderSta5($socket);
    $this->CreateOutputQueue($this->{socket});
    $this->{output_queue}->queue($this->{assoc_rq}->encode());
    if($ENV{DEBUG_POSDA}){
      print "NEW: $this\n";
    }
    return $this;
  }
  sub SetDisconnectCallback{
    my($this, $callback) = @_;
    $this->{disconnect_callback} = $callback;
  }
  sub SetReleaseCallback{
    my($this, $callback) = @_;
    $this->{ReleaseIndication} = $callback;
  }
  sub SetEchoRequestCallback{
    my($this, $callback) = @_;
    $this->{echo_request_callback} = $callback;
  }
  sub SetDatasetReceivedCallback{
    my($this, $handler) = @_;
    $this->{file_handler} = $handler;
  }
  sub SetStorageRoot{
    my($this, $dir) = @_;
    $this->{storage_root} = $dir;
  }
  sub GetStorageRoot{
    my($this) = @_;
    return $this->{storage_root};
  }
  sub ReleaseOK{
    my($this) = @_;
    if(
      exists($this->{outgoing_message}) ||
      $#{$this->{message_queue}} >= 0
    ){
      return 0;
    }
    return 1;
  }
  sub Release{
    my($this) = @_;
    $this->{ReleaseRequested} = 1;
    if(exists $this->{waiting_for_message}){
      $this->{waiting_for_message}->post_and_clear();
      delete $this->{waiting_for_message};
    }
  }
  sub Echo{
    my($this, $resp) = @_;
    my $xfr_stx = '1.2.840.10008.1.2';
    my $echo = Posda::Command->new_verif_command();
    unless(exists $this->{sopcl}->{'1.2.840.10008.1.1'}->{$xfr_stx}){
      return($this->Abort("no presentation context for echo: $xfr_stx"));
    }
    my $pc_id = $this->{sopcl}->{'1.2.840.10008.1.1'}->{$xfr_stx};
    my $ma = Dispatch::Dicom::MessageAssembler->new(
      $pc_id, $echo, undef, $resp, $this->{debug}? "Echo Assembler" : undef);
    $this->QueueMessage($ma);
  }
  sub SetUpPresContexts{
    my($this) = @_;
    my $rq = $this->{assoc_rq};
    my $ac = $this->{assoc_ac};
    my %PresContexts;
    my %SopClasses;
    for my $pc_id (keys %{$ac->{presentation_contexts}}){
      my $xfr_stx = $ac->{presentation_contexts}->{$pc_id};
      my $sopcl = $rq->{presentation_contexts}->{$pc_id}->{abstract_syntax};
      if($xfr_stx){
        $PresContexts{$pc_id}->{abs_stx} = $sopcl;
        $PresContexts{$pc_id}->{xfr_stx} = $xfr_stx;
        $PresContexts{$pc_id}->{accepted} = 1;
        $SopClasses{$sopcl}->{$xfr_stx} = $pc_id;
      } else {
        $PresContexts{$pc_id}->{accepted} = 0;
        $PresContexts{$pc_id}->{reason} = $ac->{rejected_pc}->{$pc_id};
      }
    }
    $this->{pres_cntx} = \%PresContexts;
    $this->{sopcl} = \%SopClasses;
    if($this->{type} eq "initiator"){
      $this->{max_length} = $ac->{max_length};
      $this->{rcv_max} = $rq->{max_length};
    } else {
      $this->{max_length} = $rq->{max_length};
      $this->{rcv_max} = $ac->{max_length};
    }
    if(defined($ac->{max_i})){
      $this->{max_outstanding} = $ac->{max_i};
    } else {
      $this->{max_outstanding} = 1;
    }
    $this->{outstanding} = 0;
  }
  sub CreatePduReaderSta5{
    my($this, $socket) = @_;
    my $foo = sub {
      my($disp, $sock) = @_;
      unless(defined $this->{to_read}){ 
        $this->{to_read} = 6;
      }
      unless(defined $this->{buff}){$this->{buff} = "" }
      my $to_read = $this->{to_read} - length($this->{buff});
      my $offset = length $this->{buff};
      my $inp = sysread $sock, $this->{buff}, $to_read, $offset;
      unless(defined $inp) {
        my $msg = "error ($!) sysreading socket Sta5";
        $this->DebugMsg($msg);
        $disp->Remove();
        return($this->Close($msg));
      }
      if($inp == 0) {
        my $msg = "sysread 0 bytes Sta5";
        $this->DebugMsg($msg);
        $disp->Remove();
        return($this->Close($msg));
      }
      $this->DebugMsg("sysread $inp bytes of ($to_read) Sta5");
      unless($inp == $to_read){ return }
      unless(defined $this->{pdu_size}){
        ### here we have read a pdu header
        my($pdu_type, $uk, $pdu_length) = unpack("CCN", $this->{buff});
        $this->DebugMsg("pdu header type: $pdu_type len: $pdu_length");
        if($pdu_type == 3){
          my $contents;
          my $count = read($sock, $contents, 4);
          unless($count == 4){
            print STDERR "Error trying to read assoc_rq ($count vs 4)\n";
          }
          my($foo, $result, $source, $reason) = unpack("cccc", $contents);
#          print STDERR sprintf(
#            "this guy actually rejected my assoc_rq\n" .
#            "\tresult:\t%2x\n\tsource:\t%2x\n\treason:\t%2x\n",
#            $result, $source, $reason);
          $this->{AssociationRejection} = [$result, $source, $reason];
          $this->DebugMsg("Association rejected");
          if(defined $this->{connection_callback}){
            &{$this->{connection_callback}}($this);
          }
          return($this->Abort("Association rejected"));
        }
        unless($pdu_type == 2){
          $disp->Remove("reader");
        }
        $this->{pdu_size} = $pdu_length + 6;
        $this->{to_read} = $pdu_length;
        $this->{buff} = "";
        return;
      }
      $this->{assoc_ac} = Dispatch::Dicom::AssocAc->new_from_pdu(
        $this->{buff}
      );
      $disp->Remove("reader");
      $this->SetUpPresContexts();
      $this->CreateMessageQueueEmptier();
      $this->CreatePduReaderSta6($sock);
      if(defined $this->{connection_callback}){
        &{$this->{connection_callback}}($this);
      }
      delete $this->{buff};
    };
    my $disp = Dispatch::Select::Socket->new($foo, $socket, 
      $this->{debug} ? "Socket Reader Sta5" : undef
    );
    $disp->Add("reader");
  }
  sub queue {
    my($this, $string) = @_;
    my $len = length($string);
    $this->DebugMsg("queueing $len bytes to output queue");
    $this->{output_queue}->queue($string);
  }
  sub QueueResponse {
    my($this, $message) = @_;
    if(exists $this->{waiting_for_message}){
      if($this->{print_timings}){
        my $elapsed = Time::HiRes::tv_interval(
          $this->{start_waiting_for_message}, 
          [Time::HiRes::gettimeofday]
        );
        print "Queued a response after a wait of $elapsed seconds\n";
      }
      $this->{waiting_for_message}->post_and_clear();
      delete $this->{waiting_for_message};
    }
    $message->{cmd_data} = $message->{cmd}->render();
    push(@{$this->{response_queue}}, $message);
  }
  sub QueueMessage {
    my($this, $message) = @_;
    if(exists $this->{waiting_for_message}){
      if($this->{print_timings}){
        my $elapsed = Time::HiRes::tv_interval(
          $this->{start_waiting_for_message}, 
          [Time::HiRes::gettimeofday]
        );
        print "Queued a message after a wait of $elapsed seconds\n";
      }
      $this->{waiting_for_message}->post_and_clear();
      delete $this->{waiting_for_message};
    }
    $message->{cmd}->{"(0000,0110)"} = $this->{mess_seq};
    $this->{mess_seq} += 1;
    $message->{cmd_data} = $message->{cmd}->render();
    push(@{$this->{message_queue}}, $message);
  }
  sub CreateMessageTransmissionEndEvent{
    my($this) = @_;
    my $foo = sub {
      my($back) = @_;
      delete $this->{outgoing_message};
      $this->CreateMessageQueueEmptier();
    };
    return Dispatch::Select::Event->new(
      Dispatch::Select::Background->new($foo)
    );
  }
  sub DecrementOutstanding{
    my($this) = @_;
    $this->{outstanding} -= 1;
    if(
      exists($this->{waiting_for_message}) && 
      $#{$this->{message_queue}} >= 0
    ){
      if($this->{print_timings}){
        my $elapsed = Time::HiRes::tv_interval(
          $this->{start_waiting_for_message}, 
          [Time::HiRes::gettimeofday]
        );
        print "Re-opened message queue after a wait of $elapsed seconds\n";
      }
      $this->{waiting_for_message}->post_and_clear();
      delete $this->{waiting_for_message};
    }
  }
  sub WaitMessageQueue{
    my($this, $count, $back) = @_;
    if($count < (scalar @{$this->{message_queue}})){
      $back->queue();
      return;
    }
    $this->{WaitingForMessageQueue} = $back;
  }
  sub CreateMessageQueueEmptier {
    my($this) = @_;
    my $foo = sub {
      my($back) = @_;
      if(exists $this->{Abort}){
        my $rq = Dispatch::Dicom::Abort->new(2, 0);
        my $temp = $rq->encode;
        my $len = length($temp);
        $this->DebugMsg("Abort: queueing $len bytes to queue");
        $this->queue($temp);
        $this->CreatePduReaderSta13($this->{socket});
        return;
      } elsif($#{$this->{response_queue}} >= 0){
        $this->{outgoing_message} = shift(@{$this->{response_queue}});
      } elsif(
        $#{$this->{message_queue}} >= 0 &&
        (
          $this->{max_outstanding} == 0 ||
          $this->{outstanding} < $this->{max_outstanding}
        )
      ){
        my $msg = shift(@{$this->{message_queue}});
        if(exists $this->{WaitingForMessageQueue}){
          $this->{WaitingForMessageQueue}->queue();
          delete $this->{WaitingForMessageQueue};
        }
        $this->{outgoing_message} = $msg;
        $this->{pending_messages}->{$msg->msg_id} = $msg;
        $this->{outstanding} += 1;
        if(
          exists($msg->{ds}) && $msg->{ds} &&
          $msg->{ds}->can("start")
        ){ $msg->{ds}->start }
      } elsif($this->{ReleaseRequested}) {
        my $rq = Dispatch::Dicom::ReleaseRq->new($this->{buff});
        my $temp = $rq->encode;
        my $len = length($temp);
        $this->queue($temp);
        $this->DebugMsg("ReleaseRq $len bytes");
        $this->CreatePduReaderSta8($this->{socket});
        return;
      } else {
        if($this->{print_timings}){
          $this->{start_waiting_for_message} = [Time::HiRes::gettimeofday];
        }
        $this->{waiting_for_message} = Dispatch::Select::Event->new($back);
        return;
      }
      $this->{outgoing_message}->CreatePduAssembler($this->{output_queue},
        $this->{max_length}, $this->CreateMessageTransmissionEndEvent());
    };
    my $back = Dispatch::Select::Background->new($foo);
    $back->queue();
  }
  sub CreatePduReaderSta6{
    my($this, $socket) = @_;
    my $foo = sub {
      my($disp, $sock) = @_;
      unless(defined $this->{pdu_type} || $this->{to_read} == 6){
        $this->{to_read} = 6;
        $this->{buff} = "";
      }
      my $to_read = $this->{to_read} - length($this->{buff});
      my $offset = length $this->{buff};
      if($to_read > 0){
        my $inp = sysread $sock, $this->{buff}, $to_read, $offset;
        unless(defined $inp) {
          my $msg = "error ($!) sysreading socket Sta6";
          $this->DebugMsg($msg);
          $disp->Remove();
          return($this->Close($msg));
        }
        if($inp == 0) { 
          $this->DebugMsg("sysread 0 bytes Sta6");
          $disp->Remove();
          return($this->Close("sysread 0 bytes in Sta6"));
        }
        $this->DebugMsg("sysread $inp bytes of ($to_read) Sta6");
        unless($inp == $to_read){ return }
      }
      unless(defined $this->{pdu_type}){
        my($pdu_type, $uk, $pdu_length) = unpack("CCN", $this->{buff});
        $this->DebugMsg("pdu header type: $pdu_type len: $pdu_length");
        $this->{pdu_type} = $pdu_type;
        $this->{buff} = "";
        $this->{pdu_length} = $pdu_length;
      }
      if(defined $this->{pdata_assembler}){
        $this->{pdata_assembler}->crank($this);
        return;
      }
      if($this->{finishing_release}){
        my $resp = Dispatch::Dicom::ReleaseRp->new();
        my $temp = $resp->encode;
        my $len = length($temp);
        $this->queue($temp);
        $this->DebugMsg("ReleaseRp $len bytes");
        $disp->Remove("reader");
        $this->CreatePduReaderSta13($socket);
      }
      my $pdu_type = $this->{pdu_type};
      if($pdu_type == 1){      # Assoc-RQ
        $disp->Remove("reader");
        $this->Abort("Invalid Pdu (Assoc-RQ) in Sta6");
      } elsif($pdu_type == 2){ # Assoc-AC
        $disp->Remove("reader");
        $this->Abort("Invalid Pdu (Assoc-AC) in Sta6");
      } elsif($pdu_type == 3){ # Assoc-RJ
        $disp->Remove("reader");
        $this->Abort("Invalid Pdu (Assoc-RJ) in Sta6");
      } elsif($pdu_type == 4){ # Data-TF
        $this->{pdata_assembler} = 
          Dispatch::Dicom::PdataAssembler->new($this->{pdu_length});
        $this->{to_read} = 6;
        $this->{buff} = "";
      } elsif($pdu_type == 5){ # Release-RQ
        if($this->{type} eq "initiator"){
          my $contents;
          my $count = read($sock, $contents, 4);
          unless($count == 4){
            print STDERR "Error trying to read assoc_rq ($count vs 4)\n";
          }
          my($foo, $result, $source, $reason) = unpack("cccc", $contents);
          print STDERR "##################\n" .
          "## Got a Release-RQ when I'm initiator\n" .
          "## Probably an attempt to abort\n" .
          "## result: $result\n" .
          "## source: $source\n" .
          "## reason: $reason\n" .
          "##################\n";
          if(
            exists($this->{ReleaseIndication}) &&
            ref($this->{ReleaseIndication}) eq "CODE"
          ){
            &{$this->{ReleaseIndication}}($result, $source, $reason);
          } else {
            print STDERR "No ReleaseIndication handler\n";
          }
        } else {
          $this->{finishing_release} = 1;
          $this->{to_read} = 4;
        }
      } elsif($pdu_type == 6){ # Release-RP
        $disp->Remove("reader");
        $this->Abort("Invalid Pdu (Release-RP) in Sta6");
      } elsif($pdu_type == 7){ # Abort
        $disp->Remove();
        my $contents;
        my $count = read($sock, $contents, 4);
        my($foo, $result, $source, $reason);
        if($count == 4){
          ($foo, $result, $source, $reason) = unpack("cccc", $contents);
        } else {
          print STDERR "Error trying to read abort_rq ($count vs 4)\n";
        }
        $this->Close("Abort Request Received ($result, $source, $reason)");
      }
    };
    my $disp = Dispatch::Select::Socket->new($foo, $socket,
      $this->{debug} ? "Socket Reader Sta6" : undef
    );
    $disp->Add("reader");
  }
  sub Close{
    my($this, $mess) = @_;
    if(defined $mess){
      $this->DebugMsg("Close: $mess");
    } else {
      $this->DebugMsg("Close: (normal)");
    }
    if($mess){
      $this->{close_status} = "Abnormal: $mess";
      $this->{Abort}->{mess} = "Abnormal: $mess";
    } elsif(exists $this->{Abort}){
      $this->{close_status} = "Abnormal: $this->{Abort}->{mess}";
    } else {
      $this->{close_status} = "OK";
    }
    close($this->{socket});
    delete $this->{socket};
    if($this->{waiting_for_message}){
      delete $this->{waiting_for_message};
    }
    if(
      exists($this->{disconnect_callback}) && 
      ref($this->{disconnect_callback}) eq "CODE"
    ){
      &{$this->{disconnect_callback}}($this);
    }
    if(
      exists($this->{message_being_received}) &&
      $this->{message_being_received}->can("abort")
    ){
      $this->{message_being_received}->abort();
    }
  }
  sub Abort{
    my($this, $mess) = @_;
    $this->DebugMsg("Abort: $mess");
    $this->{Abort} = {
      mess => $mess,
    };
    if(exists $this->{waiting_for_message}){
      $this->{waiting_for_message}->post_and_clear();
      delete $this->{waiting_for_message};
    } elsif(exists $this->{outgoing_message}){
      $this->{outgoing_message}->Abort();
    }
    for my $i (@{$this->{message_queue}}){
      $i->Abort();
    }
    if(
      exists($this->{disconnect_callback}) && 
      ref($this->{disconnect_callback}) eq "CODE"
    ){
      &{$this->{disconnect_callback}}($this);
    }
  }
  sub CreatePduReaderSta2{
    my($this, $socket) = @_;
    my $foo = sub {
      my($disp, $sock) = @_;
      unless(defined $this->{to_read}){ 
        $this->{to_read} = 6;
      }
      unless(defined $this->{buff}){$this->{buff} = "" }
      my $to_read = $this->{to_read} - length($this->{buff});
      my $offset = length $this->{buff};
      my $inp = sysread $sock, $this->{buff}, $to_read, $offset;
      unless(defined $inp) {
        my $msg = "error ($!) sysreading socket Sta2";
        $this->DebugMsg($msg);
        $disp->Remove();
        return($this->Close($msg));
      }
      if($inp == 0) {
        $this->DebugMsg("sysread 0 bytes Sta2");
        $disp->Remove();
        return($this->Close("sysread 0 bytes Sta2"));
      }
      $this->DebugMsg("sysread $inp bytes of ($to_read) Sta2");
      unless($inp == $to_read){ return }
      unless(defined $this->{pdu_size}){
        ### here we have read a pdu header
        my($pdu_type, $uk, $pdu_length) = unpack("CCN", $this->{buff});
        $this->DebugMsg("pdu header type: $pdu_type len: $pdu_length");
        unless($pdu_type == 1){
          $disp->Remove("reader");
          $this->Abort("invalid type pdu: $pdu_type in Sta2");
        }
        $this->{pdu_size} = $pdu_length + 6;
        $this->{to_read} = $pdu_length;
        $this->{buff} = "";
        return;
      }
      $this->{assoc_rq} = Dispatch::Dicom::AssocRq->new_from_pdu(
        $this->{buff}
      );
      ############
      #  Here's where negotiation goes
      ############
      my $resp;
      if(exists $this->{negot_callback}){
        $resp = &{$this->{negot_callback}}($this, $this->{assoc_rq});
        unless(ref($resp) eq "Dispatch::Dicom::AssocAc"){
          unless(ref($resp) eq "Dispatch::Dicom::AssocRj"){
            print STDERR "Negotiation routine returned other than " .
              "Assoc_AC or Assoc_RJ.  Treated as Assoc_RJ\n";
            $resp = Dispatch::Dicom::AssocRj->new_unknown;
          }
          # here is where sequencing for association rejection goes
          #  Send an AssocRJ
          #  set timer
          #  proceed to state 13
          $this->{assoc_rj} = $resp;
          my $temp = $resp->encode;
          my $len = length($temp);
          $this->queue($temp);
          $this->DebugMsg("AssocRj: queueing $len bytes to queue");
          $disp->Remove("reader");
          delete $this->{pdu_type};
          delete $this->{buff};
          $this->CreatePduReaderSta13($socket);
          return;
        }
      } else {
        $resp = Dispatch::Dicom::AssocAc->new_from_rq_desc(
           $this->{assoc_rq}, $this->{descrip}
        );
      }
      $this->{assoc_ac} = $resp;
      my $temp = $resp->encode;
      my $len = length($temp);
      $this->queue($temp);
      $this->DebugMsg("AssocAc: queueing $len bytes to queue");
      $disp->Remove("reader");
      delete $this->{pdu_type};
      delete $this->{buff};
      $this->CreatePduReaderSta6($sock);
      $this->CreateMessageQueueEmptier();
      $this->SetUpPresContexts();
      if(defined($this->{connection_callback})){
        &{$this->{connection_callback}}($this);
      }
    };
    my $disp = Dispatch::Select::Socket->new($foo, $socket,
      $this->{debug} ? "Socket Reader Sta2" : undef
    );
    $disp->Add("reader");
  }
  sub CreatePduReaderSta8{
    my($this, $socket) = @_;
    my $foo = sub {
      my($disp, $sock) = @_;
      unless(defined $this->{to_read}){ 
        $this->{to_read} = 6;
      }
      unless(defined $this->{buff}){$this->{buff} = "" }
      my $to_read = $this->{to_read} - length($this->{buff});
      my $offset = length $this->{buff};
      my $inp = sysread $sock, $this->{buff}, $to_read, $offset;
      unless(defined $inp) {
         my $msg = "error ($!) sysreading socket Sta8";
        $this->DebugMsg($msg);
         return($this->Close($msg))
      }
      if($inp == 0) {
        $this->DebugMsg("sysread 0 bytes");
        return($this->Close("read 0 bytes Sta8"));
      }
      $this->DebugMsg("sysread $inp bytes of ($to_read)");
      unless($inp == $to_read){ return }
      unless(defined $this->{pdu_size}){
        ### here we have read a pdu header
        my($pdu_type, $uk, $pdu_length) = unpack("CCN", $this->{buff});
        $this->DebugMsg("pdu header type: $pdu_type len: $pdu_length");
        $this->{pdu_type} = $pdu_type;
        $this->{buff} = "";
        $this->{pdu_length} = $pdu_length;
        $this->{to_read} = $pdu_length;
        unless($pdu_type == 6){
          $disp->Remove();
          return($this->Abort(
            "Invalid pdu ($pdu_type) when waiting for ReleaseRQ"
          ));
        }
        $this->{pdu_size} = 4;
        $this->{to_read} = 4;
        return();
      }
      # here we just read a release rsp (in response to release rq)
      $disp->Remove();
      if($this->{ReleaseRequested}){
        $this->Close();
      } else {;
        $this->Close("how did we get here? Sta8");
      }
    };
    delete $this->{to_read};
    delete $this->{buff};
    delete $this->{pdu_size};
    my $disp = Dispatch::Select::Socket->new($foo, $socket,
      $this->{debug} ? "Socket Reader Sta8" : undef
    );
    $disp->Add("reader");
  }
  sub CreatePduReaderSta13{
    my($this, $socket) = @_;
    my $foo = sub {
      my($disp, $sock) = @_;
      my $buff;
      my $inp = sysread $sock, $buff, 1024;
      unless(defined $inp) { 
        $this->DebugMsg("undef sysreading socket");
        $disp->Remove();
        return($this->Close("Closed socket on sysread (Sta13)"));
      }
      if($inp == 0) {
        # Normal place to close after sending release
        $this->DebugMsg("sysread 0 bytes");
        $disp->Remove();
        return($this->Close());
      } else {
        if($inp == 4) {
          my($abt_status) = unpack("L", $buff);
          $this->DebugMsg(sprintf("Abort status in Sta13: %04x", $abt_status));
          return $this->Close(sprintf("Abort status %04x", $abt_status))
        } else {
          $this->DebugMsg("sysread $inp bytes of extra in Sta13");
          print STDERR "Extra stuff in Sta13:\n";
          HexDump::PrintVax(\*STDERR, $buff, 0);
          return $this->Close("$inp Extra bytes at close");
        }
      }
    };
    delete $this->{to_read};
    delete $this->{buff};
    delete $this->{pdu_size};
    my $disp = Dispatch::Select::Socket->new($foo, $socket,
       $this->{debug}? "Socket Reader Sta13" : undef
      );
    $disp->Add("reader");
  }
  sub CreateOutputQueue{
    my($this, $socket) = @_;
    $this->{output_queue} = Dispatch::Queue->new(5, 2, 
      $this->{debug} ? "Assoc Output Queue": undef);
    $this->{output_queue}->CreateQueueEmptierEvent($socket);
  }
  sub DESTROY {
    my($this) = @_;
    if($ENV{POSDA_DEBUG}){
      print "DESTROY: $this\n";
    }
    my($dicom) = $this;
    if(
      exists($dicom->{output_queue}) &&
      defined($dicom->{output_queue}) &&
      $dicom->{output_queue}->can("finish")
    ){
      $dicom->{output_queue}->finish();
    }
  }
}
{
  package Dispatch::Dicom::Acceptor;
  use vars qw ( @ISA );
  @ISA = ( "Dispatch::Select::Socket" );
  sub new_with_negot{
    my($class, $port, $negot_callback, $conn_callback) = @_;
    my $foo = sub{
      my($this, $socket) = @_;
      my $dicom = Dispatch::Dicom::Connection->new_negot($socket, 
        $negot_callback);
      $dicom->CreatePduReaderSta2($socket);
      $dicom->CreateOutputQueue($socket);
      #$dicom->CreateMessageQueueEmptier();
      if(defined $conn_callback && ref($conn_callback) eq "CODE"){
        $dicom->{connection_callback} = $conn_callback;
      }
    };
    my $serv = Dispatch::Acceptor->new($foo)->port_server($port);
    bless $serv, $class;
    if($ENV{DEBUG_POSDA}){
      print "NEW: $serv\n";
    }
    return $serv
  }
  sub new {
    my($class, $port, $file, $call_back) = @_;
    my $descrip;
    if(-f $file) {
      $descrip = $class->parse_descrip($file);
    } else {
      $descrip = $file;
    }
    my $foo = sub {
      my($this, $socket) = @_;
      my $dicom = Dispatch::Dicom::Connection->new_accept($socket, $descrip);
      $dicom->CreatePduReaderSta2($socket);
      $dicom->CreateOutputQueue($socket);
      #$dicom->CreateMessageQueueEmptier();
      if(defined $call_back && ref($call_back) eq "CODE"){
        $dicom->{connection_callback} = $call_back;
      }
    };
    my $serv = Dispatch::Acceptor->new($foo)->port_server($port);
    bless $serv, $class;
    if($ENV{DEBUG_POSDA}){
      print "NEW: $serv\n";
    }
    return $serv
  }
  sub parse_descrip{
    my($class, $file) = @_;
    my $descrip = {};
    {
      open FILE, "<$file" or die "can't open $file";
      line:
      while(my $line = <FILE>){
        chomp $line;
        if($line =~ /^#/) { next line }
        unless($line =~ /^([a-z_]+):\s*(.*)\s*$/) { next line }
        my $type = $1;
        my $fields = $2;
        my @fields_array = split(/\|/, $fields);
        if($type eq "ae_title"){
          $descrip->{ae_title} = $fields_array[0];
        } elsif($type eq "allowed_calling_ae_titles"){
          for my $i (@fields_array){
            $descrip->{allowed_calling_ae_titles}->{$i} = 1;
          }
        } elsif($type eq "app_context"){
          $descrip->{app_context} = $fields_array[0];
        } elsif($type eq "imp_class_uid"){
          $descrip->{imp_class_uid} = $fields_array[0];
        } elsif($type eq "imp_ver_name"){
          $descrip->{imp_ver_name} = $fields_array[0];
        } elsif($type eq "protocol_version"){
          $descrip->{protocol_version} = $fields_array[0];
        } elsif($type eq "max_length"){
          $descrip->{max_length} = $fields_array[0];
        } elsif($type eq "num_invoked"){
          $descrip->{num_invoked} = $fields_array[0];
        } elsif($type eq "num_performed"){
          $descrip->{num_performed} = $fields_array[0];
        } elsif($type eq "storage_root"){
          $descrip->{storage_root} = $fields_array[0];
        } elsif($type eq "assoc_normal_close"){
          $descrip->{assoc_normal_close} = $fields_array[0];
        } elsif(
          $type eq "storage_pres_context" ||
          $type eq "delayed_storage_pres_context" ||
          $type eq "verification_pres_context"
        ){
          for my $i (1 .. $#fields_array){
            $descrip->{pres_contexts}->
             {$fields_array[0]}->{$fields_array[$i]} = 1;
          }
          if($type eq "storage_pres_context"){
            $descrip->{incoming_message_handler}->{$fields_array[0]} =
              "Dispatch::Dicom::Storage";
          }
          if($type eq "delayed_storage_pres_context"){
            $descrip->{incoming_message_handler}->{$fields_array[0]} =
              "Dispatch::Dicom::StorageWithDelay";
          }
          if($type eq "verification_pres_context"){
            $descrip->{incoming_message_handler}->{$fields_array[0]} =
              "Dispatch::Dicom::Verification";
          }
        }
      }
      close FILE;
    }
    return $descrip;
  }
  sub DESTROY {
    my($this) = @_;
    if($ENV{POSDA_DEBUG}){
      print "DESTROY: $this\n";
    }
  }
}
1;
