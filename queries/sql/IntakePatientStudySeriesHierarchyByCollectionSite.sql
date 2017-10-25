-- Name: IntakePatientStudySeriesHierarchyByCollectionSite
-- Schema: intake
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid']
-- Args: ['collection', 'site']
-- Tags: ['intake', 'Hierarchy']
-- Description: Patient, study, series hierarchy by Collection, Site on Intake
-- 

select
  p.patient_id as patient_id,
  t.study_instance_uid as study_instance_uid,
  s.series_instance_uid as series_instance_uid
from
  general_series s,
  study t,
  patient p,
  trial_data_provenance tdp
where
  s.study_pk_id = t.study_pk_id and
  t.patient_pk_id = p.patient_pk_id and
  p.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ? and
  tdp.dp_site_name = ?
