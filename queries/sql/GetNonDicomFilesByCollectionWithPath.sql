-- Name: GetNonDicomFilesByCollectionWithPath
-- Schema: posda_files
-- Columns: ['file_id', 'file_type', 'file_sub_type', 'collection', 'site', 'subject', 'visibility', 'date_last_categorized', 'rel_path']
-- Args: ['collection']
-- Tags: ['radcomp']
-- Description: Add a filter to a tab

select 
  file_id, file_type, file_sub_type, collection, site, subject, visibility, date_last_categorized, rel_path
from
  non_dicom_file natural join file_import
where
  collection = ? and
  visibility is null
