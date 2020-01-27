#!/usr/bin/env perl

use Modern::Perl;

use DBI;
use Posda::Config 'Database';


my $dbh = DBI->connect(Database('posda_files'));



my $sth = $dbh->prepare(qq{
    update import_control
    set status = 'waiting to go inservice',
      processor_pid =  null,
      pending_change_request = null
});
$sth->execute();

exec("PosdaFileProcessDaemon.pl");
