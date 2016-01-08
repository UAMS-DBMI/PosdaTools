#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/DB/PopulateInstitution.pl,v $
#$Date: 2013/09/06 19:30:18 $
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
my $q = $db->prepare("select import_event_id, remote_file, import_time\n" .
                     "from import_event natural left join submission\n" .
                     "where institution is null");
$q->execute();
while(my $h = $q->fetchrow_hashref()){
  my $id = $h->{import_event_id};
  my $file = $h->{remote_file};
  my @path = split(/\//, $file);
  my $institution = $path[6];
  my $date = $h->{import_time};
  unless($date =~ /^(....)-(..)-(..)/){
    die "non-matching date: $date";
  }
  my $yr = $1;
  my $mo = $2;
  my $mon = ["Foo", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]->[$mo];
  my $day = $3;
  print "$mon $yr, $id, $institution\n";

  my $q1 = $db->prepare(
    "insert into submission(\n" .
    "  import_event_id, institution, year, month_i, month\n" .
    ") values (\n" .
    "  ?, ?, ?, ?, ?)"
  );
  $q1->execute($id, $institution, $yr, $mo, $mon);
}
