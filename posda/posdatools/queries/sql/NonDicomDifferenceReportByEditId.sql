-- Name: NonDicomDifferenceReportByEditId
-- Schema: posda_files
-- Columns: ['report_file_id', 'num_files']
-- Args: ['subprocess_invocation_id']
-- Tags: ['used_in_file_import_into_posda', 'used_in_file_migration', 'non_dicom_edit']
-- Description: Get count of files relative to storage root

select
  distinct report_file_id, count(distinct to_file_path) as num_files
from non_dicom_edit_compare
where subprocess_invocation_id =?
group by report_file_id
order by report_file_id