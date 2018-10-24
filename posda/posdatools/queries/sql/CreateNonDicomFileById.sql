-- Name: CreateNonDicomFileById
-- Schema: posda_files
-- Columns: []
-- Args: ['file_id', 'file_type', 'file_sub_type', 'collection', 'site', 'subject']
-- Tags: ['radcomp']
-- Description: Add a filter to a tab

insert into non_dicom_file(
  file_id, file_type, file_sub_type, collection, site, subject, date_last_categorized
)values(
  ?, ?, ?, ?, ?, ?, now()
)
