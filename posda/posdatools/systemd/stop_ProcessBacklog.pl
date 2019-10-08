#!/usr/bin/env perl

use Modern::Perl;

use DBI;
use Posda::Config 'Database';


my $dbh = DBI->connect(Database('posda_backlog'));



my $sth = $dbh->prepare(qq{
    update control_status
    set 
      pending_change_request = 'shutdown',
      source_pending_change_request = 'script',
      request_time = null
    returning processor_pid
});
say "Asking process to die (via control_status table in posda_backlog)";
$sth->execute();

my @val = $sth->fetchrow_array();
my $pid = $val[0];

say "Waiting for pid to die: $pid";

while (kill 0, $pid) {
    sleep 0.5;
}
