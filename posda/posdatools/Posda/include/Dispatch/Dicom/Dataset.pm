#!/usr/bin/perl -w
use Dispatch::Dicom;
my $dbg = sub {print @_};
use strict;
package Dispatch::Dicom::Dataset;
use vars qw( @ISA );
@ISA = ( "Dispatch::DebugHandler" );
sub new{
  my($class, $file, $xfr_stx, $pdu_len, $debug) = @_;
  my $this = {
    file => $file,
    xfr_stx => $xfr_stx,
    finished => 0,
    pdv_len => $pdu_len - 6,
  };
  bless $this, $class;
  if(defined $debug){ $this->Debug($debug) }
  if($ENV{POSDA_DEBUG}){
    print "NEW: $this\n";
  }
  return $this;
}
sub new_new{
  my($class, $file, $ds_xfr_stx, $pc_xfr_stx,
    $ds_offset, $pdu_len, $debug) = @_;
  my $this = {
    file => $file,
    ds_xfr_stx => $ds_xfr_stx,
    pc_xfr_stx => $pc_xfr_stx,
    ds_offset => $ds_offset,
    xfr_stx => $pc_xfr_stx,
    finished => 0,
    pdv_len => $pdu_len - 6,
  };
  bless $this, $class;
  if(defined $debug){ $this->Debug($debug) }
  if($ENV{POSDA_DEBUG}){
    print "NEW: $this\n";
  }
  return $this;
}
sub start {
  my($this) = @_;
  $this->DebugMsg("Starting dataset: $this->{file}\n");
  my $buff;
  if(exists $this->{fh}) { return }
  my $fh;
  if(
    exists($this->{pc_xfr_stx}) && 
    $this->{ds_xfr_stx} eq $this->{ds_xfr_stx}
  ){
   $fh = FileHandle->new("<$this->{file}");
   $fh->binmode();
   $fh->sysseek($this->{ds_offset}, 0);
  } else {
    $fh = FileHandle->new("RenderDs.pl $this->{file} $this->{xfr_stx}|");
    $fh->binmode();
  }
  $this->{fh} = $fh;
  $this->CreateReader();
}
sub CreateReader{
  my($this) = @_;
  my $foo = sub {
    my($disp) = @_;
    if($this->{finished}){
      return;
    }
    my $data;
    my $length_to_read = $this->{pdv_len};
    if($#{$this->{queue}} > 1){
      unless($this->{finished}){
        $this->WaitForQueueRemoval();
      }
      return;
    }
    my $lr = sysread($this->{fh}, $data, $length_to_read);
    $this->DebugMsg("read $lr bytes from file");
    if($lr == 0){
      $this->DebugMsg("file is finished");
      $this->{finished} = 1;
    } else {
      push(@{$this->{queue}}, $data);
    }
    if(exists $this->{wait_data_in_queue}){
      $this->DebugMsg("posting wait flag");
      $this->{wait_data_in_queue}->post_and_clear();
      delete $this->{wait_data_in_queue};
    }
    $disp->queue();
  };
  $this->DebugMsg("CreatedReader");
  my $disp = Dispatch::Select::Background->new($foo);
  $disp->queue();
}
sub WaitForQueueRemoval{
  my($this) = @_;
  my $foo = sub {
    my($back) = @_;
    delete $this->{removal_event};
    $this->CreateReader();
  };
  $this->DebugMsg("Awaiting queue removal");
  $this->{removal_event} = Dispatch::Select::Event->new(
    Dispatch::Select::Background->new($foo), 
    $this->{debug} ? "Queue Removal Event" : undef
  );
}
sub ready_out{
  # returns -1 finished, 0 not ready, 1 ready
  # not ready until > pdv_len, or finished flag set
  my($this, $size) = @_;
  if($#{$this->{queue}} < 0){
    if($this->{finished}) { return -1 }
    return 0;
  }
  if($#{$this->{queue}} > 0){
    return 1;
  }
  if($this->{finished}){
    return 1;
  }
  return 0;
}
sub get_pdv{
  # trouble unless ready for pdv_len
  my($this, $pdv_len, $pc_id) = @_;
  my $flgs = 0;
  unless(defined $this->{queue}){ die "data undefined" }
  my $data = shift(@{$this->{queue}});
  my $len = length ($data);
  if(length($data) > $pdv_len) {
    unshift(@{$this->{queue}}, $data);
     $this->DebugMsg("#####ERROR######");
    return [];
  }
  if($this->{finished} && $#{$this->{queue}} < 0){
    $flgs |= 2;
  }
  if(defined($this->{removal_event})){
    unless($this->{removal_event}->can("post_and_clear")){ die "wtf!" }
    $this->{removal_event}->post_and_clear();
    delete $this->{removal_event};
  }
  my @foo;
  my $new_len = length($data) + 2;
  $this->DebugMsg("get_pdv($pdv_len) len: $new_len, pc: $pc_id " .
    "flags: $flgs\n");
  push(@foo, pack("NCC", length($data) + 2, $pc_id, $flgs));
  push(@foo, $data);
  return \@foo;
}
sub wait_ready_out{
  my($this, $event) = @_;
  $this->DebugMsg("Waiting for read");
  if($this->{debug}){
    $event->Debug("Waiting for Ready");
  }
  $this->{wait_data_in_queue} = $event;
}
sub AbortPlease{
  my($this) = @_;
  if(exists $this->{wait_data_in_queue}){
    $this->{wait_data_in_queue}->post_and_clear();
    delete $this->{wait_data_in_queue};
  }
}
sub DESTROY{
  my($this) = @_;
  if($ENV{POSDA_DEBUG}){
    print "DESTROY: $this\n";
  }
}
1;
