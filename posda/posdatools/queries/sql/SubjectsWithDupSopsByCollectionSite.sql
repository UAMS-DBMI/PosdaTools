-- Name: SubjectsWithDupSopsByCollectionSite
-- Schema: posda_files
-- Columns: ['collection', 'site', 'subj_id', 'num_sops', 'num_files', 'earliest', 'latest']
-- Args: ['collection', 'site']
-- Tags: ['dup_sops']
-- Description: Return a count of duplicate SOP Instance UIDs
-- 

select
  distinct collection, site, subj_id, 
  count(distinct file_id) as num_files,
  count(distinct sop_instance_uid) as num_sops,
  min(import_time) as earliest,
  max(import_time) as latest
from (
  select
    distinct project_name as collection,
    site_name as site, patient_id as subj_id,
    file_id, sop_instance_uid, import_time
  from
    ctp_file natural join file_sop_common
    natural join file_patient natural join file_import
    natural join import_event
  where
    sop_instance_uid in (
      select distinct sop_instance_uid from (
        select distinct sop_instance_uid, count(*) from (
          select distinct file_id, sop_instance_uid 
          from
            ctp_file natural join file_sop_common
            natural join file_patient
          where
            project_name = ? and site_name = ?
        ) as foo group by sop_instance_uid order by count desc
      ) as foo 
      where count > 1
    )
    and visibility is null
  ) as foo
group by collection, site, subj_id
