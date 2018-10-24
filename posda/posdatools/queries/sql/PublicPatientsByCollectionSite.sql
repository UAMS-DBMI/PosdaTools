-- Name: PublicPatientsByCollectionSite
-- Schema: public
-- Columns: ['PID', 'num_images']
-- Args: ['collection', 'site']
-- Tags: ['public']
-- Description: List of all Files Images By Collection, Site
-- 

select
  distinct p.patient_id as PID, count(distinct i.image_pk_id) as num_images
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
group by PID
