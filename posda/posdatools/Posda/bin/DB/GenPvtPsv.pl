#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use DBI;
my $db_name = $ARGV[0];
my $db = DBI->connect("dbi:Pg:dbname=$db_name", "", "");
my $q = $db->prepare("select * from ele where pvt order by owned_by, grp, ele");
$q->execute();
my($cur_owner, $cur_grp);
while (my $h = $q->fetchrow_hashref){
  my $ele = sprintf("%02x", $h->{ele});
  my $grp = sprintf("%04x", $h->{grp});
  my $sig = "($grp,\"$h->{owned_by}\",$ele)";
  print "$sig|$h->{name}|$h->{vr}|$h->{vm}\n";
}
