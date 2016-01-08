#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Dispatch/Dicom/Storage.pm,v $
#$Date: 2015/04/22 19:35:51 $
#$Revision: 1.11 $
use Dispatch::Dicom;
my $dbg = sub {print @_};
use strict;
use Dispatch::Dicom::Message;
use Posda::DataDict;
package Dispatch::Dicom::Storage;
use vars qw( @ISA );
@ISA = ( "Dispatch::Dicom::Message" );
my $anon_seq = 0;
sub finalize_command{
  my($this, $dcm_conn) = @_;
  my $length = length($this->{command});
  $this->{finalized_command} = Posda::Command->new($this->{command});
  if ($this->{finalized_command}->{"(0000,0100)"} == 0x01){
    my $SOPClass = $this->{finalized_command}->{"(0000,0002)"};
    my $SOPInstance = $this->{finalized_command}->{"(0000,1000)"};
    my $SOPClassPrefix = Posda::DataDict::GetSopClassPrefix($SOPClass);
    my $AbstractSyntax = $dcm_conn->{pres_cntx}->{$this->{pc_id}}->{abs_stx};
    my $TransferSyntax = $dcm_conn->{pres_cntx}->{$this->{pc_id}}->{xfr_stx};
    my $AETitle = $dcm_conn->{assoc_ac}->{called};
    my $ImpClassUID = $dcm_conn->{assoc_ac}->{imp_class_uid};
    my $ImpVerName = $dcm_conn->{assoc_ac}->{imp_ver_name};
    my $file_name = "${SOPClassPrefix}_$SOPInstance.dcm";
    if($file_name eq ".dcm"){
      $file_name = "NoUidInCommand_$anon_seq.dcm";
      $anon_seq += 1;
    }
    if(defined $dcm_conn->{storage_root}){
      $file_name =  "$dcm_conn->{storage_root}/$file_name";
    }
    my $cmd = "";
    $cmd .= pack("vv", 2, 1) . 'OB' . pack("vVv", 0, 2, 1);
    my $len = length $SOPClass;
    if($len & 1) { $SOPClass .= "\0" }
    $cmd .= pack("vv", 2, 2) . 'UI' .
      pack("v", length($SOPClass)) . $SOPClass;
    # Media Storage SOP Instance UID
    $len = length $SOPInstance;
    if($len & 1) { $SOPInstance .= "\0" }
    $cmd .= pack("vv", 2, 3) . 'UI' .
      pack("v", length($SOPInstance)) . $SOPInstance;
    # Transfer Syntax UID
    $len = length $TransferSyntax;
    if($len & 1) { $TransferSyntax .= "\0" }
    $cmd .= pack("vv", 2, 0x10) . 'UI' .
      pack("v", length($TransferSyntax)) . $TransferSyntax;
    # Implementation Class UID
    $len = length $ImpClassUID;
    if($len & 1) { $ImpClassUID .= "\0" }
    $cmd .= pack("vv", 2, 0x12) . 'UI' .
      pack("v", length($ImpClassUID)) . $ImpClassUID;
    # Implementation Version Name
    $len = length $ImpVerName;
    if($len & 1) { $ImpVerName .= " " }
    $cmd .= pack("vv", 2, 0x13) . 'SH' .
      pack("v", length($ImpVerName)) . $ImpVerName;
    # AE Title
    $len = length $AETitle;
    if($len & 1) { $AETitle .= " " }
    $cmd .= pack("vv", 2, 0x16) . 'AE' .
      pack("v", length($AETitle)) . $AETitle;
    my $full_cmd = pack("vv", 2, 0) . 'UL' . pack("vV", 4, length($cmd)) .
      $cmd;
    my $fh = FileHandle->new(">$file_name");
    unless($fh) {
      print STDERR 
        "**********************\n" .
        "Failed to open $file_name ($!)\n" .
        "**********************\n";
      return;
    }
    $fh->binmode();
    $this->{file_name} = $file_name;
    print $fh "\0" x 128;
    print $fh "DICM";
    print $fh $full_cmd;
    $this->{fh} = $fh;
  } elsif ($this->{finalized_command}->{"(0000,0100)"} == 0x8001){
    my $msg_id = $this->{finalized_command}->{"(0000,0120)"};
    $dcm_conn->DecrementOutstanding();
    my $orig_msg = $dcm_conn->{pending_messages}->{$msg_id};
    delete $dcm_conn->{pending_messages}->{$msg_id};
    if($orig_msg->can("ProcessResponse")){
      $orig_msg->ProcessResponse($this->{finalized_command});
    }
  } else {
    die "unknown command on storage presentation context";
  }
}
sub abort{
  my($this) = @_;
  $this->{fh}->close;
  delete $this->{fh};
  unlink($this->{file_name});
}
sub ds_data{
  my($this, $pc_id, $text) = @_;
  unless($this->{pc_id} == $pc_id){
    die "ds data with non-matching pc_id ($pc_id vs $this->{pc_id})";
  }
  my $len = length($text);
  if(defined $this->{fh}){
  $this->{fh}->print($text);
  } else {
    print STDERR "Discarding $len bytes of data\n";
  }
  $this->{cum_data_length} += $len;
}
sub finalize_ds{
  my($this, $dcm_conn) = @_;
  unless(defined $this->{fh}){
    $this->finalize_failure($dcm_conn);
  }
  close $this->{fh};
  delete $this->{fh};
  my $file_name = $this->{file_name};
  delete $this->{file_name};
  my $TransferSyntax = $dcm_conn->{pres_cntx}->{$this->{pc_id}}->{xfr_stx};
  #########################################################################
  #  Everything in the following if is TOTALLY wrong!!!!!!!!!!!!
  #  but it might be necessary for some lame peers to "work" with us
  #
  if($this->{finalized_command}->{"(0000,1000)"} eq ""){
    ## OOPS - blank SOP Instance in command - lets see if we can get it 
    ## from the file (Don't you just love jumping up a level??
    open FILE, "GetElementValue.pl $file_name \"(0008,0018)\" 2>/dev/null|";
    binmode FILE;
    my $uid;
    while (my $line = <FILE>){
      $uid = $line;
    }
    close FILE;
    if($uid ne ""){
      # Well the file has one.  Lets rename it....
      print STDERR "Lame alert - no SOP Inst in command, but one in dataset\n";
      my $new_file_name = "$uid.dcm";
      if(defined $dcm_conn->{storage_root}){
        $new_file_name =  "$dcm_conn->{storage_root}/$new_file_name";
      }
      my $mcmd = "mv $file_name $new_file_name";
      `$mcmd`;
      $file_name = $new_file_name;
      ###################################################################
      ####
      ##  OK - now lets COMPLETELY VIOLATE THE STANDARD
      ####
      ##  here we put the SOP Instance UID from the Dataset (not the command)
      ##  into the response and see if it helps the lamer we're talking to
      ##  (well, it doesn't seem to... )
      ##  uncomment following line to descend further into madness:
      #$this->{finalized_command}->{"(0000,1000)"} = $uid;
      ###################################################################
    }
  }
  # end of (this particular) insanity -----
  #########################################################################
  if(
    exists($dcm_conn->{file_handler}) && 
    ref($dcm_conn->{file_handler}) eq "CODE"
  ){
    &{$dcm_conn->{file_handler}}($file_name, 
      $this->{finalized_command}->{"(0000,0002)"}, 
      $this->{finalized_command}->{"(0000,1000)"}, 
      $TransferSyntax
    );
  }
  my $mess_type = $this->{finalized_command}->{"(0000,0100)"};
  my $resp = $this->{finalized_command}->new_store_response(0);
  my $cma = Dispatch::Dicom::MessageAssembler->new(
    $this->{pc_id}, $resp);
  $dcm_conn->QueueResponse($cma);
}
sub finalize_failure{
  my($this, $dcm_conn) = @_;
  my $resp = $this->{finalized_command}->new_store_response(0xa700);
  my $cma = Dispatch::Dicom::MessageAssembler->new(
    $this->{pc_id}, $resp);
  $dcm_conn->QueueResponse($cma);
}

{
  package Dispatch::Dicom::StorageWithDelay;
  use vars qw( @ISA $delay );
  @ISA = ( "Dispatch::Dicom::Message", "Dispatch::Dicom::Storage");
  $delay = 10;
  sub finalize_ds{
    my($this, $dcm_conn) = @_;
    close $this->{fh};
    delete $this->{fh};
    my $foo = Dispatch::Select::Background->new(
      $this->DelayedResponse($dcm_conn));
    $foo->timer($delay);
    return;
  }
  sub DelayedResponse{
    my($this, $dcm_conn) = @_;
    my $foo = sub {
      my($back) = @_;
      my $mess_type = $this->{finalized_command}->{"(0000,0100)"};
      my $resp = $this->{finalized_command}->new_store_response(0);
      my $cma = Dispatch::Dicom::MessageAssembler->new(
        $this->{pc_id}, $resp);
      $dcm_conn->QueueResponse($cma);
    };
    return $foo;
  }
  sub set_delay{
    my($class, $inc) = @_;
    $delay = $inc;
  }
}
1;

