#!/usr/bin/perl -w

use strict;
use Method::Signatures;
use DBI;
use JSON;

# TODO: These need to be supplied on the commandline? 
my $db_name = 'posda_files';
my $db_host = 'tcia-utilities';
my $db_user = 'postgres';
my $db_pass = '';

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


func _get_recent_uploads() {
  _execute_query(qq{
    select
        project_name,
        site_name,
        patient_id,
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
          patient_id,
          import_time

        from 
          file_import
          natural join import_event
          natural join ctp_file
          natural join dicom_file
          natural join file_sop_common
          natural join file_patient

        where import_time > now() - interval '2' day
          and visibility is null
    ) as foo
    group by
        project_name,
        site_name,
        patient_id,
        dicom_file_type
    order by minutes_ago asc;
  });
}

my $results = _get_recent_uploads();
print encode_json($results), "\n";
