#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use DBI;
unless($#ARGV == 2) { die "usage: $0 <db> <host> <user>" }
my $db = DBI->connect("dbi:Pg:dbname=$ARGV[0];host=$ARGV[1];user=$ARGV[2]",
  "", "");
my $id = $ARGV[3];
my $get_dvh_data = $db->prepare("
select distinct ss_file_id from rt_dvh_protocol_case_roi
");
$get_dvh_data->execute();
row:
while(my $data = $get_dvh_data->fetchrow_hashref){
  my $get_import_event = $db->prepare("
select
  distinct import_event_id
from
  file_import
  where file_id = ?
  ");
  my @import_events;
  $get_import_event->execute($data->{ss_file_id});
  while(my $r = $get_import_event->fetchrow_hashref){
    push(@import_events, $r->{import_event_id});
  }
  if($#import_events > 0){
    print STDERR "More than one import event for file_id $data->{ss_file_id}\n";
  } elsif($#import_events < 0){
    print STDERR "No import event for file_id $data->{ss_file_id}\n";
    next row;
  }
  my $id = $import_events[0];
  my $update = $db->prepare("
  update rt_dvh_protocol_case_roi
  set import_event_id = ?
  where ss_file_id = ?
  ");
print "setting import_event_id = $id for file_id $data->{ss_file_id}\n";
  $update->execute($id, $data->{ss_file_id});
}
