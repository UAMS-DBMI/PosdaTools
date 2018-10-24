-- Name: GetRoiCounts
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'count']
-- Args: []
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks']
-- Description: Get List of ROI's in a structure Set
-- 
-- 

select 
   distinct sop_instance_uid, count(distinct roi_id)
from 
  roi natural join structure_set natural join file_structure_set 
  join file_sop_common using(file_id)
group by sop_instance_uid
order by count desc
