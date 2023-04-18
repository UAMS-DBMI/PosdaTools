-- Name: SopsDupsInDifferentSeriesByLikeCollection
-- Schema: posda_files
-- Columns: ['collection', 'site', 'subj_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'file_id', 'file_path']
-- Args: ['collection']
-- Tags: ['duplicates', 'dup_sops', 'hide_dup_sops', 'sops_different_series']
-- Description: Return a count of duplicate SOP Instance UIDs
-- 

select
  distinct collection, site, subj_id, study_instance_uid, series_instance_uid, sop_instance_uid,
  file_id, file_path
from (
  select
    distinct project_name as collection,
    site_name as site, patient_id as subj_id,
    study_instance_uid, series_instance_uid,
    sop_instance_uid,
    file_id, root_path ||'/' || rel_path as file_path
  from
    ctp_file natural join file_sop_common
    natural join file_patient natural join file_study natural join file_series
    join file_location using(file_id) join file_storage_root using(file_storage_root_id)
  where
    sop_instance_uid in (
      select distinct sop_instance_uid from (
        select distinct sop_instance_uid, count(distinct file_id) from (
          select distinct file_id, sop_instance_uid 
          from
            ctp_file natural join file_sop_common
            natural join file_patient
          where
            project_name like ?
        ) as foo group by sop_instance_uid order by count desc
      ) as foo 
      where count > 1
    )
    and visibility is null
  ) as foo
order by sop_instance_uid

