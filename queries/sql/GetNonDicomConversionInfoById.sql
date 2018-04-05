-- Name: GetNonDicomConversionInfoById
-- Schema: posda_files
-- Columns: ['path', 'file_type', 'file_sub_type', 'collection', 'site', 'subject', 'visibility', 'size', 'date_last_categorized']
-- Args: ['file_id']
-- Tags: ['radcomp']
-- Description: Add a filter to a tab

select
  root_path || '/' || rel_path as path,
  non_dicom_file.file_type,
  file_sub_type,
  collection, site, subject, visibility, size,
  date_last_categorized
from
  file_storage_root natural join file_location natural join non_dicom_file join file using(file_id)
where file_id = ?