-- Name: GetPlansReferencingGoodSS
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'series_instance_uid', 'file_id']
-- Args: ['collection']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks', 'plan_linkages']
-- Description: Get list of plan which reference unknown SOPs
-- 
-- 

select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  file_id
from
  file_series natural join
  file_patient natural join ctp_file
where
  project_name = ? and
  visibility is null and
  file_id in (
select file_id from plan p natural join file_plan  where
exists (select sop_instance_uid from file_sop_common fsc where p.ss_referenced_from_plan 
= fsc.sop_instance_uid))