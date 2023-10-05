-- Name: DuplicateDownloadsBySubject
-- Schema: posda_files
-- Columns: ['count']
-- Args: ['subject_id', 'project_name', 'site_name']
-- Tags: ['by_subject', 'duplicates', 'find_series']
-- Description: Number of files for a subject which have been downloaded more than once
-- 

select count(*) from (
  select
    distinct file_id, count(*)
  from file_import
  where file_id in (
    select
      distinct file_id
    from 
      file_patient natural join ctp_file
    where
      patient_id = ? and project_name = ? 
      and site_name = ?
  )
  group by file_id
) as foo
where count > 1
