#!/usr/bin/perl -w

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
