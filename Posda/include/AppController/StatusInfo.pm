#!/usr/bin/perl -w
#
package AppController::StatusInfo;
# 
# A module for getting various stats about the running app
#

use strict;
use Method::Signatures;
use DBI;

# TODO: These need to be moved into a config file!
my $db_name = 'app_stats';
my $db_host = 'tcia-utilities';
my $db_user = 'postgres';
my $db_pass = '';


my $last_ran = 0;
my $cache_result;

func _get_db_connection() {
  DBI->connect("DBI:Pg:database=$db_name;host=$db_host", 
               "$db_user",
               "$db_pass");
}

func _execute_query($query) {
  my $conn = _get_db_connection();

  my $statement = $conn->prepare($query) or die "$!";
  $statement->execute() or die $!;

  # fetch as an array of hashes
  my $ret = $statement->fetchall_arrayref({});
  # my $ret = $statement->fetchrow_hashref();

  $statement->finish;
  $conn->disconnect;

  return $ret;
}

func get_info() {
  # _execute_query(qq{
  #   select 
  #     files_in_db_backlog,
  #     dirs_in_receive_backlog,
  #     at
  #   from app_measurement
  #   where extract(epoch from now() - at) < 30;
  # });
  _execute_query(qq{
    select
      minute,
      max(files_in_db_backlog) as max_db_backlog,
      max(dirs_in_receive_backlog) as max_dirs_in_backlog,
      count(*)
    from (
      select 
        files_in_db_backlog,
        dirs_in_receive_backlog,
        at,
        date_trunc('minute', at) as minute
      from app_measurement
      where at > now() - interval '1' day
    ) a
    group by minute
    order by minute
  });
}

func _get_24hour_stats() {
  my @db_backlog;
  my @rec_backlog;

  for my $row (@{get_info()}) {
    push @db_backlog, $row->{max_db_backlog};
    push @rec_backlog, $row->{max_dirs_in_backlog};
  }

  return [ \@db_backlog, \@rec_backlog ];
}

func get_24hour_stats() {
  if ((time() - $last_ran) >= 15) {
    $last_ran = time();
    $cache_result = _get_24hour_stats();
    print "Cache stale, reloading\n"; # DEBUG
  }

  return $cache_result;
}

1;
