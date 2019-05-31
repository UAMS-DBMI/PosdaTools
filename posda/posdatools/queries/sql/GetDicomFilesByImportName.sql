-- Name: GetDicomFilesByImportName
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['import_name']
-- Tags: ['posda_files', 'sops', 'BySopInstance', 'by_file']
-- Description: Get Collection, Site, Patient, Study Hierarchy in which SOP resides
-- 

select
  distinct file_id                                                                                                                                                                                                                                                                                                                                                                                                                                from
  import_event natural join file_import natural join dicom_file
where
  import_type = 'posda-api import' and import_comment = ?