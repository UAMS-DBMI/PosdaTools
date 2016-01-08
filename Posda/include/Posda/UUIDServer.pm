#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/UUIDServer.pm,v $
#$Date: 2011/09/08 23:01:54 $
#$Revision: 1.4 $
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::UUID;
use Posda::UIDServer;
package UUIDServer;
my $UID_root;
my $UID_Seq = 1;
if($ENV{POSDA_UUIDS}){
  $UID_root = Posda::UUID::GetUUID();
} elsif($ENV{POSDA_UIDS}){
  $UID_root = Posda::UID::GetUID({
    module => "UUIDServer",
    application => $0,
    purpose => "Initialization",
  });
} else {
  $UID_root = Posda::UUID::GetUUID();
  print "Defaulting to use UUID root: $UID_root\n" .
    "This may cause problems with certain brain dead DICOM implementations\n";
#  die "Need to set either POSDA_UUIDS or POSDA_UIDS environment variable";
}
sub new_root {
  my $uid = "$UID_root.$UID_Seq";
  $UID_Seq += 1;
  return $uid;
}
sub new_either_root {
  if($ENV{POSDA_UUIDS}){
    my $uid = "$UID_root.$UID_Seq";
    $UID_Seq += 1;
    return $uid;
  } else {
    return UIDServer::new_root();
  }
}
1;
