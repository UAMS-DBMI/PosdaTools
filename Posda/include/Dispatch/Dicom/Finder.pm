#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Dispatch/Dicom/Finder.pm,v $
#$Date: 2013/12/05 20:27:45 $
#$Revision: 1.2 $
use Dispatch::Dicom;
my $dbg = sub {print @_};
use strict;
use Dispatch::Dicom::Message;
use Posda::DataDict;
use HexDump;
package Dispatch::Dicom::Finder;
use vars qw( @ISA );
@ISA = ( "Dispatch::Dicom::Message" );
my $anon_seq = 0;
sub finalize_command{
  my($this, $dcm_conn) = @_;
  my $length = length($this->{command});
print STDERR "Received Command of length $length:\n";
HexDump::PrintVax(\*STDERR, $this->{command});
  $this->{finalized_command} = Posda::Command->new($this->{command});
  if ($this->{finalized_command}->{"(0000,0100)"} == 0x20){
    # Find request
    $this->{xfr_stx} = $dcm_conn->{pres_cntx}->{$this->{pc_id}}->{xfr_stx};
    if($this->{finalized_command}->{"(0000,0800)"} == 0x0101){
      die "No dataset in Find Request";
    }
    $this->{Dataset} = "";
    # Handled when dataset finalized
  } elsif ($this->{finalized_command}->{"(0000,0100)"} == 0xfff){
    # Cancel Request
    my $id = $this->{finalized_command}->{"(0000,0120)"};
    unless(exists $dcm_conn->{pending_messages}->{$id}){
      print STDERR "Cancel request for unknown FIND: $id\n";
      return;
    }
    my $orig_find = $dcm_conn->{active_finds}->{$id};
    if($orig_find->can("SCP_Cancel_Find_Req")){
      $orig_find->SCP_Cancel_Find_Req;
    }
  } elsif ($this->{finalized_command}->{"(0000,0100)"} == 0x8020){
    # Find response
    if($this->{finalized_command}->{"(0000,0800)"} == 0x0101){
      # no dataset is present - kick the find command with no dataset
      my $id = $this->{finalized_command}->{"(0000,0120)"};
      my $status = $this->{finalized_command}->{"(0000,0900)"};
      unless(exists $dcm_conn->{pending_messages}->{$id}){
        print STDERR "non-matched id ($id) for FIND_RSP (no DS)\n";
        return;
      }
      my $orig_cmd = $dcm_conn->{pending_messages}->{$id};
      unless($status == 0xff00 || $status == 0xff01){
        print STDERR "#########\nDeleting message (and decrementing)\n";
        $dcm_conn->DecrementOutstanding;
        delete $dcm_conn->{pending_messages}->{$id};
      }
      if($orig_cmd->can("ProcessResponse")){
        $orig_cmd->ProcessResponse($dcm_conn, $this, undef);
      } else {
        die "Can't handle Find Response";
      }
    }
    # otherwise will by handled when ds finalized
  } else {
    die "unknown command for FIND Handler";
  }
}
sub abort{
  my($this) = @_;
}
sub ds_data{
  my($this, $pc_id, $text) = @_;
  unless($this->{pc_id} == $pc_id){
    die "ds data with non-matching pc_id ($pc_id vs $this->{pc_id})";
  }
  my $len = length($text);
  $this->{cum_data_length} += $len;
  $this->{Dataset} .= $text;
}
sub finalize_ds{
  my($this, $dcm_conn) = @_;
  my $len = length($this->{Dataset});
  print STDERR "Finalize Dataset of length $len:\n";
  HexDump::PrintVax(\*STDERR, $this->{Dataset});
  if ($this->{finalized_command}->{"(0000,0100)"} == 0x020){
    # Dataset for Find Command
    my $id = $this->{finalized_command}->{"(0000,0110)"};
#    $dcm_conn->{active_finds}->{$id} = $this;
    $this->SCP_Handle_Find_Req($dcm_conn);
  } elsif ($this->{finalized_command}->{"(0000,0100)"} == 0x8020){
    # Dataset for Find Response
    my $id = $this->{finalized_command}->{"(0000,0120)"};
    my $status = $this->{finalized_command}->{"(0000,0900)"};
    unless(exists $dcm_conn->{pending_messages}->{$id}){
      print STDERR "non-matched id ($id) for FIND_RSP (with DS)\n";
      return;
    }
    my $orig_cmd = $dcm_conn->{pending_messages}->{$id};
    unless($status == 0xff00 || $status == 0xff01){
      delete $dcm_conn->{pending_messages}->{$id};
      print STDERR "#########\nDeleting message (and decrementing)\n";
      $dcm_conn->DecrementOutstanding;
    }
    if($orig_cmd->can("ProcessResponse")){
      $orig_cmd->ProcessResponse("OK");
    } else {
      my $class = ref($orig_cmd);
      die "$class can't handle Find Response";
    }
  } else {
    die "unknown command for FIND Handler on ds finalize";
  }
}
######### SCP Overrides ##########
sub SCP_Handle_Find_Req{
  my($this, $dcm_conn) = @_;
  print STDERR "Find Command received:\n";
  for my $k (sort keys %{$this->{finalized_command}}){
    print STDERR "$k => $this->{finalized_command}->{$k}\n";
  }
  open my $fh, ">find_req$anon_seq.dcm";
  print $fh $this->{Dataset};
  close $fh;
  print STDERR `DumpDicom.pl "find_req$anon_seq.dcm"`;
  Dispatch::Select::Background->new($this->IssueDelayedAbort($dcm_conn))
    ->timer(10);
}
sub SCP_Cancel_Find_Req{
  my($this, $dcm_conn) = @_;
}
######### SCU Overrides ##########
sub SCU_Handle_Find_Response{
  my($this, $dcm_conn, $rsp, $ds) = @_;
}
######### Temp Debug  ##########
sub IssueDelayedAbort{
  my($this, $dcm_conn) = @_;
  my $sub = sub {
    $dcm_conn->Abort("Find not really handled");
  };
  return $sub;
}
1;

