-- Name: UpdateNonDicomFileById
-- Schema: posda_files
-- Columns: []
-- Args: ['file_type', 'file_sub_type', 'collection', 'site', 'subject', 'visibility', 'file_id']
-- Tags: ['radcomp']
-- Description: Add a filter to a tab

update non_dicom_file set
  file_type = ?, 
  file_sub_type = ?, 
  collection = ?,
  site = ?,
  subject = ?,
  visibility = ?,
  date_last_categorized = now()
where 
  file_id = ?