-- Name: ImageFrameOfReferenceBySeriesPosda
-- Schema: posda_files
-- Columns: ['for_uid', 'num_files']
-- Args: ['series_instance_uid']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages']
-- Description: Get list of plan which reference unknown SOPs
-- 
-- 

select 
  distinct for_uid, count(*) as num_files
from
  file_series natural join file_sop_common natural join file_for natural join ctp_file
where 
  series_instance_uid = ?
group by for_uid