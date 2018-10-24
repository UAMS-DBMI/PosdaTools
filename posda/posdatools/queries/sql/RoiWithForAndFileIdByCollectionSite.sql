-- Name: RoiWithForAndFileIdByCollectionSite
-- Schema: posda_files
-- Columns: ['for_uid', 'roi_num', 'roi_name', 'file_id']
-- Args: ['collection', 'site']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages']
-- Description: Get list of plan which reference unknown SOPs
-- 
-- 

select
  distinct for_uid, roi_num, roi_name, file_id
from
  roi natural join file_structure_set natural join ctp_file
where 
  project_name = ? and site_name = ? and visibility is null
order by file_id, for_uid