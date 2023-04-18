-- Name: GetNonDicomFileIdTypeAndPathByCollectionSite
-- Schema: posda_files
-- Columns: ['file_id', 'file_type', 'file_sub_type', 'path']
-- Args: ['collection', 'site']
-- Tags: ['NotInteractive', 'non_dicom_phi']
-- Description: Create a dciodvfy_scan_instance row

select
  file_id, non_dicom_file.file_type as file_type, file_sub_type,
  root_path || '/' || rel_path as path
from
  file_storage_root natural join file_location natural join non_dicom_file
where
  collection = ? and site = ?