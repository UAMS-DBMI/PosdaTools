package Posda::QueryLog;

use Modern::Perl;
use Method::Signatures::Simple;

use Posda::Config 'Database';
use DBI;
use Data::Dumper;

our $connection;

func connect_to_db() {
  if (not defined $connection) {
    $connection = DBI->connect(Database('posda_queries'));
  }
}

func query_invoked($query, $user, $start_time, $end_time, $rowcount) {
  connect_to_db();
  say STDERR "query_invoked: $query->{name}, $start_time, $end_time, $rowcount";
  # figure out the arg->binding mapping
  my $res = $connection->selectrow_arrayref(qq{
    insert into query_invoked_by_dbif
    (query_name, invoking_user, query_start_time, query_end_time, number_of_rows)
    values (?, ?, to_timestamp(?), to_timestamp(?), ?)
    returning query_invoked_by_dbif_id
  }, {}, $query->{name}, $user, $start_time, $end_time, $rowcount);

  my $invoked_id = $res->[0];

  for my $i (0..$#{$query->{args}}) {
    insert_query_args($invoked_id, $i, $query->{args}->[$i], $query->{bindings}->[$i]);
  }
}

func insert_query_args($invoked_by_id, $index, $name, $value) {
  say STDERR "Inserting: $invoked_by_id, $index, $name, $value";
  $connection->do("insert into dbif_query_args values (?, ?, ?, ?)", {},
    $invoked_by_id, $index, $name, $value);
}

1;
