-- Name: FileTypeModalityCountsByImportIdWithPatId
-- Schema: posda_files
-- Columns: ['patient_id', 'dicom_file_type', 'modality', 'num_files']
-- Args: ['import_event_id', 'modality']
-- Tags: ['ACRIN-NSCLC-FDG-PET Curation']
-- Description: Get the list of files by sop, excluding base series

select
  distinct  patient_id, dicom_file_type, modality, count(*) as num_files
from file_series natural join dicom_file natural join file_patient
where file_id in (
  select distinct file_id
  from file_import natural join import_event
  where import_event_id = ?
) and modality = ?
group by patient_id, dicom_file_type, modality