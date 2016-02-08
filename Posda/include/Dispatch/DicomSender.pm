#!/usr/bin/perl -w
#
use strict;
use Dispatch::DicomSnd;
use Posda::HttpApp::HttpObj;
{
  package Dispatch::DicomSender;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpObj" );
  sub new {
    my($class, $sess, $path, $status_obj, $debug) = @_;
    my $this = Posda::HttpObj->new($sess, $path);
    $this->{StatusObj} = $status_obj;
    $this->{debug} = $debug;
    bless $this, $class;
    return $this;
  }
  sub Message{
    my($this, $msg) = @_;
    my $obj = $this->get_obj($this->{StatusObj});
    if($obj && $obj->can("Message")){
      $obj->Message($msg);
    } else {
      print STDERR "$msg\n";
    }
  }
  sub SendComplete{
    my($this, $msg) = @_;
    my $obj = $this->get_obj($this->{StatusObj});
    if($obj && $obj->can("SendComplete")){
      $obj->SendComplete;
    } else {
      die "no SendComplete method";
    }
  }
  sub ClearToSend{
    my($this) = @_;
    my $obj = $this->get_obj($this->{StatusObj});
    if($obj && $obj->can("ClearToSend")){
      $obj->ClearToSend;
    } else {
      die "no ClearToSend method in $this->{StatusObj}";
    }
  }
  sub GoodBye{
    my($this) = @_;
    my $obj = $this->get_obj($this->{StatusObj});
    if($obj && $obj->can("ConnectionGone")){
      $obj->ConnectionGone;
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
    delete $this->{num_files_to_send};
    delete $this->{num_files_sent};
    delete $this->{num_errors_on_sending};
    delete $this->{currently_remaining_to_send};
    my $sender = Dispatch::DicomSnd::connection(
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
    my($this, $dyn) = @_;
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
    my($this, $dyn) = @_;
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
  sub DESTROY{
    my($this) = @_;
    if($ENV{POSDA_DEBUG}){
      print "DESTROY: $this->{path}: $this\n";
    }
  }
}
1;
