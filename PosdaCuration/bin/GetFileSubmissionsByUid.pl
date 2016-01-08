#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/PosdaCuration/bin/GetFileSubmissionsByUid.pl,v $ #$Date: 2015/12/15 14:12:00 $
#$Revision: 1.1 $
#
use strict;
use DBI;
my $dbh = DBI->connect("DBI:Pg:database=$ARGV[0]", "", "");
my $q = <<EOF;
select *
from
  file_import natural join import_event natural join file
where
  digest = ?
EOF
my $p = $dbh->prepare($q) or die "$!";
$p->execute($ARGV[1]);
my @list;
while(my $h = $p->fetchrow_hashref){
  push(@list, $h);
}
for my $i (@list) {
  print "$ARGV[1]|$i->{import_type}|$i->{import_event_id}|" .
    "$i->{import_time}|$i->{remote_file}\n";
}

