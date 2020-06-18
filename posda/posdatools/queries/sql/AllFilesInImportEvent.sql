-- Name: AllFilesInImportEvent
-- Schema: posda_files
-- Columns: ['file_type', 'dicom_file_type', 'num_files']
-- Args: ['import_event_id']
-- Tags: ['import_event_reports']
-- Description: Report on all files (not just DICOM) in import_event
--

select 
  distinct file_type, '' as dicom_file_type, count(*) as num_files
from
  file natural join
  file_import
  -- natural left join dicom_file
where
 import_event_id = ?
group by
  file_type, dicom_file_type
order by 
  file_type