-- Name: FindingStructureSetsForTest
-- Schema: posda_files
-- Columns: ['collection', 'patient_id', 'file_id', 'dicom_file_type', 'series_description']
-- Args: []
-- Tags: ['Test Case based on Soft-tissue-Sarcoma']
-- Description: Find All of the Structure Sets In Soft-tissue-Sarcoma

select
  distinct project_name as collection, patient_id, series_description, sop_instance_uid, file_id,
  dicom_file_type
from
  ctp_file natural join dicom_file natural join file_study natural join file_series
  natural join file_patient natural join file_sop_common
where 
  dicom_file_type = 'RT Structure Set Storage' and visibility is null and project_name = 'Soft-tissue-Sarcoma'