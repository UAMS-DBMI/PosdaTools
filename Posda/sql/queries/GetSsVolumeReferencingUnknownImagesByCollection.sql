-- Name: GetSsVolumeReferencingUnknownImagesByCollection
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'file_id']
-- Args: ['collection']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages']
-- Description: Get list of plan which reference unknown SOPs
-- 
-- 

select 
  project_name as collection, 
  site_name as site, patient_id, 
  file_id 
from 
  ctp_file natural join file_patient 
where file_id in (
   select
    distinct file_id from ss_volume v 
    join ss_for using(ss_for_id) 
    join file_structure_set using (structure_set_id) 
  where 
     not exists (
       select file_id 
       from file_sop_common s 
       where s.sop_instance_uid = v.sop_instance
  )
)
and project_name = ?
and visibility is null
order by collection, site, patient_id