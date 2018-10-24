-- Name: GetNonDicomFileTypeSubTypeCollectionSiteSubjectById
-- Schema: posda_files
-- Columns: ['file_type', 'file_sub_type', 'collection', 'site', 'subject']
-- Args: ['file_id']
-- Tags: ['adding_ctp', 'for_scripting', 'non_dicom_import']
-- Description: Get stuff from non_dicom_file by id
-- 

select 
  file_type,
  file_sub_type,
  collection,
  site,
  subject
from 
  non_dicom_file
where file_id = ?