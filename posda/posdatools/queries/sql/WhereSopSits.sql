-- Name: WhereSopSits
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid']
-- Args: ['sop_instance_uid']
-- Tags: ['posda_files', 'sops', 'BySopInstance']
-- Description: Get Collection, Site, Patient, Study Hierarchy in which SOP resides
-- 

select distinct
  project_name as collection,
  site_name as site,
  patient_id,
  study_instance_uid,
  series_instance_uid,
  sop_instance_uid
from
  file_patient natural join
  file_study natural join
  file_series natural join
  file_sop_common natural join
  ctp_file
where file_id in (
  select
    distinct file_id
  from
    file_sop_common natural join ctp_file
  where
    sop_instance_uid = ? and visibility is null
)
