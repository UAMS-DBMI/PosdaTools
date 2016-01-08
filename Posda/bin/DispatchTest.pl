#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/DispatchTest.pl,v $
#$Date: 2009/05/28 17:25:19 $
#$Revision: 1.5 $

use strict;
use Dispatch::Select;
use Dispatch::Queue;
use Dispatch::Acceptor;
use Dispatch::Command::Basic;
use IO::Socket::INET;
use FileHandle;
use Dispatch::Test;
use Dispatch::Dicom;
use Dispatch::Dicom::MessageAssembler;
use Dispatch::Dicom::Message;
use Dispatch::Dicom::Verification;
use Dispatch::Http;
use Dispatch::Template;
use DBI;

my $port = $ARGV[0];
my $dir = $ARGV[1];
my %Objects;

$Objects{CmdAcceptor} = 
  Dispatch::Command::Basic::Acceptor->new($port, $dir, \%Objects);
Dispatch::Select::Dispatch();
if($ENV{POSDA_DEBUG}){
  print "Returned from Dispatch\n";
}
