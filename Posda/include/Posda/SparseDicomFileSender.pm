use Digest::MD5;
use Dispatch::Select;
use Dispatch::EventHandler;
use Dispatch::Dicom::Dataset;
use Dispatch::Dicom::Message;
use Dispatch::Dicom::Storage;
use Dispatch::Dicom::MessageAssembler;
use Posda::Command;

package Posda::SparseDicomFileSender;

use vars qw( @ISA );
@ISA = ( "Dispatch::EventHandler" );
my $MsgHandlers = {
};
sub new {
  my($class, $host, $port, $called, $calling, $file_list, $f_callback) = @_;
  my $this = {
    host => $host,
    port => $port,
    called => $called,
    calling => $calling,
    StartTime => time,
    FilesToSend => $file_list,
  };
  if(defined($f_callback) && ref($f_callback) eq "CODE"){
    print STDERR "Setting finalize_callback\n";
    $this->{finalize_callback} = $f_callback;
  }
  bless $this, $class;


  $this->Initialize;
  return $this;
}
sub Initialize{
  my($this) = @_;
  my $debug = 0;
  $this->{InProcess} = 1;
  my $new_assoc_descrip = {
    ver => 1,
    calling => $this->{calling},
    called => $this->{called},
    app_context => "1.2.840.10008.3.1.1.1",
    imp_class_uid => "1.3.6.1.4.1.22213.1.69",
    imp_ver_name => "posda_file_dist",
    max_length => "16384",
    max_i => "1",
    max_p => "1",
  };

  $this->{FilesSent} = [];
  $this->{FilesNotSent} = [];
  $this->{FilesInFlight} = {};
  $this->{FilesErrors} = [];
  my %pcs;
  # Build the presentation context list, and the Message Handlers list
  for my $file (@{$this->{FilesToSend}}) {
    $pcs{$file->{abs_stx}}->{$file->{xfr_stx}} = 1;
    $MsgHandlers->{$file->{abs_stx}} = "Dispatch::Dicom::Storage";
  }

  my $pc_id = 1;
  for my $a (keys %pcs){
    for my $t (keys %{$pcs{$a}}){
      $new_assoc_descrip->{presentation_contexts}->{$pc_id} = {
        abstract_syntax => $a,
        transfer_syntax => [$t],
      };
      $pc_id += 2;
      if($pc_id > 255) { die "Too many proposed presentation contexts" }
    }
  }
  my $connection;
  eval {
    $connection = Dispatch::Dicom::Connection->new_connect(
      $this->{host}, $this->{port}, $new_assoc_descrip, {
        incoming_message_handler => $MsgHandlers
      },
      $this->ConnectionCallback,
      $debug
    );
  };
  if($@){
    print STDERR "Unable to connect: $@\n";
    $this->{State} = "Failed";
    $this->{Error} = "Unable to connect $@";
    chomp $this->{Error};
    exit;
  }
  $connection->SetDisconnectCallback($this->DisconnectCallback);
  $connection->SetReleaseCallback($this->ReleaseCallback);
  $this->{State} = "AssociationPending";
  $this->{Association} = $connection;
}
sub StartSending{
  my($this) = @_;
  unless(defined $this->{Association}) { $this->AbortSending }
  if(exists $this->{Association}->{close_status}) { $this->AbortSending }
  my $max_i = $this->{Association}->{max_outstanding};
  unless($max_i >= 1) { $max_i = 1 }
  my $in_flight = keys %{$this->{FilesInFlight}};
  my $files_to_send = @{$this->{FilesToSend}};
  while($in_flight < $max_i && $files_to_send > 0){
    # send a file
    my $f = shift(@{$this->{FilesToSend}});
    my $a = $f->{abs_stx};
    my $t = $f->{xfr_stx};
    my $dso = $f->{dataset_offset};
    my $sop_cl = $a;
    my $sop_inst = $f->{sop_inst};
    my $file = $f->{file};
    my $len = $this->{Association}->{max_length};
    my $pc_id;
    if(exists $this->{Association}->{sopcl}->{$a}->{$t}){
      $pc_id = $this->{Association}->{sopcl}->{$a}->{$t};
      $this->{FilesInFlight}->{$file} = $f;
      my $cmd = Posda::Command->new_store_cmd($sop_cl, $sop_inst);
      my $ds = Dispatch::Dicom::Dataset->new_new($file,
        $t,
        $a,
        $dso,
        $len);
      my $ma = Dispatch::Dicom::MessageAssembler->new($pc_id,
        $cmd, $ds, $this->FileSent($file));
      $this->{Association}->QueueMessage($ma);
    } else {
      $f->{disposition} = "Not sent (no pc)";
      push(@{$this->{FilesNotSent}}, $f);
    }
    $in_flight = keys %{$this->{FilesInFlight}};
    $files_to_send = @{$this->{FilesToSend}};
  }
  if($in_flight <= 0 && $files_to_send <= 0){
    $this->Done;
  }
}
sub FileSent{
  my($this, $file) = @_;
  my $sub = sub {
    my($obj, $status) = @_;
    my $f = $this->{FilesInFlight}->{$file};
    $f->{disposition} = "Send Status: $status";
    delete $this->{FilesInFlight}->{$file};
    if($status eq "OK"){
      push(@{$this->{FilesSent}}, $f);
    } else {
      push(@{$this->{FilesSent}}, $f);
    }
    # let disconnect stuff run before cranking StartSending
    $this->InvokeAfterDelay("StartSending", 0);
  };
  return $sub;
}
sub AbortSending{
  my($this) = @_;
  for my $file (keys %{$this->{FilesInFlight}}){
    my $f = $this->{FilesInFlight}->{$file};
    $f->{disposition} = "Aborted Assoc while in flight";
    push(@{$this->{FilesNotSent}}, $f);
  }
  while(@{$this->{FilesToSend}} > 0){
    my $f = shift(@{$this->{FilesToSend}});
    $f->{disposition} = "Not sent (lost assoc)";
    push(@{$this->{FilesNotSent}}, $f);
  }
  $this->InvokeAfterDelay("StartSending", 0);
}
sub Done{
  my($this) = @_;
  if(exists $this->{Association} && $this->{Association}->can("ReleaseOK")){
    if($this->{Association}->ReleaseOK){
print STDERR "Issuing Release (and setting timer)\n";
      $this->{Association}->Release;
      $this->{State} = "ReleasePending";
      $this->InvokeAfterDelay("ReleaseTimer", 3);
    } else {
      $this->{Status} = "ReleaseRequestFailed";
      $this->{Error} = "Release at end Failed (busy)";
      $this->FinalizeStatus;
    }
  }
}
sub FinalizeStatus{
  my($this) = @_;
print STDERR "###\n### In Finalize Status\n###\n";
  delete $this->{InProcess};
  my $status = {
    files_sent => $this->{FilesSent},
    files_not_sent => $this->{FilesNotSent},
    files_with_errors => $this->{FilesErrors},
    final_state => $this->{State},
    host => $this->{host},
    port => $this->{port},
    called => $this->{called},
    calling => $this->{calling},
    association_ac => $this->{association_ac},
    start_time => $this->{StartTime},
    end_time => time,
    elapsed => time - $this->{StartTime},
  };
  # my $results;
  # if(-f $this->{ResultsFile}){
  #   eval {
  #     $results = Storable::retrieve($this->{ResultsFile});
  #   };
  #   if($@){
  #     $results = [
  #       { error => "Prior results file failed to parse $@" },
  #     ];
  #   }
  # }
  if(exists $this->{Error}){
    $status->{error} = $this->{Error};
  }
  # push(@{$results}, $status);
  # Storable::store($results, $this->{ResultsFile});
  # exit 0;  # Exiting here will kill the application thread, probably a bad idea?
  if(
    exists($this->{finalize_callback}) && 
    ref($this->{finalize_callback}) eq "CODE"
  ){
    print STDERR "Calling finalize_callback\n";
    my $func = $this->{finalize_callback};
#    for my $k (keys %$this) { delete $this->{$k} }
    &$func($status);
  }
}
################ Association Callbacks
sub ConnectionCallback{
  my($this) = @_;
  my $sub = sub {
    my($con) = @_;
    $this->{State} = "AssociationConnected";
    $this->{association_ac} = $this->{Association}->{assoc_ac};
    $this->StartSending;
  };
  return $sub;
}
sub DisconnectCallback{
  my($this) = @_;
  my $sub = sub {
    my($con) = @_;
    my $status;
    if(exists $con->{Abort}){
      $status = $con->{Abort}->{mess};
    } else {
      if($this->{State} eq "ReleasePending"){
print STDERR
   "Got disconnect callback in ReleasePending state - normal termination";
        $this->{State} = "ReleaseAcknowledged";
        $this->FinalizeStatus;
      } else {
        delete $this->{Association};
     }
   }
  };
  return $sub;
}
sub ReleaseCallback{
  my($this) = @_;
  my $sub = sub {
    my($con) = @_;
    $this->{State} = "PeerRequestedRelease";
    $this->AbortSending;
  };
  return $sub;
}
sub ReleaseTimer{
  my($this) = @_;
  if($this->{State} eq "ReleaseAcknowledged") {
    print STDERR "Stale release timer: $this\n";
    return;
  }
  $this->{State} = "ReleaseTimerTimeout";
  $this->{Error} = "Peer failed to acknowledge release request in time";
  $this->FinalizeStatus;
}
sub DESTROY{
  my($this) = @_;
  print STDERR "DESTROY: $this\n";
}
1;
