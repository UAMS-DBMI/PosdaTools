-- Name: UnHideFilesCSP
-- Schema: posda_files
-- Columns: None
-- Args: ['collection', 'site', 'subject']
-- Tags: []
-- Description: UnHide all files hidden by Collection, Site, Subject
-- 

update ctp_file set visibility = null where file_id in (
  select
    distinct file_id
  from
    ctp_file natural join file_patient
  where
    project_name = ? and site_name = ?
    and visibility = 'hidden' and patient_id = ?
);
