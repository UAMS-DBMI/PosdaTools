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
my $q = $db->prepare(
  "insert into import_plan_ss_references(\n" .
  "  import_event_id, file_id, ss_referenced_from_plan,\n" .
  "  num_files_in_import_with_ref\n" .
  ") values(\n" .
  "  ?, ?, ?,\n" .
  "  ?\n" .
  ")"
);
while (my $line = <STDIN>){
  chomp $line;
  my($import_id, $file_id, $ss_ref, $count) = split(/\s+/, $line);
  $q->execute($import_id, $file_id, $ss_ref, $count);
}
