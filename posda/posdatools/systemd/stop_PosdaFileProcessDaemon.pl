#!/usr/bin/env perl

use Modern::Perl;

use DBI;
use Posda::Config 'Database';


my $dbh = DBI->connect(Database('posda_files'));



my $sth = $dbh->prepare(qq{
    update import_control
    set 
      pending_change_request = 'shutdown'
    returning processor_pid
});
say "Asking process to die (via import_control table in posda_files)";
$sth->execute();

my @val = $sth->fetchrow_array();
my $pid = $val[0];

say "Waiting for pid to die: $pid";

while (kill 0, $pid) {
    sleep 0.5;
}
