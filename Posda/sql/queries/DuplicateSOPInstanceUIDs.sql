-- Name: DuplicateSOPInstanceUIDs
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'first', 'last', 'count']
-- Args: ['collection', 'site', 'subject']
-- Tags: ['duplicates']
-- Description: Return a count of duplicate SOP Instance UIDs
-- 

select
  sop_instance_uid, min(file_id) as first,
  max(file_id) as last, count(*)
from file_sop_common
where sop_instance_uid in (
  select distinct sop_instance_uid from (
    select distinct sop_instance_uid, count(*) from (
      select distinct file_id, sop_instance_uid 
      from
        ctp_file natural join file_sop_common
        natural join file_patient
      where project_name = ? and site_name = ? and patient_id = ?
    ) as foo natural join ctp_file
    where visibility is null
    group by sop_instance_uid order by count desc
  ) as foo where count > 1
) group by sop_instance_uid;
