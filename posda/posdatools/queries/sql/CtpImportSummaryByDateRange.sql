-- Name: CtpImportSummaryByDateRange
-- Schema: posda_files
-- Columns: ['when_loaded', 'collection', 'site', 'patient_id', 'modality', 'dicom_file_type', 'file_type', 'num_files']
-- Args: ['interval', 'from', 'to']
-- Tags: ['CTP transfers']
-- Description: Get list of CTP transfers in (i.e. import_event_id = 0
-- by date_range
-- 

select
  date_trunc(?, file_import_time) as when_loaded,
  coalesce(project_name, 'UNKNOWN') as collection,
  coalesce(site_name, 'UNKNOWN') as site,
  coalesce(patient_id, 'N/A') as patient_id,
  coalesce(modality, 'N/A') as modality,
  coalesce(dicom_file_type, 'N/A') as dicom_file_type,
  coalesce(file_type, 'awaiting import') as file_type,
  count(distinct file_id) as num_files
from
  file natural join file_import
  natural left join ctp_file
  natural left join file_patient
  natural left join file_series
  natural left join dicom_file
  where
    file_import_time >= ? and file_import_time < ?
    and import_event_id = 0
group by when_loaded, collection, site, patient_id, modality, dicom_file_type, file_type
order by when_loaded