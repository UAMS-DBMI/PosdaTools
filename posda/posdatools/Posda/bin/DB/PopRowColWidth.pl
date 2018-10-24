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
  "select distinct pixel_spacing\n" .
  "from image");
my $q1 = $db->prepare(
  "update image set\n" .
  "  row_spacing = ?,\n" .
  "  col_spacing = ?\n" .
  "where pixel_spacing = ?"
);
$q->execute();
row:
while(my $h = $q->fetchrow_hashref()){
  my $pixel_spacing = $h->{pixel_spacing};
  unless(defined $pixel_spacing) { next row }
  my($row_spacing, $col_spacing) = split(/\\/, $pixel_spacing);
  unless(defined $row_spacing) { next row }
  unless(defined $col_spacing) { next row }
  $q1->execute($row_spacing, $col_spacing, $pixel_spacing);
}
$db->disconnect();
