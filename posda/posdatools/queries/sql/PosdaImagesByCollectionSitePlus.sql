-- Name: PosdaImagesByCollectionSitePlus
-- Schema: posda_files
-- Columns: ['patient_id', 'sop_instance_uid', 'study_instance_uid', 'series_instance_uid', 'digest']
-- Args: ['collection', 'site']
-- Tags: ['posda_files']
-- Description: List of all Files Images By Collection, Site
-- 

select distinct
  patient_id,
  sop_instance_uid,
  study_instance_uid,
  series_instance_uid,
  digest
from
  file
  natural join  file_patient
  natural join file_series
  natural join file_sop_common
  natural join file_study
   natural join ctp_file
where
  file_id in (
  select distinct file_id from ctp_file
  where project_name = ? and site_name = ?)

