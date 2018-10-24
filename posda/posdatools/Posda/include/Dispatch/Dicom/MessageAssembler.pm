#!/usr/bin/perl -w
use Dispatch::Dicom;
my $dbg = sub {print @_};
use strict;
package Dispatch::Dicom::MessageAssembler;
use vars qw( @ISA );
@ISA = ( "Dispatch::DebugHandler" );
sub new{
  my($class, $pc_id, $cmd, $ds, $rh, $debug) = @_;
  my $this = {
    pc_id => $pc_id,
    cmd => $cmd,
    #cmd_data => $cmd->render(),
    finished => 0,
  };
  if(defined $ds) {
    $this->{ds} = $ds;
  }
  if(defined $rh) {
    $this->{rh} = $rh;
  }
  if($cmd->{"(0000,0800)"} == 0x0101){
    $this->{finished} = 1;
  } else {
    unless(defined $ds) { die "no ds supplied and command wants one" }
    unless($ds->can("ready_out") && $ds->can("get_pdv")){
      die "ds not capable of ready_out and get_pdv";
    }
  }
  bless $this, $class;
  if(defined $debug) { $this->Debug($debug) }
  $this->DebugMsg("New Message Assembler - pc: $this->{pc_id}");
  if($ENV{POSDA_DEBUG}){
    print "NEW: $this\n";
  }
  return $this;
}
sub ready_out{
  # returns -1 finished, 0 not ready, 1 ready
  # not ready until > pdv_len, or finished flag set
  my($this, $pdv_len) = @_;
 if(exists $this->{cmd_data}) {
   return 1;
 }
 if($this->{finished} && $this->{cmd}->{"(0000,0800)"} == 0x0101){
   return -1;
 }
 if(defined($this->{ds}) && $this->{ds}->can("ready_out")){
   return $this->{ds}->ready_out($pdv_len);
 }
 die ("no ds, but getting ds pdv");
}
sub get_pdv{
  # trouble unless ready for pdv_len
  my($this, $pdv_len) = @_;
  my($data, $flgs);
  $flgs = 0;
  if(exists($this->{cmd_data})){
    $flgs |= 1;
    my $len = length ($this->{cmd_data});
    if($len > $pdv_len){
      $this->{cmd_data} =~ /^(.{$pdv_len})(.*)$/;
      $data = $1;
      $this->{cmd_data} = $2;
    } else {
      $flgs |= 2;
      $data = $this->{cmd_data};
      delete $this->{cmd_data};
    }
    my $rlen = length($data) + 2;
    $this->DebugMsg("get_pdv($pdv_len) len: $rlen pc: $this->{pc_id} " .
      "flags: $flgs");
    return pack("NCC", length($data) + 2, $this->{pc_id}, $flgs) . $data;
  }
  if($this->{cmd}->{"(0000,0800)"} == 0x0101) {
    die "Shouldn't be fetching ds_data";
  }
  $this->DebugMsg("defering to ds");
  return $this->{ds}->get_pdv($pdv_len, $this->{pc_id});
}
sub wait_ready_out{
  my($this, $event) = @_;
  $this->{ds}->wait_ready_out($event);
}
sub msg_id{
  my($this) = @_;
  my $cmd = $this->{cmd};
  unless(exists $cmd->{"(0000,0110)"}){
    die "no message id";
  }
  return $cmd->{"(0000,0110)"};
}
sub CreatePduAssembler{
  my($this, $queue, $pdu_size, $end_event) = @_;
  my $pdv_size = $pdu_size - 6;
  my $foo = sub{
    # when ready & queue ready, gets a pdv, constructs a pdu and
    # queues it
    # otherwise waits for queue ready or assembler ready, as appropriate
    my($back) = @_;
    if($this->{AbortPlease}){
      $end_event->post_and_clear();
      return;
    }
    if($this->ready_out($pdv_size) == -1){
      $end_event->post_and_clear();
      return;
    }
    while($queue->ready_out && $this->ready_out($pdv_size) == 1){
      my $pdv = $this->get_pdv($pdv_size);
      unless(ref($pdv) eq "ARRAY"){
        $pdv = [$pdv];
      }
      my $len = 0;
      for my $p (@$pdv){
        $len += length($p);
      }
      # construct and queue pdu
      $this->DebugMsg("pdu header type: 4 len: $len");
      $queue->queue(pack("CCN", 4, 0, $len));
      for my $p (@$pdv){
        my $plen = length($p);
        $this->DebugMsg("pdv fragment len: $plen");
        $queue->queue($p);
      }
    }
    if($this->ready_out($pdv_size) == -1) {
      $end_event->post_and_clear();
      return;
    }
    if($queue->ready_out){
      $this->wait_ready_out(Dispatch::Select::Event->new($back));
    } else {
      $queue->wait_output(Dispatch::Select::Event->new($back));
    }
  };
  my $back = Dispatch::Select::Background->new($foo);
  $back->queue();
}
sub Abort{
  my($this) = @_;
  $this->{AbortPlease} = 1;
  $this->{ds}->AbortPlease();
  if(exists ($this->{rh}) && ref($this->{rh}) eq "CODE"){
    &{$this->{rh}}(undef, "ABORT");
  } else {
    print STDERR "Response handler not found\n";
  }
}
sub ProcessResponse{
  my($this, $resp) = @_;
  if(exists ($this->{rh}) && ref($this->{rh}) eq "CODE"){
    &{$this->{rh}}($resp, "OK");
  } else {
    print STDERR "Response handler not found\n";
  }
}
sub DESTROY{
  my($this) = @_;
  if($ENV{POSDA_DEBUG}){
    print "DESTROY: $this\n";
  }
}
1;
