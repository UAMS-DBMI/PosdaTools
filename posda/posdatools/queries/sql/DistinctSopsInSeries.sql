-- Name: DistinctSopsInSeries
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'count']
-- Args: ['series_instance_uid']
-- Tags: ['by_series_instance_uid', 'duplicates', 'posda_files', 'sops']
-- Description: Get Distinct SOPs in Series with number files
-- Only visible filess
-- 

select distinct sop_instance_uid, count(*)
from file_sop_common
where file_id in (
  select
    distinct file_id
  from
    file_series natural join ctp_file
  where
    series_instance_uid = ? and visibility is null
)
group by sop_instance_uid
order by count desc
