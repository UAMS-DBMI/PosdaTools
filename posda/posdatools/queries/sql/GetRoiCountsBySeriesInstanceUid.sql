-- Name: GetRoiCountsBySeriesInstanceUid
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'count']
-- Args: ['series_instance_uid']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks']
-- Description: Get List of ROI's in a structure Set
-- 
-- 

select 
   distinct sop_instance_uid, count(distinct roi_id)
from 
  roi natural join structure_set natural join file_structure_set 
  join file_sop_common using(file_id)
where sop_instance_uid in (
  select distinct sop_instance_uid from file_sop_common natural join file_series
  where series_instance_uid = ?
)
group by sop_instance_uid
order by count desc
