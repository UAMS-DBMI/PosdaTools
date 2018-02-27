-- Name: SsSopToForByCollectionSite
-- Schema: posda_files
-- Columns: ['patient_id', 'sop_instance_uid', 'for_uid']
-- Args: ['collection', 'site']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages']
-- Description: Get list of plan which reference unknown SOPs
-- 
-- 

select 
  distinct patient_id,  sop_instance_uid, 
  for_uid
from 
  roi natural join file_structure_set join file_sop_common using(file_id) join file_patient using (file_id)
where
  file_id in (
    select file_id 
    from ctp_file natural join file_structure_set 
    where project_name = ? and site_name = ? and visibility is null
  )
order by patient_id