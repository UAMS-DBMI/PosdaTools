-- Name: CreateNonDicomFileChangeRow
-- Schema: posda_files
-- Columns: []
-- Args: ['file_id', 'file_type', 'file_sub_type', 'collection', 'site', 'subject', 'visibility', 'date_last_categorized', 'who', 'why']
-- Tags: ['radcomp']
-- Description: Add a filter to a tab

insert into non_dicom_file_change(
  file_id, file_type, file_sub_type, collection, site, subject, visibility, when_categorized,
  when_recategorized, who_recategorized, why_recategorized)
values(
  ?, ?, ?, ?, ?, ?, ?, ?,
  now(), ?, ?
)
