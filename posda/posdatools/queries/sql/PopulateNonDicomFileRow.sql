-- Name: PopulateNonDicomFileRow
-- Schema: posda_files
-- Columns: []
-- Args: ['file_id', 'file_type', 'file_sub_type', 'collection', 'site', 'subject', 'date_last_categorized']
-- Tags: []
-- Description: Create a row in non_dicom_files
-- 

insert into non_dicom_file (
  file_id, file_type, file_sub_type,collection,site,subject,date_last_categorized
) values (
  ?, ?, ?, ?, ?, ?, ?
)