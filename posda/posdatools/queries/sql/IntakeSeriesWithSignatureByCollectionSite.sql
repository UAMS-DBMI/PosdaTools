-- Name: IntakeSeriesWithSignatureByCollectionSite
-- Schema: intake
-- Columns: ['series_instance_uid', 'Modality', 'signature']
-- Args: ['collection', 'site']
-- Tags: ['intake']
-- Description: List of all Series By Collection, Site on Intake
-- 

select
  p.patient_id as PID,
  s.modality as Modality,
  t.study_date as StudyDate,
  t.study_desc as StudyDescription,
  s.series_desc as SeriesDescription,
  s.series_number as SeriesNumber,
  t.study_instance_uid as StudyInstanceUID,
  s.series_instance_uid as series_instance_uid,
  concat(q.manufacturer, ":", q.manufacturer_model_name, ":",
  q.software_versions) as signature
from
  general_series s,
  study t,
  patient p,
  trial_data_provenance tdp,
  general_equipment q
where
  s.study_pk_id = t.study_pk_id and
  s.general_equipment_pk_id = q.general_equipment_pk_id and
  t.patient_pk_id = p.patient_pk_id and
  p.trial_dp_pk_id = tdp.trial_dp_pk_id and
  tdp.project = ? and
  tdp.dp_site_name = ?
