-- Name: PosdaImagesByCollectionSite
-- Schema: posda_files
-- Columns: ['PID', 'Modality', 'SopInstance', 'StudyDate', 'StudyDescription', 'SeriesDescription', 'StudyInstanceUID', 'SeriesInstanceUID', 'Mfr', 'Model', 'software_versions']
-- Args: ['collection', 'site']
-- Tags: ['posda_files']
-- Description: List of all Files Images By Collection, Site
-- 

select distinct
  patient_id as "PID",
  modality as "Modality",
  sop_instance_uid as "SopInstance",
  study_date as "StudyDate",
  study_description as "StudyDescription",
  series_description as "SeriesDescription",
  study_instance_uid as "StudyInstanceUID",
  series_instance_uid as "SeriesInstanceUID",
  manufacturer as "Mfr",
  manuf_model_name as "Model",
  software_versions
from
  file_patient natural join file_series natural join
  file_sop_common natural join file_study natural join
  file_equipment natural join ctp_file
where
  file_id in (
  select distinct file_id from ctp_file
  where project_name = ? and site_name = ?)
