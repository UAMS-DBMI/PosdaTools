#!/usr/bin/perl -w
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
use Posda::HttpApp::HttpObj;
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
sub Login {
  my($this, $http, $app) = @_;
  my $session = $this->NewSession();
  my $sess = $this->GetSession($session);
  $sess->{user} = "Anonymous";
  if(defined $http->{header}->{http_referer}){
    $sess->{referred_from} = $http->{header}->{http_referer};
  }
  my $url = "http://$http->{header}->{host}/$session/Refresh?obj_path=_top";
  $http->queue("HTTP/1.0 201 Created\n");
  $http->queue("Location: $url\n");
  $http->queue("Content-Type: text/html\n\n");
  $http->queue("<html><header>");
  $http->queue("<META HTTP-EQUIV=REFRESH CONTENT=\"2; ");
  $http->queue("URL=$url\">");
  $http->queue("</head><body>logged in OK, redirecting....");
  $http->queue("<a href=\"/$url\">$url</a>");
  $http->queue("</body></html>");
  &{$app->{app_init}}($this, $sess);
}
sub Init{
  my($this, $sess) = @_;
  my $http_obj = Posda::HttpObj->new("_top");
  $sess->{root}->{"_top"} = $http_obj;
my $dbg = sub {
  print @_;
};
  $http_obj->set_expander("Hello world");
print "Session: ";
Debug::GenPrint($dbg, $sess, 1);
print "\n";
}
my $app_struct = Dispatch::Http::App->new_obj(
  \&Login, \&Init);
my $App = 
  Dispatch::Http::App::Server->new_static(\%Static, $app_struct);
$App->Serve($port, $int, $ttl);
Dispatch::Select::Dispatch(); if($ENV{POSDA_DEBUG}){ print "Returned from Dispatch\n"}
