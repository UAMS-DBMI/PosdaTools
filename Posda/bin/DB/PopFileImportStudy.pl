#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/DB/PopFileImportStudy.pl,v $
#$Date: 2013/09/06 19:27:23 $
#$Revision: 1.1 $
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use DBI;
my $db = DBI->connect("dbi:Pg:dbname=$ARGV[0]", "", "");
my $q = $db->prepare("select * from file_import natural join file_study");
my $q1 = $db->prepare(
  "insert into file_import_study(\n" .
  "  import_event_id, file_id, study_instance_uid\n" .
  ") values (\n" .
  "  ?, ?, ?)"
);
$q->execute();
while(my $h = $q->fetchrow_hashref()){
  my $import_event_id = $h->{import_event_id};
  my $file_id = $h->{file_id};
  my $study_instance_uid = $h->{study_instance_uid};
  $q1->execute($import_event_id, $file_id, $study_instance_uid);
}
$db->disconnect();
