-- Name: IntakeImagesByCollectionSitePlus
-- Schema: intake
-- Columns: ['patient_id', 'sop_instance_uid', 'study_instance_uid', 'series_instance_uid']
-- Args: ['collection', 'site']
-- Tags: ['intake']
-- Description: N
-- o
-- n
-- e


select
  p.patient_id,
  i.sop_instance_uid,
  t.study_instance_uid,
  s.series_instance_uid
from
  general_image i,
  general_series s,
  study t,
  patient p,
  trial_data_provenance tdp,
  general_equipment q
where
  i.general_series_pk_id = s.general_series_pk_id and
  s.study_pk_id = t.study_pk_id and
  s.general_equipment_pk_id = q.general_equipment_pk_id and
  t.patient_pk_id = p.patient_pk_id and
  p.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ? and
  tdp.dp_site_name = ?

