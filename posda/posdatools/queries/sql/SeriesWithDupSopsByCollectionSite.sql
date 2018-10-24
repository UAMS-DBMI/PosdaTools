-- Name: SeriesWithDupSopsByCollectionSite
-- Schema: posda_files
-- Columns: ['collection', 'site', 'subj_id', 'num_sops', 'num_files', 'study_instance_uid', 'series_instance_uid']
-- Args: ['collection', 'site']
-- Tags: ['duplicates', 'dup_sops', 'hide_dup_sops']
-- Description: Return a count of duplicate SOP Instance UIDs
-- 

select
  distinct collection, site, subj_id, study_instance_uid, series_instance_uid, 
  count(distinct sop_instance_uid) as num_sops,
  count(distinct file_id) as num_files
from (
  select
    distinct project_name as collection,
    site_name as site, patient_id as subj_id,
    study_instance_uid, series_instance_uid,
    sop_instance_uid,
    file_id
  from
    ctp_file natural join file_sop_common
    natural join file_patient natural join file_study natural join file_series
  where
    sop_instance_uid in (
      select distinct sop_instance_uid from (
        select distinct sop_instance_uid, count(distinct file_id) from (
          select distinct file_id, sop_instance_uid 
          from
            ctp_file natural join file_sop_common
            natural join file_patient
          where
            visibility is null and project_name = ? and site_name = ?
        ) as foo group by sop_instance_uid order by count desc
      ) as foo 
      where count > 1
    )
    and visibility is null
  ) as foo
group by collection, site, subj_id, study_instance_uid, series_instance_uid

