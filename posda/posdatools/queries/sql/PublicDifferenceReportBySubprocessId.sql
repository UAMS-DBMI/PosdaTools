-- Name: PublicDifferenceReportBySubprocessId
-- Schema: posda_files
-- Columns: ['short_report_file_id', 'long_report_file_id', 'num_sops', 'num_files']
-- Args: ['subprocess_invocation_id']
-- Tags: ['used_in_file_import_into_posda', 'used_in_file_migration']
-- Description: Get count of files relative to storage root

select
  distinct short_report_file_id, long_report_file_id,
  count(distinct sop_instance_uid) as num_sops,
  count(distinct from_file_id) as num_files
from posda_public_compare
where background_subprocess_id =?
group by short_report_file_id, long_report_file_id order by short_report_file_id