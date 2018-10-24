-- Name: GetDocxToConvert
-- Schema: posda_files
-- Columns: ['file_id', 'file_type', 'file_sub_type', 'collection', 'site', 'subject', 'visibility', 'date_last_categorized']
-- Args: ['collection']
-- Tags: ['radcomp']
-- Description: Add a filter to a tab

select 
  file_id, file_type, file_sub_type, collection, site, subject, visibility, date_last_categorized
from
  non_dicom_file
where
 collection = ? and file_type = 'docx' and visibility is null