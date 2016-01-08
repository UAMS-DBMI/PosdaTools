#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/ae/SendDirectory.pl,v $
#$Date: 2013/03/19 19:51:33 $
#$Revision: 1.6 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use strict;
use Posda::Find;
use Dispatch::Select;
use Dispatch::DicomSender;
use Dispatch::DicomSnd;
use Dispatch::SingleCommandApp;
Posda::Dataset::InitDD();
use Debug;
my $dbg = sub {print @_};

use vars qw( $HTTP_APP_SINGLETON );

{
  package MessageObj;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpObj" );
  sub new{
    my($class, $session, $path, $debug) = @_;
    my $this = Posda::HttpObj->new($session, $path);
    $this->{debug} = $debug;
    return bless $this, $class;
  }
  sub Message{
    my($this, $msg) = @_;
    if($this->{debug}){
      print "$msg\n";
    }
  }
  sub SetSendList{
    my($this, $sender_name, $list) = @_;
    $this->{sender_name} = $sender_name;
    $this->{send_list} = $list;
    if($this->{ClearToSend}) {$this->InitiateSend}
  }
  sub ClearToSend{
    my($this) = @_;
    $this->{ClearToSend} = 1;
    if($this->{sender_name}) {$this->InitiateSend}
  }
  sub InitiateSend{
    my($this) = @_;
    my $send_obj = $this->get_obj($this->{sender_name});
    unless($send_obj && $send_obj->can("Send")){
      die "no Sender named $this->{sender_name}";
    }
    $send_obj->Send($this->{send_list});
  }
  sub SendComplete{
    my($this) = @_;
    my $send_obj = $this->get_obj($this->{sender_name});
    unless($send_obj && $send_obj->can("Send")){
      die "no Sender named $this->{sender_name}";
    }
    $send_obj->Release;
    #print "Send Complete\n";
  }
  sub ConnectionGone{
    my($this) = @_;
    $this->DeleteSelf;
  }
}
$HTTP_APP_SINGLETON = Dispatch::SingleCommandApp->new;
my $session = $HTTP_APP_SINGLETON->NewSession;

my $usage = sub {
  die "usage: $0 <source directory> <host> <port> <calling_aet>" .
    " <called_aet> [debug]\n";
};
unless(
  $#ARGV == 4 || ($#ARGV == 5 && $ARGV[5] eq "debug")
) {
  &$usage();
}
my $dir = $ARGV[0];
my $host = $ARGV[1];
my $port = $ARGV[2];
my $calling = $ARGV[3];
my $called = $ARGV[4];
my $debug;
if(defined($ARGV[5]) && $ARGV[5] eq "debug"){
  $debug = "Connection to $host, $port";
}
if($debug){
  print "Host: $host\n";
  print "Port: $port\n";
  print "Calling AE: $calling\n";
  print "Called AE: $called\n";
}
my $cwd = getcwd;
unless($dir =~ /^\//) { $dir = "$cwd/$dir" }
unless(-d $dir) { die "$dir is not a directory" }
if($debug) {
  print "dir: $dir\n";
}
my $list = Posda::Find::CollectMetaHeaders($dir);

my(%sop_classes, %xfr_stxs);
my @files_to_send;
for my $i (@$list){
  if($i->{sop_class} eq "1.2.840.10008.1.3.10") { next }
  $sop_classes{$i->{sop_class}} = 1;
  $xfr_stxs{$i->{xfr_stx}} = 1;
  push(@files_to_send, $i);
}
my @sop_classes = keys %sop_classes;
my @xfr_stxs = keys %xfr_stxs;
if($debug){
  print "Sop Classes:\n";
  for my $i (@sop_classes) { print "\t$i\n" }
  print "Xfr Syntaxes:\n";
  for my $i (@xfr_stxs) { print "\t$i\n" }
}

sub MakeStarter{
  my $start = sub {
    my $mess = MessageObj->new($session, "MessageObj", $debug);
    my $sender = Dispatch::DicomSender->new(
      $session, "Sender", "MessageObj", $debug ? "Sender" : undef);
    $sender->StartAssoc($host, $port,
      $calling, $called, \@sop_classes, \@xfr_stxs, $debug);
    $mess->SetSendList("Sender", \@files_to_send);
  };
  return $start;
};
{
  my $closure = MakeStarter();
  my $disp = Dispatch::Select::Background->new($closure);
  $disp->queue;
}
Dispatch::Select::Dispatch();
