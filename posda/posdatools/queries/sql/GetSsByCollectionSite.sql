-- Name: GetSsByCollectionSite
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'file_id']
-- Args: ['collection', 'site']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages']
-- Description: Get list of plan which reference unknown SOPs
-- 
-- 

select
  distinct project_name as collection,
  site_name as site,
  patient_id, file_id
from
  ctp_file natural join file_patient
where file_id in (
 select distinct file_id from file_structure_set
)
and project_name = ? and site_name = ?
order by collection, site, patient_id, file_id
