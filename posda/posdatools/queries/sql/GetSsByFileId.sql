-- Name: GetSsByFileId
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'file_id']
-- Args: ['file_id']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages']
-- Description: Get list of plan which reference unknown SOPs
-- 
-- 

select
  distinct project_name as collection,
  site_name as site,
  patient_id, file_id
from
  ctp_file natural join file_patient natural join file_structure_set
where file_id = ?