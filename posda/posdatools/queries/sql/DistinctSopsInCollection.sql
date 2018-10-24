-- Name: DistinctSopsInCollection
-- Schema: posda_files
-- Columns: ['sop_instance_uid']
-- Args: ['collection']
-- Tags: ['by_collection', 'posda_files', 'sops']
-- Description: Get Distinct SOPs in Collection with number files
-- Only visible files
-- 

select distinct sop_instance_uid
from
  file_sop_common
where file_id in (
  select
    distinct file_id
  from
    ctp_file
  where
    project_name = ? and visibility is null
)
order by sop_instance_uid
