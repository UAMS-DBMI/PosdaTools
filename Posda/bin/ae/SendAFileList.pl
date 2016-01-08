#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/ae/SendAFileList.pl,v $
#$Date: 2010/03/04 20:04:29 $
#$Revision: 1.6 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Dispatch::Select;
use Dispatch::Queue;
use Dispatch::Acceptor;
use Dispatch::Dicom::Storage;
use Dispatch::Dicom::Verification;
use Dispatch::Dicom::MessageAssembler;
use Dispatch::Dicom::Dataset;
use Dispatch::Command::Basic;
use IO::Socket::INET;
use FileHandle;

unless($#ARGV == 2){ die "usage: $0 <host> <port> <config>" }
my $host = $ARGV[0];
my $port = $ARGV[1];
my $config = $ARGV[2];

my $Outstanding = 0;
sub CreateFileResponse{
  my($file_name, $dicom) = @_;
  my $foo = sub {
    my($resp) = @_;
    print "response for send of file: $file_name\n";
    $Outstanding -= 1;
    print "$Outstanding files outstanding\n";
    if($Outstanding == 0){ $dicom->Release() }
  };
  return $foo;
}
sub CreateSender{
  my($list, $obj) = @_;
  my $foo = sub {
    my($back) = @_;
    unless(ref($list) eq "ARRAY"){ return };
    unless($#{$list} >= 0){ return };
    my $descrip = shift @$list;
    my $file = $descrip->{path};
    my $sopcl = $descrip->{sop_class};
    my $xfr_stx = $descrip->{xfr_stx};
    my $sop_inst = $descrip->{sop_inst};
    my $default_xfr_stx = '1.2.840.10008.1.2';
    unless($sopcl && $xfr_stx){
      print "couldn't get sopcl and xfr_stx from file\n";
      return;
    }
    unless(exists $obj->{sopcl}->{$sopcl}){
      print STDERR "connection doesn't handle sopcl $sopcl\n";
      unless($#{$list} >= 0){ 
        if($Outstanding == 0){
          $obj->Release();
        }
        return;
      };
      $back->queue();
      return;
    }
    unless(
      exists $obj->{sopcl}->{$sopcl}->{$xfr_stx}
    ){
      unless(
        exists $obj->{sopcl}->{$sopcl}->{$default_xfr_stx}
      ){
        print STDERR 
          "connection doesn't handle xfr_stx $xfr_stx for sopcl $sopcl\n" .
          "It handles:\n";
        for my $i (keys %{$obj->{sopcl}->{$sopcl}}){
          print STDERR "\t$i\n";
        }
        unless($#{$list} >= 0){ return };
        $back->queue();
        return;
      }
      $xfr_stx = $default_xfr_stx;
    }
    my $pc_id = $obj->{sopcl}->{$sopcl}->{$xfr_stx};
    my $len = $obj->{max_length};
    my $ds = Dispatch::Dicom::Dataset->new($file, $xfr_stx, $len);
    my $cmd = Posda::Command->new_store_cmd($sopcl, $sop_inst);
    my $ma = Dispatch::Dicom::MessageAssembler->new($pc_id,
      $cmd, $ds, CreateFileResponse($file, $obj));
    $obj->QueueMessage($ma);
    $Outstanding += 1;
    my $now = time();
    print "Queued $file for transmission at $now\n";
    unless($#{$list} >= 0){ return };
    $back->queue();
  };
  return $foo;
}

my @FilesList;
my %Overrides;

my($calling, $called);
while(my $line = <STDIN>){
  chomp $line;
  if($line =~ /^([^\|]*)\|(.*)$/){
    my $type = $1;
    my $remain = $2;
    if($type eq "file"){
      my($sop_class, $sop_instance, $xfr_stx, $path) = split(/\|/, $remain);
      push @FilesList, {
        path => $path,
        sop_class => $sop_class,
        sop_inst => $sop_instance,
        xfr_stx => $xfr_stx,
      };
    } elsif($type eq "respond_port"){
      $port = $remain;
    } elsif($type eq "called"){
      $called = $remain;
      $Overrides{called} = $called;
    } elsif($type eq "calling"){
      $calling = $remain;
      $Overrides{calling} = $calling;
    } elsif($type eq "host"){
      $host = $remain;
    }
  }
}

sub MakeConnectionCallback{
  my($FileList) = @_;
  my $foo = sub {
    my($Dicom) = @_;
    print "Connection established\n";
    my $sender = Dispatch::Select::Background->new(
      CreateSender($FileList, $Dicom)
    );
    $sender->queue();
  };
  return $foo;
}
sub MakeDoIt{
  my($host, $port, $file, $FileList) = @_;
  my $foo = sub {
    my($back) = @_;
    my $Dicom = Dispatch::Dicom::Connection->connect($host, $port, $file,
      MakeConnectionCallback($FileList), \%Overrides
    );
    unless($Dicom) { die "Couldn't connect to $host, $port using $file" }
  };
  return $foo;
}
if($#FilesList >= 0){
  my $DoIt = Dispatch::Select::Background->new(MakeDoIt(
    $host, $port, $config, \@FilesList
  ));
  $DoIt->queue();
  Dispatch::Select::Dispatch();
} else {
  print STDERR "No files to queue\n";
}
if($ENV{POSDA_DEBUG}){
  print "Returned from Dispatch\n";
}
