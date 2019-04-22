-- Name: FilesSeriesSopsVisibilityInTimepoint
-- Schema: posda_files
-- Columns: ['file_id', 'patient_id', 'study_instance_uid', 'series_instance_uid', 'sop_instance_uid', 'visibility']
-- Args: ['activity_timepoint_id']
-- Tags: ['compare_series']
-- Description: Get Distinct SOPs in Series with number files
-- Only visible filess
-- 

select 
  file_id, patient_id, study_instance_uid, series_instance_uid, sop_instance_uid, visibility
from
  file_patient natural join file_study natural join file_series natural join file_sop_common
  natural join ctp_file
where file_id in (
  select file_id from activity_timepoint where activity_timepoint_id = ?)