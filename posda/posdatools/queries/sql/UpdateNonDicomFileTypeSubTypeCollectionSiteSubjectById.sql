-- Name: UpdateNonDicomFileTypeSubTypeCollectionSiteSubjectById
-- Schema: posda_files
-- Columns: []
-- Args: ['file_type', 'file_sub_type', 'collection', 'site', 'subject', 'file_id']
-- Tags: ['adding_ctp', 'for_scripting', 'non_dicom_import']
-- Description: Get stuff from non_dicom_file by id
-- 

update non_dicom_file set
  file_type = ?,
  file_sub_type = ?,
  collection = ?,
  site = ?,
  subject = ?
where file_id = ?