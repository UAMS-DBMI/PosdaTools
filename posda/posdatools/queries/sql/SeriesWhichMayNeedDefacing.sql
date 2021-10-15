-- Name: SeriesWhichMayNeedDefacing
-- Schema: posda_files
-- Columns: ['patient_id', 'series_instance_uid', 'series_description', 'dicom_file_type', 'modality', 'num_files']
-- Args: ['activity_id']
-- Tags: ['nifti']
-- Description:  Report of series which may need to be defaced
-- 
-- Currently just all with modality of CT or MR
-- 

select 
  distinct 
  series_instance_uid, series_description,
  dicom_file_type, modality, count(distinct file_id) as num_files
from
  file_series natural join
  dicom_file natural join activity_timepoint_file
where
  modality in ('CT', 'MR') and
  activity_timepoint_id = (
    select max(activity_timepoint_id) as activity_timepoint_id
  from
    activity_timepoint
  where
    activity_id = ?
)
group by
  series_instance_uid,
  series_description, dicom_file_type, modality
order by 
  series_instance_uid