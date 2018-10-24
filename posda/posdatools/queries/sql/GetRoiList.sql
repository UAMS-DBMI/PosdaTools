-- Name: GetRoiList
-- Schema: posda_files
-- Columns: ['roi_id', 'roi_num', 'roi_name']
-- Args: ['sop_instance_uid']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks']
-- Description: Get List of ROI's in a structure Set
-- 
-- 

select 
   roi_id, roi_num ,roi_name
from 
  roi natural join structure_set natural join file_structure_set 
  join file_sop_common using(file_id)
where
  sop_instance_uid = ?
