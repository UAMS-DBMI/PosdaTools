#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use DBI;
my $db = DBI->connect("dbi:Pg:dbname=$ARGV[0]", "", "");
my $q = $db->prepare("select * from file_import natural join file_series");
my $q1 = $db->prepare(
  "insert into file_import_series(\n" .
  "  import_event_id, file_id, series_instance_uid, modality\n" .
  ") values (\n" .
  "  ?, ?, ?, ?)"
);
$q->execute();
while(my $h = $q->fetchrow_hashref()){
  my $import_event_id = $h->{import_event_id};
  my $file_id = $h->{file_id};
  my $series_instance_uid = $h->{series_instance_uid};
  my $modality = $h->{modality};
  $q1->execute($import_event_id, $file_id, $series_instance_uid, $modality);
}
$db->disconnect();
