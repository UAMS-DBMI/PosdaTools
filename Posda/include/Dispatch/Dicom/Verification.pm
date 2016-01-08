#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Dispatch/Dicom/Verification.pm,v $
#$Date: 2010/10/12 21:25:48 $
#$Revision: 1.2 $
use Dispatch::Dicom;
my $dbg = sub {print @_};
use Dispatch::Dicom::Message;
use strict;
package Dispatch::Dicom::Verification;
use vars qw( @ISA );
@ISA = ( "Dispatch::Dicom::Message" );
sub finalize_command{
  my($this, $dcm_conn) = @_;
  my $length = length($this->{command});
  $this->{finalized_command} = Posda::Command->new($this->{command});
  if($this->{finalized_command}->{"(0000,0100)"} == 0x30){
    my $resp = $this->{finalized_command}->new_verif_response(0);
    if(exists $dcm_conn->{echo_request_callback}){
      &{$dcm_conn->{echo_request_callback}}();
    }
    my $cma = Dispatch::Dicom::MessageAssembler->new(
      $this->{pc_id}, $resp);
    $dcm_conn->QueueResponse($cma);
  } elsif ($this->{finalized_command}->{"(0000,0100)"} == 0x8030){
    my $msg_id = $this->{finalized_command}->{"(0000,0120)"};
    $dcm_conn->DecrementOutstanding();
    my $orig_msg =  $dcm_conn->{pending_messages}->{$msg_id};
    delete $dcm_conn->{pending_messages}->{$msg_id};
    if($orig_msg->can("ProcessResponse")){
      $orig_msg->ProcessResponse($this->{finalized_command});
    }
  } else {
    die "unknown command in Verification SOP Class\n";
  }
}
1;
