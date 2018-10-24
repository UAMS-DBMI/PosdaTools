-- Name: IntakeImagesByCollectionSiteSubj
-- Schema: intake
-- Columns: ['PID', 'Modality', 'SopInstance', 'FilePath']
-- Args: ['collection', 'site', 'patient_id']
-- Tags: ['SymLink', 'intake']
-- Description: List of all Files Images By Collection, Site
-- 

select
  p.patient_id as PID,
  s.modality as Modality,
  i.dicom_file_uri as FilePath,
  i.sop_instance_uid as SopInstance,
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
  tdp.dp_site_name = ? and
  p.patient_id = ?
