#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use DBI;
unless($#ARGV == 1) { die "usage: $0 <posda_files_db> <posda_counts_db>" }
my $dbf = DBI->connect("dbi:Pg:dbname=$ARGV[0]",
  "", "");
my $dbc = DBI->connect("dbi:Pg:dbname=$ARGV[1]",
  "", "");
my $get_counts_q = <<EOF;
select 
    distinct project_name, site_name, count(*) as num_subjects,
    sum(num_studies) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
from (
  select
    distinct project_name, site_name, patient_id, count(*) as num_studies,
    sum(num_series) as num_series, sum(total_files) as total_files
  from (
    select
       distinct project_name, site_name, patient_id, study_instance_uid, 
       count(*) as num_series, sum(num_files) as total_files
    from (
      select
        distinct project_name, site_name, patient_id, study_instance_uid, 
        series_instance_uid, count(*) as num_files 
      from (
        select
          distinct project_name, site_name, patient_id, study_instance_uid,
          series_instance_uid, sop_instance_uid 
        from
           ctp_file natural join file_study natural join
           file_series natural join file_sop_common natural join file_patient
      ) as foo
      group by
        project_name, site_name, patient_id, 
        study_instance_uid, series_instance_uid
    ) as foo
    group by project_name, site_name, patient_id, study_instance_uid
  ) as foo
  group by project_name, site_name, patient_id
) as foo
group by project_name, site_name
order by project_name, site_name
EOF
my $insert_totals_q = <<EOF;
insert into totals_by_collection_site(
  count_report_id,
  collection_name, site_name,
  num_subjects, num_studies, num_series, num_sops
) values (
  currval('count_report_count_report_id_seq'),
  ?, ?,
  ?, ?, ?, ?
)
EOF
my $get_counts = $dbf->prepare($get_counts_q);
my $insert_rpt = $dbc->prepare("insert into count_report(at) values (now())");
my $insert_totals = $dbc->prepare($insert_totals_q);
$insert_rpt->execute;
$get_counts->execute;
while(my $h = $get_counts->fetchrow_hashref){
  $insert_totals->execute($h->{project_name}, $h->{site_name},
    $h->{num_subjects}, $h->{num_studies}, $h->{num_series}, $h->{total_files});
}
