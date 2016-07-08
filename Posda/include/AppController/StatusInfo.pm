package AppController::StatusInfo;
# 
# A module for getting various stats about the running app
#

use Method::Signatures::Simple;
use DBI;
use DBD::Pg ':async';


func _get_db_connection($database_name) {
  DBI->connect("DBI:Pg:database=$database_name");
}

func _execute_query_async($conn, $query, $callback) {
  my $statement = $conn->prepare($query, {pg_async => PG_ASYNC}) or die "$!";
  $statement->execute() or die $!;

  # now we have to Dispatch to the background
  my $back = Dispatch::Select::Background->new(func($disp) {
    if ($statement->pg_ready()) {
      # results are ready

      # fetch as an array of hashes
      $statement->pg_result();  # fetch the results into the statement?
      my $ret = $statement->fetchall_arrayref({});

      $statement->finish;
      $conn->disconnect;

      &$callback($ret);

      $disp->clear();

    } else {
      $disp->timer(0.5);  # check again in 1/2 second
    }
  });

  $back->queue();
}

func get_recent_uploads_async($database_name, $callback) {

  my $query = qq{
    select
        project_name,
        site_name,
        dicom_file_type,
        count(*),
        (extract(epoch from now() - max(import_time)) / 60)::int as minutes_ago,
        to_char(max(import_time), 'HH24:MI') as time

    from (
        select 
          project_name,
          site_name,
          dicom_file_type,
          sop_instance_uid,
          import_time

        from 
          file_import
          natural join import_event
          natural join ctp_file
          natural join dicom_file
          natural join file_sop_common
          natural join file_patient

        where import_time > now() - interval '1' day
          and visibility is null
    ) as foo
    group by
        project_name,
        site_name,
        dicom_file_type
    order by minutes_ago asc;
  };

  _execute_query_async(_get_db_connection($database_name), $query, $callback);
}

func get_db_backlog_async($database_name, $callback) {
  my $query = qq{
    select
      minute,
      max(files_in_db_backlog) as max_db_backlog,
      count(*)
    from (
      select 
        files_in_db_backlog,
        at,
        date_trunc('minute', at) as minute
      from app_measurement
      where at > now() - interval '1' day
    ) a
    group by minute
    order by minute
  };

  _execute_query_async(_get_db_connection($database_name), $query, $callback);
}

func get_rec_backlog_async($database_name, $callback) {
  my $query = qq{
    select
      minute,
      max(dirs_in_receive_backlog) as max_dirs_in_backlog,
      count(*)
    from (
      select 
        dirs_in_receive_backlog,
        at,
        date_trunc('minute', at) as minute
      from app_measurement
      where at > now() - interval '1' day
    ) a
    group by minute
    order by minute
  };

  _execute_query_async(_get_db_connection($database_name), $query, $callback);
}

1;
