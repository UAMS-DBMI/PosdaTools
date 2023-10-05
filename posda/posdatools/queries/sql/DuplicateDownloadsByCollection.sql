-- Name: DuplicateDownloadsByCollection
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'count']
-- Args: ['project_name', 'site_name']
-- Tags: ['by_collection', 'duplicates', 'find_series']
-- Description: Number of files for a subject which have been downloaded more than once
-- 

select distinct patient_id, series_instance_uid, count(*)
from file_series natural join file_patient
where file_id in (
  select file_id from (
    select
      distinct file_id, count(*)
    from file_import
    where file_id in (
      select
        distinct file_id
      from 
        file_patient natural join ctp_file
      where
        project_name = ? 
        and site_name = ?
    )
    group by file_id
  ) as foo
  where count > 1
)
group by patient_id, series_instance_uid
order by patient_id
