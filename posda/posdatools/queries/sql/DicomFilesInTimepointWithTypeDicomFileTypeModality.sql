-- Name: DicomFilesInTimepointWithTypeDicomFileTypeModality
-- Schema: posda_files
-- Columns: ['file_id', 'file_type', 'dicom_file_type', 'modality']
-- Args: ['activity_timepoint_id']
-- Tags: ['activity_timepoints', 'export_event']
-- Description:   Get DICOM  files in timepoint with type, dicom_file_type, and modality
-- 

select
  file_id, file_type, dicom_file_type, modality
from
  file f natural join dicom_file natural join file_series
where file_id in (
  select file_id from activity_timepoint_file where activity_timepoint_id = ? 
  )