-- Name: DistinctVisibleSopsAndFilesInSeriesWithPatAndStudy
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'file_id']
-- Args: ['series_instance_uid']
-- Tags: ['by_series_instance_uid', 'file_ids', 'posda_files']
-- Description: Get Distinct Unhidden Files in Series
-- 

select distinct
  patient_id, study_instance_uid, series_instance_uid,
  sop_instance_uid, file_id
from
  file_patient natural join file_study natural join file_series natural join file_sop_common
where file_id in 
  (select
    distinct file_id
  from
    file_series natural join file_sop_common natural join ctp_file
  where
    series_instance_uid = ? and visibility is null)
