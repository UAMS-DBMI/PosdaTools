-- Name: FileTypeModalityCountsByImportId
-- Schema: posda_files
-- Columns: ['dicom_file_type', 'modality', 'num_files']
-- Args: ['import_event_id']
-- Tags: ['ACRIN-NSCLC-FDG-PET Curation']
-- Description: Get the list of files by sop, excluding base series

select
  distinct  dicom_file_type, modality, count(*) as num_files
from file_series natural join dicom_file
where file_id in (
  select distinct file_id
  from file_import natural join import_event
  where import_event_id = ?
) group by dicom_file_type, modality