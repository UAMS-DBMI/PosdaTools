#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Dispatch/Dicom/Message.pm,v $
#$Date: 2013/10/04 19:38:42 $
#$Revision: 1.6 $
use Dispatch::Dicom;
my $dbg = sub {print @_};
use strict;
{
  package Dispatch::Dicom::Message;
  sub new {
    my($class, $pc_id, $dcm_conn, $delay) = @_;
    my $this = {
      pc_id => $pc_id,
      pres_contexts => $dcm_conn->{pres_cntx},
      command => "",
      cum_data_length => 0,
    };
    if(defined $delay){
      $this->{delay} = $delay;
    }
    my $abs_stx = $dcm_conn->{pres_cntx}->{$pc_id}->{abs_stx};
    if(exists $dcm_conn->{incoming_message_handler}->{$abs_stx}){
      ############  This is the funky magic you're looking for: 
      $class = $dcm_conn->{incoming_message_handler}->{$abs_stx};
      ############
    }
    bless $this, $class;
    if($this->can("Initialize")) {
      $this->Initialize($pc_id, $dcm_conn, $delay)
#    } else {
#      print STDERR "$class can't initialize ($abs_stx)\n";
    }
    if($ENV{POSDA_DEBUG}){
      print "NEW: $this\n";
    }
    return $this;
  }
  sub command_data{
    my($this, $pc_id, $text) = @_;
    unless($this->{pc_id} == $pc_id){
      die "command data with non-matching pc_id ($pc_id vs $this->{pc_id})";
    }
    $this->{command} .= $text;
  }
  sub finalize_command{
    my($this, $dcm_conn) = @_;
    my $class = ref($this);
    my $abs_stx = $this->{pres_contexts}->{$this->{pc_id}}->{abs_stx};
    die "Error:\n" .
     "\tPerhaps finalize_command should be overridden in $class\n" .
     "\tOr perhaps you need to configure $abs_stx\n" .
     "\tto have a better IncomingMessageHandler\n ---";
  }
  sub has_dataset{
    my($this) = @_;
    if($this->{finalized_command}->{"(0000,0800)"} == 0x0101){
      return 0;
    } 
    return 1;
  } 
#  sub ds_data{
#    my($this, $pc_id, $text) = @_;
#    die "ds_data be overridden";
#  }
#  sub finalize_ds{
#    my($this, $dcm_conn) = @_;
#    die "finialize_ds be overridden";
#  }
  sub DESTROY{
    my($this) = @_;
    if($ENV{POSDA_DEBUG}){
      print "DESTROY: $this\n";
    }
  }
}
1;
