#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Digest::MD5;
use Dispatch::Select;
use Dispatch::EventHandler;
use Dispatch::Dicom::Dataset;
use Dispatch::Dicom::Message;
use Dispatch::Dicom::Storage;
use Dispatch::Dicom::MessageAssembler;
use Posda::Command;
use Storable qw( store retrieve retrieve fd_retrieve store_fd );
use Debug;
$| = 1;
my $dbg = sub { print STDERR @_ };
my $help = <<EOF;
Usage: 
  DicomSendTransaction.pl <host> <port> <called> <calling> <dicom_info> <res>
or
  DicomSendTransaction.pl -h

<dicom_info> is a file containing a serialized perl data structure:
\$hash = {
  FilesByDigest => {
    <file_digest> => {
       dataset_start_offset => <offset of dataset within file>,
       dataset_size => <size of dataset>,
       xfr_stx => <transfer syntax>,
       file => <path to file>
       ... # lots of other stuff
    },
    ...
  },
  FilesToDigest => {
    <path to file> => <digest>,
    ...
  },
};
<res> is the path of a file in which to store the results of the send.  It
collects all of the results of any send for this directory (sends are atomic
because the directory must be locked for the duration),  <res> is a
serialized perl array, each entry of which is a hash which represents a send
event:
\$event = {
  files_sent => {
    file => <path_to_file>
    xfr_stx => <xfr_stx>,
    abs_stx => <sop_class_uid>,
    sop_inst => <sop_inst_uid>,
    dataset_offset => <dataset_start_offset>,
    dataset_size => <dataset_size>,
    disposition => <dispostion>,
  },
  files_not_sent => {
    file => <path_to_file>
    xfr_stx => <xfr_stx>,
    abs_stx => <sop_class_uid>,
    sop_inst => <sop_inst_uid>,
    dataset_offset => <dataset_start_offset>,
    dataset_size => <dataset_size>,
    disposition => <dispostion>,
  }
  files_with_errors => {
    file => <path_to_file>
    xfr_stx => <xfr_stx>,
    abs_stx => <sop_class_uid>,
    sop_inst => <sop_inst_uid>,
    dataset_offset => <dataset_start_offset>,
    dataset_size => <dataset_size>,
    disposition => <dispostion>,
  },
  final_state => <final_state>,
  host => <host>,
  port => <port>,
  called => <called>,
  calling => <calling>,
  association_ac => {
    app_context => "1.2.840.10008.3.1.1.1"
    called => "LOCAL_SCP"
    calling => "FILE_DIST"
    imp_class_uid => "1.3.6.1.4.1.22213.1.69"
    imp_version_name => "Posda Ver 1.0"
    max_i => "1"
    max_length => "16384"
    max_p => "1"
    presentation_contexts => {
      <pc_id> => <xfr_stx> | undef,
      ...
    }
    rejected_pc => {
      <pd_id> => <reason>,
      ...
    }
    ver => "1"
  },
  start_time => <start_time>,
  end_time => <end_time>,
  elapsed => <elapsed>,
  [ error => <error_message>, ]
};
EOF
if($#ARGV != 5 || ($ARGV[0] eq "-h")){
  print $help;
  exit;
}
my $host = $ARGV[0];
my $port = $ARGV[1];
my $called = $ARGV[2];
my $calling = $ARGV[3];
my $dicom_info_file = $ARGV[4];
my $results = $ARGV[5];
unless(-f $dicom_info_file) { die "file $dicom_info_file doesn't exist" }
my $dicom_info = Storable::retrieve($dicom_info_file);
## execution skips around object and function definitions to near bottom...
{
  package Sender;
  use vars qw( @ISA );
  @ISA = ( "Dispatch::EventHandler" );
  my $MsgHandlers;
  sub new {
    my($class, $host, $port, $called, $calling, $info, $results) = @_;
    my $this = {
      host => $host,
      port => $port,
      called => $called,
      calling => $calling,
      info => $info,
      StartTime => time,
      ResultsFile => $results,
    };
    bless $this, $class;
    $this->Initialize;
    Dispatch::Select::Background->new($this->StatusReporter)->queue;
    return $this;
  }
  sub StatusReporter{
    my($this) = @_;
    my $sub = sub {
      my($disp) = @_;
      # if still InProcess,
      if($this->{InProcess}){
        # Report Status on STDOUT
        $this->ReportStatus;
        $disp->timer(2);
        # and do it again in 2 seconds
      }
      #otherwise, stop (we're done).
    };
    return $sub;
  }
  sub ReportStatus{
    my($this) = @_;
    # if still InProcess,
    unless($this->{InProcess}) { return }
    # Report Status on STDOUT
    my %statii;
#    $statii{Status} = $this->{State};
    my $elapsed = time - $this->{StartTime};
    $statii{Elapsed} = time - $this->{StartTime};
    my $files_to_send = @{$this->{FilesToSend}};
    if($files_to_send){
      $statii{FilesToSend} = $files_to_send;
    }
    my $files_sent = @{$this->{FilesSent}};
    if($files_sent){
      $statii{FilesSent} = $files_sent;
    }
    my $files_not_sent = @{$this->{FilesNotSent}};
    if($files_not_sent){
      $statii{FilesNotSent} = $files_not_sent;
    }
    my $files_in_flight = keys %{$this->{FilesInFlight}};
    if($files_in_flight){
      $statii{FilesInFlight} = $files_in_flight;
    }
    my $files_errors = @{$this->{FilesErrors}};
    if($files_errors){
      $statii{FilesErrors} = $files_errors;
    }
    if(exists $this->{Error}) {
      $statii{Error} = $this->{Error};
    }
    print "Status=$this->{State}";
    for my $i (keys %statii){
      print "&$i=$statii{$i}";
    }
    print "\n";
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
    $this->{FilesToSend} = [];
    $this->{FilesSent} = [];
    $this->{FilesNotSent} = [];
    $this->{FilesInFlight} = {};
    $this->{FilesErrors} = [];
    my %pcs;
    for my $file (sort keys %{$this->{info}->{FilesToDigest}}){
      my $dig = $this->{info}->{FilesToDigest}->{$file};
      my $finfo = $this->{info}->{FilesByDigest}->{$dig};
      $MsgHandlers->{$finfo->{sop_class_uid}} = "Dispatch::Dicom::Storage";
      push(@{$this->{FilesToSend}}, {
        file => $file,
        xfr_stx => $finfo->{xfr_stx},
        abs_stx => $finfo->{sop_class_uid},
        sop_inst => $finfo->{sop_inst_uid},
        dataset_offset => $finfo->{dataset_start_offset},
        dataset_size => $finfo->{meta_header}->{DataSetSize},
      });
      my $abs = $this->{info}->{FilesByDigest}->{$dig}->{sop_class_uid};
      my $xfr = $this->{info}->{FilesByDigest}->{$dig}->{xfr_stx};
      $pcs{$abs}->{$xfr} = 1;
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
      #print STDERR "Unable to connect: $@\n";
      $this->{State} = "Failed";
      $this->{Error} = "Unable to connect $@";
      chomp $this->{Error};
      $this->ReportStatus;
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
        $this->{Association}->Release;
        $this->{State} = "ReleasePending";
        $this->ReportStatus;
        $this->InvokeAfterDelay("ReleaseTimer", 3);
      } else {
        $this->{Status} = "ReleaseRequestFailed";
        $this->{Error} = "Release at end Failed (busy)";
        $this->ReportStatus;
        $this->FinalizeStatus;
      }
    }
  }
  sub FinalizeStatus{
    my($this) = @_;
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
    my $results;
    if(-f $this->{ResultsFile}){
      eval {
        $results = Storable::retrieve($this->{ResultsFile});
      };
      if($@){
        $results = [
          { error => "Prior results file failed to parse $@" },
        ];
      }
    }
    if(exists $this->{Error}){
      $status->{error} = $this->{Error};
    }
    push(@{$results}, $status);
    Storable::store($results, $this->{ResultsFile});
    exit 0;
  }
  ################ Association Callbacks
  sub ConnectionCallback{
    my($this) = @_;
    my $sub = sub {
      my($con) = @_;
      $this->{State} = "AssociationConnected";
      $this->{association_ac} = $this->{Association}->{assoc_ac};
      $this->ReportStatus;
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
          $this->{State} = "ReleaseAcknowledged";
          $this->ReportStatus;
          $this->FinalizeStatus;
        } else {
          delete $this->{Association};
       }
     }
     $this->ReportStatus;
    };
    return $sub;
  }
  sub ReleaseCallback{
    my($this) = @_;
    my $sub = sub {
      my($con) = @_;
      $this->{State} = "PeerRequestedRelease";
      $this->ReportStatus;
      $this->AbortSending;
    };
    return $sub;
  }
  sub ReleaseTimer{
    my($this) = @_;
    $this->{State} = "ReleaseTimerTimeout";
    $this->{Error} = "Peer failed to acknowledge release request in time";
    $this->ReportStatus;
    $this->FinalizeStatus;
  }
}
###  These routines create closures to queue
sub MakeSender{
  my($host, $port, $called, $calling, $dicom_info, $results) = @_;
  my $sub = sub {
    my($disp) = @_;
    Sender->new($host, $port, $called, $calling, $dicom_info, $results);
  };
  return $sub;
}
####
### Execution of main prog continues here
{
  Dispatch::Select::Background->new(MakeSender(
    $host, $port, $called, $calling, $dicom_info, $results))->queue;
}
Dispatch::Select::Dispatch();
