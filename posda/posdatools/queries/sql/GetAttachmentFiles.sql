-- Name: GetAttachmentFiles
-- Schema: posda_files
-- Columns: ['file_id', 'path', 'ext']
-- Args: ['collection']
-- Tags: ['radcomp']
-- Description: Add a filter to a tab

select 
  fl.file_id,
  root_path || '/' || rel_path as path,
  ndf.file_type as ext
from
  non_dicom_file ndf,
  file_location as fl natural join file_storage_root,
  non_dicom_attachments a
where
  a.non_dicom_file_id = ndf.file_id and 
  a.non_dicom_file_id = fl.file_id and
  ndf.collection = ?