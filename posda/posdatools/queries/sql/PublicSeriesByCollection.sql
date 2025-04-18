-- Name: PublicSeriesByCollection
-- Schema: public
-- Columns: ['PID', 'Modality', 'StudyDate', 'StudyDescription', 'SeriesDescription', 'SeriesNumber', 'StudyInstanceUID', 'SeriesInstanceUID', 'Mfr', 'Model', 'software_versions']
-- Args: ['collection']
-- Tags: ['public']
-- Description: List of all Series By Collection, Site on Public
-- 

select
  p.patient_id as PID,
  s.modality as Modality,
  t.study_date as StudyDate,
  t.study_desc as StudyDescription,
  s.series_desc as SeriesDescription,
  s.series_number as SeriesNumber,
  t.study_instance_uid as StudyInstanceUID,
  s.series_instance_uid as SeriesInstanceUID,
  q.manufacturer as Mfr,
  q.manufacturer_model_name as Model,
  q.software_versions
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
  tdp.project = ? 
