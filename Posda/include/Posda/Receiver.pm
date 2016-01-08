#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/Receiver.pm,v $
#$Date: 2015/12/15 14:06:03 $
#$Revision: 1.20 $
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
package Posda::Receiver;
use strict;
use Dispatch::EventHandler;
use Dispatch::Select;
use Dispatch::Queue;
use Dispatch::Acceptor;
use Dispatch::Dicom::Storage;
use Dispatch::Dicom::Finder;
use Dispatch::Dicom::Verification;
use Dispatch::Dicom::MessageAssembler;
use Dispatch::Dicom::Dataset;
use Dispatch::LineReader;
use IO::Socket::INET;
use FileHandle;

use vars qw(@ISA);
@ISA = qw( Dispatch::EventHandler );
sub new{
  my($class, $dcm_port, $config, $rcv_dir) = @_;
  unless(-d $rcv_dir) { die "$rcv_dir is not a directory" }
  my %aes;
  for my $ae_title (keys %{$config->{dicom_aes}}){
    my $c = $config->{dicom_aes}->{$ae_title};
    key:
    for my $k (keys %$c){
      if($k eq "incoming_message_handler"){
        $aes{$ae_title}->{$k} = 
          $config->{incoming_message_handlers}->{$c->{$k}};
      } elsif ($k eq "pres_contexts") {
        $aes{$ae_title}->{$k} =
          $config->{presentation_context_groups}->{$c->{$k}};
      } elsif ($k eq "end_handler") {
        $aes{$ae_title}->{$k} =
          $config->{association_end_handlers}->{$c->{$k}};
      } else { $aes{$ae_title}->{$k} = $c->{$k} }
    }
  }
  my $this = {
    dcm_port => $dcm_port,
    aes => \%aes,
    rcv_dir => $rcv_dir,
    connection_count => 0,
  };
  bless $this, $class;
  $this->KeepAlive("Notify", 5, "Keep Alive");
  my $scp = Dispatch::Dicom::Acceptor->new_with_negot( $dcm_port,
    $this->CreateNegotiator($this->{aes}), 
    $this->CreateConnectionHandler("SCP", $rcv_dir));
  $scp->Add("reader");
  $this->{scp} = $scp;
  return bless $this, $class;
}
#
# $dicom_aes is a hash of dicom application entities indexed by
# "called application entity title"
#
#  Each is a hash with the following format:
#
#  $dae = {
#    ae_title => <called_ae_title>, 
#                (same as hash index unless hash_index eq "UNKNOWN")
#                "UNKNOWN" is reserved for a non-matching ae_title, 
#                and will have ae_title set to last attempting connector
#    allowed_calling_ae_titles => {
#      <calling_ae_title> => 1,
#      ...
#      [OTHER => 1]                 (indicates promiscuity)
#    },
#    app_context => "1.2.840.10008.3.1.1.1",
#    imp_class_uid => "1.3.6.1.4.1.22213.1.69",
#    inp_ver_name => <version>,
#    max_length => <max_pdu_length>,
#    num_invoked => <num_invoked>,
#    num_performed => <num_performed>,
#    protocol_version => "1",
#    storage_root => <directory into which incoming messages stored>, 
#    incoming_message_handler => {
#      <abstract_syntax_uid> => <class_name of handler>,
#      ...
#    },
#    pres_contexts" => {
#      <abstract_syntax_uid> => {
#        <acceptable_transfer_syntax_uid> => 1,
#        ..
#      },
#      ...
#    },
#  };
sub CreateNegotiator{
  my($this, $dicom_aes) = @_;
  my $foo = sub{
    my($dcm_conn, $assoc_rq) = @_;
    my $called = $assoc_rq->{called};
    $called =~ s/^\s*//;
    $called =~ s/\s*$//;
    my $is_promiscuous = 0;
    unless( exists($dicom_aes->{$called})){
      unless(exists($dicom_aes->{"<UNKNOWN>"})){
        $this->Notify(
          "Rejecting ASSOC unknown called ($called) and no <UNKNOWN> entry");
        return Dispatch::Dicom::AssocRj->new(2, 2, 7);
      }
      $is_promiscuous = 1;
    }
    my $ae = $is_promiscuous ? $dicom_aes->{"<UNKNOWN>"}: $dicom_aes->{$called};
    if($is_promiscuous){
      $ae->{called} = $called;
    }
    my $calling = $assoc_rq->{calling};
    $calling =~ s/^\s*//;
    $calling =~ s/\s*$//;
    unless(
      exists($ae->{allowed_calling_ae_titles}->{$calling}) ||
      exists($ae->{allowed_calling_ae_titles}->{"<ANY>"})
    ){
      $this->Notify(
        "Rejecting ASSOC unknown calling ($calling) for called ($called)" .
        " and no <ANY> entry");
      return Dispatch::Dicom::AssocRj->new(2, 2, 3);
    }
    $dcm_conn->{incoming_message_handler} = $ae->{incoming_message_handler};
    $dcm_conn->{association_completion_handler} = $ae->{end_handler};
    ########
    #  right here is where you can set up rcv_root based upon 
    #  called, calling pair and put it into dcm_conn
    ########
    return Dispatch::Dicom::AssocAc->new_from_rq_desc($assoc_rq, $ae);
  };
  return $foo;
}
sub CreateConnectionHandler{
  my($this, $name, $rcv_dir) = @_;
  my $foo = sub {
    my($obj) = @_;
    $this->{connection_count} += 1;
    my $new = "$name" . "_" . $this->{connection_count};
    my $called = $obj->{assoc_ac}->{called};
    $called =~ s/\s*$//;
    $called =~ s/^\s*//;
    my $calling = $obj->{assoc_ac}->{calling};
    $calling =~ s/\s*$//;
    $calling =~ s/^\s*//;
    my($port, $iaddr) = sockaddr_in($obj->{socket}->peername);
    my $host_ip = inet_ntoa($iaddr);
    my $peer_network_addr = "$host_ip:$port";
    if($calling =~ /^(.*\S)\s*$/){ $calling = $1 }
    my $session_name = "$host_ip-$calling-$this->{connection_count}";
    $this->Notify("$new: Connected ($calling, $called, ($port, $host_ip))");
#    if(exists $this->{ActiveConnections}->{$session_name}){
#      $this->Notify("Error: Second association $host_ip:$calling");
#      $obj->Abort();
#      return;
#    }
    my $now = time;
    my $now_suffix = $this->now_dir;
    if(exists $this->{ReceiveDirs}->{$now_suffix}) {
      $this->{ReceiveDirs}->{$now_suffix}->{increment} += 1;
    } else {
      $this->{ReceiveDirs}->{$now_suffix} = {
        at => $now,
        increment => 0,
      };
    }
    my $increment = $this->{ReceiveDirs}->{$now_suffix}->{increment};
    my $rel_dir = "$called/$calling/$host_ip-" . $now_suffix .
      "_$increment";
    my $count = 1;
    my $base_rel_dir = $rel_dir;
    if(-d "$rcv_dir/$rel_dir"){
      print STDERR "##############################\n" .
        "Receive directory $rcv_dir/$rel_dir exists\n" .
        "##############################\n";
    }
    unless(-d "$rcv_dir/$called"){
      mkdir("$rcv_dir/$called");
    }
    unless(-d "$rcv_dir/$called/$calling"){
      mkdir("$rcv_dir/$called/$calling");
    }
    unless(-d "$rcv_dir/$rel_dir"){
      mkdir("$rcv_dir/$rel_dir");
    }
    $this->{objs}->{$new} = $obj;
    $obj->{peer_network_addr} = $peer_network_addr;
    my $session_info = {
      calling => $calling,
      called => $called,
      start_time => time,
      session_index => $new,
      name => $session_name,
      rel_dir => $rel_dir,
      pres_ctx => {},
    };
    if($obj->{association_completion_handler}) {
      $session_info->{end_handler} = $obj->{association_completion_handler};
    }
    for my $i (keys %{$obj->{assoc_rq}->{presentation_contexts}}){
      $session_info->{pres_ctx}->{$i}->{abs_stx} = 
        $obj->{assoc_rq}->{presentation_contexts}->{$i}->{abstract_syntax};
      $session_info->{pres_ctx}->{$i}->{xfer_stxs} = 
        $obj->{assoc_rq}->{presentation_contexts}->{$i}->{transfer_syntaxes};
      if($obj->{assoc_ac}->{presentation_contexts}->{$i}){
        $session_info->{pres_ctx}->{$i}->{accepted} = 
          $obj->{assoc_ac}->{presentation_contexts}->{$i};
      } else {
        $session_info->{pres_ctx}->{$i}->{rejected} = 
          $obj->{assoc_ac}->{rejected_pc}->{$i};
      }
    }
    $this->{ActiveConnections}->{$new} = $session_info;
    if($obj->can("SetDisconnectCallback")){
      $obj->SetDisconnectCallback($this->AnnounceDisconnect(
        $new, $calling, $host_ip, $session_info));
    } else {
      die "Can't handle SetDisconnectCallback";
    }
    if($obj->can("SetDatasetReceivedCallback")){
      $obj->SetDatasetReceivedCallback($this->AnnounceFileReceived($new, 
        $calling, $host_ip, $session_info));
    } else {
      die "Can't handle SetDatasetReceivedCallback";
    }
    if($obj->can("SetEchoRequestCallback")){
      $obj->SetEchoRequestCallback($this->AnnounceEchoRequest($new, 
        $calling, $host_ip, $session_info));
    }
    if($obj->can("SetStorageRoot")){
      $obj->SetStorageRoot("$rcv_dir/$rel_dir");
    } else {
      die "Can't handle SetStorageRoot";
    }
  };
  return $foo;
}
sub AnnounceDisconnect{
  my($this, $name, $calling, $host, $session_info) = @_;
  my $foo = sub {
    my $now = time;
    my $elapsed = $now - $session_info->{start_time};
    $this->Notify("$name: Disconnected ($elapsed)");
    my $status = "OK";
    if(exists $this->{objs}->{$name}){
      if(exists $this->{objs}->{$name}->{Abort}){
        $status = $this->{objs}->{$name}->{Abort}->{mess}; 
      }
      $session_info->{Status} = $status;
    } else {
      print STDERR "Announce Disconnect on already disconnected session\n";
    }
    delete $this->{objs}->{$name};
    delete $this->{ActiveConnections}->{$name};
    open FILE, ">$this->{rcv_dir}/$session_info->{rel_dir}/Session.info";
    print FILE "SCU|$name\n";
    print FILE "host|$host\n";
    print FILE "status|$session_info->{Status}\n";
    print FILE "calling|$session_info->{calling}\n";
    print FILE "called|$session_info->{called}\n";
    print FILE "start time|$session_info->{start_time}\n";
    print FILE "elapsed time|$elapsed\n";
    for my $i (sort { $a <=> $b } keys %{$session_info->{pres_ctx}}){
      print FILE "proposed_pc|$i|$session_info->{pres_ctx}->{$i}->{abs_stx}";
      for my $t (@{$session_info->{pres_ctx}->{$i}->{xfer_stxs}}){
        print FILE "|$t";
      }
      print FILE "\n";
      if(exists $session_info->{pres_ctx}->{$i}->{rejected}){
        print FILE 
          "rejected_pc|$i|$session_info->{pres_ctx}->{$i}->{rejected}\n";
      } else {
        print FILE 
          "accepted_pc|$i|$session_info->{pres_ctx}->{$i}->{accepted}\n";
      }
    }
    for my $i (keys %{$session_info->{files}}){
      for my $j (keys %{$session_info->{files}->{$i}}){
        print FILE "file|$i|" .
          "$session_info->{files}->{$i}->{$j}->{sop_instance}|" .
          "$session_info->{files}->{$i}->{$j}->{xfrstx}|$j\n";
      }
    }
    close FILE;
    if(exists $session_info->{end_handler}) {
      $this->StartAssociationPostProcessor($session_info);
    }
  };
  return $foo;
}
sub AnnounceEchoRequest{
  my($this, $name, $calling, $host, $session_info) = @_;
  my $sub = sub {
    my $now = time;
    my $elapsed = $now - $session_info->{start_time};
    $session_info->{num_echo} += 1;
    $this->Notify("$name: Echo Request ($elapsed)");
  };
  return $sub;
}
sub AnnounceFileReceived{
  my($this, $name, $calling, $host, $session_info) = @_;
  my $foo = sub {
    my($file_name, $sop_class, $sop_instance, $xfrstx) = @_;
    my $dir_name = "$this->{rcv_dir}/$session_info->{rel_dir}";
    $dir_name =~ s/ *$//;
    unless(-d "$dir_name"){
      `mkdir $dir_name`;
    }
    unless (-f $file_name){
      $this->Notify("Storage interrupted (socket unexpectedly closed?)");
      return;
    }
   my $short_name;
   $file_name =~ /\/([^\/]*)$/;
   $short_name = $1;
   my $new_file_name = "$dir_name/$short_name";
    $session_info->{files}->{$sop_class}->{$file_name} = {
      xfrstx => $xfrstx,
      sop_instance => $sop_instance,
    };
  };
  return $foo;
}
sub NotificationRegistration{
  my($this, $callback) = @_;
  unless($this->{notifiers}) { $this->{notifiers} = [] }
  push(@{$this->{notifiers}}, $callback);
}
sub KeepAlive{
  my($this, $method, $delay, $message) = @_;
  my $foo = sub {
    my($self) = @_;
    unless($this->{KillTimer}){
      $this->$method($message);
      $self->timer($delay);
    }
  };
  my $timer = Dispatch::Select::Background->new($foo);
  $timer->timer($delay);
}
sub Notify{
  my($this, $message) = @_;
  my $now = time;
  for my $i (keys %{$this->{ReceiveDirs}}){
    if($now - $this->{ReceiveDirs}->{$i}->{at} > 5){
      delete $this->{ReceiveDirs}->{$i};
    }
  }
  my @survivors;
  unless(exists($this->{notifiers})){
    unless($message eq "Keep Alive"){
      print STDERR "$message\n";
    }
    return;
  }
  for my $i (@{$this->{notifiers}}){
    if($i && ref($i) eq "CODE"){
      my $alive = &{$i}($message);
      if($alive) { push @survivors, $i }
    }
  }
  if($#survivors >= 0){
    $this->{notifiers} = \@survivors;
  } else {
    delete $this->{notifiers};
  }
}
sub StartAssociationPostProcessor{
  my($this, $session_info) = @_;
  my $spec = $session_info->{end_handler};
  $spec->{assoc_dir} = "$this->{rcv_dir}/$session_info->{rel_dir}";
  $spec->{called} = "$session_info->{called}";
  $spec->{calling} = "$session_info->{calling}";
  my $cmd_template = $spec->{script};
  my $remain = $cmd_template;
  my $cmd = "";
  while($remain ne ""){
    if($remain =~ /^([^<]*)<([^>]+)>(.*)$/){
      my $first = $1;
      my $sym = $2;
      $remain = $3;
      if(exists $spec->{$sym}){
        $cmd = $cmd . $first . $spec->{$sym};
      } else {
        print STDERR "AssociationCompletionHandler\n";
        print STDERR "symbol not found in spec: $sym\n";
        return;
      }
    } else {
      $cmd = $cmd . $remain;
      $remain = "";
    }
  }
  unless(exists $this->{PostProcessingQueue}){
    $this->{PostProcessingQueue} = [];
  }
  push @{$this->{PostProcessingQueue}}, $cmd;
  $this->InvokeAfterDelay("PostProcessAssociations", 0);
}
sub PostProcessAssociations{
  my($this) = @_;
  my $num_running = keys %{$this->{RunningPostProcesses}};
  my $num_queued = @{$this->{PostProcessingQueue}};
  while(
    $num_queued > 0 && 
    $num_running < 3,
  ){
    # Start a handler ...
    # then try again:
    my $cmd = shift(@{$this->{PostProcessingQueue}});
    eval {
      Dispatch::LineReader->new_cmd($cmd, $this->ProcessingStatus($cmd),
        $this->ProcessingEnd($cmd));
    };
    if($@){
      print STDERR "Dispatch::LineRead->new_cmd exception:\n$@\n";
    } else {
      $this->{RunningPostProcesses}->{$cmd} = 1;
    }
    $num_running = keys %{$this->{RunningPostProcesses}};
    $num_queued = @{$this->{PostProcessingQueue}};
  }
}
sub ProcessingStatus{
  my($this, $cmd) = @_;
  my $sub = sub {
    my($line) = @_;
    print STDERR "############################\n";
    print STDERR "Received from command ($cmd):\n";
    print STDERR "$line\n";
    print STDERR "############################\n";
  };
  return $sub;
}
sub ProcessingEnd{
  my($this, $cmd) = @_;
  my $sub = sub {
    my($line) = @_;
    print STDERR "############################\n";
    print STDERR "Command ($cmd):\n";
    print STDERR "Complete\n";
    print STDERR "############################\n";
    delete $this->{RunningPostProcesses}->{$cmd};
    $this->InvokeAfterDelay("PostProcessAssociations", 0);
  };
  return $sub;
}
1;
