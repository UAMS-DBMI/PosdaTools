-- Name: DupSopsByCollection
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'earliest', 'latest']
-- Args: ['collection']
-- Tags: ['meta', 'test', 'hello', 'bills_test']
-- Description: List of duplicate sops with file_ids and latest load date

select distinct sop_instance_uid, min(latest) as earliest, max(latest) as latest
from (
  select
    distinct sop_instance_uid, file_id, max(import_time) latest
  from file_location join file_import using(file_id) join import_event using (import_event_id)  
    join file_sop_common using(file_id) join ctp_file using (file_id)
  where sop_instance_uid in (
    select distinct sop_instance_uid from (
      select distinct sop_instance_uid, count(distinct file_id)
      from file_sop_common natural join ctp_file
      where project_name = ? and visibility is null group by sop_instance_uid
      ) as foo
    where count > 1
    ) and visibility is null
  group by sop_instance_uid, file_id
) as foo
group by sop_instance_uid