#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/HttpApp.pl,v $
#$Date: 2010/04/21 17:55:12 $
#$Revision: 1.18 $
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Dispatch::Select;
use Dispatch::Queue;
use Dispatch::Acceptor;
use IO::Socket::INET;
use FileHandle;
use Dispatch::Http;
use Dispatch::Template;
use Posda::Try;
use Posda::ElementNames;
use Posda::Find;
use Posda::DicomAnalysis;
use Posda::Anonymizer;
use Posda::UID;
use Posda::UIDServer;
use Cwd;
use Debug;
$SIG{'PIPE'} = 'IGNORE';

my $port = $ARGV[0];
my $dir = $ARGV[1];
my $int = $ARGV[2];
my $ttl = $ARGV[3]; #Time to Live
unless(defined $int) {$int = 10}
unless(defined $ttl) {$ttl = 100}
use vars qw( $Commands $Templates $Logins %Static );
use Posda::HttpApp::Common;
use Posda::HttpApp::DebugDump;
use Posda::HttpApp::ThreeFrames;
use Posda::HttpApp::MenuBox;
use Posda::HttpApp::DirBox;
use Posda::HttpApp::InfoBox;
use Posda::HttpApp::TestApp;
use Posda::HttpApp::Anonymizer;
use Posda::HttpApp::DicomFile;

my $app_struct = Dispatch::Http::App->new_from_hashes(
  $Commands, $Templates, $Logins, \%Static);
my $App = 
  Dispatch::Http::App::Server->new_static(\%Static, $app_struct);
$App->Serve($port, $int, $ttl);
Dispatch::Select::Dispatch(); if($ENV{POSDA_DEBUG}){ print "Returned from Dispatch\n"}
