#!/usr/bin/env perl

use Modern::Perl;

use DBI;
use Posda::Config 'Database';


my $dbh = DBI->connect(Database('posda_backlog'));



my $sth = $dbh->prepare(qq{
    update control_status
    set status = 'waiting to go inservice',
      processor_pid =  null,
      pending_change_request = null,
      source_pending_change_request = null,
      request_time = null
});
$sth->execute();

exec("ProcessBacklog.pl");
