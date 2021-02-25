-- Name: GetFileInfoForSeriesReport
-- Schema: posda_files
-- Columns: ['file_id', 'sop_instance_uid', 'series_instance_uid', 'series_date', 'study_instance_uid', 'study_date', 'instance_number', 'patient_id', 'modality', 'dicom_file_type', 'for_uid', 'iop', 'ipp', 'pixel_data_digest']
-- Args: ['file_id']
-- Tags: ['activity_timepoint', 'series_report']
-- Description: Get Distinct SOPs in Series with number files
-- Only visible filess
-- 

select
  distinct file_id,
  sop_instance_uid,
  series_instance_uid,
  series_date,
  study_instance_uid,
  study_date,
  cast (instance_number as integer) as instance_number,
  patient_id,
  modality,
  dicom_file_type,
  for_uid, iop, ipp, 
  pixel_data_digest
from
  file_location
  natural join dicom_file
  natural join file_series
  natural join file_study
  natural join file_patient
  natural join file_sop_common
  left join file_image_geometry using(file_id) 
  left join image_geometry using(image_geometry_id)
where file_id  = ?
order by instance_number