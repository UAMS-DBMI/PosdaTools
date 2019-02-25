-- Name: ReportOnStudiesWithSomeMissingStudyDates
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'study_date', 'study_description', 'series_instance_uid', 'series_date', 'series_description', 'dicom_file_type', 'modality', 'num_files']
-- Args: ['activity_timepoint_id', 'activity_timepoint_id_1']
-- Tags: ['Exceptional-Responders_NCI_Oct2018_curation', 'New_HNSCC_Investigation']
-- Description: Find files which have unique_pixel_data_id but no image_id, then find out where the hell they came from

select
  distinct patient_id, study_instance_uid, study_date, study_description, series_instance_uid,series_date,
  series_description, dicom_file_type, modality, count(distinct file_id) as num_files
from
  file_patient natural join file_study natural join file_series natural join dicom_file
where file_id in (
 select file_id from file_study natural join activity_timepoint_file 
 where activity_timepoint_id = ? and study_instance_uid in (
    select distinct study_instance_uid from (
      select distinct study_date, study_instance_uid
      from ctp_file natural join file_series natural join file_study natural join activity_timepoint_file
      where activity_timepoint_id = ? and visibility is null
    ) as foo 
    where study_date is null
  )
)
group by
  patient_id, study_instance_uid, study_date, study_description, series_instance_uid, series_date,
  series_description, dicom_file_type, modality
order by patient_id, modality