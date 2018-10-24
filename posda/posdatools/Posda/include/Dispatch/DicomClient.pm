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
package Dispatch::DicomClient;
use vars qw( ISA $ConConfig);
@ISA = qw( Dispatch::EventHandler Dispatch::DebugHandler);
$ConConfig = {
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
sub new {
  my($class, $status_obj, $debug) = @_;
  my $this = {};
  $this->{StatusObj} = $status_obj;
  $this->{debug} = $debug;
  return bless $this, $class;
}
sub DESTROY{
  my($this) = @_;
  if($ENV{POSDA_DEBUG}){
    print "DESTROY: $this->{path}: $this\n";
  }
}
sub Message{
  my($this, $msg) = @_;
  if($this->{StatusObj} && $this->{StatusObj}->can("Message")){
    $this->{StatusObj}->Message($msg);
  } else {
    print STDERR "$msg\n";
  }
}
sub SendComplete{
  my($this, $msg) = @_;
  if($this->{StatusObj} && $this->{StatusObj}->can("SendComplete")){
    $this->{StatusObj}->SendComplete;
  } else {
    die "no SendComplete method";
  }
}
sub ClearToSend{
  my($this) = @_;
  if($this->{StatusObj} && $this->{StatusObj}->can("ClearToSend")){
    $this->{StatusObj}->ClearToSend;
  } else {
    die "no ClearToSend method in $this->{StatusObj}";
  }
}
sub GoodBye{
  my($this) = @_;
  if($this->{StatusObj} && $this->{StatusObj}->can("ConnectionGone")){
    $this->{StatusObj}->ConnectionGone;
  } else {
    die "no ConnectionGone method in $this->{StatusObj}";
  }
}
sub StartAssoc{
  my($this, $server, $port, 
    $calling, $called, $sops, $xfr_stxs, $debug) = @_;
  if(exists $this->{association}){
    $this->Message("Already have an association open");
    return;
  }
  if(exists $this->{pending_association}){
    $this->Message("Already have an association pending");
    return;
  }
  $this->{server} = $server;
  $this->{port} = $port;
  $this->{calling} = $calling;
  $this->{called} = $called;
  $this->{sops} = $sops;
  $this->{xfr_stxs} = $xfr_stxs;
  $this->{debug} = $debug;
  delete $this->{num_files_to_send};
  delete $this->{num_files_sent};
  delete $this->{num_errors_on_sending};
  delete $this->{currently_remaining_to_send};
  my $sender = $this->connection(
    $server, $port, $calling, $called,
    $this->{session}, $this->{path}, "connection",
    $sops, $xfr_stxs, $debug
  );
  if(defined $sender){
    $this->Message("Sender: trying to connect");
    $this->{pending_association} = $sender;
    $this->{assoc_port} = $port;
    $this->{assoc_server} = $server;
    $this->{assoc_calling_ae_title} = $calling;
    $this->{assoc_called_ae_title} = $called;
  }
}
sub connection {
  my($this) = @_;
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
  my $connection;
  my $new_assoc_descrip = {};
  for my $i (keys %$assoc_descrip){
    $new_assoc_descrip->{$i} = $assoc_descrip->{$i};
  }
  $new_assoc_descrip->{presentation_contexts} = MakePresentationContextList(
    $this->{sops}, $this->{xfr_stxs});
  $new_assoc_descrip->{calling} = $this->{calling};
  $new_assoc_descrip->{called} = $this->{called};
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
      $this->Message("Failed to create association $sender_name: $@");
      print STDERR "Failed to create association $sender_name: $@";
    }
    return undef;
  }
  $connection->SetDisconnectCallback(MakeDisCallback($session, $obj_name, 
    $sender_name));
  return $connection;
}
sub add_connection{
  my($this, $name, $con) = @_;
  $this->Message("Sender: $con is connected");
  $this->{association} = $this->{pending_association};
  delete $this->{pending_association};
  $this->ClearToSend;
}
sub del_connection{
  my($this, $name) = @_;
  $this->Message("Sender: $name is disconnected");
  $this->GoodBye;
  delete $this->{association};
  $this->DeleteSelf;
}
sub Release{
  my($this) = @_;
  unless(exists $this->{association}){
    return;
  }
  my $sender = $this->{association};
  unless(
    defined($sender) &&
    $sender->can("ReleaseOK")
  ){
    $this->Message("No Sender to release");
    return;
  }
  my $message = "Released association";
  if($sender->ReleaseOK()){
    delete $this->{running_send_request};
    $sender->Release();
  } else {
    $message = "Busy - can't release";
  }
  $this->Message($message);
}
sub Abort{
  my($this) = @_;
  unless(
    defined($this->{association}) &&
    $this->{association}->can("Abort")
  ){
    $this->Message("No Association to abort");
    return;
  }
  my $sender = $this->{association};
  $sender->Abort("Operator requested abort");
  delete $this->{running_send_request};
}
sub SendDone{
  my($this, $sender_id, $status, $num_files_remaining) = @_;
  $this->Message("SendDone: $status remaining: $num_files_remaining");
  $this->{currently_remaining_to_send} = $num_files_remaining;
  if ($status eq "OK"){
    $this->{num_files_sent}++;
  } else {
    $this->{num_errors_on_sending}++;
  }
  if($num_files_remaining == 0){
    $this->SendComplete;
  }
}
sub QueueComplete{
  my($this, $sender_id, $file_count) = @_;
  $this->Message("$this->{path}:QueueComplete file_count: $file_count.");
  $this->{currently_queued_to_send} = $file_count;
}
sub SenderDone{
  my($this, $sender_id) = @_;
  $this->Message("$this->{path}:SenderDone called, id: $sender_id.");
  delete $this->{send_request};
  $this->{send_request_done} = 1;
}
sub Send{
  my($this, $file_list) = @_;
  $this->Message("$this->{path}:Send called");
  if(
    exists($this->{send_request}) ||
    exists($this->{running_send_request})
  ){
    $this->Message("Send already in progress");
    return;
  }
  my $send_req_id = "sender";
  $this->{send_request} = {
    id => $send_req_id,
  };
  my $sender = $this->{association};
  $this->Message("Starting sender");
  $this->{num_files_to_send} = $#{$file_list} + 1;
  $this->{num_files_sent} = 0;
  $this->{num_errors_on_sending} = 0;
  $this->{currently_remaining_to_send} = $this->{num_files_to_send};
  my $connection = $this->{association};
  my $send_request = Dispatch::DicomSnd::Sender->new(
    $connection, $this->{session}, $this->{path},
    $send_req_id, $file_list, $this->{debug});
  $this->{running_send_request} = $send_request;
}
sub StartSender{
  my ($this) = @_;
#  sub new{
#    my($class, $connection, $session, $notify_obj_name, 
#      $sender_name, $file_list, $debug) = @_;
#    my $this = Posda::HttpObj->new($session, "$notify_obj_name/$sender_name");
#    $this->{connection} = $connection;
    $this->{start_time} = time();
#    bless $this, $class;
    my $loop = Dispatch::Select::Background->new(
      $this->MakeLoopStep($notify_obj_name, $sender_name, $file_list));
    $loop->queue();
    if($debug) { Dispatch::DebugHandler::Debug($this, $debug) }
    return $this;
  }
}
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
sub MakeConCallback{
  my($this) = @_;
  my $foo = sub {
    my($con) = @_;
    $this->Message("Sender $this->{sender_name} Connected (" .
        "$this->{calling}, $this->{called}, " .
        "($this->{port}, $this->{host}))");
    if(
      $this->{StatusObj} &&
      $this->{StatusObj}->can("add_connection")
    ){
      $this->{StatusObj}->add_connection($sender_name, $con);
    } else { die "Can't inform status object of new connection" }
  };
  return $foo;
}
sub MakeDisCallback{
  my($session) = @_;
  my $foo = sub {
    my($con) = @_;
    $rsp_obj->Message("Sender $this->{sender_name} Disconnected (" .
      "status: $con->{close_status})");
    if(
      $this->{StatusObj} &&
      $this->{StatusObj}->can("del_connection")
    ){
      $this->{StatusObj}->del_connection($sender_name);
    } else { die "Can't inform status object of disconnection" }
  };
  return $foo;
}
sub MakeEchoCallback{
  my($session) = @_;
  my $then = time();
  my $foo = sub {
    my($con) = @_;
    my $now = time();
    my $elapsed = $now - $then;
    # $rsp_obj->Message("Echo response on  $sender_name after $elapsed sec");
    if(
      $this->{StatusObject} &&
      $this->{StatusObject}->can("EchoResponse")
    ){
      $rsp_obj->EchoResponse();
    } else { die "Can't inform status object of echo response" }
  };
  return $foo;
}
sub MakePresentationContextList{
  my($this) = @_;
  my @list;
  my %list;
  for my $i(@{$this->{sops}){
    for my $j (@{$this->{xfr_stxs}}){
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
sub DESTROY{
  my($this) = @_;
  if($ENV{POSDA_DEBUG}){
    print "DESTROY: $this->{path}: $this\n";
  }
}
1;
