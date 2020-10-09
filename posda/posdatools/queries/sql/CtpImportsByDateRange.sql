-- Name: CtpImportsByDateRange
-- Schema: posda_files
-- Columns: ['file_id', 'file_import_time', 'collection', 'site', 'patient_id', 'modality', 'dicom_file_type', 'file_type']
-- Args: ['from', 'to']
-- Tags: ['CTP transfers']
-- Description: Get list of CTP transfers in (i.e. import_event_id = 0
-- by date_range
-- 

select
  distinct file_id, file_import_time,
  coalesce(project_name, 'UNKNOWN') as collection,
  coalesce(site_name, 'UNKNOWN') as site,
  coalesce(patient_id, 'N/A') as patient_id,
  coalesce(modality, 'N/A') as modality,
  coalesce(dicom_file_type, 'N/A') as dicom_file_type,
  coalesce(file_type, 'awaiting import') as file_type
from
  file natural join file_import
  natural left join ctp_file
  natural left join file_patient
  natural left join file_series
  natural left join dicom_file
  where
    file_import_time >= ? and file_import_time < ?
    and import_event_id = 0
order by file_import_time