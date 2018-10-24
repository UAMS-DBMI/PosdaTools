-- Name: GetNonDicomFilesByPatientId
-- Schema: posda_files
-- Columns: ['file_id', 'file_type', 'file_sub_type', 'collection', 'site', 'subject', 'visibility', 'date_last_categorized', 'size', 'digest', 'path']
-- Args: ['patient_id']
-- Tags: ['radcomp']
-- Description: Add a filter to a tab

select 
  file_id, non_dicom_file.file_type, file_sub_type, 
  collection, site, subject, visibility, date_last_categorized,
  size, digest, root_path || '/' || rel_path as path
from
  non_dicom_file join file using (file_id) natural join file_location natural join file_storage_root
where
  visibility is null
  and subject = ?
