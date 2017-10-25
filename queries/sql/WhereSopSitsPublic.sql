-- Name: WhereSopSitsPublic
-- Schema: public
-- Columns: ['collection', 'site', 'patient_id', 'study_instance_uid', 'series_instance_uid']
-- Args: ['sop_instance_uid']
-- Tags: ['posda_files', 'sops', 'BySopInstance']
-- Description: Get Collection, Patient, Study Hierarchy in which SOP resides
-- 

select distinct
  tdp.project as collection,
  tdp.dp_site_name as site,
  p.patient_id,
  i.study_instance_uid,
  i.series_instance_uid
from
  general_image i,
  patient p,
  trial_data_provenance tdp
where
  sop_instance_uid = ?
  and i.patient_pk_id = p.patient_pk_id
  and i.trial_dp_pk_id = tdp.trial_dp_pk_id
