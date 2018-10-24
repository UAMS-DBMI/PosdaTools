-- Name: DupSopsWithFileIdByCollectionSiteDateRange
-- Schema: posda_files
-- Columns: ['collection', 'site', 'subj_id', 'sop_instance_uid', 'file_id', 'visibility']
-- Args: ['collection', 'site', 'from', 'to']
-- Tags: ['duplicates', 'dup_sops', 'hide_dup_sops']
-- Description: Return a count of duplicate SOP Instance UIDs
-- 

select
  distinct collection, site, subj_id, 
  sop_instance_uid,
  file_id,
  visibility
from (
  select
    distinct project_name as collection,
    site_name as site, patient_id as subj_id,
    study_instance_uid, series_instance_uid,
    sop_instance_uid,
    file_id,
    visibility
  from
    ctp_file natural join file_sop_common
    natural join file_patient natural join file_study natural join file_series
  where
    sop_instance_uid in (
      select distinct sop_instance_uid 
      from (
        select distinct sop_instance_uid, count(distinct file_id)
        from file_sop_common natural join ctp_file
        where visibility is null and sop_instance_uid in (
          select distinct sop_instance_uid
          from file_sop_common natural join ctp_file
            join file_import using(file_id) 
            join import_event using(import_event_id)
          where project_name = ? and site_name = ? and
             visibility is null and import_time > ?
              and import_time < ?
        ) group by sop_instance_uid
      ) as foo 
      where count > 1
    )
    and visibility is null
  ) as foo
order by sop_instance_uid


