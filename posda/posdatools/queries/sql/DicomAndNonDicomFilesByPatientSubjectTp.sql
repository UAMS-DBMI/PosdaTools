-- Name: DicomAndNonDicomFilesByPatientSubjectTp
-- Schema: posda_files
-- Columns: ['file_id', 'file_type', 'dicom_file_type', 'patient_id', 'non_dicom_file_type', 'subject', 'non_dicom_file_subtype']
-- Args: ['activity_timepoint_id', 'patient_id', 'subject']
-- Tags: ['non_dicom_extensions']
-- Description: All DICOM and nonDICOM files by patient/subject in timepoint
-- 

select
  distinct file_id, f.file_type, 
  coalesce(dicom_file_type, 'N/A') as dicom_file_type,
  coalesce(patient_id, 'N/A') as patient_id,
  coalesce(nd.file_type, 'N/A') as non_dicom_file_type,
  coalesce(nd.file_sub_type, 'N/A') as non_dicom_file_subtype,
  coalesce(nd.subject, 'N/A') as subject
from
  file f left join non_dicom_file nd using(file_id)
  natural left join file_patient natural left join dicom_file d
  natural join activity_timepoint_file
where
  activity_timepoint_id = ? and
 ((patient_id is null and subject = ?) or (subject is null and patient_id = ?))