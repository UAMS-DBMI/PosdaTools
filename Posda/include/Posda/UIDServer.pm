#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/UIDServer.pm,v $
#$Date: 2011/09/08 23:35:46 $
#$Revision: 1.5 $
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::UID;
use Posda::UUIDServer;
package UID::Server;
my $UID_root;
my $UID_Seq;
my $user = `whoami`;
chomp $user;
my $host = `hostname`;
chomp $host;
if($ENV{POSDA_UIDS}){
  $UID_root = Posda::UID::GetUID({
    package => "UID::Server",
    user => $user,
    host => $host,
    purpose => "Initialize In-line Posda UIDServer",
  });
  print "UID Root: $UID_root\n";
}
$UID_Seq = 1;
sub new_root {
  if($ENV{POSDA_UIDS}){
    $UID_Seq += 1;
    return "$UID_root.$UID_Seq";
  } else {
    return UUIDServer::new_root();
  }
}
1;
