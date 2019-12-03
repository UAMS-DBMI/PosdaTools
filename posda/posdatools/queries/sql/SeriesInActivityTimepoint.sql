-- Name: SeriesInActivityTimepoint
-- Schema: posda_files
-- Columns: ['patient_id', 'series_instance_uid', 'modality', 'dicom_file_type', 'num_files']
-- Args: ['activity_id']
-- Tags: ['activity_timepoint']
-- Description: Get Summary of series in latest timepoint for activity
--

select distinct patient_id, series_instance_uid, modality, dicom_file_type, count(distinct file_id) as num_files
from file_series natural join file_patient natural join dicom_file natural left join ctp_file
where file_id in (
  select file_id from activity_timepoint_file
  where  activity_timepoint_id = (
    select max(activity_timepoint_id) as activity_timepoint_id from activity_timepoint
    where activity_id = ?
  )
) and visibility is null
group by patient_id, series_instance_uid, modality, dicom_file_type