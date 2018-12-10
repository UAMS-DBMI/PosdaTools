-- Name: PosdaPublicDifferenceReportByEditId
-- Schema: posda_files
-- Columns: ['short_report_file_id', 'long_report_file_id', 'num_files']
-- Args: ['compare_public_to_posda_instance_id']
-- Tags: ['used_in_file_import_into_posda', 'used_in_file_migration']
-- Description: Get count of files relative to storage root

select
  distinct short_report_file_id, long_report_file_id, count(distinct sop_instance_uid) as num_files
from public_to_posda_file_comparison
where compare_public_to_posda_instance_id =?
group by short_report_file_id, long_report_file_id order by short_report_file_id