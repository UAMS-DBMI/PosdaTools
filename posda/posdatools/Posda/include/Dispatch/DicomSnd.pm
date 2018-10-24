#!/usr/bin/perl -w
#
use strict;
use Dispatch::Select;
use Dispatch::Queue;
use Dispatch::Acceptor;
use Dispatch::Dicom::Storage;
use Dispatch::Dicom::Verification;
use Dispatch::Dicom::MessageAssembler;
use Dispatch::Dicom::Dataset;
use IO::Socket::INET;
use FileHandle;
use Debug;
my $dbg = sub {print @_};
{
  package Dispatch::DicomSnd;

  sub MakeConCallback{
    my($session,$obj_name, $sender_name, $calling, $called, $host, $port) = @_;
    my $foo = sub {
      my($con) = @_;
      # my $rsp_obj = $main::HTTP_APP_SINGLETON->{Inventory}->{$session}->
      #   {root}->{$obj_name};
      my $rsp_obj = Posda::HttpObj->get_obj_session($session,$obj_name);
      unless (defined $rsp_obj) {
         print STDERR "MakeConCallback: could not find obj: $obj_name\n";
         return;
      }
      if($rsp_obj->can("Message")){
        $rsp_obj->Message("Sender $sender_name Connected (" .
          "$calling, $called, ($port, $host))");
      }
      if($rsp_obj->can("add_connection")){
        $rsp_obj->add_connection($sender_name, $con);
      }
    };
    return $foo;
  }
  sub MakeDisCallback{
    my($session, $obj_name, $sender_name) = @_;
    my $foo = sub {
      my($con) = @_;
      # my $rsp_obj = $main::HTTP_APP_SINGLETON->{Inventory}->{$session}->
      #   {root}->{$obj_name};
      my $rsp_obj = Posda::HttpObj->get_obj_session($session,$obj_name);
      unless (defined $rsp_obj) {
         print STDERR 
           "MakeDisCallback: could not find obj: $session, $obj_name\n";
         return;
      }
      if($rsp_obj->can("Message")){
        $rsp_obj->Message("Sender $sender_name Disconnected (" .
          "status: $con->{close_status})");
      }
      if($rsp_obj->can("del_connection")){
        $rsp_obj->del_connection($sender_name);
      }
    };
    return $foo;
  }
  sub MakeEchoCallback{
    my($session, $obj_name, $sender_name) = @_;
    my $then = time();
    my $foo = sub {
      my($con) = @_;
      # my $rsp_obj = $main::HTTP_APP_SINGLETON->{Inventory}->{$session}->
      #   {root}->{$obj_name};
      my $rsp_obj = Posda::HttpObj->get_obj_session($session,$obj_name);
      unless (defined $rsp_obj) {
         print STDERR "MakeEchoCallback: could not find obj: $obj_name\n";
         return;
      }
      if($rsp_obj->can("Message")){
        my $now = time();
        my $elapsed = $now - $then;
        # $rsp_obj->Message("Echo response on  $sender_name after $elapsed sec");
      }
      if($rsp_obj->can("EchoResponse")){
        $rsp_obj->EchoResponse();
      }
    };
    return $foo;
  }
  
  my $assoc_descrip = {
    "calling" => "CALLING",
    "called" => "CALLED",
    "app_context" => "1.2.840.10008.3.1.1.1",
    "imp_class_uid" => "1.3.6.1.4.1.22213.1.69",
    "imp_ver_name" => "dcm_test_ver_0",
    "max_length" => "16384",
    "max_i" => "1",
    "max_p" => "1",
    "ver" => "1",
  };
  my $con_config = {
    "incoming_message_handler" => {
      "1.2.840.10008.1.1" => "Dispatch::Dicom::Verification",
      "1.2.840.10008.5.1.4.1.1.1" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.1.1" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.1.1.1" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.1.2" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.1.2.1" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.1.3" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.1.3.1" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.104.1" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.11.1" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.11.2" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.11.3" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.11.4" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.12.1" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.12.1.1" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.12.2" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.12.2.1" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.128" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.129" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.2" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.2.1" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.20" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.3.1" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.4" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.4.1" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.4.2" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.481.1" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.481.2" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.481.3" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.481.4" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.481.5" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.481.6" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.481.7" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.6.1" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.66" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.66.1" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.66.2" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.67" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.7" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.7.1" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.7.2" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.7.3" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.7.4" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.77.1.1" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.77.1.2" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.77.1.3" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.77.1.4" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.77.1.5.1" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.77.1.5.2" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.77.1.5.3" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.88.11" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.88.22" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.88.33" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.88.40" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.88.50" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.88.59" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.88.65" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.88.67" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.9.1.1" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.9.1.2" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.9.1.3" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.9.2.1" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.9.3.1" => "Dispatch::Dicom::Storage",
      "1.2.840.10008.5.1.4.1.1.9.4.1" => "Dispatch::Dicom::Storage"
    },
  };
  sub MakePresentationContextList{
    my($sop_class_list, $xfr_stx_list) = @_;
    my @list;
    my %list;
    for my $i(@$sop_class_list){
      for my $j (@$xfr_stx_list){
        push(@list, {
          abstract_syntax => $i,
          transfer_syntax => [ $j ],
        });
      }
    }
    for my $i (0 .. $#list){
      my $ctx_id = ($i * 2) + 1;
      $list{$ctx_id} = $list[$i];
    }
    return \%list;
  } 
  
  sub connection {
    my($host, $port, $calling, $called, 
      $session, $obj_name, $sender_name,
      $sop_class_list, $xfer_stx_list, $debug) = @_;
    my $connection;
    my $new_assoc_descrip = {};
    for my $i (keys %$assoc_descrip){
      $new_assoc_descrip->{$i} = $assoc_descrip->{$i};
    }
    $new_assoc_descrip->{presentation_contexts} = MakePresentationContextList(
      $sop_class_list, $xfer_stx_list);
    $new_assoc_descrip->{calling} = $calling;
    $new_assoc_descrip->{called} = $called;
    my $rsp_obj = 
      $main::HTTP_APP_SINGLETON->{Inventory}->{$session}->{root}->{$obj_name};
    unless($rsp_obj) { die "can't find obj named: $obj_name" };
    eval { 
      $connection = Dispatch::Dicom::Connection->new_connect(
        $host, $port, $new_assoc_descrip, $con_config, 
        MakeConCallback($session, $obj_name,
          $sender_name, $calling, $called, $host, $port
        ),
        $debug
      );
    };
    if($@){
      if($rsp_obj->can("Message")){
        $rsp_obj->Message("Failed to create association $sender_name: $@");
      } else {
        print STDERR "Failed to create association $sender_name: $@";
      }
      return undef;
    }
  #  $connection->SetConnectionCallback(MakeConCallback($session, $obj_name,
  #    $sender_name, $calling, $called, $host, $port));
    $connection->SetDisconnectCallback(MakeDisCallback($session, $obj_name, 
      $sender_name));
    return $connection;
  }
}
{
  package Dispatch::DicomSnd::Sender;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpObj" , "Dispatch::DebugHandler");
  sub MakeFileResponder{
    my($this, $file_name, $notify_obj_name, $sender_name, $file_count) = @_;
    my $foo = sub {
      my($obj, $status) = @_;
      my $result_obj = $this->get_obj($notify_obj_name);
      unless (defined $result_obj) { return; }
      my $now = time();
      if($status eq "OK"){
        # $result_obj->Message(
        #   "$sender_name: sent file $file_name at $now"
        # );
      } else {
        $result_obj->Message(
          "$sender_name: abort file $file_name at $now"
        );
      }
      # $result_obj->Message(
      #   "$sender_name: $file_count remaining"
      # );
      $result_obj->SendDone($sender_name, $status, $file_count);
      if($file_count == 0){
        $result_obj->SenderDone($sender_name);
        $this->delete_obj;
        my $elapsed = $now - $this->{start_time};
        $result_obj->Message(
          "$sender_name: done $now after $elapsed seconds"
        );
      }
    };
    return $foo;
  }
  sub MakeLoopStep{
    my($this, $notify_obj_name, $sender_name, $file_list) = @_;
    my $total_files = scalar @$file_list;
    my $files_queued = 0;
    my $foo = sub {
      my $disp = shift;
      my $result_obj = $this->get_obj($notify_obj_name);
      my $files_remaining = scalar @$file_list;
      unless($#{$file_list} >= 0){
        $result_obj->QueueComplete($sender_name, $files_queued);
        if($files_queued == 0){
          $this->delete_obj;
        }
        return;
      }
      my $file_desc = shift @$file_list;
      my $file = $file_desc->{file};
      my $sopcl = $file_desc->{sop_class};
      my $xfr_stx = $file_desc->{xfr_stx};
      my $sop_inst = $file_desc->{sop_inst};
      my $offset = $file_desc->{offset};
      unless(
        exists($this->{connection}->{sopcl}->{$sopcl}) &&
        exists($this->{connection}->{sopcl}->{$sopcl}->{$xfr_stx})&&
        defined($this->{connection}->{sopcl}->{$sopcl}->{$xfr_stx})
      ){
        $result_obj->Message(
          "Can't find presentation context for $file"
        );
        $result_obj->Message(
          "SOP class: $sopcl"
        );
        $result_obj->Message(
          "Xfr stx: $xfr_stx"
        );
        $disp->queue();
        return;
      }
      my $pc_id = $this->{connection}->{sopcl}->{$sopcl}->{$xfr_stx};
      $this->DebugMsg("PC: $pc_id, SOP: $sopcl, XFR: $xfr_stx");
      unless(defined $pc_id){
        die "can't find pc_id";
      }
      my $len = $this->{connection}->{max_length};
      my $ds = Dispatch::Dicom::Dataset->new_new($file, 
        $xfr_stx, $xfr_stx, $offset, $len, 
        $this->{debug} ? "file: $file" : undef
      );
      my $cmd = Posda::Command->new_store_cmd($sopcl, $sop_inst);
      my $ma = Dispatch::Dicom::MessageAssembler->new($pc_id,
        $cmd, $ds, $this->MakeFileResponder(
          $file, $notify_obj_name, $sender_name, $files_remaining - 1
        ),
        $this->{debug} ? "Store: $file" : undef
      );
      $this->{connection}->QueueMessage($ma);
      $files_queued += 1;
      my $now = time();
      # $result_obj->Message("Queued $file for transmission at $now");
      if($#{$file_list} >= 0){
        $disp->queue();
      } else {
        $result_obj->QueueComplete($sender_name, $files_queued);
      }
      return;
    };
    return $foo;
  }
  sub new{
    my($class, $connection, $session, $notify_obj_name, 
      $sender_name, $file_list, $debug) = @_;
    my $this = Posda::HttpObj->new($session, "$notify_obj_name/$sender_name");
    $this->{connection} = $connection;
    $this->{start_time} = time();
    bless $this, $class;
    my $loop = Dispatch::Select::Background->new(
      $this->MakeLoopStep($notify_obj_name, $sender_name, $file_list));
    $loop->queue();
    if($debug) { Dispatch::DebugHandler::Debug($this, $debug) }
    return $this;
  }
  sub DESTROY{
    my($this) = @_;
    if($ENV{POSDA_DEBUG}){
      print "DESTROY: $this->{path}: $this\n";
    }
  }
}
1;
