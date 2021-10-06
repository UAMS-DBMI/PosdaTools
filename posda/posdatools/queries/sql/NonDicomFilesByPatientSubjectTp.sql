-- Name: NonDicomFilesByPatientSubjectTp
-- Schema: posda_files
-- Columns: ['file_id', 'file_type', 'non_dicom_file_type', 'subject']
-- Args: ['activity_timepoint_id', 'subject']
-- Tags: ['non_dicom_extensions']
-- Description: All nonDICOM files bysubject in timepoint
-- 

select
  distinct file_id, f.file_type, 
  coalesce(nd.file_type, 'N/A') as non_dicom_file_type,
  coalesce(nd.subject, 'N/A') as subject
from
  file f natural left join non_dicom_file nd
  natural join activity_timepoint_file
where
  activity_timepoint_id = ? and
  subject = ?