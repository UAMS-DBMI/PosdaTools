-- Name: DupSopCountsByCSS
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'min', 'max', 'count']
-- Args: ['collection', 'site', 'subject']
-- Tags: []
-- Description: Counts of DuplicateSops By Collection, Site, Subject
-- 

select
  distinct sop_instance_uid, min, max, count
from (
  select
    distinct sop_instance_uid, min(file_id),
    max(file_id),count(*)
  from (
    select
      distinct sop_instance_uid, file_id
    from
      file_sop_common 
    where sop_instance_uid in (
      select
        distinct sop_instance_uid
      from
        file_sop_common natural join ctp_file
        natural join file_patient
      where
        project_name = ? and site_name = ? 
        and patient_id = ? and visibility is null
    )
  ) as foo natural join ctp_file
  where visibility is null
  group by sop_instance_uid
)as foo where count > 1
