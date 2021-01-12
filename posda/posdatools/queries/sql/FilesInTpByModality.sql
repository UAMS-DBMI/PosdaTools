-- Name: FilesInTpByModality
-- Schema: posda_files
-- Columns: ['file_id', 'file_type', 'dicom_file_type', 'patient_id']
-- Args: ['activity_timepoint_id', 'modality']
-- Tags: ['non_dicom_extensions']
-- Description: All DICOM and nonDICOM files by patient/subject in timepoint
-- 

select
  distinct file_id, file_type, 
  coalesce(dicom_file_type, 'N/A') as dicom_file_type,
  coalesce(patient_id, 'N/A') as patient_id,
  modality
 from
  file natural left join file_patient natural left join dicom_file
  natural join activity_timepoint_file
  natural join file_series
where
  activity_timepoint_id = ? and modality = ?