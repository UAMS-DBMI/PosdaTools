-- Name: VerboseActivityReportWithSeriesNumber
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'patient_age', 'study_instance_uid', 'study_date', 'study_description', 'series_instance_uid', 'series_date', 'series_description', 'series_number', 'dicom_file_type', 'modality', 'num_files']
-- Args: ['activity_id']
-- Tags: ['activity_timepoint_reports']
-- Description:  Make a very verbose report of files in the latest timepoint for an activity
-- 

select 
  distinct project_name as collection, site_name as site, patient_id,
  patient_age,
  study_instance_uid, study_date, study_description,
  series_instance_uid, series_date, series_description, series_number,
  dicom_file_type, modality, count(distinct file_id) as num_files
from
  file_patient natural join file_study natural join file_series natural join
  dicom_file natural left join ctp_file natural join activity_timepoint_file
where
  activity_timepoint_id = (
    select max(activity_timepoint_id) as activity_timepoint_id
  from
    activity_timepoint
  where
    activity_id = ?
)
group by
  collection, site, patient_id, patient_age, study_instance_uid, study_date,
  study_description, series_instance_uid, series_date,
  series_description, series_number, dicom_file_type, modality
order by 
  collection, site, patient_id, study_date, series_instance_uid