-- Name: DifferenceReportByEditId
-- Schema: posda_files
-- Columns: ['short_report_file_id', 'long_report_file_id', 'num_files']
-- Args: ['subprocess_invocation_id']
-- Tags: ['used_in_file_import_into_posda', 'used_in_file_migration']
-- Description: Get count of files relative to storage root

select
  distinct short_report_file_id, long_report_file_id, count(distinct to_file_path) as num_files
from dicom_edit_compare
where subprocess_invocation_id =?
group by short_report_file_id, long_report_file_id order by short_report_file_id